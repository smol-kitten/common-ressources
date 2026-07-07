#!/usr/bin/env python3
"""
gap.py — coverage & completeness gap analysis for common-ressources.

Three complementary views, all dependency-free and deterministic:

  1. CARDINALITY  — compares each dataset's entry count against a curated table of
     canonical "complete" sizes (118 elements, 88 IAU constellations, 148 CSS named
     colors, ~180 active ISO 4217 currencies, ...). Flags datasets that are notably
     short of a well-defined universe.

  2. FIELD FILL   — per dataset, which optional fields are sparsely populated
     (present on some rows, empty/missing on others). Surfaces low-effort enrichment
     targets without treating optional fields as errors.

  3. CROSS-REF    — values referenced across files that have no backing entry
     (currency codes in countries.json absent from currencies.json, etc.).

Usage:
  python3 tools/gap.py                 # human report, all views
  python3 tools/gap.py --json          # + tools/reports/gap.json
  python3 tools/gap.py --top 20        # limit field-fill rows
"""
import json
import os
import sys
import glob
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
        return json.load(fh)


def count(rel):
    d = load(rel)
    return len(d) if isinstance(d, (list, dict)) else 0


# Curated canonical universe sizes. `target` is the size of the complete set;
# `note` cites what defines it. Only include sets with a well-defined universe.
CARDINALITY = {
    "science/elements/elements.json":            (118, "confirmed elements Z=1..118 (IUPAC)"),
    "astronomy/constellations/constellations.json": (88, "88 IAU-recognised constellations"),
    "colors/named.json":                         (148, "CSS Color Module named colors"),
    "space/planets/planets.json":                (8,   "8 IAU planets (dwarf planets separate)"),
    "space/dwarf-planets/dwarf-planets.json":    (5,   "5 IAU-recognised dwarf planets"),
    "bio/amino-acids/amino-acids.json":          (20,  "20 standard proteinogenic amino acids"),
    "bio/codon-table/codon-table.json":          (64,  "64 codons of the standard genetic code"),
    "science/si-prefixes/si-prefixes.json":      (24,  "24 BIPM SI prefixes (quetta..quecto)"),
    "unicode/blocks/blocks.json":                (346, "all Unicode 17.0 blocks"),
    "networking/special-use-ips/special-use-ips.json": (49, "IANA IPv4+IPv6 special-purpose blocks"),
    "science/si-base-units/si-base-units.json":  (7,   "7 SI base units"),
    "science/si-derived-units/si-derived-units.json": (22, "22 SI derived units with special names"),
    "geo/countries/countries.json":              (195, "193 UN members + 2 observers"),
    "geo/currencies/currencies.json":            (159, "circulating ISO 4217 currencies (excl. XAU/XAG precious-metal & fund codes)"),
    "iso/15924/scripts.json":                    (226, "all ISO 15924 codes incl. aliases, special & reserved"),
    "i18n/languages/languages.json":             (184, "184 ISO 639-1 assigned codes"),
    "security/owasp-top10/owasp-top10.json":     (10,  "OWASP Top 10 categories"),
    "iso/216/paper-sizes.json":                  (3,   "A/B/C series"),
    "web/http/methods.json":                     (9,   "9 standard HTTP methods (RFC 9110/5789)"),
    "net/ports/ports.json":                      (0,   "open-ended (well-known + registered)"),
}


def view_cardinality():
    rows = []
    for rel, (target, note) in CARDINALITY.items():
        if not os.path.exists(os.path.join(ROOT, rel)):
            rows.append((rel, None, target, note, "MISSING FILE"))
            continue
        n = count(rel)
        if target == 0:
            status = "open"
        elif n >= target:
            status = "complete" if n == target else f"+{n - target} extra"
        else:
            pct = 100 * n / target
            status = f"{n}/{target} ({pct:.0f}%)  SHORT {target - n}"
        rows.append((rel, n, target, note, status))
    return rows


