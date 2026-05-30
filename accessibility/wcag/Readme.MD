# WCAG 2.1 Success Criteria

A structured reference for 25 key WCAG 2.1 success criteria. Each entry includes the criterion ID, conformance level (A/AA/AAA), principle, guideline, title, and plain-language description. Useful for accessibility audits, compliance checklists, annotation tooling, and developer education.

## JSON

### Structure as of 24.05.2026

```json
{
  "id": "1.4.3",
  "level": "AA",
  "principle": "Perceivable",
  "guideline": "Distinguishable",
  "title": "Contrast (Minimum)",
  "description": "Text and images of text have a contrast ratio of at least 4.5:1 (3:1 for large text)."
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | WCAG success criterion identifier (e.g. `1.4.3`) |
| `level` | string | Conformance level: `A`, `AA`, or `AAA` |
| `principle` | string | POUR principle: `Perceivable`, `Operable`, `Understandable`, `Robust` |
| `guideline` | string | Guideline name within the principle |
| `title` | string | Short criterion title |
| `description` | string | Plain-language description of the requirement |

### Conformance Levels

| Level | Description |
|---|---|
| `A` | Minimum accessibility requirements; essential for most users |
| `AA` | Standard target for most websites; required by many laws/regulations |
| `AAA` | Highest level; not required for all content |

### Principles (POUR)

| Principle | Description |
|---|---|
| `Perceivable` | Information and UI components must be presentable to users |
| `Operable` | UI components and navigation must be operable |
| `Understandable` | Information and operation of the UI must be understandable |
| `Robust` | Content must be robust enough to be interpreted by assistive technologies |

## Entries

| ID | Level | Principle | Title |
|---|---|---|---|
| 1.1.1 | A | Perceivable | Non-text Content |
| 1.2.1 | A | Perceivable | Audio-only and Video-only (Prerecorded) |
| 1.2.2 | A | Perceivable | Captions (Prerecorded) |
| 1.2.3 | A | Perceivable | Audio Description or Media Alternative |
| 1.3.1 | A | Perceivable | Info and Relationships |
| 1.3.2 | A | Perceivable | Meaningful Sequence |
| 1.4.1 | A | Perceivable | Use of Color |
| 1.4.3 | AA | Perceivable | Contrast (Minimum) |
| 1.4.4 | AA | Perceivable | Resize Text |
| 1.4.6 | AAA | Perceivable | Contrast (Enhanced) |
| 1.4.10 | AA | Perceivable | Reflow |
| 1.4.11 | AA | Perceivable | Non-text Contrast |
| 2.1.1 | A | Operable | Keyboard |
| 2.1.2 | A | Operable | No Keyboard Trap |
| 2.4.1 | A | Operable | Bypass Blocks |
| 2.4.2 | A | Operable | Page Titled |
| 2.4.3 | A | Operable | Focus Order |
| 2.4.4 | A | Operable | Link Purpose (In Context) |
| 2.4.7 | AA | Operable | Focus Visible |
| 3.1.1 | A | Understandable | Language of Page |
| 3.2.1 | A | Understandable | On Focus |
| 3.3.1 | A | Understandable | Error Identification |
| 3.3.2 | A | Understandable | Labels or Instructions |
| 4.1.1 | A | Robust | Parsing |
| 4.1.2 | A | Robust | Name, Role, Value |

## Examples

### Shell — list all AA-level criteria

```bash
jq '[.[] | select(.level == "AA") | {id, title}]' criteria.json
```

### Shell — find all Operable principle criteria

```bash
jq '[.[] | select(.principle == "Operable") | {id, level, title}]' criteria.json
```

### JavaScript — build a compliance checklist for Level AA

```javascript
const criteria = await fetch('criteria.json').then(r => r.json());
const aa = criteria.filter(c => c.level === 'A' || c.level === 'AA');
const checklist = aa.map(c => ({
  id: c.id,
  title: c.title,
  level: c.level,
  passed: false  // set by auditor
}));
console.log(`${checklist.length} criteria to check for AA conformance`);
```

### PHP — group criteria by principle

```php
$criteria = json_decode(file_get_contents('criteria.json'), true);
$byPrinciple = [];
foreach ($criteria as $c) {
    $byPrinciple[$c['principle']][] = "[{$c['id']}] {$c['title']} ({$c['level']})";
}
foreach ($byPrinciple as $principle => $items) {
    echo "\n## $principle\n";
    foreach ($items as $item) {
        echo "  - $item\n";
    }
}
```
