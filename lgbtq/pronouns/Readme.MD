# Pronouns

A structured JSON reference for gender pronouns — including traditional, neutral, and neopronouns — with full conjugation sets and usage examples.

## JSON

### Structure as of 23.05.2026

```json
{
  "subject": "they",
  "object": "them",
  "possessive-adjective": "their",
  "possessive-pronoun": "theirs",
  "reflexive": "themselves",
  "neopronouns": false,
  "description": "Gender-neutral pronouns with a long history in the English language.",
  "example": "They went to the store. I saw them there. Their bag was heavy.",
  "related": ["he/they", "she/they"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `subject` | string | Subject form — who does the action (e.g. *They* went) |
| `object` | string | Object form — who receives the action (e.g. I saw *them*) |
| `possessive-adjective` | string | Modifies a noun (e.g. *Their* bag) |
| `possessive-pronoun` | string | Stands alone (e.g. That bag is *theirs*) |
| `reflexive` | string | Refers back to the subject (e.g. *Themselves*) |
| `neopronouns` | boolean | `true` if these are neopronouns not in mainstream dictionaries |
| `description` | string | Background and usage context |
| `example` | string | Full example sentence using all five forms in order |
| `related` | string[] | Pronoun sets commonly used alongside or similar to this one |

## Pronoun sets included

| Set | Neopronouns |
|---|---|
| he/him | no |
| she/her | no |
| they/them | no |
| ze/zir | yes |
| ze/hir | yes |
| xe/xem | yes |
| ey/em (Spivak) | yes |
| fae/faer | yes |
| it/its | no |
| per/per | yes |
| ve/ver | yes |
| any/all | no |

## Usage note

Always use the pronouns a person uses for themselves. Never assume pronouns from appearance. When unsure, singular *they/them* is a safe, grammatically accepted neutral default.

## Examples

### PHP — display a full pronoun set

```php
$pronouns = json_decode(file_get_contents('pronouns.json'), true);
foreach ($pronouns as $set) {
    if (!$set['neopronouns']) {
        echo $set['subject'] . '/' . $set['object'] . "\n";
        echo '  Example: ' . $set['example'] . "\n";
    }
}
```

### Shell — list all neopronoun sets

```bash
jq '[.[] | select(.neopronouns == true) | "\(.subject)/\(.object)"]' pronouns.json
```

### JavaScript

```javascript
const pronouns = await fetch('pronouns.json').then(r => r.json());
const traditional = pronouns.filter(p => !p.neopronouns);
console.log(traditional.map(p => `${p.subject}/${p.object}`));
// ["he/him", "she/her", "they/them", "it/its", "any/any"]
```
