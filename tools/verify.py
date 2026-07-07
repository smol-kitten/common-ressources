#!/usr/bin/env python3
"""
verify.py — deterministic auto-verification for common-ressources datasets.

Goes beyond `validate.sh` (JSON syntax + presence of a few fields): this catches
*semantic* defects that would otherwise ship silently:

  - duplicate primary keys within a list (same country twice, same color name, ...)
  - malformed hex colors and hex/rgb mismatches
  - malformed ISO / code fields (iso2, iso3, currency codes, script codes, ...)
  - cross-file referential integrity (a country's currency_code must exist in the
    currencies dataset; a language's script should be a known ISO 15924 name; ...)
  - numeric sanity (unique ordinals, positive masses, offset formats, ...)

It is dependency-free (stdlib only), deterministic, and CI-friendly:
  exit 0 = clean, exit 1 = errors found. Use --warn-as-error to also fail on warnings.
  --json writes a machine-readable report to tools/reports/verify.json.

Usage:
  python3 tools/verify.py            # human report
  python3 tools/verify.py --json     # + machine report
  python3 tools/verify.py --warn-as-error
"""
import json
import os
import re
import sys
import glob
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ERRORS = []
WARNINGS = []
STATS = Counter()


def err(file, msg):
    ERRORS.append({"file": file, "level": "error", "msg": msg})


def warn(file, msg):
    WARNINGS.append({"file": file, "level": "warning", "msg": msg})


def load(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
        return json.load(fh)


def data_files():
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(f, ROOT)
        if rel.startswith(".git") or "node_modules" in rel:
            continue
        if rel.startswith("package") or rel.endswith("package-lock.json"):
            continue
        if rel.startswith("tools/reports"):
            continue
        out.append(rel)
    return out


HEX_RE = re.compile(r"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")
# Fields that MUST be globally unique within a dataset — a repeat is a real defect.
# Deliberately excludes name/symbol/code: the same glyph or code legitimately maps to
# multiple concepts (σ = Sigma & Stefan-Boltzmann; e = charge & Euler; a country code
# shared by several mirror rows), so those are not reliable primary keys.
STRICT_ID_FIELDS = ["id", "iso2", "iso3", "iana", "slug", "uuid"]
# Fields whose presence differentiates otherwise-similar rows (VOLUME instruction vs
# volume object) — used to suppress false duplicate reports.
DISCRIMINATORS = ["category", "type", "kind", "class", "group", "series"]


def hex_to_rgb(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) < 6:
        return None
    try:
        return [int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)]
    except ValueError:
        return None


def check_generic(rel, d):
    """Checks applied to every list-of-objects dataset."""
    if not isinstance(d, list) or not d or not all(isinstance(x, dict) for x in d):
        return
    STATS["list_datasets"] += 1

    # 1a. strict-ID duplicates — these fields must be unique; a repeat is a defect.
    for pk in STRICT_ID_FIELDS:
        if all(pk in x and x[pk] not in (None, "") for x in d):
            norm = [x[pk].lower() if isinstance(x[pk], str) else x[pk] for x in d]
            dups = [v for v, c in Counter(norm).items() if c > 1]
            if dups:
                err(rel, f"duplicate {pk!r}: {', '.join(map(str, sorted(map(str, dups))[:8]))}")

    # 1b. fully-identical rows — always a mistake regardless of schema.
    seen_rows = {}
    for i, x in enumerate(d):
        sig = json.dumps(x, sort_keys=True, ensure_ascii=False)
        if sig in seen_rows:
            err(rel, f"identical duplicate rows at index {seen_rows[sig]} and {i}")
        else:
            seen_rows[sig] = i

    # 1c. name/code near-unique collisions — WARN only, suppressed when a discriminator
    #     field (category/type/...) differs between the colliding rows.
    for pk in ("code", "name", "symbol"):
        if not all(pk in x and isinstance(x[pk], (str, int)) for x in d):
            continue
        by_val = defaultdict(list)
        for x in d:
            key = x[pk].lower() if isinstance(x[pk], str) else x[pk]
            by_val[key].append(x)
        distinct_ratio = len(by_val) / len(d)
        if distinct_ratio < 0.9:
            continue  # field is clearly not a key (many repeats by design)
        for val, rows in by_val.items():
            if len(rows) < 2:
                continue
            disc = next((f for f in DISCRIMINATORS if all(f in r for r in rows)), None)
            if disc and len({r[disc] for r in rows}) == len(rows):
                continue  # differentiated by category/type → legitimate
            warn(rel, f"repeated {pk!r} value {val!r} ({len(rows)}×) with no discriminator")
        break  # only report on the first usable key field

    # 2. hex color validity + hex/rgb agreement (any field whose value looks hex-ish)
    for i, x in enumerate(d):
        for k, v in x.items():
            if isinstance(v, str) and v.startswith("#") and len(v) in (4, 7, 9):
                if not HEX_RE.match(v):
                    err(rel, f"item {i} field {k!r}: malformed hex {v!r}")
        # rgb tuple should match a sibling hex field when both present
        if "hex" in x and "rgb" in x and isinstance(x["rgb"], list):
            expect = hex_to_rgb(x["hex"]) if isinstance(x["hex"], str) else None
            if expect and list(x["rgb"])[:3] != expect:
                pkid = next((x[f] for f in ("name", "id", "code") if f in x), i)
                err(rel, f"{pkid}: rgb {x['rgb']} != hex {x['hex']} ({expect})")


