<?php

$scale = 10;

$width = 200 * $scale;
$height = 0;

$flags = file_get_contents('https://raw.githubusercontent.com/polo-nyan/common-ressources/refs/heads/main/flags/countries/flags.json');

$flags = json_decode($flags, true);

if (!$flags) {
    die('Error loading flags data.');
}

$flagRows = ceil(count($flags) / 9);
$height = $flagRows * (14 * $scale) + (20 * $scale);

header("Content-Type: image/png");
$im = imagecreatetruecolor($width, $height);

$white = imagecolorallocate($im, 255, 255, 255);
imagefill($im, 0, 0, $white);

function hexToRgb($hex)
{
    $hex = str_replace('#', '', $hex);
    if (strlen($hex) == 3) {
        $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
    }
    return [
        hexdec(substr($hex, 0, 2)),
        hexdec(substr($hex, 2, 2)),
        hexdec(substr($hex, 4, 2))
    ];
}

function createFlagImage($flagData, $width, $height)
{
    $flag = imagecreatetruecolor($width, $height);
    $colors = $flagData['colors'];
    $type = $flagData['type'] ?? 'horizontal-stripes';

    $angle = null;
    if (preg_match('/(\d+)-degree-stripes$/', $type, $matches)) {
        $angle = intval($matches[1]);
    }

    if ($type === 'vertical-stripes') {
        $stripeWidth = $width / count($colors);
        foreach ($colors as $i => $color) {
            $rgb = hexToRgb($color);
            $col = imagecolorallocate($flag, $rgb[0], $rgb[1], $rgb[2]);
            imagefilledrectangle($flag, (int)($i * $stripeWidth), 0, (int)(($i + 1) * $stripeWidth), $height, $col);
        }
    } elseif ($angle !== null) {
        $diagonalLength = sqrt($width * $width + $height * $height);
        $stripeWidth = $diagonalLength / count($colors);
        $radians = deg2rad($angle);

        $dx = cos($radians);
        $dy = sin($radians);
        $nx = -$dy;
        $ny = $dx;

        for ($i = 0; $i < count($colors); $i++) {
            $rgb = hexToRgb($colors[$i]);
            $col = imagecolorallocate($flag, $rgb[0], $rgb[1], $rgb[2]);

            $centeredIndex = $i - (count($colors) - 1) / 2;
            $cx = $width / 2 + $nx * $centeredIndex * $stripeWidth;
            $cy = $height / 2 + $ny * $centeredIndex * $stripeWidth;

            $half = $diagonalLength;
            $w = $stripeWidth / 2;

            $polygon = [
                round($cx - $dx * $half - $nx * $w),
                round($cy - $dy * $half - $ny * $w),
                round($cx - $dx * $half + $nx * $w),
                round($cy - $dy * $half + $ny * $w),
                round($cx + $dx * $half + $nx * $w),
                round($cy + $dy * $half + $ny * $w),
                round($cx + $dx * $half - $nx * $w),
                round($cy + $dy * $half - $ny * $w),
            ];

            imagefilledpolygon($flag, $polygon, $col);
        }
    } else {
        // Default: horizontal stripes
        $stripeHeight = $height / count($colors);
        foreach ($colors as $i => $color) {
            $rgb = hexToRgb($color);
            $col = imagecolorallocate($flag, $rgb[0], $rgb[1], $rgb[2]);
            imagefilledrectangle($flag, 0, (int)($i * $stripeHeight), $width, (int)(($i + 1) * $stripeHeight), $col);
        }
    }

    return $flag;
}

$flagHeight = 10 * $scale;
$flagWidth = 15 * $scale;
$flagX = 10 * $scale;
$flagY = 10 * $scale;

foreach ($flags as $flagData) {
    $flagImage = createFlagImage($flagData, $flagWidth, $flagHeight);
    imagecopy($im, $flagImage, $flagX, $flagY, 0, 0, $flagWidth, $flagHeight);
    imagedestroy($flagImage);

    $label = $flagData['name'] ?? 'Unknown';
    if (isset($flagData['iso'])) {
        $label .= ' (' . $flagData['iso'] . ')';
    }
    $fontSize = 2 * $scale;
    $textColor = imagecolorallocate($im, 0, 0, 0);
    $textWidth = imagefontwidth($fontSize) * strlen($label);
    $textX = $flagX + ($flagWidth - $textWidth) / 2;
    $textY = $flagY + $flagHeight + 2 * $scale;

    imagestring($im, $fontSize, (int)$textX, (int)$textY, $label, $textColor);

    $flagX += $flagWidth + 5 * $scale;
    if ($flagX + $flagWidth > $width - 10 * $scale) {
        $flagX = 10 * $scale;
        $flagY += $flagHeight + 4 * $scale;
    }
}

imagepng($im);
imagedestroy($im);
