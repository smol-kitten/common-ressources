# LGBTQ+ Glossary Terms

A structured JSON reference of LGBTQ+ terminology — including gender identities, sexual orientations, community concepts, and medical/legal terms — with definitions, categories, and related terms.

## JSON

### Structure as of 23.05.2026

```json
{
  "term": "Nonbinary",
  "abbreviation": "NB / Enby",
  "definition": "A spectrum of gender identities that are not exclusively masculine or feminine. Nonbinary people may identify as having no gender, multiple genders, a fluctuating gender, or a gender that falls outside the male/female binary. The term is often used as both a specific identity and a broader umbrella.",
  "category": "gender",
  "neologism": false,
  "related": ["Genderfluid", "Agender", "Bigender", "Transgender", "Xenogender"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `term` | string | The term or identity name, as commonly written |
| `abbreviation` | string \| null | Common abbreviation or shorthand, or `null` if none |
| `definition` | string | Definition of 2–4 sentences explaining the term and its context |
| `category` | string | Thematic category (see below) |
| `neologism` | boolean | `true` if the term is a recent coinage not yet in mainstream dictionaries |
| `related` | string[] | Terms that are closely related, overlapping, or commonly discussed together |

### Categories

| Category | Description |
|---|---|
| `gender` | Identities relating to a person's internal sense of their own gender |
| `sexuality` | Sexual and romantic orientations |
| `identity` | Broader identity concepts that span gender and sexuality |
| `community` | Terms relating to LGBTQ+ culture, community structures, and social dynamics |
| `medical` | Terms used in medical, clinical, or health contexts |
| `legal` | Terms relating to legal recognition, rights, or protections |

## Terms included

| Term | Abbreviation | Category |
|---|---|---|
| Transgender | Trans | gender |
| Nonbinary | NB / Enby | gender |
| Genderfluid | — | gender |
| Agender | — | gender |
| Bigender | — | gender |
| Demiboy | — | gender |
| Demigirl | — | gender |
| Xenogender | — | gender |
| Two-Spirit | 2S | identity |
| Intersex | — | medical |
| Asexual | Ace | sexuality |
| Aromantic | Aro | sexuality |
| Bisexual | Bi | sexuality |
| Pansexual | Pan | sexuality |
| Polysexual | — | sexuality |
| Demisexual | — | sexuality |
| Graysexual | Gray-ace | sexuality |
| Lesbian | — | sexuality |
| Gay | — | sexuality |
| Queer | — | identity |
| Questioning | — | identity |
| Ally | — | community |
| LGBTQ+ | LGBTQ+ | community |
| Gender Dysphoria | — | medical |
| Gender Euphoria | — | identity |
| Dead Name | — | identity |
| Misgendering | — | community |
| Transitioning | — | identity |
| HRT (Hormone Replacement Therapy) | HRT | medical |
| Gender Affirming Care | GAC | medical |
| Passing | — | identity |
| Stealth | — | identity |
| Outing | — | community |
| Coming Out | — | community |
| Chosen Family | — | community |
| Pride | — | community |

## Usage note

Terminology evolves. Some terms may be contested within subgroups of the community, and individual preferences always take priority over any glossary. When describing a real person, use the language they use for themselves.

## Examples

### Shell — list all neologisms

```bash
jq '[.[] | select(.neologism == true) | .term]' terms.json
```

### Shell — find all terms in a category

```bash
jq '[.[] | select(.category == "sexuality") | {term: .term, abbreviation: .abbreviation}]' terms.json
```

### Shell — search by related term

```bash
jq '[.[] | select(.related | contains(["Transgender"])) | .term]' terms.json
```

### PHP — look up a term by name

```php
$terms = json_decode(file_get_contents('terms.json'), true);
$index = array_column($terms, null, 'term');

$entry = $index['Nonbinary'];
echo $entry['definition'] . "\n";
// "A spectrum of gender identities..."
```

### PHP — list all terms in a category

```php
$terms = json_decode(file_get_contents('terms.json'), true);
$medical = array_filter($terms, fn($t) => $t['category'] === 'medical');
foreach ($medical as $term) {
    echo $term['term'] . "\n";
}
```

### JavaScript — filter by category

```javascript
const terms = await fetch('terms.json').then(r => r.json());
const genderTerms = terms.filter(t => t.category === 'gender');
console.log(genderTerms.map(t => t.term));
// ["Transgender", "Nonbinary", "Genderfluid", ...]
```

### JavaScript — find related terms

```javascript
const terms = await fetch('terms.json').then(r => r.json());
const index = Object.fromEntries(terms.map(t => [t.term, t]));

function getRelated(termName) {
  return (index[termName]?.related ?? []).map(name => index[name]).filter(Boolean);
}

console.log(getRelated('Asexual').map(t => t.term));
// ["Aromantic", "Demisexual", "Graysexual", "Queer"]
```
