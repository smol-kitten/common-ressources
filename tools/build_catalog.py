#!/usr/bin/env python3
"""
build_catalog.py — generate meta/catalog.json: a machine-readable index of every
dataset in the repo (path, category, entry count, top-level fields, description,
provenance flag). One file a consumer can fetch to discover everything available,
and the source of truth for entry counts shown elsewhere.

Deterministic, stdlib-only. Descriptions are lifted from the nearest Readme's first
prose paragraph so they track the human docs.

Run:  python3 tools/build_catalog.py            # writes meta/catalog.json
      python3 tools/build_catalog.py --check    # exit 1 if it would change (CI)
"""
import json
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP_DIRS = (".git", "node_modules", "tests", ".github", ".gitea", ".claude", "tools/reports")
# files that are config/export rather than reference datasets
SKIP_FILES = {"package.json", "package-lock.json", "playwright.config.js"}
# generated artefacts (not hand-authored reference datasets)
SKIP_RELS = {"meta/catalog.json", "meta/sources.json"}


def is_data(rel):
    if any(rel.startswith(d) or f"/{d}/" in rel for d in SKIP_DIRS):
        return False
    if os.path.basename(rel) in SKIP_FILES or rel in SKIP_RELS:
        return False
    return rel.endswith(".json")


def nearest_readme(rel):
    d = os.path.dirname(rel)
    while True:
        for cand in ("Readme.MD", "README.md", "readme.md", "Readme.md", "README.MD"):
            p = os.path.join(ROOT, d, cand)
            if os.path.exists(p):
                return os.path.relpath(p, ROOT)
        if not d:
            return None
        d = os.path.dirname(d)


def first_paragraph(readme_rel):
    if not readme_rel:
        return None
    txt = open(os.path.join(ROOT, readme_rel), encoding="utf-8").read()
    for block in re.split(r"\n\s*\n", txt):
        block = block.strip()
        if not block or block.startswith(("#", ">", "|", "```", "-", "*")):
            continue
        # collapse whitespace, trim to a sentence-ish length
        block = re.sub(r"\s+", " ", block)
        return block[:280]
    return None


def describe(d):
    """Return (kind, count, fields) for a dataset payload."""
    if isinstance(d, list):
        fields = sorted(set().union(*[x.keys() for x in d if isinstance(x, dict)])) \
            if d and all(isinstance(x, dict) for x in d) else []
        return "list", len(d), fields
    if isinstance(d, dict):
        # wrapper-with-array (e.g. {"standards": [...]}) → count the array
        arr = next((v for v in d.values() if isinstance(v, list)), None)
        if arr is not None:
            return "wrapped-list", len(arr), sorted(d.keys())
        return "map", len(d), sorted(d.keys())
    return type(d).__name__, 0, []


def has_source(d):
    if isinstance(d, dict):
        return any(k in d for k in ("source", "sources", "meta", "_note")) or \
            any(isinstance(v, dict) and ("source" in v) for v in d.values())
    if isinstance(d, list):
        return any(isinstance(x, dict) and any(k in x for k in ("source", "sources", "rfc", "ref"))
                   for x in d)
    return False


def build():
    datasets = []
    for f in sorted(glob.glob(os.path.join(ROOT, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(f, ROOT)
        if not is_data(rel):
            continue
        try:
            d = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        kind, count, fields = describe(d)
        category = rel.split("/")[0]
        readme = nearest_readme(rel)
        datasets.append({
            "path": rel,
            "category": category,
            "kind": kind,
            "count": count,
            "fields": fields,
            "has_source": has_source(d),
            "readme": readme,
            "description": first_paragraph(readme),
        })

    categories = {}
    for ds in datasets:
        categories.setdefault(ds["category"], 0)
        categories[ds["category"]] += 1

    return {
        "_generated_by": "tools/build_catalog.py",
        "_regenerate": "python3 tools/build_catalog.py",
        "dataset_count": len(datasets),
        "entry_total": sum(ds["count"] for ds in datasets),
        "category_count": len(categories),
        "with_source": sum(1 for ds in datasets if ds["has_source"]),
        "categories": dict(sorted(categories.items())),
        "datasets": datasets,
    }


def main():
    check = "--check" in sys.argv[1:]
    cat = build()
    path = os.path.join(ROOT, "meta", "catalog.json")
    new = json.dumps(cat, indent=2, ensure_ascii=False) + "\n"
    if check:
        cur = open(path, encoding="utf-8").read() if os.path.exists(path) else ""
        if cur != new:
            print("meta/catalog.json is stale — run tools/build_catalog.py")
            sys.exit(1)
        print("meta/catalog.json up to date")
        return
    os.makedirs(os.path.join(ROOT, "meta"), exist_ok=True)
    open(path, "w", encoding="utf-8").write(new)
    print(f"wrote meta/catalog.json — {cat['dataset_count']} datasets, "
          f"{cat['entry_total']} entries, {cat['category_count']} categories, "
          f"{cat['with_source']} with provenance")


if __name__ == "__main__":
    main()
