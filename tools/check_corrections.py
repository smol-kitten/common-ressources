#!/usr/bin/env python3
"""
check_corrections.py — verify that every correction logged in meta/corrections.json
is actually reflected in the data (and that no later edit silently reverted one).

For each correction {file, entry, field, new_value} it locates the record in `file`
and asserts the current value at `field` equals `new_value`. This keeps the
fact-check log honest: a regression (someone re-introduces the old value) or a
mis-logged correction becomes a hard CI failure instead of rotting silently.

Field syntax understood: "mass", "currency_code", "colors[1]" (array index).
Entry matching tolerates a trailing "(CODE)" qualifier, e.g. "Helium (He)",
"Bulgaria (BG)", "Indonesian Rupiah (IDR)".

Run:  python3 tools/check_corrections.py            # exit 1 on any mismatch
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
        return json.load(fh)


def entry_variants(entry):
    """Yield candidate identifiers for an entry label like 'Helium (He)'."""
    entry = entry.strip()
    yield entry
    m = re.match(r"^(.*?)\s*\(([^)]+)\)\s*$", entry)
    if m:
        yield m.group(1).strip()   # 'Helium'
        yield m.group(2).strip()   # 'He'


def find_record(data, entry):
    """Find the dict in a list (or the value in a map) matching `entry`."""
    cands = list(entry_variants(entry))
    if isinstance(data, list):
        for rec in data:
            if not isinstance(rec, dict):
                continue
            for key in ("name", "code", "symbol", "iso2", "iso3", "id", "entry"):
                if key in rec and str(rec[key]) in cands:
                    return rec
        # fall back: any string field exactly matching
        for rec in data:
            if isinstance(rec, dict) and any(str(v) in cands for v in rec.values()):
                return rec
    elif isinstance(data, dict):
        for c in cands:
            if c in data:
                return data[c]
    return None


def get_field(rec, field):
    """Resolve a field path against a record. Returns (found, value).

    Supports dotted nesting and array indices: 'mass', 'colors[1]',
    'pricing.input_mtok', 'a.b[2].c'.
    """
    cur = rec
    for seg in field.split("."):
        m = re.match(r"^([\w-]+)(\[(\d+)\])?$", seg)
        if not m:
            return False, None
        key = m.group(1)
        if not isinstance(cur, dict) or key not in cur:
            return False, None
        cur = cur[key]
        if m.group(3) is not None:
            idx = int(m.group(3))
            if not isinstance(cur, list) or idx >= len(cur):
                return False, None
            cur = cur[idx]
    return True, cur


def norm(v):
    return v.upper() if isinstance(v, str) else v


def main():
    m = load("meta/corrections.json")
    corrections = m.get("corrections", [])
    mismatches, unresolved, ok = [], [], 0

    for c in corrections:
        rel, entry, field = c.get("file"), c.get("entry"), c.get("field")
        new_value = c.get("new_value")
        if not (rel and entry and field):
            continue
        try:
            data = load(rel)
        except FileNotFoundError:
            unresolved.append((rel, entry, field, "file not found"))
            continue
        rec = find_record(data, entry)
        if rec is None:
            unresolved.append((rel, entry, field, "entry not found"))
            continue
        found, cur = get_field(rec, field)
        if not found:
            unresolved.append((rel, entry, field, "field not found"))
            continue
        if norm(cur) == norm(new_value):
            ok += 1
        else:
            mismatches.append((rel, entry, field, new_value, cur))

    print("=== check_corrections.py — fact-check log integrity ===")
    print(f"corrections: {len(corrections)}   verified applied: {ok}   "
          f"mismatch: {len(mismatches)}   unresolved: {len(unresolved)}\n")
    if mismatches:
        print("MISMATCHES (logged correction not reflected in data — regression?):")
        for rel, entry, field, want, cur in mismatches:
            print(f"  ✗ {rel} [{entry}].{field}: expected {want!r}, found {cur!r}")
    if unresolved:
        print("\nUNRESOLVED (could not locate — check entry/field label):")
        for rel, entry, field, why in unresolved:
            print(f"  ? {rel} [{entry}].{field}: {why}")
    if not mismatches and not unresolved:
        print("all logged corrections are correctly applied.")

    # Unresolved is a warning (label drift), mismatch is a hard error.
    sys.exit(1 if mismatches else 0)


if __name__ == "__main__":
    main()
