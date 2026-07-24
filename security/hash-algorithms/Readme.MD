# Hash Algorithms

Common cryptographic hash functions (and a couple of important non-cryptographic references) with their digest size, internal block size, construction, year, and current security status. Covers the MD family, SHA-0/1, the SHA-2 and SHA-3 (Keccak) families, SHAKE XOFs, BLAKE2/BLAKE3, RIPEMD-160, and Whirlpool. Useful for choosing a hash, flagging deprecated ones in audits, and educational references.

## JSON

### Structure

```json
{
  "name": "SHA-256",
  "slug": "sha-256",
  "digest_bits": 256,
  "block_bits": 512,
  "construction": "Merkle–Damgård",
  "released_year": 2001,
  "status": "secure",
  "cryptographic": true,
  "notes": "..."
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Algorithm name |
| `slug` | string | Lowercase hyphenated identifier |
| `digest_bits` | integer | Output size in bits; omitted for extendable-output functions (XOFs) with arbitrary-length output |
| `block_bits` | integer | Internal block size in bits; **omitted** for sponge (Keccak/SHAKE), tree (BLAKE3), and HAIFA (BLAKE2) constructions where a single Merkle–Damgård block size does not apply |
| `construction` | string | Underlying construction (e.g. `Merkle–Damgård`, `sponge (Keccak)`, `Merkle tree`) |
| `released_year` | integer | Year the algorithm was published/standardised |
| `status` | string | `secure`, `broken` (practical collisions / deprecated by NIST), or `not-applicable` (non-cryptographic checksum) |
| `cryptographic` | boolean | Whether the function is designed to be cryptographically secure |
| `notes` | string | Security context, standard reference, and typical usage |

### Notes

- `status` reflects the consensus / NIST position at the time of writing (e.g. SHA-1 is `broken` following the 2017 SHAttered collision and NIST SP 800-131A deprecation). Always confirm against current guidance for security-critical decisions.
- For sponge functions the concept analogous to `block_bits` is the sponge *rate* (e.g. SHA3-256 rate = 1088 bits); these are given in `notes` rather than `block_bits` to avoid conflating different constructions.
- `CRC32` is included and clearly marked non-cryptographic (`status: not-applicable`) because it is frequently misused as if it provided integrity guarantees.

## Sources

- NIST FIPS 180-4 (SHA-1/SHA-2), FIPS 202 (SHA-3/SHAKE), and SP 800-131A (transitions).
- Original algorithm specifications for MD5, RIPEMD-160, BLAKE2 (RFC 7693), BLAKE3, and Whirlpool.
