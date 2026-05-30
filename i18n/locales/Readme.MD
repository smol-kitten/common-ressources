# Locales

A structured BCP 47 locale reference covering 25 widely used language-region combinations. Each entry includes language, region, writing script, text direction, and native name — everything needed to power a language picker, set `lang` attributes, or configure i18n libraries.

## JSON

### Structure as of 24.05.2026

```json
{
  "code": "fr-FR",
  "language": "French",
  "language_code": "fr",
  "region": "France",
  "region_code": "FR",
  "script": "Latin",
  "direction": "ltr",
  "native_name": "Français (France)"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `code` | string | BCP 47 locale tag (e.g. `en-US`, `zh-CN`) |
| `language` | string | English language name |
| `language_code` | string | ISO 639-1 two-letter language code |
| `region` | string | English region/country name |
| `region_code` | string | ISO 3166-1 alpha-2 region code |
| `script` | string | Writing script used |
| `direction` | string | Text direction: `ltr` (left-to-right) or `rtl` (right-to-left) |
| `native_name` | string | Locale name as written in the locale's own language/script |

## Entries

| Code | Language | Region | Script | Direction |
|---|---|---|---|---|
| `en-US` | English | United States | Latin | ltr |
| `en-GB` | English | United Kingdom | Latin | ltr |
| `en-AU` | English | Australia | Latin | ltr |
| `fr-FR` | French | France | Latin | ltr |
| `fr-CA` | French | Canada | Latin | ltr |
| `de-DE` | German | Germany | Latin | ltr |
| `es-ES` | Spanish | Spain | Latin | ltr |
| `es-MX` | Spanish | Mexico | Latin | ltr |
| `pt-BR` | Portuguese | Brazil | Latin | ltr |
| `pt-PT` | Portuguese | Portugal | Latin | ltr |
| `it-IT` | Italian | Italy | Latin | ltr |
| `nl-NL` | Dutch | Netherlands | Latin | ltr |
| `sv-SE` | Swedish | Sweden | Latin | ltr |
| `pl-PL` | Polish | Poland | Latin | ltr |
| `ru-RU` | Russian | Russia | Cyrillic | ltr |
| `uk-UA` | Ukrainian | Ukraine | Cyrillic | ltr |
| `ar-SA` | Arabic | Saudi Arabia | Arabic | rtl |
| `ar-EG` | Arabic | Egypt | Arabic | rtl |
| `he-IL` | Hebrew | Israel | Hebrew | rtl |
| `zh-CN` | Chinese (Simplified) | China | Han (Simplified) | ltr |
| `zh-TW` | Chinese (Traditional) | Taiwan | Han (Traditional) | ltr |
| `ja-JP` | Japanese | Japan | Japanese | ltr |
| `ko-KR` | Korean | South Korea | Hangul | ltr |
| `hi-IN` | Hindi | India | Devanagari | ltr |
| `tr-TR` | Turkish | Turkey | Latin | ltr |

## Examples

### Shell — list all right-to-left locales

```bash
jq '[.[] | select(.direction == "rtl") | {code, language, region}]' locales.json
```

### Shell — find all locales for a given language code

```bash
jq '[.[] | select(.language_code == "es") | .code]' locales.json
```

### JavaScript — set the HTML lang attribute and dir

```javascript
const locales = await fetch('locales.json').then(r => r.json());
const byCode = Object.fromEntries(locales.map(l => [l.code, l]));

function applyLocale(code) {
  const locale = byCode[code];
  if (!locale) return;
  document.documentElement.lang = locale.code;
  document.documentElement.dir = locale.direction;
  console.log(`Applied: ${locale.native_name}`);
}

applyLocale('ar-SA');
// Applied: العربية (المملكة العربية السعودية)
```

### PHP — build a language selector

```php
$locales = json_decode(file_get_contents('locales.json'), true);

echo '<select name="locale">' . "\n";
foreach ($locales as $locale) {
    printf(
        '  <option value="%s">%s</option>' . "\n",
        htmlspecialchars($locale['code']),
        htmlspecialchars($locale['native_name'])
    );
}
echo '</select>';
```
