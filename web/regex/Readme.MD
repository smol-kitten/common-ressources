# Regex Validation Patterns

A structured JSON reference of common regular expression patterns for validating input in web applications — covering contact details, URLs, dates, identifiers, numbers, and security tokens.

## JSON

### Structure as of 23.05.2026

```json
{
  "name": "Email Address",
  "slug": "email",
  "pattern": "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$",
  "flags": "",
  "description": "Validates a standard email address format.",
  "example-valid": ["user@example.com", "firstname.lastname@domain.co.uk"],
  "example-invalid": ["user@", "@domain.com"],
  "category": "contact",
  "notes": "Does not perform DNS lookup or mailbox verification.",
  "source": "RFC 5321"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable name of the pattern |
| `slug` | string | URL-friendly identifier for programmatic lookup |
| `pattern` | string | Regex pattern without delimiters — add your language's delimiter syntax when compiling |
| `flags` | string | Suggested regex flags (e.g. `"i"` for case-insensitive, `"m"` for multiline). Empty string means no flags |
| `description` | string | What the pattern validates and how |
| `example-valid` | string[] | Sample strings that should match |
| `example-invalid` | string[] | Sample strings that should not match |
| `category` | string | Thematic category (see below) |
| `notes` | string | Caveats, edge cases, and recommendations |
| `source` | string \| null | Authoritative standard or specification, if applicable |

### Categories

| Category | Description |
|---|---|
| `contact` | Contact information — email, phone, postal codes |
| `url` | Web addresses and URL components |
| `date` | Date and datetime strings |
| `identity` | Identifiers — IP addresses, UUIDs, usernames |
| `number` | Numeric formats — credit cards, version numbers |
| `text` | General text formats — slugs, headings, markup |
| `security` | Security-sensitive patterns — passwords, tokens |

## Patterns included

| Slug | Name | Category |
|---|---|---|
| `email` | Email Address | contact |
| `url` | URL (HTTP/HTTPS) | url |
| `ipv4` | IPv4 Address | identity |
| `ipv6` | IPv6 Address | identity |
| `phone-e164` | Phone Number (E.164) | contact |
| `date-iso` | Date (ISO 8601) | date |
| `datetime-iso` | Datetime (ISO 8601) | date |
| `hex-color` | Hex Color Code | text |
| `uuid` | UUID (v1–v5) | identity |
| `slug` | URL Slug | url |
| `username` | Username | identity |
| `password-strong` | Strong Password | security |
| `credit-card-luhn` | Credit Card Number (Luhn) | number |
| `postal-code-de` | German Postal Code | contact |
| `postal-code-us` | US ZIP Code | contact |
| `semantic-version` | Semantic Version | text |
| `jwt` | JSON Web Token (JWT) | security |
| `markdown-heading` | Markdown Heading | text |
| `html-tag` | HTML Tag | text |
| `base64` | Base64 String | security |

## Important notes on regex and validation

- **Regex is not a silver bullet.** For complex inputs (HTML, URLs, email), always prefer a dedicated parsing library in production.
- **The `pattern` field contains no delimiters.** Add the appropriate delimiter for your language (e.g. `/` in JavaScript, `~` or `#` in PHP).
- **Flags are suggestions.** Always read the `flags` field and apply the recommended flags when compiling the pattern.
- **Read the `notes` field.** Many patterns have important caveats about what they do not validate.

## Examples

### JavaScript — compile and test a pattern

```javascript
const patterns = await fetch('patterns.json').then(r => r.json());

// Build a lookup map by slug
const bySlug = Object.fromEntries(patterns.map(p => [p.slug, p]));

function validate(slug, value) {
  const entry = bySlug[slug];
  if (!entry) throw new Error(`Unknown pattern: ${slug}`);
  const regex = new RegExp(entry.pattern, entry.flags);
  return regex.test(value);
}

console.log(validate('email', 'user@example.com')); // true
console.log(validate('email', 'not-an-email'));      // false
console.log(validate('uuid', '550e8400-e29b-41d4-a716-446655440000')); // true
```

### JavaScript — validate a form field

```javascript
const patterns = await fetch('patterns.json').then(r => r.json());
const bySlug = Object.fromEntries(patterns.map(p => [p.slug, p]));

function getValidator(slug) {
  const { pattern, flags } = bySlug[slug];
  return new RegExp(pattern, flags);
}

const emailRegex = getValidator('email');
const phoneRegex = getValidator('phone-e164');

document.getElementById('email').addEventListener('input', e => {
  const valid = emailRegex.test(e.target.value);
  e.target.setCustomValidity(valid ? '' : 'Please enter a valid email address.');
});
```

### PHP — compile and test a pattern

```php
$patterns = json_decode(file_get_contents('patterns.json'), true);

// Build a lookup map by slug
$bySlug = array_column($patterns, null, 'slug');

function validate(string $slug, string $value, array $bySlug): bool {
    $entry = $bySlug[$slug] ?? null;
    if (!$entry) {
        throw new \InvalidArgumentException("Unknown pattern: $slug");
    }
    $flags = $entry['flags'];
    $delimiter = '~';
    $regex = $delimiter . $entry['pattern'] . $delimiter . $flags;
    return (bool) preg_match($regex, $value);
}

var_dump(validate('email', 'user@example.com', $bySlug)); // bool(true)
var_dump(validate('email', 'not-an-email', $bySlug));     // bool(false)
var_dump(validate('ipv4', '192.168.1.1', $bySlug));       // bool(true)
```

### PHP — validate multiple fields at once

```php
$patterns = json_decode(file_get_contents('patterns.json'), true);
$bySlug = array_column($patterns, null, 'slug');

$fields = [
    'email'    => 'user@example.com',
    'phone-e164' => '+14155552671',
    'uuid'     => '550e8400-e29b-41d4-a716-446655440000',
];

$errors = [];
foreach ($fields as $slug => $value) {
    $entry = $bySlug[$slug];
    $regex = '~' . $entry['pattern'] . '~' . $entry['flags'];
    if (!preg_match($regex, $value)) {
        $errors[$slug] = "Invalid {$entry['name']}";
    }
}
print_r($errors); // []
```

### Shell — list all patterns in a category

```bash
jq '[.[] | select(.category == "security") | {slug: .slug, name: .name}]' patterns.json
```

### Shell — test a value against a pattern (using grep)

```bash
slug="email"
value="user@example.com"
pattern=$(jq -r --arg slug "$slug" '.[] | select(.slug == $slug) | .pattern' patterns.json)
echo "$value" | grep -Pq "^${pattern}$" && echo "valid" || echo "invalid"
```
