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

// 5-pointed star polygon points string; first point at top.
function starPolygon(cx, cy, outerR, innerR, n = 5) {
  const pts = [];
  for (let i = 0; i < 2 * n; i++) {
    const r = i % 2 === 0 ? outerR : innerR;
    const a = -Math.PI / 2 + (i * Math.PI / n);
    pts.push(`${(cx + r * Math.cos(a)).toFixed(2)},${(cy + r * Math.sin(a)).toFixed(2)}`);
  }
  return pts.join(' ');
}

// Render a flag as an inline SVG string for a $w×$h viewport.
// Supports: horizontal-stripes, vertical-stripes, N-degree-stripes,
//           nordic-cross, cross, saltire, triangle-hoist, circle,
//           quarters, crescent-star, pall.
function flagToSVG(flag, w, h) {
  const colors = flag.colors || [];
  const type   = flag.type   || 'horizontal-stripes';
  const n      = colors.length;
  const parts  = [];

  const esc = s => String(s).replace(/&/g,'&amp;').replace(/"/g,'&quot;');

  const diagBand = (cx, cy, angle, diag, hw, fill) => {
    const dx = Math.cos(angle), dy = Math.sin(angle);
    const nx = -dy, ny = dx;
    const pts = [
      `${(cx-dx*diag-nx*hw).toFixed(2)},${(cy-dy*diag-ny*hw).toFixed(2)}`,
      `${(cx-dx*diag+nx*hw).toFixed(2)},${(cy-dy*diag+ny*hw).toFixed(2)}`,
      `${(cx+dx*diag+nx*hw).toFixed(2)},${(cy+dy*diag+ny*hw).toFixed(2)}`,
      `${(cx+dx*diag-nx*hw).toFixed(2)},${(cy+dy*diag-ny*hw).toFixed(2)}`,
    ].join(' ');
    parts.push(`<polygon points="${pts}" fill="${esc(fill)}"/>`);
  };

  if (type === 'vertical-stripes') {
    const sw = w / n;
    colors.forEach((c, i) => parts.push(
      `<rect x="${(i*sw).toFixed(2)}" y="0" width="${sw.toFixed(2)}" height="${h}" fill="${esc(c)}"/>`
    ));

  } else if (/^(\d+(?:\.\d+)?)-degree-stripes$/.test(type)) {
    const deg  = parseFloat(type);
    const rad  = deg * Math.PI / 180;
    const dx   = Math.cos(rad), dy = Math.sin(rad);
    const nx   = -dy, ny = dx;
    const diag = Math.sqrt(w*w + h*h);
    const sw   = diag / n;
    for (let i = 0; i < n; i++) {
      const ci = i - (n-1)/2;
      diagBand(w/2 + nx*ci*sw, h/2 + ny*ci*sw, rad, diag, sw/2, colors[i]);
    }

  } else if (type === 'nordic-cross' || type === 'cross') {
    const crossX = type === 'nordic-cross' ? (flag.cross_x ?? 0.4) : 0.5;
    const armW   = (flag.cross_arm_width ?? 0.2) * h;
    const vx = crossX * w, hy = h / 2;
    parts.push(`<rect x="0" y="0" width="${w}" height="${h}" fill="${esc(colors[0])}"/>`);
    const drawBar = (bw, bc) => {
      parts.push(`<rect x="${(vx-bw/2).toFixed(2)}" y="0" width="${bw.toFixed(2)}" height="${h}" fill="${esc(bc)}"/>`);
      parts.push(`<rect x="0" y="${(hy-bw/2).toFixed(2)}" width="${w}" height="${bw.toFixed(2)}" fill="${esc(bc)}"/>`);
    };
    if (n >= 3) { drawBar(armW, colors[1]); drawBar(armW * 0.58, colors[2]); }
    else        { drawBar(armW, colors[1]); }

  } else if (type === 'saltire') {
    const hw   = (flag.cross_arm_width ?? 0.12) * h / 2;
    const diag = Math.sqrt(w*w + h*h);
    const cx   = w/2, cy = h/2;
    if (n === 2) {
      parts.push(`<rect x="0" y="0" width="${w}" height="${h}" fill="${esc(colors[0])}"/>`);
      [Math.atan2(h,w), Math.atan2(-h,w)].forEach(a => diagBand(cx, cy, a, diag, hw, colors[1]));
    } else {
      // colors[0]=X, colors[1]=top/bottom triangles, colors[2]=left/right triangles
      const p = (x,y) => `${x.toFixed(1)},${y.toFixed(1)}`;
      parts.push(`<polygon points="0,0 ${w},0 ${p(cx,cy)}" fill="${esc(colors[1])}"/>`);
      parts.push(`<polygon points="0,${h} ${w},${h} ${p(cx,cy)}" fill="${esc(colors[1])}"/>`);
      parts.push(`<polygon points="0,0 0,${h} ${p(cx,cy)}" fill="${esc(colors[2])}"/>`);
      parts.push(`<polygon points="${w},0 ${w},${h} ${p(cx,cy)}" fill="${esc(colors[2])}"/>`);
      [Math.atan2(h,w), Math.atan2(-h,w)].forEach(a => diagBand(cx, cy, a, diag, hw, colors[0]));
    }

  } else if (type === 'triangle-hoist') {
    const depth  = (flag.hoist_depth ?? 0.4) * w;
    const stripe = colors.slice(0, -1);
    const triC   = colors[n - 1];
    const sh     = h / Math.max(1, stripe.length);
    stripe.forEach((c, i) => parts.push(
      `<rect x="0" y="${(i*sh).toFixed(2)}" width="${w}" height="${sh.toFixed(2)}" fill="${esc(c)}"/>`
    ));
    parts.push(`<polygon points="0,0 ${depth.toFixed(2)},${(h/2).toFixed(2)} 0,${h}" fill="${esc(triC)}"/>`);

  } else if (type === 'circle') {
    const r = (flag.circle_radius ?? 0.3) * h;
    parts.push(`<rect x="0" y="0" width="${w}" height="${h}" fill="${esc(colors[0])}"/>`);
    parts.push(`<circle cx="${(w/2).toFixed(1)}" cy="${(h/2).toFixed(1)}" r="${r.toFixed(1)}" fill="${esc(colors[1])}"/>`);

  } else if (type === 'quarters') {
    // colors: [top-left, top-right, bottom-left, bottom-right]
    const hw = w / 2, hh = h / 2;
    [[0,0,colors[0]],[hw,0,colors[1]??colors[0]],[0,hh,colors[2]??colors[0]],[hw,hh,colors[3]??colors[1]??colors[0]]].forEach(([x,y,c]) =>
      parts.push(`<rect x="${x.toFixed(2)}" y="${y.toFixed(2)}" width="${hw.toFixed(2)}" height="${hh.toFixed(2)}" fill="${esc(c)}"/>`)
    );

  } else if (type === 'crescent-star') {
    // colors[0]=bg, colors[1]=symbol; optional colors[2]=circle-backdrop+cutout (e.g. Tunisia)
    // optional hoist_stripe, crescent_x, crescent_radius, crescent_offset, backdrop_radius, star_size, star_offset
    parts.push(`<rect x="0" y="0" width="${w}" height="${h}" fill="${esc(colors[0])}"/>`);
    if (flag.hoist_stripe) {
      const sw = (flag.hoist_stripe_width ?? 0.25) * w;
      parts.push(`<rect x="0" y="0" width="${sw.toFixed(2)}" height="${h}" fill="${esc(flag.hoist_stripe)}"/>`);
    }
    const cx  = (flag.crescent_x ?? (flag.hoist_stripe ? 0.58 : 0.48)) * w;
    const cy  = h / 2;
    const r   = (flag.crescent_radius ?? 0.28) * h;
    const off = (flag.crescent_offset ?? 0.22) * r * 2;
    const cutC = n >= 3 ? colors[2] : colors[0];
    if (n >= 3) {
      const br = (flag.backdrop_radius ?? 0.36) * h;
      parts.push(`<circle cx="${cx.toFixed(1)}" cy="${cy.toFixed(1)}" r="${br.toFixed(1)}" fill="${esc(colors[2])}"/>`);
    }
    parts.push(`<circle cx="${cx.toFixed(1)}" cy="${cy.toFixed(1)}" r="${r.toFixed(1)}" fill="${esc(colors[1])}"/>`);
    parts.push(`<circle cx="${(cx - off).toFixed(1)}" cy="${cy.toFixed(1)}" r="${(r * 0.83).toFixed(1)}" fill="${esc(cutC)}"/>`);
    const sx = cx + r * (flag.star_offset ?? 0.65);
    const sr = (flag.star_size ?? 0.11) * h;
    parts.push(`<polygon points="${starPolygon(sx, cy, sr, sr * 0.42)}" fill="${esc(colors[1])}"/>`);

  } else if (type === 'pall') {
    // Y-shaped division; colors[0]=Y-band, colors[1]=top-right, colors[2]=bottom-right
    // optional pall_left (left triangle color), pall_border (outline color), pall_x, pall_width
    const jx   = (flag.pall_x     ?? 0.45) * w;
    const jy   = h / 2;
    const phw  = (flag.pall_width ?? 0.17) * h / 2;
    const diag2 = Math.sqrt(w * w + h * h);
    const leftC   = flag.pall_left   ?? colors[0];
    const borderC = flag.pall_border ?? null;
    parts.push(`<rect x="0" y="0" width="${w}" height="${jy.toFixed(2)}" fill="${esc(colors[1])}"/>`);
    parts.push(`<rect x="0" y="${jy.toFixed(2)}" width="${w}" height="${jy.toFixed(2)}" fill="${esc(colors[2])}"/>`);
    parts.push(`<polygon points="0,0 ${jx.toFixed(2)},${jy.toFixed(2)} 0,${h}" fill="${esc(leftC)}"/>`);
    const arms = [Math.PI, Math.atan2(-jy, w - jx), Math.atan2(h - jy, w - jx)];
    const drawPallArm = (hw, col) => arms.forEach(a => {
      const dx = Math.cos(a), dy = Math.sin(a), nx = -dy, ny = dx;
      parts.push(`<polygon points="${[
        `${(jx-dx*diag2-nx*hw).toFixed(2)},${(jy-dy*diag2-ny*hw).toFixed(2)}`,
        `${(jx-dx*diag2+nx*hw).toFixed(2)},${(jy-dy*diag2+ny*hw).toFixed(2)}`,
        `${(jx+dx*diag2+nx*hw).toFixed(2)},${(jy+dy*diag2+ny*hw).toFixed(2)}`,
        `${(jx+dx*diag2-nx*hw).toFixed(2)},${(jy+dy*diag2-ny*hw).toFixed(2)}`,
      ].join(' ')}" fill="${esc(col)}"/>`);
    });
    if (borderC) drawPallArm(phw + (flag.pall_border_width ?? 4), borderC);
    drawPallArm(phw, colors[0]);

  } else {
    // Default: horizontal stripes
    const sh = h / Math.max(1, n);
    colors.forEach((c, i) => parts.push(
      `<rect x="0" y="${(i*sh).toFixed(2)}" width="${w}" height="${sh.toFixed(2)}" fill="${esc(c)}"/>`
    ));
  }

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}">${parts.join('')}</svg>`;
}

// Pre-render country flag cards — inline SVG handles all shape types.
function buildFlagCards(flags) {
  return flags.map(flag => {
    const svg = flagToSVG(flag, 150, 100);
    return `<div class="flag-card">
      <div class="flag">${svg}</div>
      <div class="flag-meta">
        <div class="flag-name">${flag.name}</div>
        <div class="flag-iso">${flag.iso || ''}</div>
        <div class="flag-continent">${flag.continent || ''}</div>
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