def check_colors_named():
    rel = "colors/named.json"
    d = load(rel)
    for c in d:
        rgb = hex_to_rgb(c["hex"])
        if rgb != c["rgb"]:
            err(rel, f"{c['name']}: rgb {c['rgb']} != hex {c['hex']}")
    STATS["cross_checks"] += 1


def check_countries_currencies():
    countries = load("geo/countries/countries.json")
    currencies = load("geo/currencies/currencies.json")
    known = {c["code"] for c in currencies}
    missing = set()
    for c in countries:
        code = c.get("currency_code")
        if not code:
            continue
        if not re.match(r"^[A-Z]{3}$", code):
            err("geo/countries/countries.json", f"{c['name']}: bad currency_code {code!r}")
        elif code not in known:
            missing.add(code)
    if missing:
        warn("geo/currencies/currencies.json",
             f"{len(missing)} currency codes referenced by countries.json are missing: "
             f"{', '.join(sorted(missing))}")
    # iso2/iso3 shape + uniqueness
    for field, length in (("iso2", 2), ("iso3", 3)):
        seen = Counter(c[field] for c in countries if c.get(field))
        for v, n in seen.items():
            if not re.match(rf"^[A-Z]{{{length}}}$", v):
                err("geo/countries/countries.json", f"bad {field} {v!r}")
            if n > 1:
                err("geo/countries/countries.json", f"duplicate {field} {v!r}")
    STATS["cross_checks"] += 1


def check_languages_scripts():
    langs = load("i18n/languages/languages.json")
    scripts = load("iso/15924/scripts.json")
    # ISO 15924 names carry parentheticals/aliases, e.g. "Bengali (Bangla)",
    # "Oriya (Odia)". Accept a language's script if it matches the leading name
    # OR appears as a whole alpha token anywhere in the canonical name.
    tokens = set()
    fullnames = []
    for s in scripts:
        name = s["name"].lower()
        fullnames.append(name)
        tokens.add(name)
        tokens.add(name.split(" (")[0].strip())
        for tok in re.findall(r"[a-z']{3,}", name):
            tokens.add(tok)
    for l in langs:
        sc = l.get("script")
        if not sc:
            continue
        scl = sc.lower()
        if scl not in tokens and not any(scl in fn for fn in fullnames):
            warn("i18n/languages/languages.json",
                 f"{l['name']}: script {sc!r} not a known ISO 15924 name")
    STATS["cross_checks"] += 1


def check_timezones():
    tz = load("geo/timezones/timezones.json")
    off = re.compile(r"^[+-]\d{2}:\d{2}$")
    for t in tz:
        for f in ("utc_offset", "dst_offset"):
            if f in t and not off.match(str(t[f])):
                err("geo/timezones/timezones.json", f"{t.get('iana')}: bad {f} {t[f]!r}")
    STATS["cross_checks"] += 1


def check_elements():
    el = load("science/elements/elements.json")
    nums = [e["number"] for e in el]
    if sorted(nums) != list(range(1, len(el) + 1)):
        err("science/elements/elements.json", "atomic numbers not contiguous 1..N")
    for e in el:
        if e.get("mass", 0) <= 0:
            err("science/elements/elements.json", f"{e['symbol']}: non-positive mass")
    STATS["cross_checks"] += 1


def check_planets():
    p = load("space/planets/planets.json")
    orders = [x["order"] for x in p if "order" in x]
    if len(orders) != len(set(orders)):
        err("space/planets/planets.json", "duplicate 'order' values")
    STATS["cross_checks"] += 1


def check_http_status():
    for rel in ("net/http-status-codes/http-status-codes.json",
                "web/http/status-codes.json"):
        if not os.path.exists(os.path.join(ROOT, rel)):
            continue
        d = load(rel)
        for x in d:
            code = x.get("code")
            if code is not None and not (100 <= int(code) <= 599):
                err(rel, f"status code out of range: {code}")
    STATS["cross_checks"] += 1


