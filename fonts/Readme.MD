# Font Stacks

A structured JSON reference of CSS font stacks — ready-to-paste font family declarations covering system fonts, web-safe stacks, and curated Google Fonts combinations for every major typeface category.

## JSON

### Structure as of 23.05.2026

```json
{
  "name": "System Sans-Serif",
  "slug": "system-sans",
  "category": "sans-serif",
  "system": true,
  "fonts": ["-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif"],
  "css": "-apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif",
  "description": "The standard native sans-serif stack used by Bootstrap 5 and GitHub.",
  "usage": "Body text, UI elements, general-purpose web typography.",
  "tags": ["native", "ui", "bootstrap", "github", "cross-platform"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable name of the font stack |
| `slug` | string | URL-friendly identifier for programmatic lookup |
| `category` | string | Typeface classification (see below) |
| `system` | boolean | `true` if the stack relies primarily on fonts built into the operating system |
| `fonts` | string[] | Ordered list of font family names. Multi-word names include their own quotes within the array value |
| `css` | string | Ready-to-paste CSS `font-family` value, with correct quoting for multi-word font names |
| `description` | string | What this stack is, where it comes from, and how it renders on different platforms |
| `usage` | string | Recommended use cases |
| `tags` | string[] | Keywords for filtering and discovery |

### Categories

| Category | Description |
|---|---|
| `sans-serif` | Fonts without serifs — clean, modern, versatile |
| `serif` | Fonts with serifs — traditional, editorial, authoritative |
| `monospace` | Fixed-width fonts — code, terminals, tabular data |
| `display` | Decorative or headline-only fonts — high impact at large sizes |
| `handwriting` | Script and handwriting-style fonts — personal, decorative |

## Stacks included

| Slug | Name | Category | System |
|---|---|---|---|
| `system-sans` | System Sans-Serif | sans-serif | yes |
| `system-serif` | System Serif | serif | yes |
| `system-mono` | System Monospace | monospace | yes |
| `system-ui` | System UI | sans-serif | yes |
| `geometric-sans` | Geometric Sans-Serif | sans-serif | no |
| `humanist-sans` | Humanist Sans-Serif | sans-serif | no |
| `transitional-serif` | Transitional Serif | serif | no |
| `old-style-serif` | Old-Style Serif | serif | no |
| `slab-serif` | Slab Serif | serif | no |
| `modern-serif` | Modern Serif (Didone) | serif | no |
| `code-mono` | Code Monospace | monospace | no |
| `terminal-mono` | Terminal Monospace | monospace | no |
| `rounded-sans` | Rounded Sans-Serif | sans-serif | no |
| `display-sans` | Display Sans-Serif | display | no |
| `handwriting` | Handwriting | handwriting | no |

## Usage note

The `css` field is the value of the `font-family` CSS property — paste it directly into your stylesheet. For non-system stacks, load the first font via a web font service (e.g. Google Fonts) to ensure it is available; the remaining entries in the stack serve as fallbacks.

## Examples

### CSS — apply a stack directly

```css
/* Paste the css field value directly into font-family */
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
    "Helvetica Neue", Arial, "Noto Sans", "Liberation Sans", sans-serif,
    "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
}

code, pre {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas,
    "Liberation Mono", "Courier New", monospace;
}

h1, h2 {
  font-family: "Bebas Neue", Anton, "Barlow Condensed", Oswald,
    Impact, "Arial Narrow", sans-serif;
}
```

### CSS — using a Google Fonts web font from the stack

```html
<!-- Load the first font in the geometric-sans stack from Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
```

```css
body {
  /* Use the full stack so non-Inter users still get a good fallback */
  font-family: Inter, "Nunito Sans", "DM Sans", Poppins, Outfit,
    "Helvetica Neue", Arial, sans-serif;
}
```

### JavaScript — look up a stack by slug

```javascript
const stacks = await fetch('stacks.json').then(r => r.json());
const bySlug = Object.fromEntries(stacks.map(s => [s.slug, s]));

const stack = bySlug['code-mono'];
console.log(stack.css);
// "JetBrains Mono", "Fira Code", "Cascadia Code", ...

// Apply it dynamically
document.querySelectorAll('pre, code').forEach(el => {
  el.style.fontFamily = stack.css;
});
```

### JavaScript — filter stacks by category

```javascript
const stacks = await fetch('stacks.json').then(r => r.json());

const serifStacks = stacks.filter(s => s.category === 'serif');
console.log(serifStacks.map(s => s.name));
// ["System Serif", "Transitional Serif", "Old-Style Serif", ...]

const systemOnly = stacks.filter(s => s.system);
console.log(systemOnly.map(s => s.slug));
// ["system-sans", "system-serif", "system-mono", "system-ui"]
```

### JavaScript — generate a CSS custom properties block

```javascript
const stacks = await fetch('stacks.json').then(r => r.json());

const cssVars = stacks
  .map(s => `  --font-${s.slug}: ${s.css};`)
  .join('\n');

console.log(`:root {\n${cssVars}\n}`);
/*
:root {
  --font-system-sans: -apple-system, BlinkMacSystemFont, ...;
  --font-system-serif: Georgia, Cambria, ...;
  ...
}
*/
```

### PHP — render a font-family declaration

```php
$stacks = json_decode(file_get_contents('stacks.json'), true);
$bySlug = array_column($stacks, null, 'slug');

function fontFamily(string $slug, array $bySlug): string {
    $stack = $bySlug[$slug] ?? null;
    if (!$stack) {
        throw new \InvalidArgumentException("Unknown font stack: $slug");
    }
    return $stack['css'];
}

echo 'font-family: ' . fontFamily('geometric-sans', $bySlug) . ';';
// font-family: Inter, "Nunito Sans", "DM Sans", Poppins, Outfit, "Helvetica Neue", Arial, sans-serif;
```

### PHP — list all non-system stacks

```php
$stacks = json_decode(file_get_contents('stacks.json'), true);
$webStacks = array_filter($stacks, fn($s) => !$s['system']);
foreach ($webStacks as $stack) {
    echo $stack['name'] . ': ' . $stack['css'] . "\n";
}
```

### Shell — list stacks by category

```bash
jq '[.[] | select(.category == "monospace") | {slug: .slug, name: .name, system: .system}]' stacks.json
```

### Shell — get CSS value for a specific stack

```bash
jq -r '.[] | select(.slug == "system-sans") | .css' stacks.json
```

### Shell — find all system font stacks

```bash
jq '[.[] | select(.system == true) | .slug]' stacks.json
```
