<?php
// Renders all terminal themes as fake terminal window previews — PNG output
// Usage: php colortest.php > colortest.png   OR serve via web server

$themes = json_decode(file_get_contents(
    'https://raw.githubusercontent.com/polo-nyan/common-ressources/refs/heads/main/colors/terminal/themes.json'
), true);

/*
// Local alternative:
$themes = json_decode(file_get_contents(__DIR__ . '/themes.json'), true);
*/

if (!$themes) {
    die('Error loading themes data.');
}

function hexToRgb($hex)
{
    $hex = ltrim($hex, '#');
    return [hexdec(substr($hex, 0, 2)), hexdec(substr($hex, 2, 2)), hexdec(substr($hex, 4, 2))];
}

function alloc($im, $hex)
{
    [$r, $g, $b] = hexToRgb($hex);
    return imagecolorallocate($im, $r, $g, $b);
}

// Layout constants (pixel units, no scaling needed for a reference PNG)
$cols       = 2;
$cardW      = 480;
$cardH      = 195;
$pad        = 14;
$titleBarH  = 30;
$dotR       = 7;    // traffic-light dot radius
$swatchW    = 48;
$swatchH    = 34;
$swatchGap  = 3;

$rows   = (int) ceil(count($themes) / $cols);
$imgW   = $pad + ($cardW + $pad) * $cols;
$imgH   = $pad + ($cardH + $pad) * $rows;

$im     = imagecreatetruecolor($imgW, $imgH);
$canvas = imagecolorallocate($im, 18, 18, 18);
imagefill($im, 0, 0, $canvas);

// macOS traffic-light colors
$dotClose    = imagecolorallocate($im, 255, 95,  86);
$dotMinimize = imagecolorallocate($im, 255, 189, 46);
$dotMaximize = imagecolorallocate($im, 39,  201, 63);
$titleBarBg  = imagecolorallocate($im, 38, 38, 38);
$dimGray     = imagecolorallocate($im, 100, 100, 100);

$colorKeys = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'];

foreach ($themes as $idx => $theme) {
    $col = $idx % $cols;
    $row = (int) floor($idx / $cols);

    $cx = $pad + $col * ($cardW + $pad);   // card X
    $cy = $pad + $row * ($cardH + $pad);   // card Y

    // Card background
    $bg = alloc($im, $theme['background']);
    imagefilledrectangle($im, $cx, $cy, $cx + $cardW - 1, $cy + $cardH - 1, $bg);

    // Title bar
    imagefilledrectangle($im, $cx, $cy, $cx + $cardW - 1, $cy + $titleBarH - 1, $titleBarBg);

    // Traffic light dots
    $dotY = $cy + (int) ($titleBarH / 2);
    imagefilledellipse($im, $cx + 16, $dotY, $dotR * 2, $dotR * 2, $dotClose);
    imagefilledellipse($im, $cx + 30, $dotY, $dotR * 2, $dotR * 2, $dotMinimize);
    imagefilledellipse($im, $cx + 44, $dotY, $dotR * 2, $dotR * 2, $dotMaximize);

    // Theme name centered in title bar
    $fg       = alloc($im, $theme['foreground']);
    $nameFont = 3;
    $nameW    = strlen($theme['name']) * imagefontwidth($nameFont);
    $nameX    = $cx + (int) (($cardW - $nameW) / 2);
    $nameY    = $cy + (int) (($titleBarH - imagefontheight($nameFont)) / 2);
    imagestring($im, $nameFont, $nameX, $nameY, $theme['name'], $fg);

    // Two swatch rows: normal (top) and bright (bottom)
    $swRow1Y = $cy + $titleBarH + 12;
    $swRow2Y = $swRow1Y + $swatchH + $swatchGap;
    $swStartX = $cx + (int) (($cardW - count($colorKeys) * ($swatchW + $swatchGap) + $swatchGap) / 2);

    foreach ($colorKeys as $ki => $key) {
        $sx = $swStartX + $ki * ($swatchW + $swatchGap);

        // Normal swatch
        $c = alloc($im, $theme['colors'][$key]);
        imagefilledrectangle($im, $sx, $swRow1Y, $sx + $swatchW - 1, $swRow1Y + $swatchH - 1, $c);

        // Bright swatch
        $cb = alloc($im, $theme['colors']['bright-' . $key]);
        imagefilledrectangle($im, $sx, $swRow2Y, $sx + $swatchW - 1, $swRow2Y + $swatchH - 1, $cb);
    }

    // Row labels
    $labelFont = 1;
    imagestring($im, $labelFont, $swStartX, $swRow1Y - imagefontheight($labelFont) - 2, 'normal', $dimGray);
    imagestring($im, $labelFont, $swStartX, $swRow2Y - imagefontheight($labelFont) - 2, 'bright', $dimGray);

    // Fake terminal prompt line
    $promptY   = $swRow2Y + $swatchH + 10;
    $promptFont = 2;
    $green = alloc($im, $theme['colors']['green']);
    $blue  = alloc($im, $theme['colors']['blue']);
    $charW = imagefontwidth($promptFont);

    $promptStr  = 'user@' . strtolower(str_replace(' ', '-', $theme['name'])) . ':~$ ';
    $commandStr = 'echo "Hello, ' . $theme['name'] . '"';

    imagestring($im, $promptFont, $cx + 10, $promptY, $promptStr, $green);
    $cmdX = $cx + 10 + strlen($promptStr) * $charW;
    imagestring($im, $promptFont, $cmdX, $promptY, $commandStr, $fg);

    $outputY = $promptY + imagefontheight($promptFont) + 2;
    $yellow  = alloc($im, $theme['colors']['yellow']);
    imagestring($im, $promptFont, $cx + 10, $outputY, 'Hello, ' . $theme['name'] . '!', $yellow);
}

header('Content-Type: image/png');
imagepng($im);
imagedestroy($im);
