# PowerShell Snippets

A structured JSON reference for useful PowerShell one-liners and short functions. Covers system information, file operations, networking, process management, the registry, WSL, and winget.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Get Public IP Address",
  "slug": "get-public-ip",
  "description": "Fetches the machine's public IP address via a web service.",
  "code": "(Invoke-WebRequest -Uri 'https://api.ipify.org').Content",
  "category": "network",
  "min-version": "5.1",
  "tags": ["network", "ip", "internet"],
  "example-output": "203.0.113.42"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable snippet name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `description` | string | What the snippet does |
| `code` | string | The PowerShell code to execute |
| `category` | string | Functional category (see below) |
| `min-version` | string | Minimum PowerShell version required |
| `tags` | string[] | Keywords for filtering and discovery |
| `example-output` | string | Example of what the snippet outputs (\\n for newlines) |

### Categories

| Category | Description |
|---|---|
| `system-info` | Hardware, OS, and environment information |
| `file-ops` | File system operations (copy, find, symlinks) |
| `network` | Network diagnostics, connectivity, and ports |
| `process` | Process and service management |
| `registry` | Windows Registry read/write operations |
| `wsl` | Windows Subsystem for Linux management |
| `winget` | Package management via winget |

## Snippets included

| Slug | Name | Category |
|---|---|---|
| `get-system-info` | Get System Info | system-info |
| `get-public-ip` | Get Public IP Address | network |
| `get-local-ip` | Get Local IP Addresses | network |
| `test-connectivity` | Test Network Connectivity | network |
| `download-file` | Download File | file-ops |
| `find-large-files` | Find Large Files | file-ops |
| `get-disk-usage` | Get Disk Usage | system-info |
| `list-running-services` | List Running Services | process |
| `kill-process-by-name` | Kill Process by Name | process |
| `top-cpu-processes` | Get Top CPU Processes | process |
| `get-installed-programs` | Get Installed Programs | registry |
| `read-registry-value` | Read Registry Value | registry |
| `set-registry-value` | Set Registry Value | registry |
| `list-wsl-distros` | List WSL Distros | wsl |
| `export-wsl-distro` | Export WSL Distro | wsl |
| `winget-install` | Install winget Package | winget |
| `winget-upgrade-all` | Update All winget Packages | winget |
| `get-open-ports` | Get Open Network Ports | network |
| `get-event-log-errors` | Get Event Log Errors | system-info |
| `create-symlink` | Create Symbolic Link | file-ops |

## Examples

### Shell — list all network snippets

```bash
jq '[.[] | select(.category == "network") | {slug, name}]' snippets.json
```

### Shell — get code for a specific snippet

```bash
jq -r '.[] | select(.slug == "get-public-ip") | .code' snippets.json
```

### JavaScript — run a snippet lookup by slug

```javascript
const snippets = await fetch('snippets.json').then(r => r.json());
const bySlug = Object.fromEntries(snippets.map(s => [s.slug, s]));

const snippet = bySlug['find-large-files'];
console.log(snippet.code);
// "Get-ChildItem -Path 'C:\\' ..."
```

### JavaScript — filter by category and version

```javascript
const snippets = await fetch('snippets.json').then(r => r.json());
const fileOps = snippets.filter(s => s.category === 'file-ops');
console.log(fileOps.map(s => s.name));
// ["Download File", "Find Large Files", "Create Symbolic Link"]
```

### PHP — display snippets grouped by category

```php
$snippets = json_decode(file_get_contents('snippets.json'), true);
$byCategory = [];
foreach ($snippets as $s) {
    $byCategory[$s['category']][] = $s;
}
foreach ($byCategory as $cat => $group) {
    echo "$cat:\n";
    foreach ($group as $s) {
        echo "  [{$s['slug']}] {$s['name']}\n";
    }
}
```
