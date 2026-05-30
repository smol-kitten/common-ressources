# Well-Known Network Ports

A structured reference for 42 well-known TCP/UDP port assignments. Covers system ports (0–1023) and a selection of registered/high ports for popular databases and services. Useful for firewall rule documentation, network tooling, educational references, and port-scanning result enrichment.

## JSON

### Structure as of 24.05.2026

```json
{
  "port": 443,
  "protocol": "TCP",
  "service": "HTTPS",
  "description": "HTTP over TLS — encrypted web traffic"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `port` | number | Port number |
| `protocol` | string | Transport protocol: `TCP`, `UDP`, or `TCP/UDP` |
| `service` | string | Service or application name |
| `description` | string | Brief description of the service |

## Entries

| Port | Protocol | Service | Description |
|---|---|---|---|
| 20 | TCP | FTP Data | File transfer data channel |
| 21 | TCP | FTP Control | File transfer command channel |
| 22 | TCP | SSH | Secure Shell |
| 23 | TCP | Telnet | Unencrypted remote login (deprecated) |
| 25 | TCP | SMTP | Server-to-server email |
| 53 | TCP/UDP | DNS | Domain Name System |
| 67 | UDP | DHCP Server | DHCP server |
| 68 | UDP | DHCP Client | DHCP client |
| 69 | UDP | TFTP | Trivial File Transfer (PXE) |
| 80 | TCP | HTTP | Unencrypted web traffic |
| 110 | TCP | POP3 | Email retrieval |
| 123 | UDP | NTP | Clock synchronization |
| 143 | TCP | IMAP | Email retrieval |
| 161 | UDP | SNMP | Network management polling |
| 162 | UDP | SNMP Trap | Network management traps |
| 194 | TCP | IRC | Internet Relay Chat |
| 389 | TCP/UDP | LDAP | Directory access |
| 443 | TCP | HTTPS | Encrypted web traffic |
| 445 | TCP | SMB | Windows file sharing |
| 465 | TCP | SMTPS | Secure SMTP (implicit TLS) |
| 514 | UDP | Syslog | System log messages |
| 587 | TCP | SMTP Submission | Email client submission |
| 636 | TCP | LDAPS | Secure directory access |
| 993 | TCP | IMAPS | Secure email retrieval |
| 995 | TCP | POP3S | Secure email retrieval |
| 1194 | UDP | OpenVPN | OpenVPN default |
| 1433 | TCP | MSSQL | Microsoft SQL Server |
| 1521 | TCP | Oracle DB | Oracle Database |
| 2049 | TCP/UDP | NFS | Network File System |
| 3306 | TCP | MySQL | MySQL / MariaDB |
| 3389 | TCP | RDP | Windows Remote Desktop |
| 5432 | TCP | PostgreSQL | PostgreSQL |
| 5900 | TCP | VNC | Remote desktop (VNC) |
| 6379 | TCP | Redis | Redis data store |
| 6443 | TCP | Kubernetes API | Kubernetes API server |
| 6881 | TCP/UDP | BitTorrent | Peer-to-peer file sharing |
| 8080 | TCP | HTTP Alt | Alternate HTTP / dev server |
| 8443 | TCP | HTTPS Alt | Alternate HTTPS |
| 9200 | TCP | Elasticsearch | Elasticsearch REST API |
| 9418 | TCP | Git | Git protocol |
| 27017 | TCP | MongoDB | MongoDB database |
| 51820 | UDP | WireGuard | WireGuard VPN |

## Examples

### Shell — list all TCP-only ports

```bash
jq '[.[] | select(.protocol == "TCP") | {port, service}]' ports.json
```

### Shell — look up a service name for port 443

```bash
jq '.[] | select(.port == 443) | .service' ports.json
```

### JavaScript — check if a port number is in the well-known list

```javascript
const ports = await fetch('ports.json').then(r => r.json());
const byPort = Object.fromEntries(ports.map(p => [p.port, p]));

function lookupPort(num) {
  return byPort[num] ?? { service: 'Unknown', description: 'Not in well-known list' };
}

console.log(lookupPort(22).service);   // "SSH"
console.log(lookupPort(9999).service); // "Unknown"
```

### PHP — generate a firewall allow-list comment block

```php
$ports = json_decode(file_get_contents('ports.json'), true);
$tcp = array_filter($ports, fn($p) => str_contains($p['protocol'], 'TCP'));

foreach ($tcp as $p) {
    printf("# %-6d %-12s %s\n", $p['port'], $p['service'], $p['description']);
}
```
