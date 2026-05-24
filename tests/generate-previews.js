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

// Pre-render terminal theme cards server-side to avoid client-JS issues
const ANSI_KEYS = [
  'black','red','green','yellow','blue','magenta','cyan','white',
  'bright-black','bright-red','bright-green','bright-yellow',
  'bright-blue','bright-magenta','bright-cyan','bright-white',
];

function buildTerminalCards(themes) {
  return themes.map(theme => {
    const bg     = theme.background || '#1e1e2e';
    const fg     = theme.foreground || '#cdd6f4';
    const accent = (theme.colors['blue'] || theme.colors['cyan'] || fg);
    const green  = theme.colors['green']  || '#a6e3a1';
    const yellow = theme.colors['yellow'] || '#f9e2af';
    const swatches = ANSI_KEYS.map(k =>
      `<div class="swatch" style="background:${theme.colors[k] || '#888'}" title="${k}"></div>`
    ).join('');
    return `<div class="terminal-card">
  <div class="titlebar" style="background:${bg}cc">
    <div class="dot dot-red"></div>
    <div class="dot dot-yel"></div>
    <div class="dot dot-grn"></div>
    <div class="title-label">${theme.name}</div>
  </div>
  <div class="term-body" style="background:${bg};color:${fg}">
    <div class="swatches">${swatches}</div>
    <div class="prompt-line">
      <span class="ps1-user" style="color:${green}">user</span>
      <span class="ps1-sep">@arch</span>
      <span class="ps1-sep">:</span>
      <span class="ps1-dir" style="color:${accent}">~/dotfiles</span>
      <span class="ps1-git" style="color:${yellow}"> main</span>
      <span class="ps1-sym" style="color:${green}">$</span>
    </div>
    <div class="cmd-line" style="color:${fg}">ls -la rice/</div>
    <div class="out-line">alacritty/  dunst/  hyprland/  kitty/  rofi/  waybar/  wezterm/</div>
  </div>
</div>`;
  }).join('');
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
    data: { CARDS: () => buildTerminalCards(load('colors/terminal/themes.json')) },
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
