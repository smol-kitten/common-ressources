# AUR Tools

A structured JSON reference for popular AUR helpers and build tools used on Arch Linux. Covers helpers that automate AUR package management, core build tools like makepkg, and pacman wrappers that extend base functionality.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "paru",
  "slug": "paru",
  "description": "Feature-rich AUR helper written in Rust.",
  "language": "Rust",
  "install-cmd": "git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si",
  "homepage": "https://github.com/morganamilo/paru",
  "stars-approx": 6000,
  "category": "aur-helper",
  "tags": ["aur", "rust", "popular"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable tool name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `description` | string | What the tool does and key characteristics |
| `language` | string | Primary implementation language |
| `install-cmd` | string | Shell command to install the tool |
| `homepage` | string | Official homepage or source repository URL |
| `stars-approx` | number | Approximate GitHub star count (0 for official tools) |
| `category` | string | Tool category (see below) |
| `tags` | string[] | Keywords for filtering and discovery |

### Categories

| Category | Description |
|---|---|
| `aur-helper` | Tools that automate AUR package search, build, and install |
| `build-tool` | Low-level tools for building packages from PKGBUILDs |
| `pacman-wrapper` | Tools that wrap pacman with additional features (GUI, extra backends) |

## Tools included

| Slug | Name | Category | Language |
|---|---|---|---|
| `yay` | yay | aur-helper | Go |
| `paru` | paru | aur-helper | Rust |
| `trizen` | trizen | aur-helper | Perl |
| `pikaur` | pikaur | aur-helper | Python |
| `bauerbill` | bauerbill | pacman-wrapper | Python |
| `makepkg` | makepkg | build-tool | Bash |
| `aurutils` | aurutils | build-tool | Bash |
| `pacaur` | pacaur | aur-helper | Bash |
| `pamac` | pamac | pacman-wrapper | Vala |
| `asp` | asp | build-tool | Bash |

## Examples

### Shell — list all AUR helpers

```bash
jq '[.[] | select(.category == "aur-helper") | {slug, name, language}]' aur-tools.json
```

### Shell — find the install command for a specific tool

```bash
jq -r '.[] | select(.slug == "paru") | .["install-cmd"]' aur-tools.json
```

### Shell — sort tools by approximate star count

```bash
jq '[.[] | {name, "stars-approx"}] | sort_by(-."stars-approx")' aur-tools.json
```

### JavaScript — look up a tool by slug

```javascript
const tools = await fetch('aur-tools.json').then(r => r.json());
const bySlug = Object.fromEntries(tools.map(t => [t.slug, t]));

const paru = bySlug['paru'];
console.log(paru.description);
// "Feature-rich AUR helper written in Rust..."
```

### JavaScript — filter by category

```javascript
const tools = await fetch('aur-tools.json').then(r => r.json());
const helpers = tools.filter(t => t.category === 'aur-helper');
console.log(helpers.map(t => t.name));
// ["yay", "paru", "trizen", "pikaur", "pacaur"]
```

### PHP — display tool list by category

```php
$tools = json_decode(file_get_contents('aur-tools.json'), true);
$byCategory = [];
foreach ($tools as $tool) {
    $byCategory[$tool['category']][] = $tool;
}
foreach ($byCategory as $cat => $group) {
    echo "$cat:\n";
    foreach ($group as $t) {
        echo "  {$t['name']} ({$t['language']}): {$t['install-cmd']}\n";
    }
}
```
