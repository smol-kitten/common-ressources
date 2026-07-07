# common-ressources — data tooling orchestration
# All tools are stdlib Python 3 + jq; no install step required.

PY := python3

.PHONY: help all build check verify gap validate sources coverage clean

help:
	@echo "common-ressources make targets:"
	@echo "  make build     regenerate derived artefacts (catalog, sources, currencies)"
	@echo "  make check     CI gate — validate + verify + assert generated files are current"
	@echo "  make verify    semantic verification (duplicates, colors, cross-file refs)"
	@echo "  make gap       coverage & completeness gap analysis"
	@echo "  make validate  JSON syntax + schema checks (validate.sh)"
	@echo "  make coverage  provenance coverage report"

# Regenerate every derived/generated artefact.
build:
	$(PY) tools/build_currencies.py
	$(PY) tools/build_catalog.py
	$(PY) tools/build_sources.py

# Non-mutating checks suitable for CI. Fails if any generated file is stale.
check: validate verify
	$(PY) tools/build_currencies.py --check
	$(PY) tools/build_catalog.py --check
	$(PY) tools/build_sources.py --check
	@echo "== all checks passed =="

verify:
	$(PY) tools/verify.py

gap:
	$(PY) tools/gap.py

validate:
	bash validate.sh

sources:
	$(PY) tools/build_sources.py

coverage:
	$(PY) tools/build_sources.py --coverage

all: build verify gap

clean:
	rm -rf tools/reports
