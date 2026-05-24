#!/usr/bin/env node
// Generates PNG preview images from HTML template files using Playwright.
// Each HTML template has a "__KEY__" placeholder that is replaced with
// the corresponding JSON data before the page is rendered.
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
    // Replace the JSON-string placeholder "\"__KEY__\"" with serialized data
    out = out.replace(`"__${key}__"`, JSON.stringify(value));
  }
  return out;
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
    data: { FLAGS: () => load('flags/countries/flags.json') },
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
    waitUntil: 'domcontentloaded',
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

      // Resolve data (call each loader)
      const resolvedData = {};
      for (const [key, loader] of Object.entries(preview.data)) {
        resolvedData[key] = loader();
      }

      const html = fs.readFileSync(htmlFile, 'utf8');
      const hydrated = inject(html, resolvedData);

      // Use a tall initial viewport so fullPage captures everything without a
      // resize step (resize triggers async re-layout that can race the screenshot)
      await page.setViewportSize({ width: preview.width, height: 4000 });
      await page.setContent(hydrated, { waitUntil: 'domcontentloaded' });

      // Give JS time to render content (rice/xterm.js needs more)
      const waitMs = preview.id === 'rice' ? 2000 : 400;
      await page.waitForTimeout(waitMs);

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
