#!/usr/bin/env node
// Generates PNG preview images from HTML template files using Playwright.
//
// Two injection modes:
//   "<!--__KEY__-->"  → raw HTML string (pre-rendered server-side)
//   "\"__KEY__\""     → JSON-serialised value (parsed client-side)
//
// Usage:
//   node tests/generate-previews.js
//   node tests/generate-previews.js colors/terminal  # only one group

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

function load(relPath) {
  const abs = path.join(ROOT, relPath);
  if (!fs.existsSync(abs)) throw new Error(`File not found: ${abs}`);
  return JSON.parse(fs.readFileSync(abs, 'utf8'));
}

function inject(html, dataMap) {
  let out = html;
  for (const [key, value] of Object.entries(dataMap)) {
    if (typeof value === 'string') {
      // Raw HTML injection — no JS needed in the template
      out = out.replace(`<!--__${key}__-->`, value);
    } else {
      // JSON injection — client-side JS parses the value
      out = out.replace(`"__${key}__"`, JSON.stringify(value));
    }
  }
  return out;
}

// Pre-render country flag cards server-side to avoid client-JS issues
function buildFlagCards(flags) {
  return flags.map(flag => {
    const isVertical = (flag.type || '') === 'vertical-stripes';
    const dir = isVertical ? 'row' : 'column';
    const stripes = (flag.colors || []).map(c =>
      `<div style="background:${c};flex:1"></div>`
    ).join('');
    return `<div class="flag-card">
      <div class="flag" style="display:flex;flex-direction:${dir}">${stripes}</div>
      <div class="flag-meta">
        <div class="flag-name">${flag.name}</div>
        <div class="flag-iso">${flag.iso}</div>
        <div class="flag-continent">${flag.continent}</div>
      </div>
    </div>`;
  }).join('');
}

const PREVIEWS = [
  {
    id: 'lgbtq/flags',
    html: 'lgbtq/flags/preview.html',
    output: 'lgbtq/flags/colortest.png',
    width: 1100,
    data: { FLAGS: () => load('lgbtq/flags/flags.json') },
  },
  {
    id: 'flags/countries',
    html: 'flags/countries/preview.html',
    output: 'flags/countries/colortest.png',
    width: 1100,
    // Pre-render cards server-side → raw HTML injection, no client JS needed
    data: { CARDS: () => buildFlagCards(load('flags/countries/flags.json')) },
  },
  {
    id: 'colors/palettes',
    html: 'colors/preview.html',
    output: 'colors/colortest.png',
    width: 1100,
    data: { PALETTES: () => load('colors/palettes.json') },
  },
  {
    id: 'colors/terminal',
    html: 'colors/terminal/preview.html',
    output: 'colors/terminal/colortest.png',
    width: 1060,
    data: { THEMES: () => load('colors/terminal/themes.json') },
  },
  {
    id: 'social',
    html: 'social/preview.html',
    output: 'social/brandsheet.png',
    width: 950,
    data: { PLATFORMS: () => load('social/platforms.json') },
  },
  {
    id: 'web/http',
    html: 'web/http/preview.html',
    output: 'web/http/reference.png',
    width: 1000,
    data: { CODES: () => load('web/http/status-codes.json') },
  },
  {
    id: 'rice',
    html: 'rice/preview.html',
    output: 'rice/preview.png',
    width: 1100,
    data: { THEMES: () => load('colors/terminal/themes.json') },
  },
];

async function generateAll(filter) {
  const targets = filter
    ? PREVIEWS.filter(p => p.id.startsWith(filter))
    : PREVIEWS;

  if (!targets.length) {
    console.error(`No previews match filter: ${filter}`);
    process.exit(1);
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();
  let ok = 0, fail = 0;

  for (const preview of targets) {
    try {
      const htmlFile = path.join(ROOT, preview.html);
      const outFile = path.join(ROOT, preview.output);

      if (!fs.existsSync(htmlFile)) {
        console.warn(`  SKIP ${preview.id} — HTML template not found: ${preview.html}`);
        continue;
      }

      const resolvedData = {};
      for (const [key, loader] of Object.entries(preview.data)) {
        resolvedData[key] = loader();
      }

      const html = fs.readFileSync(htmlFile, 'utf8');
      const hydrated = inject(html, resolvedData);

      // height:1 ensures scrollHeight == content height so fullPage captures
      // exactly the content — no empty black space below short pages.
      await page.setViewportSize({ width: preview.width, height: 1 });
      await page.setContent(hydrated, { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(400);

      await page.screenshot({ path: outFile, fullPage: true });
      console.log(`  OK  ${preview.output}`);
      ok++;
    } catch (err) {
      console.error(`  FAIL ${preview.id}: ${err.message}`);
      fail++;
    }
  }

  await browser.close();
  console.log(`\nDone: ${ok} generated, ${fail} failed.`);
  if (fail > 0) process.exit(1);
}

const filter = process.argv[2];
generateAll(filter).catch(err => { console.error(err); process.exit(1); });
