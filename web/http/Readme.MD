# HTTP Resources

A collection of structured JSON references for the HTTP protocol — status codes, request methods, and common headers.

## Files

| File | Description |
|---|---|
| [`status-codes.json`](status-codes.json) | HTTP response status codes with names, descriptions, and categories |
| [`methods.json`](methods.json) | HTTP request methods with safety, idempotency, and cacheability flags |
| [`headers.json`](headers.json) | Common HTTP request and response headers |

---

## status-codes.json

### Structure as of 23.05.2026

```json
{
  "code": 200,
  "name": "OK",
  "description": "The request has succeeded.",
  "category": "success",
  "cacheable": true,
  "source": "RFC 9110"
}
```

### Categories

| Category | Range | Meaning |
|---|---|---|
| `informational` | 1xx | Request received, processing continues |
| `success` | 2xx | Request successfully received, understood, and accepted |
| `redirection` | 3xx | Further action needs to be taken to complete the request |
| `client-error` | 4xx | Request contains bad syntax or cannot be fulfilled |
| `server-error` | 5xx | Server failed to fulfill an apparently valid request |

---

## methods.json

### Structure as of 23.05.2026

```json
{
  "method": "GET",
  "safe": true,
  "idempotent": true,
  "cacheable": true,
  "request-body": "not allowed",
  "response-body": "yes",
  "description": "Requests a representation of the specified resource.",
  "source": "RFC 9110"
}
```

### Fields

- **`safe`** — A method is safe if it does not modify server state (GET, HEAD, OPTIONS, TRACE).
- **`idempotent`** — A method is idempotent if calling it multiple times has the same effect as calling it once.
- **`cacheable`** — Whether responses to this method may be stored by a cache.
- **`request-body`** — Whether the method allows a request body (`yes`, `no`, `optional`, `may`, `not allowed`).

---

## headers.json

### Structure as of 23.05.2026

```json
{
  "name": "Content-Type",
  "direction": "both",
  "category": "representation",
  "description": "Indicates the media type of the resource.",
  "example": "Content-Type: application/json; charset=utf-8",
  "source": "RFC 9110"
}
```

### Fields

- **`direction`** — `request` (sent by client), `response` (sent by server), or `both`.
- **`category`** — Functional grouping: `authentication`, `caching`, `content-negotiation`, `cookies`, `cors`, `representation`, `routing`, `security`, `rate-limiting`, `server-info`, `client-info`.

---

## Examples

### Find all 4xx status codes (shell)

```bash
jq '[.[] | select(.category == "client-error")]' status-codes.json
```

### Find safe HTTP methods (shell)

```bash
jq '[.[] | select(.safe == true) | .method]' methods.json
```

### Find security-related response headers (shell)

```bash
jq '[.[] | select(.category == "security" and .direction != "request") | .name]' headers.json
```

### PHP — look up a status code

```php
$codes = json_decode(file_get_contents('status-codes.json'), true);
$lookup = array_column($codes, null, 'code');
echo $lookup[404]['name']; // "Not Found"
```
