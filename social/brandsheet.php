<?php
// Renders all social platforms as a brand color reference sheet — PNG output
// Usage: php brandsheet.php > brandsheet.png   OR serve via web server

$platforms = json_decode(file_get_contents(
    'https://raw.githubusercontent.com/polo-nyan/common-ressources/refs/heads/main/social/platforms.json'
), true);

/*
// Local alternative:
$platforms = json_decode(file_get_contents(__DIR__ . '/platforms.json'), true);
*/

if (!$platforms) {
    die('Error loading platforms data.');
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

function textOnColor($im, $hex)
{
    [$r, $g, $b] = hexToRgb($hex);
    $lum = 0.299 * $r + 0.587 * $g + 0.114 * $b;
    return ($lum > 140)
        ? imagecolorallocate($im, 20, 20, 20)
        : imagecolorallocate($im, 240, 240, 240);
}

// Layout
$cols    = 3;
$cardW   = 250;
$cardH   = 100;
$pad     = 12;
$rows    = (int) ceil(count($platforms) / $cols);

$imgW = $pad + ($cardW + $pad) * $cols;
$imgH = $pad + ($cardH + $pad) * $rows + 30; // +30 for top title

$im     = imagecreatetruecolor($imgW, $imgH);
$canvas = imagecolorallocate($im, 24, 24, 26);
imagefill($im, 0, 0, $canvas);

// Title bar
$titleColor = imagecolorallocate($im, 200, 200, 210);
imagestring($im, 4, $pad, 8, 'Social Platform Brand Colors', $titleColor);

$offsetY = 30; // push cards below the title

foreach ($platforms as $idx => $platform) {
    $col = $idx % $cols;
    $row = (int) floor($idx / $cols);

    $cx = $pad + $col * ($cardW + $pad);
    $cy = $offsetY + $pad + $row * ($cardH + $pad);

    $brand = $platform['brand-color'];

    // Card background in brand color
    $brandCol = alloc($im, $brand);
    imagefilledrectangle($im, $cx, $cy, $cx + $cardW - 1, $cy + $cardH - 1, $brandCol);

    $textCol = textOnColor($im, $brand);
    $dimCol  = ($brand === '#000000' || hexdec(ltrim($brand, '#')) < 0x333333)
        ? imagecolorallocate($im, 150, 150, 150)
        : imagecolorallocate($im, 60, 60, 60);

    // Platform name (large)
    $nameFont = 4;
    imagestring($im, $nameFont, $cx + 10, $cy + 10, $platform['name'], $textCol);

    // Hex color
    $hexFont = 2;
    imagestring($im, $hexFont, $cx + 10, $cy + 10 + imagefontheight($nameFont) + 4, strtoupper($brand), $textCol);

    // Category
    $catFont = 1;
    imagestring($im, $catFont, $cx + 10, $cy + $cardH - imagefontheight($catFont) - 24, $platform['category'], $textCol);

    // Badges row
    $badgeY = $cy + $cardH - imagefontheight($catFont) - 12;
    $bx     = $cx + 10;

    if ($platform['open-source']) {
        imagestring($im, $catFont, $bx, $badgeY, '[OSS]', $textCol);
        $bx += 6 * imagefontwidth($catFont);
    }
    if ($platform['federated']) {
        $proto = $platform['protocol'] ?? 'federated';
        imagestring($im, $catFont, $bx, $badgeY, '[' . $proto . ']', $textCol);
    }

    // Character limit (right-aligned)
    if (!empty($platform['character-limit'])) {
        $limitStr = number_format($platform['character-limit']) . ' chars';
        $limitX   = $cx + $cardW - strlen($limitStr) * imagefontwidth($catFont) - 8;
        imagestring($im, $catFont, $limitX, $cy + $cardH - imagefontheight($catFont) - 12, $limitStr, $textCol);
    }
}

header('Content-Type: image/png');
imagepng($im);
imagedestroy($im);
