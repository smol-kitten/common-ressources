# Shell Prompt Themes

A structured JSON reference for popular Zsh, Bash, and Fish shell prompt themes. Covers Oh My Zsh built-ins, standalone themes, cross-shell engines, and Fish-specific prompts.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Powerlevel10k",
  "slug": "powerlevel10k",
  "shell": "zsh",
  "framework": "oh-my-zsh",
  "install-cmd": "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ...",
  "preview-colors": ["#00afff", "#d75f00", "#af00af"],
  "description": "The most popular Zsh theme...",
  "features": ["instant-prompt", "interactive-wizard", "segments"],
  "tags": ["omz", "popular", "fast"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable theme name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `shell` | string | Target shell: `zsh`, `bash`, or `fish` |
| `framework` | string | Required framework (`oh-my-zsh`, `none`, etc.) |
| `install-cmd` | string | Shell command to install and activate the theme |
| `preview-colors` | string[] | Representative hex colors from the theme's appearance |
| `description` | string | What the theme looks like and its distinguishing characteristics |
| `features` | string[] | Notable capabilities and segments |
| `tags` | string[] | Keywords for filtering and discovery |

## Themes included

| Slug | Name | Shell | Framework |
|---|---|---|---|
| `robbyrussell` | robbyrussell | zsh | oh-my-zsh |
| `agnoster` | agnoster | zsh | oh-my-zsh |
| `powerlevel10k` | Powerlevel10k | zsh | oh-my-zsh |
| `spaceship` | Spaceship | zsh | oh-my-zsh |
| `starship` | Starship | zsh | none |
| `pure` | Pure | zsh | none |
| `bira` | bira | zsh | oh-my-zsh |
| `ys` | ys | zsh | oh-my-zsh |
| `tide` | Tide | fish | none |
| `hydro` | Hydro | fish | none |
| `bash-powerline` | Bash Powerline | bash | none |
| `oh-my-posh` | Oh My Posh | bash | none |

## Examples

### Shell — list all Zsh themes

```bash
jq '[.[] | select(.shell == "zsh") | {slug, name, framework}]' prompt-themes.json
```

### Shell — find themes that work without Oh My Zsh

```bash
jq '[.[] | select(.framework == "none") | {slug, name, shell}]' prompt-themes.json
```

### Shell — get install command for a theme

```bash
jq -r '.[] | select(.slug == "starship") | .["install-cmd"]' prompt-themes.json
```

### JavaScript — look up a theme by slug

```javascript
const themes = await fetch('prompt-themes.json').then(r => r.json());
const bySlug = Object.fromEntries(themes.map(t => [t.slug, t]));

const p10k = bySlug['powerlevel10k'];
console.log(p10k.features);
// ["instant-prompt", "interactive-wizard", "segments", ...]
```

### JavaScript — filter by shell

```javascript
const themes = await fetch('prompt-themes.json').then(r => r.json());
const fish = themes.filter(t => t.shell === 'fish');
console.log(fish.map(t => t.name));
// ["Tide", "Hydro"]
```

### PHP — display themes grouped by shell

```php
$themes = json_decode(file_get_contents('prompt-themes.json'), true);
$byShell = [];
foreach ($themes as $t) {
    $byShell[$t['shell']][] = $t;
}
foreach ($byShell as $shell => $group) {
    echo "$shell:\n";
    foreach ($group as $t) {
        echo "  {$t['name']} (framework: {$t['framework']})\n";
    }
}
```
