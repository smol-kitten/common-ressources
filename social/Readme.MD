# Social Platforms

Structured metadata for major social media and community platforms — brand colors, federation status, handle formats, character limits, and more.

## JSON

### Structure as of 23.05.2026

```json
{
  "name": "Mastodon",
  "slug": "mastodon",
  "url": "https://joinmastodon.org",
  "brand-color": "#6364FF",
  "open-source": true,
  "federated": true,
  "protocol": "ActivityPub",
  "handle-prefix": "@",
  "handle-format": "user@instance.tld",
  "description": "A decentralized, open-source social network part of the Fediverse.",
  "content-types": ["text", "image", "video", "audio", "link"],
  "character-limit": 500,
  "founded": 2016,
  "category": "microblogging"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Platform display name |
| `slug` | string | URL-safe identifier |
| `url` | string | Primary platform URL |
| `brand-color` | string | Official or widely recognized brand hex color |
| `open-source` | boolean | Whether the server software is open source |
| `federated` | boolean | Whether the platform supports federation with other servers |
| `protocol` | string or null | Federation protocol (`ActivityPub`, `AT Protocol`, or `null`) |
| `handle-prefix` | string or null | Character prepended to handles (usually `@`) |
| `handle-format` | string | Description of valid handle character set |
| `description` | string | Summary of the platform |
| `content-types` | string[] | Supported content types (`text`, `image`, `video`, `audio`, `link`, etc.) |
| `character-limit` | number | Default post character limit |
| `founded` | number | Year the platform was founded |
| `category` | string | Platform category |

### Categories

| Category | Examples |
|---|---|
| `microblogging` | Bluesky, Mastodon, Twitter/X, Threads |
| `photo-video` | Instagram, Pixelfed |
| `video` | TikTok, YouTube |
| `live-streaming` | Twitch |
| `messaging` | Discord |
| `forum` | Reddit |
| `blogging` | Tumblr |
| `professional` | LinkedIn |
| `developer` | GitHub, GitLab |

## Examples

### Shell — list all federated platforms

```bash
jq '[.[] | select(.federated == true) | .name]' platforms.json
```

### Shell — find platforms with ActivityPub

```bash
jq '[.[] | select(.protocol == "ActivityPub") | {name, url}]' platforms.json
```

### Shell — get brand colors

```bash
jq '.[] | "\(.name): \(.["brand-color"])"' platforms.json
```

### PHP — build platform CSS custom properties

```php
$platforms = json_decode(file_get_contents('platforms.json'), true);
foreach ($platforms as $p) {
    echo "--brand-{$p['slug']}: {$p['brand-color']};\n";
}
```

### JavaScript — filter by content type

```javascript
const platforms = await fetch('platforms.json').then(r => r.json());
const videoSupport = platforms.filter(p => p['content-types'].includes('video'));
console.log(videoSupport.map(p => p.name));
```