def check_geo_crossref():
    """iso2 references in airports/cities/currencies must exist in countries.json."""
    countries = load("geo/countries/countries.json")
    iso2 = {c["iso2"] for c in countries if c.get("iso2")}
    # currencies.country_code → countries.iso2 (skip regional None / EU / IMF)
    for c in load("geo/currencies/currencies.json"):
        cc = c.get("country_code")
        if cc and cc not in iso2 and cc not in ("EU",):
            warn("geo/currencies/currencies.json",
                 f"{c['code']}: country_code {cc} not in countries.json")
    # airports.country_iso2
    try:
        for a in load("geo/airports/airports.json"):
            cc = a.get("country_iso2")
            if cc and cc not in iso2:
                warn("geo/airports/airports.json", f"{a.get('iata')}: country_iso2 {cc} unknown")
            for f, lo, hi in (("lat", -90, 90), ("lon", -180, 180)):
                if f in a and not (lo <= a[f] <= hi):
                    err("geo/airports/airports.json", f"{a.get('iata')}: {f} out of range: {a[f]}")
            if a.get("iata") and not re.match(r"^[A-Z]{3}$", a["iata"]):
                err("geo/airports/airports.json", f"bad IATA code {a['iata']!r}")
            if a.get("icao") and not re.match(r"^[A-Z]{4}$", a["icao"]):
                err("geo/airports/airports.json", f"bad ICAO code {a['icao']!r}")
    except FileNotFoundError:
        pass
    # cities.country (iso2)
    try:
        for c in load("geo/cities/cities.json"):
            cc = c.get("country")
            if cc and cc not in iso2:
                warn("geo/cities/cities.json", f"{c.get('name')}: country {cc} not in countries.json")
            for f, lo, hi in (("lat", -90, 90), ("lng", -180, 180)):
                if f in c and not (lo <= c[f] <= hi):
                    err("geo/cities/cities.json", f"{c.get('name')}: {f} out of range: {c[f]}")
    except FileNotFoundError:
        pass
    STATS["cross_checks"] += 1


def check_formats():
    """Regex / range sanity on well-specified code fields."""
    try:
        for c in load("geo/countries/countries.json"):
            dc = c.get("dial_code")
            if dc and not re.match(r"^\+\d{1,4}(-\d+)?$", str(dc)):
                warn("geo/countries/countries.json", f"{c['name']}: unusual dial_code {dc!r}")
    except FileNotFoundError:
        pass
    try:
        for l in load("i18n/languages/languages.json"):
            if l.get("iso639_1") and not re.match(r"^[a-z]{2}$", l["iso639_1"]):
                err("i18n/languages/languages.json", f"bad iso639_1 {l['iso639_1']!r}")
            if l.get("iso639_2") and not re.match(r"^[a-z]{3}$", l["iso639_2"]):
                err("i18n/languages/languages.json", f"bad iso639_2 {l['iso639_2']!r}")
            if l.get("direction") not in (None, "ltr", "rtl"):
                err("i18n/languages/languages.json", f"bad direction {l['direction']!r}")
    except FileNotFoundError:
        pass
    try:
        for c in load("geo/currencies/currencies.json"):
            if not (0 <= c.get("decimals", 0) <= 4):
                err("geo/currencies/currencies.json", f"{c['code']}: decimals out of range")
    except FileNotFoundError:
        pass
    try:
        for p in load("net/ports/ports.json"):
            port = p.get("port")
            if port is not None and not (0 <= int(port) <= 65535):
                err("net/ports/ports.json", f"port out of range: {port}")
    except FileNotFoundError:
        pass
    STATS["cross_checks"] += 1


def main():
    argv = sys.argv[1:]
    want_json = "--json" in argv
    warn_as_error = "--warn-as-error" in argv

    # generic pass
    parsed = 0
    for rel in data_files():
        try:
            d = load(rel)
        except Exception as e:  # noqa
            err(rel, f"JSON parse error: {e}")
            continue
        parsed += 1
        check_generic(rel, d)
    STATS["files_parsed"] = parsed

    # targeted cross-file checks (guarded so a missing file never crashes the run)
    for fn in (check_colors_named, check_countries_currencies, check_languages_scripts,
               check_timezones, check_elements, check_planets, check_http_status,
               check_geo_crossref, check_formats):
        try:
            fn()
        except FileNotFoundError:
            pass
        except Exception as e:  # noqa
            err(fn.__name__, f"checker crashed: {e}")

    # report
    print("=== verify.py — semantic verification ===")
    print(f"files parsed: {STATS['files_parsed']}   "
          f"list datasets: {STATS['list_datasets']}   "
          f"cross-checks: {STATS['cross_checks']}")
    print()
    if ERRORS:
        print(f"ERRORS ({len(ERRORS)}):")
        for e in ERRORS:
            print(f"  ✗ {e['file']}: {e['msg']}")
    if WARNINGS:
        print(f"\nWARNINGS ({len(WARNINGS)}):")
        for w in WARNINGS:
            print(f"  ! {w['file']}: {w['msg']}")
    if not ERRORS and not WARNINGS:
        print("clean — no semantic issues found.")

    if want_json:
        os.makedirs(os.path.join(ROOT, "tools", "reports"), exist_ok=True)
        rep = {
            "stats": dict(STATS),
            "errors": ERRORS,
            "warnings": WARNINGS,
        }
        with open(os.path.join(ROOT, "tools", "reports", "verify.json"), "w") as fh:
            json.dump(rep, fh, indent=2, ensure_ascii=False)
        print("\nwrote tools/reports/verify.json")

    rc = 1 if ERRORS or (warn_as_error and WARNINGS) else 0
    sys.exit(rc)


if __name__ == "__main__":
    main()
