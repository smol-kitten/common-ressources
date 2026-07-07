# Special-Use IP Address Blocks

The IANA-registered special-purpose IPv4 and IPv6 address blocks — private-use ranges (10/8, 172.16/12, 192.168/16), loopback (127/8, ::1), link-local (169.254/16, fe80::/10), shared CGN space (100.64/10), documentation/test ranges (TEST-NET-1/2/3, 2001:db8::/32), unique-local (fc00::/7), and more. Each entry records the block, its registered name, address family, defining RFC(s), and the routing properties IANA tracks (forwardable, globally reachable, reserved-by-protocol). Useful for IP validation, firewall/ACL tooling, network simulation, and teaching addressing.

## JSON

### Structure

```json
{
  "block": "10.0.0.0/8",
  "name": "Private-Use",
  "family": "IPv4",
  "rfcs": ["RFC 1918"],
  "forwardable": true,
  "globally_reachable": false,
  "reserved_by_protocol": false
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `block` | string | CIDR address block (normalised network address) |
| `name` | string | IANA-registered name for the block |
| `family` | string | `IPv4` or `IPv6` |
| `rfcs` | string[] | RFC(s) that define the block's special use |
| `forwardable` | boolean \| null | Whether a router may forward a datagram with a source address in this block; `null` if the registry lists N/A |
| `globally_reachable` | boolean \| null | Whether the block is reachable across the public Internet |
| `reserved_by_protocol` | boolean \| null | Whether the block is reserved by the protocol itself |

### Notes

- Values come directly from the IANA IPv4/IPv6 Special-Purpose Address Registries; the boolean properties mirror the registry columns. Where the registry gives a footnoted or N/A value, the field is `null`.
- This registry covers *special-purpose* blocks only. Ordinary multicast (224.0.0.0/4) and other assignments live in separate IANA registries and are not included here.

## Sources

- IANA — [IPv4 Special-Purpose Address Registry](https://www.iana.org/assignments/iana-ipv4-special-registry/) and [IPv6 Special-Purpose Address Registry](https://www.iana.org/assignments/iana-ipv6-special-registry/) (per RFC 6890).
