# ISO 639-2 Language Codes

The complete ISO 639-2 set of three-letter language codes (Library of Congress registration authority) — 487 entries covering individual languages, collective codes (e.g. `bat` Baltic languages), and special codes (`und` Undetermined, `mul` Multiple, `zxx` No linguistic content). Where a language has both a bibliographic (B) and terminologic (T) code they are both given, and the ISO 639-1 two-letter code is included where one exists (cross-referencing `i18n/languages`). Names are provided in English and French. Useful for library systems, language tagging, and bibliographic metadata.

## JSON

### Structure

```json
{
  "alpha3_b": "ger",
  "alpha3_t": "deu",
  "alpha2": "de",
  "name": "German",
  "name_french": "allemand"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `alpha3_b` | string | Bibliographic three-letter code (the primary key) |
| `alpha3_t` | string | Terminologic three-letter code, present only for the 20 languages where it differs from the bibliographic code |
| `alpha2` | string | ISO 639-1 two-letter code, present for the 183 languages that have one |
| `name` | string | English name |
| `name_french` | string | French name |

### Notes

- **B vs T codes:** 20 languages have two 639-2 codes — a bibliographic one (historically English-based, e.g. `ger`, `fre`, `chi`) and a terminologic one (based on the native name, e.g. `deu`, `fra`, `zho`). ISO 639-3 later adopted the terminologic codes.
- Every `alpha2` value here also appears in `i18n/languages` (ISO 639-1), and every `iso639_2` value in that dataset resolves to a code here — the two are kept mutually consistent by `tools/verify.py`.
- One entry, `qaa-qtz`, is the standard's **reserved range for local use** rather than a single code; it is retained verbatim from the Library of Congress source.

## Sources

- Library of Congress — [ISO 639-2 registration authority](https://www.loc.gov/standards/iso639-2/) ([`ISO-639-2_utf-8.txt`](https://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt)).
