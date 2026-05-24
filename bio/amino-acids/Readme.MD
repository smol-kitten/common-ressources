# Amino Acids

All 20 standard proteinogenic amino acids with one-letter code, three-letter code, molecular weight, electrical charge, polarity, essentiality, side chain type, and structural category. An essential reference for bioinformatics tools, sequence analysis, educational content, and protein data applications.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Leucine",
  "symbol_1": "L",
  "symbol_3": "Leu",
  "mw": 131.17,
  "charge": "neutral",
  "polarity": "nonpolar",
  "essential": true,
  "side_chain": "isobutyl",
  "category": "aliphatic"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Full amino acid name |
| `symbol_1` | string | Single-letter IUPAC code |
| `symbol_3` | string | Three-letter IUPAC abbreviation |
| `mw` | number | Molecular weight in g/mol (Da) |
| `charge` | string | Net charge at physiological pH: `neutral`, `positive`, `negative` |
| `polarity` | string | Side chain polarity: `nonpolar` or `polar` |
| `essential` | boolean | Whether it is an essential amino acid (must be obtained from diet) |
| `side_chain` | string | Type of side chain functional group |
| `category` | string | Structural/chemical category (see below) |

### Categories

| Category | Amino Acids |
|---|---|
| `aliphatic` | Gly, Ala, Val, Leu, Ile |
| `aromatic` | Phe, Tyr, Trp |
| `hydroxyl` | Ser, Thr |
| `sulfur` | Cys, Met |
| `basic` | Lys, Arg, His |
| `acidic` | Asp, Glu |
| `amide` | Asn, Gln |
| `cyclic` | Pro |

## Entries

| 1-letter | 3-letter | Name | MW | Charge | Essential |
|---|---|---|---|---|---|
| A | Ala | Alanine | 89.09 | neutral | No |
| R | Arg | Arginine | 174.20 | positive | Yes |
| N | Asn | Asparagine | 132.12 | neutral | No |
| D | Asp | Aspartic acid | 133.10 | negative | No |
| C | Cys | Cysteine | 121.16 | neutral | No |
| E | Glu | Glutamic acid | 147.13 | negative | No |
| Q | Gln | Glutamine | 146.15 | neutral | No |
| G | Gly | Glycine | 75.03 | neutral | No |
| H | His | Histidine | 155.16 | positive | Yes |
| I | Ile | Isoleucine | 131.17 | neutral | Yes |
| L | Leu | Leucine | 131.17 | neutral | Yes |
| K | Lys | Lysine | 146.19 | positive | Yes |
| M | Met | Methionine | 149.21 | neutral | Yes |
| F | Phe | Phenylalanine | 165.19 | neutral | Yes |
| P | Pro | Proline | 115.13 | neutral | No |
| S | Ser | Serine | 105.09 | neutral | No |
| T | Thr | Threonine | 119.12 | neutral | Yes |
| W | Trp | Tryptophan | 204.23 | neutral | Yes |
| Y | Tyr | Tyrosine | 181.19 | neutral | No |
| V | Val | Valine | 117.15 | neutral | Yes |

## Examples

### Shell — list all essential amino acids

```bash
jq '[.[] | select(.essential == true) | {symbol_1, symbol_3, name}]' amino-acids.json
```

### Shell — find all positively charged amino acids

```bash
jq '[.[] | select(.charge == "positive") | {name, symbol_1}]' amino-acids.json
```

### JavaScript — look up an amino acid by single-letter code

```javascript
const aminoAcids = await fetch('amino-acids.json').then(r => r.json());
const bySymbol1 = Object.fromEntries(aminoAcids.map(a => [a.symbol_1, a]));

function lookupAA(letter) {
  const aa = bySymbol1[letter.toUpperCase()];
  return aa ? `${aa.name} (${aa.symbol_3}), MW: ${aa.mw}` : 'Unknown';
}

console.log(lookupAA('W')); // "Tryptophan (Trp), MW: 204.23"
```

### PHP — decode a one-letter protein sequence

```php
$aminoAcids = json_decode(file_get_contents('amino-acids.json'), true);
$bySymbol1 = array_column($aminoAcids, null, 'symbol_1');

$sequence = 'MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSPLHSVYVDQWDWERVMGDGERQFSTLKSTVEAIWAGIKATEAAVSEEFGLAPFLPDQIHFVHSQELLSRYPDLDAKGRERAIAKDLGAVFLVGIGGKLSDGHRHDVRAPDYDDWSTPSELGHAGLNGDILVWNPVLEDAFELSSMGIRVDADTLKHQLALTGDEDRLELEWHQALLRGEMPQTIGGGIGQSRLTMLLLQLPHIGQVQAGVWPAAVRESVPSLL';
$names = [];
foreach (str_split($sequence) as $letter) {
    $names[] = $bySymbol1[$letter]['symbol_3'] ?? '???';
}
echo implode('-', array_slice($names, 0, 5)) . '...';
// "Met-Lys-Thr-Ala-Tyr..."
```
