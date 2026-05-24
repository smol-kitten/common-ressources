# Chemical Elements

A structured subset of the periodic table covering 30 elements — the first 20 by atomic number, plus selected heavier elements of broad interest (Cr, Fe, Ni, Cu, Zn, Br, Kr, Ag, Au, Pb). Each entry includes atomic number, symbol, standard atomic weight, group, period, category, and phase at room temperature.

## JSON

### Structure as of 24.05.2026

```json
{
  "number": 6,
  "symbol": "C",
  "name": "Carbon",
  "mass": 12.011,
  "group": 14,
  "period": 2,
  "category": "nonmetal",
  "phase": "solid"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `number` | number | Atomic number (protons) |
| `symbol` | string | IUPAC element symbol |
| `name` | string | Full element name |
| `mass` | number | Standard atomic weight in daltons (Da / u) |
| `group` | number | Periodic table group (column) |
| `period` | number | Periodic table period (row) |
| `category` | string | Element category (see below) |
| `phase` | string | Phase at room temperature: `solid`, `liquid`, `gas` |

### Categories

| Category | Examples |
|---|---|
| `nonmetal` | H, C, N, O, P, S |
| `noble-gas` | He, Ne, Ar, Kr |
| `alkali-metal` | Li, Na, K |
| `alkaline-earth-metal` | Be, Mg, Ca |
| `transition-metal` | Fe, Cu, Au, Ag |
| `post-transition-metal` | Al, Pb |
| `metalloid` | B, Si |
| `halogen` | F, Cl, Br |

## Entries

| # | Symbol | Name | Mass | Category | Phase |
|---|---|---|---|---|---|
| 1 | H | Hydrogen | 1.008 | nonmetal | gas |
| 2 | He | Helium | 4.003 | noble-gas | gas |
| 3 | Li | Lithium | 6.941 | alkali-metal | solid |
| 4 | Be | Beryllium | 9.012 | alkaline-earth-metal | solid |
| 5 | B | Boron | 10.811 | metalloid | solid |
| 6 | C | Carbon | 12.011 | nonmetal | solid |
| 7 | N | Nitrogen | 14.007 | nonmetal | gas |
| 8 | O | Oxygen | 15.999 | nonmetal | gas |
| 9 | F | Fluorine | 18.998 | halogen | gas |
| 10 | Ne | Neon | 20.180 | noble-gas | gas |
| 11 | Na | Sodium | 22.990 | alkali-metal | solid |
| 12 | Mg | Magnesium | 24.305 | alkaline-earth-metal | solid |
| 13 | Al | Aluminium | 26.982 | post-transition-metal | solid |
| 14 | Si | Silicon | 28.086 | metalloid | solid |
| 15 | P | Phosphorus | 30.974 | nonmetal | solid |
| 16 | S | Sulfur | 32.065 | nonmetal | solid |
| 17 | Cl | Chlorine | 35.453 | halogen | gas |
| 18 | Ar | Argon | 39.948 | noble-gas | gas |
| 19 | K | Potassium | 39.098 | alkali-metal | solid |
| 20 | Ca | Calcium | 40.078 | alkaline-earth-metal | solid |
| 24 | Cr | Chromium | 51.996 | transition-metal | solid |
| 26 | Fe | Iron | 55.845 | transition-metal | solid |
| 28 | Ni | Nickel | 58.693 | transition-metal | solid |
| 29 | Cu | Copper | 63.546 | transition-metal | solid |
| 30 | Zn | Zinc | 65.38 | transition-metal | solid |
| 35 | Br | Bromine | 79.904 | halogen | liquid |
| 36 | Kr | Krypton | 83.798 | noble-gas | gas |
| 47 | Ag | Silver | 107.868 | transition-metal | solid |
| 79 | Au | Gold | 196.967 | transition-metal | solid |
| 82 | Pb | Lead | 207.2 | post-transition-metal | solid |

## Examples

### Shell — list all noble gases

```bash
jq '[.[] | select(.category == "noble-gas") | {symbol, name}]' elements.json
```

### Shell — find elements that are liquid at room temperature

```bash
jq '[.[] | select(.phase == "liquid") | {symbol, name}]' elements.json
```

### JavaScript — look up an element by symbol

```javascript
const elements = await fetch('elements.json').then(r => r.json());
const bySymbol = Object.fromEntries(elements.map(e => [e.symbol, e]));

const iron = bySymbol['Fe'];
console.log(`${iron.name}: atomic number ${iron.number}, mass ${iron.mass}`);
// "Iron: atomic number 26, mass 55.845"
```

### PHP — group elements by category

```php
$elements = json_decode(file_get_contents('elements.json'), true);
$byCategory = [];
foreach ($elements as $el) {
    $byCategory[$el['category']][] = $el['symbol'];
}
foreach ($byCategory as $cat => $symbols) {
    echo "$cat: " . implode(', ', $symbols) . "\n";
}
```
