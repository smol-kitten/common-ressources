# World Cuisines

A structured reference for 16 major world cuisines with key ingredients, staple dishes, cooking methods, and spice level. Useful for recipe apps, restaurant finders, food content tagging, and cultural reference.

## JSON

### Structure as of 24.05.2026

```json
{
  "slug": "japanese",
  "name": "Japanese",
  "country": "Japan",
  "continent": "Asia",
  "key_ingredients": ["rice", "soy sauce", "miso", "dashi", "seaweed"],
  "staple_dishes": ["sushi", "ramen", "tempura", "miso soup"],
  "cooking_methods": ["steaming", "grilling", "raw preparation"],
  "spice_level": "mild"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `slug` | string | Lowercase hyphen-separated identifier |
| `name` | string | Cuisine name |
| `country` | string | Country or region of origin |
| `continent` | string | Geographic continent |
| `key_ingredients` | string[] | Defining or characteristic ingredients |
| `staple_dishes` | string[] | Iconic dishes associated with this cuisine |
| `cooking_methods` | string[] | Primary cooking techniques |
| `spice_level` | string | Typical heat level (see below) |

### Spice Levels

| Value | Description |
|---|---|
| `mild` | Little to no heat |
| `mild-to-medium` | Occasionally spiced, generally mild |
| `medium` | Moderate spice; may vary by dish |
| `medium-to-hot` | Often spicy; heat is a defining feature |
| `hot` | Frequently very spicy |

## Entries

| Slug | Name | Country | Continent | Spice Level |
|---|---|---|---|---|
| `italian` | Italian | Italy | Europe | mild |
| `french` | French | France | Europe | mild |
| `japanese` | Japanese | Japan | Asia | mild |
| `chinese` | Chinese | China | Asia | mild-to-hot |
| `indian` | Indian | India | Asia | medium-to-hot |
| `mexican` | Mexican | Mexico | Americas | medium-to-hot |
| `thai` | Thai | Thailand | Asia | hot |
| `greek` | Greek | Greece | Europe | mild |
| `moroccan` | Moroccan | Morocco | Africa | medium |
| `ethiopian` | Ethiopian | Ethiopia | Africa | hot |
| `spanish` | Spanish | Spain | Europe | mild-to-medium |
| `vietnamese` | Vietnamese | Vietnam | Asia | mild-to-medium |
| `lebanese` | Lebanese | Lebanon | Asia | mild |
| `peruvian` | Peruvian | Peru | Americas | medium |
| `korean` | Korean | South Korea | Asia | medium-to-hot |
| `american` | American | United States | Americas | mild-to-medium |

## Examples

### Shell — find mild cuisines from Asia

```bash
jq '[.[] | select(.continent == "Asia" and .spice_level == "mild") | {name, country}]' cuisines.json
```

### Shell — list all staple dishes for a given cuisine

```bash
jq '.[] | select(.slug == "italian") | .staple_dishes[]' cuisines.json
```

### JavaScript — filter cuisines by spice level

```javascript
const cuisines = await fetch('cuisines.json').then(r => r.json());
const spicyOnes = cuisines.filter(c =>
  ['hot', 'medium-to-hot'].includes(c.spice_level)
);
console.log(spicyOnes.map(c => c.name));
// ["Indian", "Mexican", "Thai", "Ethiopian", "Korean"]
```

### PHP — group cuisines by continent

```php
$cuisines = json_decode(file_get_contents('cuisines.json'), true);
$byContinent = [];
foreach ($cuisines as $c) {
    $byContinent[$c['continent']][] = $c['name'];
}
foreach ($byContinent as $continent => $names) {
    echo "$continent: " . implode(', ', $names) . "\n";
}
```
