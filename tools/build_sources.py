#!/usr/bin/env python3
"""
build_sources.py — generate meta/sources.json: a provenance map linking every dataset
to the authoritative source(s) it should be verified against, plus a coverage report.

Motivation: the repo README tells users to "always verify critical values against
authoritative primary sources", but until now only ~17/171 datasets recorded any
source. This centralises provenance in one machine-readable file keyed by dataset
path, so a consumer (or the corrections workflow) can look up where each dataset's
ground truth lives.

`kind` for each dataset:
  standard  — backed by a formal standard / official register (ISO, IETF RFC, IANA,
              IUPAC, Unicode, W3C, OWASP, ...). Values should match the cited primary source.
  official  — sourced from vendor / project official docs (distros, browsers, ...).
  curated   — editorially compiled; no single authoritative source (palettes, cuisines).

Run:  python3 tools/build_sources.py            # writes meta/sources.json
      python3 tools/build_sources.py --check    # exit 1 if stale (CI)
      python3 tools/build_sources.py --coverage # print coverage report only
"""
import json
import os
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def S(url, title):
    return {"title": title, "url": url}


# path -> {"kind": ..., "sources": [S(...), ...], "note": optional}
# Grouped by category. URLs point at primary/authoritative references.
SOURCES = {
    # ── science / astronomy / bio ──────────────────────────────────────────────
    "science/elements/elements.json": {"kind": "standard", "sources": [
        S("https://iupac.org/what-we-do/periodic-table-of-elements/", "IUPAC Periodic Table"),
        S("https://iupac.qmul.ac.uk/AtWt/", "IUPAC Standard Atomic Weights")]},
    "science/constants/constants.json": {"kind": "standard", "sources": [
        S("https://physics.nist.gov/cuu/Constants/", "NIST CODATA Fundamental Physical Constants")]},
    "science/units/units.json": {"kind": "standard", "sources": [
        S("https://www.bipm.org/en/publications/si-brochure", "BIPM SI Brochure (9th ed.)")]},
    "science/propagation/signal-speeds.json": {"kind": "standard", "sources": [
        S("https://physics.nist.gov/cuu/Constants/", "NIST — speed of light & material velocity factors")]},
    "bio/amino-acids/amino-acids.json": {"kind": "standard", "sources": [
        S("https://www.uniprot.org/help/amino_acids", "UniProt amino-acid reference"),
        S("https://iupac.org/", "IUPAC-IUBMB nomenclature")]},
    "bio/codon-table/codon-table.json": {"kind": "standard", "sources": [
        S("https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi", "NCBI — The Genetic Codes (translation table 1)"),
        S("https://iupac.org/", "IUPAC-IUBMB amino-acid nomenclature")]},
    "science/si-prefixes/si-prefixes.json": {"kind": "standard", "sources": [
        S("https://www.bipm.org/en/measurement-units/si-prefixes", "BIPM — SI prefixes"),
        S("https://www.bipm.org/en/committees/cg/cgpm/27-2022/resolution-3", "27th CGPM (2022) Resolution 3")]},
    "science/binary-prefixes/binary-prefixes.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/standard/31898.html", "IEC 80000-13:2008 — binary prefixes")]},
    "science/si-base-units/si-base-units.json": {"kind": "standard", "sources": [
        S("https://www.bipm.org/en/measurement-units/si-base-units", "BIPM — SI base units")]},
    "science/si-derived-units/si-derived-units.json": {"kind": "standard", "sources": [
        S("https://www.bipm.org/en/measurement-units", "BIPM — SI Brochure, Table 4 (derived units with special names)")]},
    "astronomy/constellations/constellations.json": {"kind": "standard", "sources": [
        S("https://www.iau.org/public/themes/constellations/", "IAU — The Constellations")]},
    "astronomy/stars/notable-stars.json": {"kind": "official", "sources": [
        S("https://simbad.u-strasbg.fr/simbad/", "SIMBAD Astronomical Database")]},
    "astronomy/moons/moons.json": {"kind": "official", "sources": [
        S("https://ssd.jpl.nasa.gov/sats/", "JPL Solar System Dynamics — Planetary Satellites")]},
    "space/planets/planets.json": {"kind": "official", "sources": [
        S("https://nssdc.gsfc.nasa.gov/planetary/factsheet/", "NASA NSSDCA Planetary Fact Sheet")]},
    "space/dwarf-planets/dwarf-planets.json": {"kind": "official", "sources": [
        S("https://www.iau.org/public/themes/pluto/", "IAU — Pluto & dwarf planets"),
        S("https://science.nasa.gov/dwarf-planets/", "NASA — Dwarf Planets")]},

    # ── geo / i18n / iso ───────────────────────────────────────────────────────
    "geo/countries/countries.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/iso-3166-country-codes.html", "ISO 3166-1 country codes"),
        S("https://www.un.org/en/about-us/member-states", "UN Member States")]},
    "geo/currencies/currencies.json": {"kind": "standard", "sources": [
        S("https://www.six-group.com/en/products-services/financial-information/data-standards.html",
          "ISO 4217 maintenance agency (SIX)")]},
    "geo/timezones/timezones.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/time-zones", "IANA Time Zone Database")]},
    "geo/airports/airports.json": {"kind": "official", "sources": [
        S("https://www.iata.org/en/publications/directories/code-search/", "IATA airport codes"),
        S("https://www.icao.int/", "ICAO location indicators")]},
    "geo/cities/cities.json": {"kind": "curated", "sources": [
        S("https://population.un.org/wpp/", "UN World Population Prospects")]},
    "i18n/languages/languages.json": {"kind": "standard", "sources": [
        S("https://www.loc.gov/standards/iso639-2/php/code_list.php", "ISO 639 Registration Authority (LoC)")]},
    "i18n/locales/locales.json": {"kind": "standard", "sources": [
        S("https://cldr.unicode.org/", "Unicode CLDR"),
        S("https://www.rfc-editor.org/rfc/rfc5646", "BCP 47 / RFC 5646 language tags")]},
    "iso/15924/scripts.json": {"kind": "standard", "sources": [
        S("https://www.unicode.org/iso15924/codelists.html", "ISO 15924 code list (Unicode RA)")]},
    "iso/216/paper-sizes.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/standard/36631.html", "ISO 216 — trimmed paper sizes")]},
    "iso/724/metric-threads.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/standard/1391.html", "ISO 724 — metric screw threads")]},
    "iso/8601/formats.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/iso-8601-date-and-time-format.html", "ISO 8601 date/time")]},
    "iso/27001/controls.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/standard/27001", "ISO/IEC 27001:2022 Annex A")]},
    "iso/9001/clauses.json": {"kind": "standard", "sources": [
        S("https://www.iso.org/standard/62085.html", "ISO 9001:2015")]},

    # ── web / net / networking / security ──────────────────────────────────────
    "web/http/status-codes.json": {"kind": "standard", "sources": [
        S("https://www.rfc-editor.org/rfc/rfc9110", "RFC 9110 — HTTP Semantics"),
        S("https://www.iana.org/assignments/http-status-codes/", "IANA HTTP Status Code Registry")]},
    "web/http/methods.json": {"kind": "standard", "sources": [
        S("https://www.rfc-editor.org/rfc/rfc9110", "RFC 9110 §9 — Methods")]},
    "web/http/headers.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/http-fields/", "IANA HTTP Field Name Registry")]},
    "web/http/auth-schemes.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/http-authschemes/", "IANA HTTP Authentication Scheme Registry")]},
    "web/mime/mappings.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/media-types/", "IANA Media Types")]},
    "web/csp/directives.json": {"kind": "standard", "sources": [
        S("https://www.w3.org/TR/CSP3/", "W3C Content Security Policy Level 3")]},
    "web/regex/patterns.json": {"kind": "curated", "sources": [
        S("https://www.regular-expressions.info/", "regular-expressions.info")]},
    "web/browsers.json": {"kind": "official", "sources": [
        S("https://developer.mozilla.org/en-US/docs/Web", "MDN Web Docs")]},
    "net/http-status-codes/http-status-codes.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/http-status-codes/", "IANA HTTP Status Code Registry")]},
    "net/dns-record-types/dns-record-types.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/dns-parameters/", "IANA DNS Parameters")]},
    "net/ports/ports.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/service-names-port-numbers/", "IANA Service Name & Port Registry")]},
    "networking/protocols/ip-protocols.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/protocol-numbers/", "IANA Protocol Numbers")]},
    "networking/subnets/cidr.json": {"kind": "standard", "sources": [
        S("https://www.rfc-editor.org/rfc/rfc4632", "RFC 4632 — CIDR")]},
    "networking/special-use-ips/special-use-ips.json": {"kind": "standard", "sources": [
        S("https://www.iana.org/assignments/iana-ipv4-special-registry/", "IANA IPv4 Special-Purpose Address Registry"),
        S("https://www.iana.org/assignments/iana-ipv6-special-registry/", "IANA IPv6 Special-Purpose Address Registry")]},
    "networking/devices/device-types.json": {"kind": "curated", "sources": [
        S("https://www.cisco.com/", "Cisco networking documentation")]},
    "security/owasp-top10/owasp-top10.json": {"kind": "standard", "sources": [
        S("https://owasp.org/www-project-top-ten/", "OWASP Top 10")]},
    "security/headers/security-headers.json": {"kind": "standard", "sources": [
        S("https://owasp.org/www-project-secure-headers/", "OWASP Secure Headers Project")]},
    "security/tls/versions.json": {"kind": "standard", "sources": [
        S("https://www.rfc-editor.org/rfc/rfc8446", "RFC 8446 — TLS 1.3"),
        S("https://datatracker.ietf.org/doc/html/rfc5246", "RFC 5246 — TLS 1.2")]},
    "security/hash-algorithms/hash-algorithms.json": {"kind": "standard", "sources": [
        S("https://csrc.nist.gov/publications/detail/fips/180/4/final", "NIST FIPS 180-4 (SHA-1/SHA-2)"),
        S("https://csrc.nist.gov/publications/detail/fips/202/final", "NIST FIPS 202 (SHA-3/SHAKE)")]},

    # ── programming / accessibility / unicode ──────────────────────────────────
    "programming/licenses/licenses.json": {"kind": "standard", "sources": [
        S("https://spdx.org/licenses/", "SPDX License List"),
        S("https://opensource.org/licenses", "OSI Approved Licenses")]},
    "programming/languages.json": {"kind": "curated", "sources": [
        S("https://www.tiobe.com/tiobe-index/", "TIOBE index (popularity)")]},
    "programming/frameworks.json": {"kind": "curated", "sources": []},
    "programming/design-patterns/design-patterns.json": {"kind": "curated", "sources": [
        S("https://en.wikipedia.org/wiki/Software_design_pattern", "GoF design patterns")]},
    "accessibility/wcag/criteria.json": {"kind": "standard", "sources": [
        S("https://www.w3.org/TR/WCAG22/", "W3C WCAG 2.2")]},
    "accessibility/aria-roles/aria-roles.json": {"kind": "standard", "sources": [
        S("https://www.w3.org/TR/wai-aria-1.2/", "W3C WAI-ARIA 1.2")]},
    "unicode/blocks/blocks.json": {"kind": "standard", "sources": [
        S("https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt", "Unicode Character Database — Blocks")]},
    "unicode/symbols/special-chars.json": {"kind": "standard", "sources": [
        S("https://www.unicode.org/charts/", "Unicode Code Charts")]},
    "math/symbols/symbols.json": {"kind": "standard", "sources": [
        S("https://www.unicode.org/charts/PDF/U2200.pdf", "Unicode Mathematical Operators")]},
    "math/constants/constants.json": {"kind": "standard", "sources": [
        S("https://oeis.org/", "OEIS — decimal expansions"),
        S("https://mpmath.org/", "mpmath — arbitrary-precision computation")]},

    # ── devops / linux / hardware ──────────────────────────────────────────────
    "devops/kubernetes/objects.json": {"kind": "official", "sources": [
        S("https://kubernetes.io/docs/reference/", "Kubernetes API reference")]},
    "devops/docker/objects.json": {"kind": "official", "sources": [
        S("https://docs.docker.com/reference/dockerfile/", "Dockerfile reference")]},
    "linux/signals/signals.json": {"kind": "standard", "sources": [
        S("https://man7.org/linux/man-pages/man7/signal.7.html", "signal(7) man page"),
        S("https://pubs.opengroup.org/onlinepubs/9699919799/", "POSIX.1-2017")]},
    "linux/exit-codes/exit-codes.json": {"kind": "official", "sources": [
        S("https://tldp.org/LDP/abs/html/exitcodes.html", "Advanced Bash-Scripting Guide — exit codes")]},
    "linux/filesystem/filesystem.json": {"kind": "standard", "sources": [
        S("https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html", "Filesystem Hierarchy Standard 3.0")]},

    # ── finance ────────────────────────────────────────────────────────────────
    "finance/stock-exchanges/stock-exchanges.json": {"kind": "standard", "sources": [
        S("https://www.iso20022.org/market-identifier-codes", "ISO 10383 Market Identifier Codes")]},
    "finance/forex/pairs.json": {"kind": "curated", "sources": [
        S("https://www.six-group.com/en/products-services/financial-information/data-standards.html", "ISO 4217")]},
}


