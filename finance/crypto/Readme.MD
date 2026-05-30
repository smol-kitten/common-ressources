# Cryptocurrency Reference

Top 20 cryptocurrencies by market capitalization rank. Each entry includes ticker symbol, full name, decimal precision, consensus mechanism, layer classification, and founding year — useful for crypto wallets, exchange integrations, portfolio trackers, and educational content.

## JSON

### Structure as of 24.05.2026

```json
{
  "rank": 1,
  "ticker": "BTC",
  "name": "Bitcoin",
  "decimals": 8,
  "consensus": "proof-of-work",
  "layer": 1,
  "founded_year": 2009,
  "notes": "First and largest cryptocurrency by market cap"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `rank` | number | Approximate market cap rank (may shift over time) |
| `ticker` | string | Trading ticker/symbol (e.g. `BTC`, `ETH`) |
| `name` | string | Full name of the cryptocurrency or project |
| `decimals` | number | Number of decimal places for the base unit |
| `consensus` | string | Consensus mechanism used by the network |
| `layer` | number | Protocol layer: `0` (cross-chain), `1` (base chain), `2` (built on L1) |
| `founded_year` | number | Year the network or project launched |
| `notes` | string | Key context or technical highlights |

### Consensus Mechanisms

| Mechanism | Examples |
|---|---|
| `proof-of-work` | BTC, DOGE, LTC, XMR |
| `proof-of-stake` | ETH, ADA, AVAX, DOT |
| `proof-of-history` | SOL |
| `delegated-proof-of-stake` | USDT (Tron chain) |
| `federated-byzantine-agreement` | XRP, XLM |
| `pure-proof-of-stake` | ALGO |
| `tendermint-bft` | ATOM |
| `proof-of-replication` | FIL |

## Entries

| Rank | Ticker | Name | Decimals | Layer | Founded |
|---|---|---|---|---|---|
| 1 | BTC | Bitcoin | 8 | 1 | 2009 |
| 2 | ETH | Ethereum | 18 | 1 | 2015 |
| 3 | USDT | Tether | 6 | 2 | 2014 |
| 4 | BNB | BNB | 18 | 1 | 2017 |
| 5 | SOL | Solana | 9 | 1 | 2020 |
| 6 | USDC | USD Coin | 6 | 2 | 2018 |
| 7 | XRP | XRP | 6 | 1 | 2012 |
| 8 | ADA | Cardano | 6 | 1 | 2017 |
| 9 | AVAX | Avalanche | 18 | 1 | 2020 |
| 10 | DOGE | Dogecoin | 8 | 1 | 2013 |
| 11 | DOT | Polkadot | 10 | 0 | 2020 |
| 12 | MATIC | Polygon | 18 | 2 | 2019 |
| 13 | LTC | Litecoin | 8 | 1 | 2011 |
| 14 | LINK | Chainlink | 18 | 2 | 2017 |
| 15 | UNI | Uniswap | 18 | 2 | 2018 |
| 16 | ATOM | Cosmos | 6 | 1 | 2019 |
| 17 | XMR | Monero | 12 | 1 | 2014 |
| 18 | XLM | Stellar | 7 | 1 | 2014 |
| 19 | ALGO | Algorand | 6 | 1 | 2019 |
| 20 | FIL | Filecoin | 18 | 1 | 2020 |

## Examples

### Shell — list all proof-of-work coins

```bash
jq '[.[] | select(.consensus == "proof-of-work") | {ticker, name}]' crypto.json
```

### Shell — find all Layer 2 tokens

```bash
jq '[.[] | select(.layer == 2) | {ticker, name, notes}]' crypto.json
```

### JavaScript — look up token decimal places by ticker

```javascript
const tokens = await fetch('crypto.json').then(r => r.json());
const byTicker = Object.fromEntries(tokens.map(t => [t.ticker, t]));

function formatAmount(ticker, rawAmount) {
  const token = byTicker[ticker];
  if (!token) return rawAmount;
  return rawAmount / Math.pow(10, token.decimals);
}

// ETH uses 18 decimals (wei → ether)
console.log(formatAmount('ETH', 1e18)); // 1
console.log(formatAmount('BTC', 100000000)); // 1
```

### PHP — group tokens by consensus mechanism

```php
$tokens = json_decode(file_get_contents('crypto.json'), true);
$byConsensus = [];
foreach ($tokens as $t) {
    $byConsensus[$t['consensus']][] = $t['ticker'];
}
foreach ($byConsensus as $consensus => $tickers) {
    echo "$consensus: " . implode(', ', $tickers) . "\n";
}
```
