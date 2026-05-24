// @ts-check
// Playwright tests: validate JSON data integrity and screenshot each preview page.
// Run with: npx playwright test

const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

function load(rel) {
  return JSON.parse(fs.readFileSync(path.join(ROOT, rel), 'utf8'));
}

function injectInto(htmlRel, dataMap) {
  let html = fs.readFileSync(path.join(ROOT, htmlRel), 'utf8');
  for (const [key, value] of Object.entries(dataMap)) {
    html = html.replace(`"__${key}__"`, JSON.stringify(value));
  }
  return html;
}

async function renderAndShot(page, html, outputRel, width = 1100) {
  await page.setViewportSize({ width, height: 800 });
  await page.setContent(html, { waitUntil: 'networkidle' });
  await page.waitForTimeout(150);
  const height = await page.evaluate(() => document.body.scrollHeight);
  await page.setViewportSize({ width, height: Math.max(height, 200) });
  await page.screenshot({ path: path.join(ROOT, outputRel), fullPage: true });
}

// ─── JSON validation ──────────────────────────────────────────────────────────

test.describe('JSON data integrity', () => {
  test('pride flags have required fields', () => {
    const flags = load('lgbtq/flags/flags.json');
    expect(flags.length).toBeGreaterThan(0);
    for (const f of flags) {
      expect(f, `${f.name} missing colors`).toHaveProperty('colors');
      expect(f.colors.length, `${f.name} has no colors`).toBeGreaterThan(0);
      expect(f, `${f.name} missing type`).toHaveProperty('type');
    }
  });

  test('country flags have ISO codes and continent', () => {
    const flags = load('flags/countries/flags.json');
    expect(flags.length).toBeGreaterThan(0);
    for (const f of flags) {
      expect(f.iso, `${f.name} missing ISO`).toBeTruthy();
      expect(f.iso.length, `${f.name} ISO code wrong length`).toBe(2);
      expect(f.continent, `${f.name} missing continent`).toBeTruthy();
    }
  });

  test('terminal themes have all 16 ANSI color keys', () => {
    const themes = load('colors/terminal/themes.json');
    const required = [
      'black','red','green','yellow','blue','magenta','cyan','white',
      'bright-black','bright-red','bright-green','bright-yellow',
      'bright-blue','bright-magenta','bright-cyan','bright-white',
    ];
    expect(themes.length).toBeGreaterThan(0);
    for (const t of themes) {
      for (const key of required) {
        expect(t.colors[key], `${t.name} missing color key: ${key}`).toMatch(/^#[0-9a-fA-F]{6}$/);
      }
    }
  });

  test('color palettes have slug and at least one color', () => {
    const palettes = load('colors/palettes.json');
    for (const p of palettes) {
      expect(p.slug, `"${p.name}" missing slug`).toBeTruthy();
      expect(p.colors.length, `"${p.name}" has no colors`).toBeGreaterThan(0);
      for (const c of p.colors) {
        expect(c.hex, `palette "${p.name}" color "${c.name}" bad hex`).toMatch(/^#[0-9a-fA-F]{6}$/i);
      }
    }
  });

  test('CSS named colors all have valid hex', () => {
    const colors = load('colors/named.json');
    expect(colors.length).toBeGreaterThanOrEqual(140);
    for (const c of colors) {
      expect(c.hex, `"${c.name}" has invalid hex`).toMatch(/^#[0-9a-fA-F]{6}$/);
      expect(c.rgb.length, `"${c.name}" rgb must have 3 elements`).toBe(3);
    }
  });

  test('HTTP status codes are in range and have categories', () => {
    const codes = load('web/http/status-codes.json');
    const validCats = ['informational','success','redirection','client-error','server-error'];
    expect(codes.length).toBeGreaterThan(0);
    for (const c of codes) {
      expect(c.code, `code ${c.code} out of range`).toBeGreaterThanOrEqual(100);
      expect(c.code, `code ${c.code} out of range`).toBeLessThanOrEqual(599);
      expect(validCats, `code ${c.code} unknown category`).toContain(c.category);
    }
  });

  test('HTTP methods have safe and idempotent flags', () => {
    const methods = load('web/http/methods.json');
    for (const m of methods) {
      expect(typeof m.safe, `${m.method} safe must be boolean`).toBe('boolean');
      expect(typeof m.idempotent, `${m.method} idempotent must be boolean`).toBe('boolean');
    }
  });

  test('social platforms have brand color and slug', () => {
    const platforms = load('social/platforms.json');
    for (const p of platforms) {
      expect(p.slug, `"${p.name}" missing slug`).toBeTruthy();
      expect(p['brand-color'], `"${p.name}" missing brand-color`).toMatch(/^#[0-9a-fA-F]{6}$/i);
      expect(typeof p['open-source'], `"${p.name}" open-source must be boolean`).toBe('boolean');
      expect(typeof p.federated, `"${p.name}" federated must be boolean`).toBe('boolean');
    }
  });

  test('Windows Terminal export matches themes count', () => {
    const themes = load('colors/terminal/themes.json');
    const wt = load('colors/terminal/export/windows-terminal.json');
    expect(wt.length).toBe(themes.length);
  });
});

// ─── Preview rendering ────────────────────────────────────────────────────────

test.describe('Preview screenshots', () => {
  test('pride flags preview', async ({ page }) => {
    const html = injectInto('lgbtq/flags/preview.html', {
      FLAGS: load('lgbtq/flags/flags.json'),
    });
    await renderAndShot(page, html, 'lgbtq/flags/colortest.png', 1100);
    const cards = await page.locator('.flag-card').count();
    expect(cards).toBeGreaterThan(0);
  });

  test('country flags preview', async ({ page }) => {
    const html = injectInto('flags/countries/preview.html', {
      FLAGS: load('flags/countries/flags.json'),
    });
    await renderAndShot(page, html, 'flags/countries/colortest.png', 1100);
    const cards = await page.locator('.flag-card').count();
    expect(cards).toBe(load('flags/countries/flags.json').length);
  });

  test('color palettes preview', async ({ page }) => {
    const html = injectInto('colors/preview.html', {
      PALETTES: load('colors/palettes.json'),
    });
    await renderAndShot(page, html, 'colors/colortest.png', 1100);
    const rows = await page.locator('.palette').count();
    expect(rows).toBeGreaterThan(0);
  });

  test('terminal themes preview', async ({ page }) => {
    const themes = load('colors/terminal/themes.json');
    const html = injectInto('colors/terminal/preview.html', { THEMES: themes });
    await renderAndShot(page, html, 'colors/terminal/colortest.png', 1060);
    const cards = await page.locator('.card').count();
    expect(cards).toBe(themes.length);
  });

  test('social platforms preview', async ({ page }) => {
    const html = injectInto('social/preview.html', {
      PLATFORMS: load('social/platforms.json'),
    });
    await renderAndShot(page, html, 'social/brandsheet.png', 950);
    const cards = await page.locator('.card').count();
    expect(cards).toBeGreaterThan(0);
  });

  test('HTTP status code reference', async ({ page }) => {
    const html = injectInto('web/http/preview.html', {
      CODES: load('web/http/status-codes.json'),
    });
    await renderAndShot(page, html, 'web/http/reference.png', 1000);
    const sections = await page.locator('.section').count();
    expect(sections).toBe(5); // 5 HTTP categories
  });

  test('rice terminal preview', async ({ page }) => {
    const themes = load('colors/terminal/themes.json');
    const html = injectInto('rice/preview.html', { THEMES: themes });
    // rice/preview.html has inline xterm.js — use domcontentloaded to avoid
    // networkidle timeout, then wait for xterm to render
    await page.setViewportSize({ width: 1100, height: 800 });
    await page.setContent(html, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(800);
    const height = await page.evaluate(() => document.body.scrollHeight);
    await page.setViewportSize({ width: 1100, height: Math.max(height, 200) });
    await page.screenshot({ path: path.join(ROOT, 'rice/preview.png'), fullPage: true });
    const cards = await page.locator('.terminal-card').count();
    expect(cards).toBe(themes.length);
  });
});
