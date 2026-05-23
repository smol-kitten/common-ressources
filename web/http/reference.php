<?php
// Renders HTTP status codes as a color-coded reference sheet — PNG output
// Usage: php reference.php > reference.png   OR serve via web server

$codes = json_decode(file_get_contents(
    'https://raw.githubusercontent.com/polo-nyan/common-ressources/refs/heads/main/web/http/status-codes.json'
), true);

/*
// Local alternative:
$codes = json_decode(file_get_contents(__DIR__ . '/status-codes.json'), true);
*/

if (!$codes) {
    die('Error loading status codes data.');
}

// Category colors (background, text)
$categoryColors = [
    'informational' => ['bg' => '#1A3A4A', 'dot' => '#4DBBDD', 'label' => '1xx Informational'],
    'success'       => ['bg' => '#1A3A1A', 'dot' => '#4DDD88', 'label' => '2xx Success'],
    'redirection'   => ['bg' => '#3A3A1A', 'dot' => '#DDBB4D', 'label' => '3xx Redirection'],
    'client-error'  => ['bg' => '#3A1A1A', 'dot' => '#DD6644', 'label' => '4xx Client Error'],
    'server-error'  => ['bg' => '#2A1A2E', 'dot' => '#CC55AA', 'label' => '5xx Server Error'],
];

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

// Group codes by category preserving order
$grouped = [];
$catOrder = ['informational', 'success', 'redirection', 'client-error', 'server-error'];
foreach ($catOrder as $cat) {
    $grouped[$cat] = array_values(array_filter($codes, fn($c) => $c['category'] === $cat));
}

// Layout
$imgW      = 900;
$padH      = 20;
$rowH      = 22;
$headerH   = 28;
$sectionGap = 8;
$dotR      = 5;
$codeColW  = 42;
$nameColW  = 220;

// Pre-calculate total height
$totalH = $padH;
foreach ($grouped as $cat => $items) {
    if (empty($items)) continue;
    $totalH += $headerH + count($items) * $rowH + $sectionGap;
}
$totalH += $padH;

$im     = imagecreatetruecolor($imgW, $totalH);
$canvas = imagecolorallocate($im, 18, 18, 20);
imagefill($im, 0, 0, $canvas);

$white   = imagecolorallocate($im, 228, 228, 235);
$dimText = imagecolorallocate($im, 140, 140, 155);
$divider = imagecolorallocate($im, 40, 40, 45);

$y = $padH;

// Title
imagestring($im, 4, $padH, $y, 'HTTP Status Code Reference', $white);
$y += imagefontheight(4) + 16;

foreach ($grouped as $cat => $items) {
    if (empty($items)) continue;

    $catCfg  = $categoryColors[$cat];
    $bgCol   = alloc($im, $catCfg['bg']);
    $dotCol  = alloc($im, $catCfg['dot']);

    // Section header bar
    imagefilledrectangle($im, 0, $y, $imgW, $y + $headerH - 1, $bgCol);
    // Colored left accent stripe
    imagefilledrectangle($im, 0, $y, 4, $y + $headerH - 1, $dotCol);

    $hFont = 3;
    $hY    = $y + (int) (($headerH - imagefontheight($hFont)) / 2);
    imagestring($im, $hFont, $padH + 4, $hY, strtoupper($catCfg['label']), $dotCol);

    $y += $headerH;

    foreach ($items as $i => $entry) {
        // Alternating row background
        $rowBg = ($i % 2 === 0)
            ? imagecolorallocate($im, 24, 24, 26)
            : imagecolorallocate($im, 28, 28, 32);
        imagefilledrectangle($im, 0, $y, $imgW, $y + $rowH - 1, $rowBg);

        // Dot indicator
        $dotX = $padH + $dotR;
        $dotY = $y + (int) ($rowH / 2);
        imagefilledellipse($im, $dotX, $dotY, $dotR * 2, $dotR * 2, $dotCol);

        $textY  = $y + (int) (($rowH - imagefontheight(2)) / 2);
        $startX = $padH + $dotR * 2 + 8;

        // Status code
        $codeFont = 3;
        imagestring($im, $codeFont, $startX, $textY, (string) $entry['code'], $dotCol);

        // Name
        $nameFont = 2;
        imagestring($im, $nameFont, $startX + $codeColW, $textY + 1, $entry['name'], $white);

        // Description (truncated to fit)
        $descFont = 1;
        $descX    = $startX + $codeColW + $nameColW;
        $maxChars = (int) (($imgW - $descX - $padH) / imagefontwidth($descFont));
        $desc     = strlen($entry['description']) > $maxChars
            ? substr($entry['description'], 0, $maxChars - 1) . '…'
            : $entry['description'];
        imagestring($im, $descFont, $descX, $textY + 3, $desc, $dimText);

        // Cacheable badge (right-aligned)
        if (!empty($entry['cacheable'])) {
            $badgeStr = 'cacheable';
            $badgeX   = $imgW - $padH - strlen($badgeStr) * imagefontwidth($descFont);
            imagestring($im, $descFont, $badgeX, $textY + 3, $badgeStr, $dotCol);
        }

        $y += $rowH;
    }

    $y += $sectionGap;
}

header('Content-Type: image/png');
imagepng($im);
imagedestroy($im);