def view_field_fill(top=None):
    """Per list-dataset, optional fields that are sparsely populated."""
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(f, ROOT)
        if rel.startswith((".git", "tools/reports")) or "node_modules" in rel:
            continue
        if rel.startswith("package"):
            continue
        try:
            d = load(rel)
        except Exception:
            continue
        if not isinstance(d, list) or not d or not all(isinstance(x, dict) for x in d):
            continue
        keys = set().union(*(x.keys() for x in d))
        sparse = []
        for k in sorted(keys):
            filled = sum(1 for x in d if x.get(k) not in (None, "", [], {}))
            if 0 < filled < len(d):
                sparse.append((k, filled, len(d)))
        if sparse:
            out.append((rel, sparse))
    out.sort(key=lambda r: sum((t - f) for _, f, t in r[1]), reverse=True)
    if top:
        out = out[:top]
    return out


def view_crossref():
    findings = []
    # country → currency
    try:
        countries = load("geo/countries/countries.json")
        known = {c["code"] for c in load("geo/currencies/currencies.json")}
        miss = sorted({c["currency_code"] for c in countries
                       if c.get("currency_code") and c["currency_code"] not in known})
        if miss:
            findings.append(("geo/currencies/currencies.json",
                             f"{len(miss)} currency codes used by countries but absent",
                             miss))
    except FileNotFoundError:
        pass
    # language → script (tokenised: ISO 15924 names carry parenthetical aliases)
    try:
        import re as _re
        langs = load("i18n/languages/languages.json")
        tokens = set()
        fullnames = []
        for s in load("iso/15924/scripts.json"):
            nm = s["name"].lower()
            fullnames.append(nm)
            tokens.add(nm)
            tokens.add(nm.split(" (")[0].strip())
            tokens.update(_re.findall(r"[a-z']{3,}", nm))
        miss = sorted({l["script"] for l in langs
                       if l.get("script") and l["script"].lower() not in tokens
                       and not any(l["script"].lower() in fn for fn in fullnames)})
        if miss:
            findings.append(("iso/15924/scripts.json",
                             f"{len(miss)} script names used by languages but absent",
                             miss))
    except FileNotFoundError:
        pass
    return findings


def main():
    argv = sys.argv[1:]
    want_json = "--json" in argv
    top = None
    if "--top" in argv:
        top = int(argv[argv.index("--top") + 1])

    card = view_cardinality()
    fill = view_field_fill(top)
    cross = view_crossref()

    print("=== gap.py — coverage & completeness ===\n")
    print("── 1. CARDINALITY vs canonical universe ──")
    short = 0
    for rel, n, target, note, status in card:
        flag = "  " if status in ("complete", "open") or "extra" in status else "⚠ "
        if flag == "⚠ ":
            short += 1
        print(f"{flag}{rel:46} {str(n):>4}  {status:20} {note}")
    print(f"\n  {short} dataset(s) short of their canonical universe.\n")

    print("── 2. FIELD FILL (sparsely-populated optional fields) ──")
    for rel, sparse in fill:
        gaps = ", ".join(f"{k} {f}/{t}" for k, f, t in sorted(sparse, key=lambda s: s[1] - s[2])[:6])
        print(f"  {rel}")
        print(f"      {gaps}")
    print(f"\n  {len(fill)} dataset(s) with enrichable fields.\n")

    print("── 3. CROSS-REF gaps ──")
    if not cross:
        print("  none")
    for rel, msg, items in cross:
        print(f"  {rel}: {msg}")
        print(f"      {', '.join(items)}")

    if want_json:
        os.makedirs(os.path.join(ROOT, "tools", "reports"), exist_ok=True)
        rep = {
            "cardinality": [
                {"file": rel, "count": n, "target": target, "note": note, "status": status}
                for rel, n, target, note, status in card
            ],
            "field_fill": [
                {"file": rel, "sparse": [{"field": k, "filled": f, "total": t}
                                         for k, f, t in sparse]}
                for rel, sparse in fill
            ],
            "crossref": [{"file": rel, "message": msg, "items": items}
                         for rel, msg, items in cross],
        }
        with open(os.path.join(ROOT, "tools", "reports", "gap.json"), "w") as fh:
            json.dump(rep, fh, indent=2, ensure_ascii=False)
        print("\nwrote tools/reports/gap.json")


if __name__ == "__main__":
    main()
