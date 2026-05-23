<?php
// Renders all color palettes as a swatch sheet — PNG output
// Usage: php colortest.php > colortest.png   OR serve via web server

$palettes = json_decode(file_get_contents(
    'https://raw.githubusercontent.com/polo-nyan/common-ressources/refs/heads/main/colors/palettes.json'
), true);

/*
// Local alternative:
$palettes = json_decode(file_get_contents(__DIR__ . '/palettes.json'), true);
*/

if (!$palettes) {
    die('Error loading palettes data.');
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

// Layout
$imgW       = 900;
$padV       = 8;    // vertical padding between rows
$padH       = 16;   // left margin
$labelW     = 190;  // width reserved for palette name
$swatchH    = 48;
$swatchGap  = 3;
$rowH       = $swatchH + $padV * 2;

$imgH = $padV + count($palettes) * ($rowH + $padV);

$im     = imagecreatetruecolor($imgW, $imgH);
$canvas = imagecolorallocate($im, 28, 28, 30);
imagefill($im, 0, 0, $canvas);

$white   = imagecolorallocate($im, 230, 230, 230);
$subtext = imagecolorallocate($im, 130, 130, 140);
$divider = imagecolorallocate($im, 50, 50, 55);

foreach ($palettes as $idx => $palette) {
    $y = $padV + $idx * ($rowH + $padV);

    // Horizontal divider
    imagefilledrectangle($im, 0, $y - 1, $imgW, $y, $divider);

    // Palette name
    $nameFont = 3;
    $nameY    = $y + (int) (($rowH - imagefontheight($nameFont)) / 2) - 6;
    imagestring($im, $nameFont, $padH, $nameY, $palette['name'], $white);

    // Tag line below name
    if (!empty($palette['tags'])) {
        $tagStr  = implode(', ', $palette['tags']);
        $tagFont = 1;
        imagestring($im, $tagFont, $padH, $nameY + imagefontheight($nameFont) + 3, $tagStr, $subtext);
    }

    // Color swatches
    $colors   = $palette['colors'];
    $count    = count($colors);
    $maxW     = $imgW - $labelW - $padH * 2;
    $swW      = min(72, (int) (($maxW - ($count - 1) * $swatchGap) / $count));
    $swStartX = $padH + $labelW;
    $swY      = $y + $padV;

    foreach ($colors as $ci => $color) {
        $sx = $swStartX + $ci * ($swW + $swatchGap);

        // Swatch rectangle
        [$r, $g, $b] = hexToRgb($color['hex']);
        $c = imagecolorallocate($im, $r, $g, $b);
        imagefilledrectangle($im, $sx, $swY, $sx + $swW - 1, $swY + $swatchH - 1, $c);

        // Color name below swatch (tiny)
        $labelFont = 1;
        $labelStr  = strtoupper(ltrim($color['hex'], '#'));
        $labelX    = $sx + (int) (($swW - strlen($labelStr) * imagefontwidth($labelFont)) / 2);
        $labelY    = $swY + $swatchH - imagefontheight($labelFont) - 2;

        // Determine contrasting text color
        $luminance = 0.299 * $r + 0.587 * $g + 0.114 * $b;
        $textCol   = ($luminance > 128)
            ? imagecolorallocate($im, 0, 0, 0)
            : imagecolorallocate($im, 255, 255, 255);

        imagestring($im, $labelFont, $labelX, $labelY, $labelStr, $textCol);
    }
}

header('Content-Type: image/png');
imagepng($im);
imagedestroy($im);
