# Countries

ISO 3166-1 country reference covering 25 major countries. Each entry includes ISO alpha-2 and alpha-3 codes, capital city, continent, international dial code, currency code, and approximate population — everything needed to drive country pickers, form validation, and localization features.

## JSON

### Structure as of 24.05.2026

```json
{
  "iso2": "DE",
  "iso3": "DEU",
  "name": "Germany",
  "capital": "Berlin",
  "continent": "Europe",
  "dial_code": "+49",
  "currency_code": "EUR",
  "population_approx": 83000000
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `iso2` | string | ISO 3166-1 alpha-2 two-letter country code |
| `iso3` | string | ISO 3166-1 alpha-3 three-letter country code |
| `name` | string | Common English country name |
| `capital` | string | Capital city |
| `continent` | string | Geographic continent |
| `dial_code` | string | International telephone dial code with `+` prefix |
| `currency_code` | string | ISO 4217 currency code |
| `population_approx` | number | Approximate population (rounded) |

### Continents

`Africa` · `Americas` · `Asia` · `Europe` · `Oceania`

## Entries

| ISO2 | ISO3 | Name | Continent |
|---|---|---|---|
| US | USA | United States | Americas |
| GB | GBR | United Kingdom | Europe |
| DE | DEU | Germany | Europe |
| FR | FRA | France | Europe |
| JP | JPN | Japan | Asia |
| CN | CHN | China | Asia |
| IN | IND | India | Asia |
| BR | BRA | Brazil | Americas |
| CA | CAN | Canada | Americas |
| AU | AUS | Australia | Oceania |
| MX | MEX | Mexico | Americas |
| ZA | ZAF | South Africa | Africa |
| NG | NGA | Nigeria | Africa |
| EG | EGY | Egypt | Africa |
| AR | ARG | Argentina | Americas |
| RU | RUS | Russia | Europe |
| KR | KOR | South Korea | Asia |
| SE | SWE | Sweden | Europe |
| NL | NLD | Netherlands | Europe |
| CH | CHE | Switzerland | Europe |
| SG | SGP | Singapore | Asia |
| PL | POL | Poland | Europe |
| ID | IDN | Indonesia | Asia |
| PK | PAK | Pakistan | Asia |
| UA | UKR | Ukraine | Europe |

## Examples

### Shell — list all African countries

```bash
jq '[.[] | select(.continent == "Africa") | {iso2, name, capital}]' countries.json
```

### Shell — look up dial code by ISO2

```bash
jq -r '.[] | select(.iso2 == "JP") | .dial_code' countries.json
```

### JavaScript — build a country dropdown

```javascript
const countries = await fetch('countries.json').then(r => r.json());
const sorted = [...countries].sort((a, b) => a.name.localeCompare(b.name));
const options = sorted.map(c => `<option value="${c.iso2}">${c.name}</option>`);
document.getElementById('country').innerHTML = options.join('\n');
```

### PHP — validate and look up a country code

```php
$countries = json_decode(file_get_contents('countries.json'), true);
$byIso2 = array_column($countries, null, 'iso2');

function lookupCountry(string $code, array $index): ?array {
    return $index[strtoupper($code)] ?? null;
}

$country = lookupCountry('sg', $byIso2);
echo $country['name'];      // "Singapore"
echo $country['capital'];   // "Singapore"
echo $country['dial_code']; // "+65"
```
