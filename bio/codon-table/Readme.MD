# Codon Table (Standard Genetic Code)

All 64 mRNA codons of the standard genetic code (NCBI translation table 1), each mapped to the amino acid it encodes or to a stop signal. Includes the canonical AUG start codon and the three stop codons (UAA, UAG, UGA). Amino-acid names and three-letter codes cross-reference the `bio/amino-acids` dataset. Useful for bioinformatics tools, sequence translation, molecular-biology education, and codon-usage tooling.

## JSON

### Structure

```json
{
  "codon": "AUG",
  "amino_acid_1": "M",
  "amino_acid_3": "Met",
  "amino_acid": "Methionine",
  "start": true,
  "stop": false
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `codon` | string | Three-base mRNA codon, 5′→3′, using RNA bases (A, C, G, U) |
| `amino_acid_1` | string \| null | One-letter IUPAC amino-acid code; `null` for stop codons |
| `amino_acid_3` | string | Three-letter amino-acid abbreviation, or `Stop` |
| `amino_acid` | string | Full amino-acid name, or `Stop` |
| `start` | boolean | `true` for the canonical initiation codon (AUG) |
| `stop` | boolean | `true` for the three stop codons (UAA, UAG, UGA) |

### Notes

- Codons use **RNA bases** (U, not T); for DNA replace U with T.
- This is the **standard code** (NCBI table 1) used by the nuclear genome of most organisms. Mitochondrial and some microbial genomes use variant codes not covered here.
- AUG is marked as the start codon. GUG and UUG can act as alternative initiation codons in some biological contexts but are not flagged as `start` here, since under the standard code they encode Val and Leu respectively.

## Sources

- NCBI, *The Genetic Codes* — translation table 1 (Standard Code).
- IUPAC-IUBMB nomenclature for amino-acid codes.