def build():
    cataloged = []
    for f in sorted(glob.glob(os.path.join(ROOT, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(f, ROOT)
        if rel.startswith((".git", "tools/reports", "node_modules")) or rel.startswith("package"):
            continue
        if rel in ("meta/catalog.json", "meta/sources.json"):
            continue
        cataloged.append(rel)

    documented = {k: v for k, v in SOURCES.items()}
    return {
        "_generated_by": "tools/build_sources.py",
        "_about": "Authoritative source map. 'kind' = standard | official | curated. "
                  "Consumers should verify safety/compliance-critical values against the cited primary source.",
        "documented": len(documented),
        "total_datasets": len(cataloged),
        "sources": dict(sorted(documented.items())),
    }, cataloged


def main():
    argv = sys.argv[1:]
    doc, cataloged = build()
    if "--coverage" in argv:
        undoc = [r for r in cataloged if r not in doc["sources"]]
        print(f"provenance coverage: {doc['documented']}/{doc['total_datasets']} datasets")
        print(f"undocumented ({len(undoc)}):")
        for r in undoc:
            print(f"  {r}")
        return
    path = os.path.join(ROOT, "meta", "sources.json")
    new = json.dumps(doc, indent=2, ensure_ascii=False) + "\n"
    if "--check" in argv:
        cur = open(path, encoding="utf-8").read() if os.path.exists(path) else ""
        if cur != new:
            print("meta/sources.json is stale — run tools/build_sources.py")
            sys.exit(1)
        print("meta/sources.json up to date")
        return
    os.makedirs(os.path.join(ROOT, "meta"), exist_ok=True)
    open(path, "w", encoding="utf-8").write(new)
    print(f"wrote meta/sources.json — {doc['documented']} datasets documented "
          f"of {doc['total_datasets']}")


if __name__ == "__main__":
    main()
