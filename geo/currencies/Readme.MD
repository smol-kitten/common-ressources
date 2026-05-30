# Currencies

ISO 4217 currency reference covering 25 major world currencies. Each entry includes the currency code, symbol, decimal precision, and issuing country — everything needed to format monetary values correctly in a multi-currency application.

## JSON

### Structure as of 24.05.2026

```json
{
  "code": "USD",
  "name": "United States Dollar",
  "symbol": "$",
  "decimals": 2,
  "country": "United States",
  "country_code": "US"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `code` | string | ISO 4217 three-letter currency code |
| `name` | string | Full English name of the currency |
| `symbol` | string | Common display symbol (may be shared across currencies) |
| `decimals` | number | Number of minor units (e.g. 2 for cents, 0 for Japanese Yen) |
| `country` | string | Primary issuing country or region |
| `country_code` | string | ISO 3166-1 alpha-2 country code (or `EU` for Euro) |

## Entries

| Code | Name | Symbol | Decimals |
|---|---|---|---|
| USD | United States Dollar | $ | 2 |
| EUR | Euro | € | 2 |
| GBP | British Pound Sterling | £ | 2 |
| JPY | Japanese Yen | ¥ | 0 |
| CNY | Chinese Yuan Renminbi | ¥ | 2 |
| INR | Indian Rupee | ₹ | 2 |
| CAD | Canadian Dollar | C$ | 2 |
| AUD | Australian Dollar | A$ | 2 |
| CHF | Swiss Franc | Fr | 2 |
| SEK | Swedish Krona | kr | 2 |
| NOK | Norwegian Krone | kr | 2 |
| DKK | Danish Krone | kr | 2 |
| NZD | New Zealand Dollar | NZ$ | 2 |
| BRL | Brazilian Real | R$ | 2 |
| MXN | Mexican Peso | $ | 2 |
| ZAR | South African Rand | R | 2 |
| KRW | South Korean Won | ₩ | 0 |
| SGD | Singapore Dollar | S$ | 2 |
| HKD | Hong Kong Dollar | HK$ | 2 |
| TRY | Turkish Lira | ₺ | 2 |
| RUB | Russian Ruble | ₽ | 2 |
| PLN | Polish Zloty | zł | 2 |
| AED | UAE Dirham | د.إ | 2 |
| SAR | Saudi Riyal | ﷼ | 2 |
| IDR | Indonesian Rupiah | Rp | 0 |

## Examples

### Shell — find currencies with 0 decimal places (no minor units)

```bash
jq '[.[] | select(.decimals == 0) | {code, name}]' currencies.json
```

### Shell — look up a currency by code

```bash
jq '.[] | select(.code == "EUR")' currencies.json
```

### JavaScript — format an amount using the correct number of decimals

```javascript
const currencies = await fetch('currencies.json').then(r => r.json());
const byCode = Object.fromEntries(currencies.map(c => [c.code, c]));

function formatAmount(code, amount) {
  const cur = byCode[code];
  return `${cur.symbol}${amount.toFixed(cur.decimals)}`;
}

console.log(formatAmount('USD', 1234.5));  // "$1234.50"
console.log(formatAmount('JPY', 1234));    // "¥1234"
```

### PHP — format a monetary value with correct decimal places

```php
$currencies = json_decode(file_get_contents('currencies.json'), true);
$byCode = array_column($currencies, null, 'code');

function formatMoney(string $code, float $amount, array $currencies): string {
    $cur = $currencies[$code];
    return $cur['symbol'] . number_format($amount, $cur['decimals']);
}

echo formatMoney('EUR', 1234.5, $byCode); // "€1,234.50"
echo formatMoney('KRW', 50000, $byCode);  // "₩50,000"
```
