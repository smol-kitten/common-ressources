#!/usr/bin/env node
/**
 * Generates meta/manifest.json — a machine-readable catalog of all JSON data files.
 * Run from repo root: node scripts/build-manifest.js
 */

import { readdirSync, statSync, lstatSync, readFileSync, writeFileSync } from 'fs';
import { join, relative, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

const SKIP_DIRS = new Set([
  'node_modules', '.git', '.claude', 'rice', 'setups', 'tests', 'scripts', 'docker',
]);
const SKIP_FILES = new Set([
  'package.json', 'package-lock.json',
]);

// Human-readable descriptions per file (keyed by repo-relative path)
const DESCRIPTIONS = {
  'flags/countries/flags.json': 'Country flags with SVG geometry type, colors, and shape metadata',
  'lgbtq/flags/flags.json': 'LGBTQ+ pride flag color palettes',
  'colors/named.json': 'CSS named colors with hex values',
  'colors/palettes.json': 'Curated color palettes with names and hex arrays',
  'colors/terminal/themes.json': 'Terminal color schemes (16-color ANSI + metadata)',
  'colors/terminal/export/windows-terminal.json': 'Terminal themes in Windows Terminal JSON format',
  'science/elements/elements.json': 'All 118 chemical elements with IUPAC 2021 atomic masses',
  'science/constants/constants.json': 'Fundamental physical constants (SI units)',
  'science/units/units.json': 'SI and common measurement units',
  'geo/countries/countries.json': 'All 195 countries with ISO codes, capital, currency, dial code',
  'geo/timezones/timezones.json': 'IANA timezone identifiers with UTC offsets and major cities',
  'geo/airports/airports.json': 'Major world airports with IATA/ICAO codes, coordinates, timezone',
  'geo/cities/cities.json': 'Major world cities with population and coordinates',
  'geo/currencies/currencies.json': 'World currencies with ISO 4217 code, symbol, and decimal places',
  'geo/mountains/peaks.json': 'Highest mountain peaks with elevation and first-ascent data',
  'geo/rivers/rivers.json': 'Longest rivers with length, source, mouth, and drainage area',
  'geo/oceans/oceans.json': 'Oceans and major seas with area and depth data',
  'i18n/languages/languages.json': 'World languages with ISO 639 codes, native name, script, speakers',
  'ai/models.json': 'AI language models with provider, context window, and capabilities',
  'web/http/status-codes.json': 'HTTP status codes with category and description',
  'web/http/methods.json': 'HTTP methods with safe/idempotent flags and RFC references',
  'web/http/headers.json': 'HTTP request/response headers with direction and description',
  'web/mime/mappings.json': 'File extension to MIME type mappings',
  'web/regex/patterns.json': 'Common regex patterns for validation (email, URL, UUID, etc.)',
  'web/csp/directives.json': 'Content Security Policy directive reference',
  'web/browsers/browsers.json': 'Major web browsers with engine, vendor, and platform support',
  'net/http-status-codes/http-status-codes.json': 'HTTP status codes (extended reference)',
  'net/ports/ports.json': 'Well-known TCP/UDP port numbers with service names',
  'social/platforms.json': 'Social media platforms with brand colors and metadata',
  'programming/languages/languages.json': 'Programming languages with paradigm, typing, and use cases',
  'programming/frameworks/frameworks.json': 'Frameworks and libraries across languages and domains',
  'programming/design-patterns/design-patterns.json': 'GoF and other software design patterns',
  'programming/licenses/licenses.json': 'Open-source software licenses with permissions summary',
  'math/formulas/formulas.json': 'Mathematical formulas with LaTeX notation by category',
  'math/symbols/symbols.json': 'Mathematical symbols with Unicode codepoint and LaTeX',
  'math/number-systems/bases.json': 'Positional number systems (binary, octal, decimal, hex, etc.)',
  'database/sql-keywords/keywords.json': 'ANSI SQL keywords grouped by category (DQL/DML/DDL/DCL/TCL)',
  'database/engines/engines.json': 'Database engines with type, license, ACID compliance, default port',
  'security/headers/security-headers.json': 'HTTP security headers with recommended values and risk if missing',
  'security/tls/versions.json': 'TLS/SSL protocol versions with status (current/deprecated/broken)',
  'security/owasp-top10/vulnerabilities.json': 'OWASP Top 10 web application security risks',
  'devops/docker/objects.json': 'Dockerfile instructions and Docker objects reference',
  'devops/kubernetes/objects.json': 'Kubernetes resource kinds with API group and category',
  'devops/ci-platforms/platforms.json': 'CI/CD platforms with config file format and trigger types',
  'design/breakpoints/breakpoints.json': 'CSS breakpoint systems (Tailwind, Bootstrap, MUI, Bulma, Foundation)',
  'design/spacing/scales.json': 'CSS spacing/sizing scales by design system',
  'design/z-index/conventions.json': 'CSS z-index conventions and named layers',
  'typography/type-scale/scales.json': 'Typographic scale ratios with step sizes',
  'typography/font-weights/weights.json': 'CSS font-weight values with keywords and typical uses',
  'typography/line-height/guidelines.json': 'Line-height guidelines by content type',
  'fonts/stacks.json': 'System and web font stacks with CSS values',
  'keyboard/vscode/shortcuts.json': 'VS Code keyboard shortcuts by category',
  'keyboard/browser/shortcuts.json': 'Browser keyboard shortcuts',
  'keyboard/terminal-multiplexers/shortcuts.json': 'tmux, zellij, and screen keyboard shortcuts',
  'unicode/blocks/blocks.json': 'Unicode character blocks with code point ranges',
  'unicode/symbols/special-chars.json': 'Common special characters with codepoint, HTML entity, and usage',
  'astronomy/constellations/constellations.json': 'All 88 IAU constellations with abbreviation, area, and hemisphere',
  'astronomy/moons/moons.json': 'Named moons with orbital data and planet association',
  'astronomy/stars/notable-stars.json': 'Prominent named stars with distance, magnitude, and spectral class',
  'space/planets/planets.json': 'Solar system planets with physical and orbital data',
  'space/dwarf-planets/dwarf-planets.json': 'IAU dwarf planets and likely candidates',
  'space/missions/missions.json': 'Major space missions with agency, destination, and achievements',
  'finance/forex/pairs.json': 'Forex currency pairs (major, minor, exotic) with typical spread',
  'finance/indices/indices.json': 'Stock market indices with ticker, exchange, and weighting method',
  'networking/subnets/cidr.json': 'CIDR subnet reference with host counts and subnet masks',
  'networking/protocols/ip-protocols.json': 'IP protocol numbers with RFC and connection type',
  'networking/devices/device-types.json': 'Network device types with OSI layer and function',
  'macos/defaults/commands.json': 'macOS defaults write commands with revert commands',
  'macos/homebrew/packages.json': 'Essential Homebrew formulae and casks with categories',
  'macos/keyboard/shortcuts.json': 'macOS system keyboard shortcuts',
  'windows/winget/packages.json': 'Essential winget packages for Windows setup',
  'windows/registry/common-tweaks.json': 'Common Windows Registry tweaks',
  'linux/packages/aur-tools.json': 'Popular AUR packages for Arch Linux',
  'linux/desktop/wm-configs.json': 'Window manager configuration references',
  'linux/system/pacman-mirrors.json': 'Pacman mirror locations',
  'accessibility/aria-roles/aria-roles.json': 'WAI-ARIA roles with required properties and allowed children',
  'iso/15924/scripts.json': 'ISO 15924 writing system script codes',
  'iso/8601/formats.json': 'ISO 8601 date and time format patterns',
  'music/genres/genres.json': 'Music genres with BPM range, mood, origin, and example artists',
  'food/cuisines/cuisines.json': 'World cuisines with key ingredients, dishes, and spice level',
  'food/nutrition/nutrients.json': 'Essential nutrients with RDA, function, and food sources',
  'gaming/platforms/platforms.json': 'Gaming consoles and platforms with generation and release year',
  'gaming/genres/genres.json': 'Video game genres with subgenres and notable examples',
  'hardware/pc/form-factors.json': 'PC form factors and standards',
  'history/eras/eras.json': 'Major historical eras with date range, region, and key developments',
  'history/inventions/inventions.json': 'Major inventions with inventor, year, and historical impact',
  'chemistry/functional-groups/groups.json': 'Organic chemistry functional groups with formula and examples',
  'physics/laws/laws.json': 'Fundamental physics laws, principles, and theories',
  'medicine/specialties/specialties.json': 'Medical specialties with focus area and common conditions',
  'sports/sports.json': 'Major sports with category, players per side, and governing body',
  'biology/amino-acids/amino-acids.json': 'The 20 standard amino acids with properties and codon table',
  'biology/taxonomy/taxonomy.json': 'Biological taxonomy domains, kingdoms, and major phyla',
  'lgbtq/terms/terms.json': 'LGBTQ+ terminology with definitions and context',
  'lgbtq/identities/identities.json': 'Gender and sexual identity definitions',
  'lgbtq/history/milestones.json': 'Key milestones in LGBTQ+ rights history',
  'lgbtq/organisations/organisations.json': 'Notable LGBTQ+ organizations worldwide',
  'lgbtq/pronouns/pronouns.json': 'Pronoun sets with subject/object/reflexive forms',
  'lgbtq/symbols/symbols.json': 'LGBTQ+ symbols with meaning and history',
  'dates/formats/formats.json': 'Date format conventions by locale and standard',
};

function walkJson(dir, results = []) {
  let entries;
  try { entries = readdirSync(dir); } catch { return results; }

  for (const entry of entries.sort()) {
    if (SKIP_DIRS.has(entry)) continue;
    const fullPath = join(dir, entry);
    const relPath = relative(ROOT, fullPath);
    const lstat = lstatSync(fullPath);
    if (lstat.isSymbolicLink()) continue;
    const stat = statSync(fullPath);

    if (stat.isDirectory()) {
      walkJson(fullPath, results);
    } else if (entry.endsWith('.json') && !SKIP_FILES.has(entry)) {
      let count = null;
      let fields = null;
      try {
        const data = JSON.parse(readFileSync(fullPath, 'utf8'));
        if (Array.isArray(data)) {
          count = data.length;
          if (data.length > 0 && typeof data[0] === 'object' && data[0] !== null) {
            fields = Object.keys(data[0]);
          }
        }
      } catch { /* non-array or malformed */ }

      results.push({
        path: relPath,
        description: DESCRIPTIONS[relPath] || null,
        count,
        fields,
      });
    }
  }
  return results;
}

const files = walkJson(ROOT);
const totalEntries = files.reduce((s, f) => s + (f.count ?? 0), 0);

// Group by top-level domain
const domains = {};
for (const f of files) {
  const parts = f.path.split('/');
  const domain = parts[0];
  if (!domains[domain]) domains[domain] = [];
  domains[domain].push(f);
}

const manifest = {
  generated: new Date().toISOString().slice(0, 10),
  total_files: files.length,
  total_entries: totalEntries,
  domains: Object.entries(domains).sort().map(([name, domainFiles]) => ({
    domain: name,
    file_count: domainFiles.length,
    entry_count: domainFiles.reduce((s, f) => s + (f.count ?? 0), 0),
    files: domainFiles,
  })),
};

writeFileSync(join(ROOT, 'meta/manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(`Written meta/manifest.json: ${files.length} files, ${totalEntries} total entries`);
