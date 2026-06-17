<?php
/**
 * Country flag sheet — PNG (default) or SVG
 *
 * Usage:
 *   colortest.php            → PNG sheet (requires PHP GD)
 *   colortest.php?format=svg → SVG sheet (no dependencies)
 *
 * Supported flag types: horizontal-stripes, vertical-stripes,
 *   N-degree-stripes, nordic-cross, cross, saltire, triangle-hoist, circle
 */

$scale  = 10;
$format = (isset($_GET['format']) && $_GET['format'] === 'svg') ? 'svg' : 'png';

$raw = file_get_contents('https://raw.githubusercontent.com/smol-kitten/common-ressources/refs/heads/main/flags/countries/flags.json');
$flags = json_decode($raw, true);

if (!$flags) {
    http_response_code(500);
    die('Error loading flags data.');
}

// ── Layout constants ───────────────────────────────────────────────────────────

$flagH   = 10 * $scale;   // 100 px
$flagW   = 15 * $scale;   // 150 px
$cols    = 9;
$padL    = 10 * $scale;
$padT    = 10 * $scale;
$gapX    =  5 * $scale;
$gapY    =  4 * $scale;
$labelH  =  4 * $scale;
$cellW   = $flagW + $gapX;
$cellH   = $flagH + $labelH + $gapY;
$rows    = (int) ceil(count($flags) / $cols);
$totalW  = $padL * 2 + $cols * $flagW + ($cols - 1) * $gapX;
$totalH  = $padT * 2 + $rows * $cellH - $gapY;

// ── Helpers ───────────────────────────────────────────────────────────────────

function hexToRgb($hex) {
    $hex = ltrim($hex, '#');
    if (strlen($hex) === 3) {
        $hex = $hex[0].$hex[0].$hex[1].$hex[1].$hex[2].$hex[2];
    }
    return [hexdec(substr($hex, 0, 2)), hexdec(substr($hex, 2, 2)), hexdec(substr($hex, 4, 2))];
}

function xe($s) { return htmlspecialchars((string)$s, ENT_XML1 | ENT_QUOTES, 'UTF-8'); }

// Returns SVG polygon points string for an n-pointed star, first point at top.
function star_polygon_svg($cx, $cy, $outerR, $innerR, $n = 5) {
    $pts = [];
    for ($i = 0; $i < 2 * $n; $i++) {
        $r = ($i % 2 === 0) ? $outerR : $innerR;
        $a = -M_PI / 2 + ($i * M_PI / $n);
        $pts[] = round($cx + $r * cos($a), 2) . ',' . round($cy + $r * sin($a), 2);
    }
    return implode(' ', $pts);
}

// ── SVG flag body renderer ─────────────────────────────────────────────────────
// Returns inner SVG elements (no <svg> wrapper) for a $w × $h viewport.

function flagBodySVG($f, $w, $h) {
    $colors = $f['colors'] ?? [];
    $type   = $f['type']   ?? 'horizontal-stripes';
    $n      = count($colors);
    $parts  = [];

    // ── helpers reused across shapes ──────────────────────────────────────────

    // diagonal polygon band centered at ($cx,$cy) going along direction ($dx,$dy)
    $diagBand = function($cx, $cy, $angle_rad, $diag, $hw, $fill) use (&$parts) {
        $dx = cos($angle_rad); $dy = sin($angle_rad);
        $nx = -$dy;            $ny = $dx;
        $pts = [
            round($cx - $dx*$diag - $nx*$hw, 2).','.round($cy - $dy*$diag - $ny*$hw, 2),
            round($cx - $dx*$diag + $nx*$hw, 2).','.round($cy - $dy*$diag + $ny*$hw, 2),
            round($cx + $dx*$diag + $nx*$hw, 2).','.round($cy + $dy*$diag + $ny*$hw, 2),
            round($cx + $dx*$diag - $nx*$hw, 2).','.round($cy + $dy*$diag - $ny*$hw, 2),
        ];
        $parts[] = '<polygon points="'.implode(' ', $pts).'" fill="'.xe($fill).'"/>';
    };

    $bg = function($c) use ($w, $h, &$parts) {
        $parts[] = '<rect x="0" y="0" width="'.$w.'" height="'.$h.'" fill="'.xe($c).'"/>';
    };

    // ── shape dispatch ─────────────────────────────────────────────────────────

    if ($type === 'vertical-stripes') {
        $sw = $w / $n;
        foreach ($colors as $i => $c) {
            $parts[] = sprintf('<rect x="%.2f" y="0" width="%.2f" height="%d" fill="%s"/>',
                $i * $sw, $sw, $h, xe($c));
        }

    } elseif (preg_match('/^(\d+(?:\.\d+)?)-degree-stripes$/', $type, $m)) {
        $rad  = deg2rad((float) $m[1]);
        $dx   = cos($rad); $dy = sin($rad);
        $nx   = -$dy;      $ny = $dx;
        $diag = sqrt($w * $w + $h * $h);
        $sw   = $diag / $n;
        for ($i = 0; $i < $n; $i++) {
            $ci = $i - ($n - 1) / 2;
            $cx = $w / 2 + $nx * $ci * $sw;
            $cy = $h / 2 + $ny * $ci * $sw;
            $diagBand($cx, $cy, $rad, $diag, $sw / 2, $colors[$i]);
        }

    } elseif ($type === 'nordic-cross' || $type === 'cross') {
        $crossX = ($type === 'nordic-cross') ? ($f['cross_x'] ?? 0.4) : 0.5;
        $armW   = ($f['cross_arm_width'] ?? 0.2) * $h;
        $vx     = $crossX * $w;
        $hy     = $h / 2;

        $bg($colors[0]);

        if ($n >= 3) {
            // outer bar (colors[1]) then narrower inner bar (colors[2])
            foreach ([[$armW, $colors[1]], [$armW * 0.58, $colors[2]]] as [$bw, $bc]) {
                $parts[] = sprintf('<rect x="%.2f" y="0" width="%.2f" height="%d" fill="%s"/>',
                    $vx - $bw / 2, $bw, $h, xe($bc));
                $parts[] = sprintf('<rect x="0" y="%.2f" width="%d" height="%.2f" fill="%s"/>',
                    $hy - $bw / 2, $w, $bw, xe($bc));
            }
        } else {
            $parts[] = sprintf('<rect x="%.2f" y="0" width="%.2f" height="%d" fill="%s"/>',
                $vx - $armW / 2, $armW, $h, xe($colors[1]));
            $parts[] = sprintf('<rect x="0" y="%.2f" width="%d" height="%.2f" fill="%s"/>',
                $hy - $armW / 2, $w, $armW, xe($colors[1]));
        }

    } elseif ($type === 'saltire') {
        $hw   = ($f['cross_arm_width'] ?? 0.12) * $h / 2;
        $diag = sqrt($w * $w + $h * $h);
        $cx   = $w / 2; $cy = $h / 2;

        if ($n === 2) {
            $bg($colors[0]);
            foreach ([atan2($h, $w), atan2(-$h, $w)] as $angle) {
                $diagBand($cx, $cy, $angle, $diag, $hw, $colors[1]);
            }
        } else {
            // colors[0]=X, colors[1]=top/bottom triangles, colors[2]=left/right triangles
            $cxs = round($cx, 1); $cys = round($cy, 1);
            $parts[] = '<polygon points="0,0 '.$w.',0 '.$cxs.','.$cys.'" fill="'.xe($colors[1]).'"/>';
            $parts[] = '<polygon points="0,'.$h.' '.$w.','.$h.' '.$cxs.','.$cys.'" fill="'.xe($colors[1]).'"/>';
            $parts[] = '<polygon points="0,0 0,'.$h.' '.$cxs.','.$cys.'" fill="'.xe($colors[2]).'"/>';
            $parts[] = '<polygon points="'.$w.',0 '.$w.','.$h.' '.$cxs.','.$cys.'" fill="'.xe($colors[2]).'"/>';
            foreach ([atan2($h, $w), atan2(-$h, $w)] as $angle) {
                $diagBand($cx, $cy, $angle, $diag, $hw, $colors[0]);
            }
        }

    } elseif ($type === 'triangle-hoist') {
        // last color = triangle; preceding colors = horizontal stripes top→bottom
        $depth   = ($f['hoist_depth'] ?? 0.4) * $w;
        $stripe  = array_slice($colors, 0, -1);
        $triC    = $colors[$n - 1];
        $ns      = count($stripe);
        $sh      = $h / max(1, $ns);

        foreach ($stripe as $i => $c) {
            $parts[] = sprintf('<rect x="0" y="%.2f" width="%d" height="%.2f" fill="%s"/>',
                $i * $sh, $w, $sh, xe($c));
        }
        $parts[] = sprintf('<polygon points="0,0 %.2f,%.2f 0,%d" fill="%s"/>',
            $depth, $h / 2, $h, xe($triC));

    } elseif ($type === 'circle') {
        $r = ($f['circle_radius'] ?? 0.3) * $h;
        $bg($colors[0]);
        $parts[] = sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>',
            $w / 2, $h / 2, $r, xe($colors[1]));

    } elseif ($type === 'quarters') {
        $hw = $w / 2; $hh = $h / 2;
        foreach ([[$colors[0],0,0],[$colors[1]??$colors[0],$hw,0],[$colors[2]??$colors[0],0,$hh],[$colors[3]??$colors[1]??$colors[0],$hw,$hh]] as [$c,$x,$y]) {
            $parts[] = sprintf('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s"/>',
                $x, $y, $hw, $hh, xe($c));
        }

    } elseif ($type === 'crescent-star') {
        $bg($colors[0]);
        if (!empty($f['hoist_stripe'])) {
            $sw = ($f['hoist_stripe_width'] ?? 0.25) * $w;
            $parts[] = sprintf('<rect x="0" y="0" width="%.2f" height="%d" fill="%s"/>', $sw, $h, xe($f['hoist_stripe']));
        }
        $cx  = ($f['crescent_x'] ?? (!empty($f['hoist_stripe']) ? 0.58 : 0.48)) * $w;
        $cy  = $h / 2;
        $r   = ($f['crescent_radius'] ?? 0.28) * $h;
        $off = ($f['crescent_offset'] ?? 0.22) * $r * 2;
        $cutC = ($n >= 3) ? $colors[2] : $colors[0];
        if ($n >= 3) {
            $br = ($f['backdrop_radius'] ?? 0.36) * $h;
            $parts[] = sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>', $cx, $cy, $br, xe($colors[2]));
        }
        $parts[] = sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>', $cx, $cy, $r, xe($colors[1]));
        $parts[] = sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>', $cx - $off, $cy, $r * 0.83, xe($cutC));
        $sx = $cx + $r * ($f['star_offset'] ?? 0.65);
        $sr = ($f['star_size'] ?? 0.11) * $h;
        $parts[] = '<polygon points="' . star_polygon_svg($sx, $cy, $sr, $sr * 0.42) . '" fill="' . xe($colors[1]) . '"/>';

    } elseif ($type === 'pall') {
        $jx    = ($f['pall_x']     ?? 0.45) * $w;
        $jy    = $h / 2;
        $phw   = ($f['pall_width'] ?? 0.17) * $h / 2;
        $diag2 = sqrt($w * $w + $h * $h);
        $leftC   = $f['pall_left']   ?? $colors[0];
        $borderC = $f['pall_border'] ?? null;
        $parts[] = sprintf('<rect x="0" y="0" width="%d" height="%.2f" fill="%s"/>', $w, $jy, xe($colors[1]));
        $parts[] = sprintf('<rect x="0" y="%.2f" width="%d" height="%.2f" fill="%s"/>', $jy, $w, $jy, xe($colors[2]));
        $parts[] = sprintf('<polygon points="0,0 %.2f,%.2f 0,%d" fill="%s"/>', $jx, $jy, $h, xe($leftC));
        $arms = [M_PI, atan2(-$jy, $w - $jx), atan2($h - $jy, $w - $jx)];
        $drawPallArm = function($hw, $col) use (&$parts, $jx, $jy, $diag2, $arms) {
            foreach ($arms as $a) {
                $dx = cos($a); $dy = sin($a); $nx = -$dy; $ny = $dx;
                $pts = [
                    round($jx-$dx*$diag2-$nx*$hw,2).','.round($jy-$dy*$diag2-$ny*$hw,2),
                    round($jx-$dx*$diag2+$nx*$hw,2).','.round($jy-$dy*$diag2+$ny*$hw,2),
                    round($jx+$dx*$diag2+$nx*$hw,2).','.round($jy+$dy*$diag2+$ny*$hw,2),
                    round($jx+$dx*$diag2-$nx*$hw,2).','.round($jy+$dy*$diag2-$ny*$hw,2),
                ];
                $parts[] = '<polygon points="'.implode(' ',$pts).'" fill="'.xe($col).'"/>';
            }
        };
        if ($borderC) $drawPallArm($phw + ($f['pall_border_width'] ?? 4), $borderC);
        $drawPallArm($phw, $colors[0]);

    } else {
        // Default: horizontal stripes
        $sh = $h / max(1, $n);
        foreach ($colors as $i => $c) {
            $parts[] = sprintf('<rect x="0" y="%.2f" width="%d" height="%.2f" fill="%s"/>',
                $i * $sh, $w, $sh, xe($c));
        }
    }

    return implode('', $parts);
}

// ── PNG GD renderer ───────────────────────────────────────────────────────────

function createFlagImage($f, $w, $h) {
    $img    = imagecreatetruecolor($w, $h);
    $colors = $f['colors'] ?? [];
    $type   = $f['type']   ?? 'horizontal-stripes';
    $n      = count($colors);

    $alloc = function($hex) use ($img) {
        [$r, $g, $b] = hexToRgb($hex);
        return imagecolorallocate($img, $r, $g, $b);
    };

    $diagBand = function($cx, $cy, $angle, $diag, $hw, $col) use ($img) {
        $dx = cos($angle); $dy = sin($angle);
        $nx = -$dy;        $ny = $dx;
        imagefilledpolygon($img, [
            (int)round($cx - $dx*$diag - $nx*$hw), (int)round($cy - $dy*$diag - $ny*$hw),
            (int)round($cx - $dx*$diag + $nx*$hw), (int)round($cy - $dy*$diag + $ny*$hw),
            (int)round($cx + $dx*$diag + $nx*$hw), (int)round($cy + $dy*$diag + $ny*$hw),
            (int)round($cx + $dx*$diag - $nx*$hw), (int)round($cy + $dy*$diag - $ny*$hw),
        ], $col);
    };

    if ($type === 'vertical-stripes') {
        $sw = $w / $n;
        foreach ($colors as $i => $c) {
            imagefilledrectangle($img, (int)($i*$sw), 0, (int)(($i+1)*$sw)-1, $h-1, $alloc($c));
        }

    } elseif (preg_match('/^(\d+(?:\.\d+)?)-degree-stripes$/', $type, $m)) {
        $rad  = deg2rad((float) $m[1]);
        $diag = sqrt($w * $w + $h * $h);
        $sw   = $diag / $n;
        $dx   = cos($rad); $dy = sin($rad);
        $nx   = -$dy;      $ny = $dx;
        for ($i = 0; $i < $n; $i++) {
            $ci = $i - ($n - 1) / 2;
            $cx = $w / 2 + $nx * $ci * $sw;
            $cy = $h / 2 + $ny * $ci * $sw;
            $diagBand($cx, $cy, $rad, $diag, $sw / 2, $alloc($colors[$i]));
        }

    } elseif ($type === 'nordic-cross' || $type === 'cross') {
        $crossX = ($type === 'nordic-cross') ? ($f['cross_x'] ?? 0.4) : 0.5;
        $armW   = (int) (($f['cross_arm_width'] ?? 0.2) * $h);
        $vx     = (int) ($crossX * $w);
        $hy     = (int) ($h / 2);

        imagefilledrectangle($img, 0, 0, $w-1, $h-1, $alloc($colors[0]));

        if ($n >= 3) {
            foreach ([[$armW, $colors[1]], [(int)($armW * 0.58), $colors[2]]] as [$bw, $bc]) {
                $col = $alloc($bc);
                imagefilledrectangle($img, $vx-(int)($bw/2), 0,    $vx+(int)($bw/2), $h-1,  $col);
                imagefilledrectangle($img, 0, $hy-(int)($bw/2),    $w-1, $hy+(int)($bw/2),  $col);
            }
        } else {
            $col = $alloc($colors[1]);
            imagefilledrectangle($img, $vx-(int)($armW/2), 0,  $vx+(int)($armW/2), $h-1, $col);
            imagefilledrectangle($img, 0, $hy-(int)($armW/2),  $w-1, $hy+(int)($armW/2),  $col);
        }

    } elseif ($type === 'saltire') {
        $hw   = (int) (($f['cross_arm_width'] ?? 0.12) * $h / 2);
        $diag = sqrt($w * $w + $h * $h);
        $cx   = $w / 2; $cy = $h / 2;

        if ($n === 2) {
            imagefilledrectangle($img, 0, 0, $w-1, $h-1, $alloc($colors[0]));
            $col = $alloc($colors[1]);
            $diagBand($cx, $cy, atan2($h, $w),  $diag, $hw, $col);
            $diagBand($cx, $cy, atan2(-$h, $w), $diag, $hw, $col);
        } else {
            // 3-color: X=colors[0], top/bottom=colors[1], left/right=colors[2]
            imagefilledpolygon($img, [0,0, $w,0, (int)$cx,(int)$cy], $alloc($colors[1]));
            imagefilledpolygon($img, [0,$h, $w,$h, (int)$cx,(int)$cy], $alloc($colors[1]));
            imagefilledpolygon($img, [0,0, 0,$h, (int)$cx,(int)$cy], $alloc($colors[2]));
            imagefilledpolygon($img, [$w,0, $w,$h, (int)$cx,(int)$cy], $alloc($colors[2]));
            $col = $alloc($colors[0]);
            $diagBand($cx, $cy, atan2($h, $w),  $diag, $hw, $col);
            $diagBand($cx, $cy, atan2(-$h, $w), $diag, $hw, $col);
        }

    } elseif ($type === 'triangle-hoist') {
        $depth  = (int) (($f['hoist_depth'] ?? 0.4) * $w);
        $stripe = array_slice($colors, 0, -1);
        $triC   = $colors[$n - 1];
        $ns     = count($stripe);
        $sh     = $h / max(1, $ns);

        foreach ($stripe as $i => $c) {
            imagefilledrectangle($img, 0, (int)($i*$sh), $w-1, (int)(($i+1)*$sh)-1, $alloc($c));
        }
        imagefilledpolygon($img, [0, 0, $depth, (int)($h/2), 0, $h], $alloc($triC));

    } elseif ($type === 'circle') {
        $r = (int) (($f['circle_radius'] ?? 0.3) * $h);
        imagefilledrectangle($img, 0, 0, $w-1, $h-1, $alloc($colors[0]));
        imagefilledellipse($img, (int)($w/2), (int)($h/2), $r*2, $r*2, $alloc($colors[1]));

    } elseif ($type === 'quarters') {
        $hw = (int)($w / 2); $hh = (int)($h / 2);
        imagefilledrectangle($img, 0,  0,  $hw-1, $hh-1, $alloc($colors[0]));
        imagefilledrectangle($img, $hw, 0,  $w-1,  $hh-1, $alloc($colors[1] ?? $colors[0]));
        imagefilledrectangle($img, 0,  $hh, $hw-1, $h-1,  $alloc($colors[2] ?? $colors[0]));
        imagefilledrectangle($img, $hw, $hh, $w-1, $h-1,  $alloc($colors[3] ?? $colors[1] ?? $colors[0]));

    } elseif ($type === 'crescent-star') {
        imagefilledrectangle($img, 0, 0, $w-1, $h-1, $alloc($colors[0]));
        if (!empty($f['hoist_stripe'])) {
            $sw = (int)(($f['hoist_stripe_width'] ?? 0.25) * $w);
            imagefilledrectangle($img, 0, 0, $sw-1, $h-1, $alloc($f['hoist_stripe']));
        }
        $cx  = (int)(($f['crescent_x'] ?? (!empty($f['hoist_stripe']) ? 0.58 : 0.48)) * $w);
        $cy  = (int)($h / 2);
        $r   = (int)(($f['crescent_radius'] ?? 0.28) * $h);
        $off = (int)(($f['crescent_offset'] ?? 0.22) * $r * 2);
        $cutC = ($n >= 3) ? $colors[2] : $colors[0];
        if ($n >= 3) {
            $br = (int)(($f['backdrop_radius'] ?? 0.36) * $h);
            imagefilledellipse($img, $cx, $cy, $br*2, $br*2, $alloc($colors[2]));
        }
        imagefilledellipse($img, $cx, $cy, $r*2, $r*2, $alloc($colors[1]));
        imagefilledellipse($img, $cx-$off, $cy, (int)($r*0.83)*2, (int)($r*0.83)*2, $alloc($cutC));
        $sx  = (int)($cx + $r * ($f['star_offset'] ?? 0.65));
        $sr  = (int)(($f['star_size'] ?? 0.11) * $h);
        $sir = (int)($sr * 0.42);
        $sPts = [];
        for ($i = 0; $i < 10; $i++) {
            $rr = ($i % 2 === 0) ? $sr : $sir;
            $a  = -M_PI / 2 + ($i * M_PI / 5);
            $sPts[] = (int)round($sx + $rr * cos($a));
            $sPts[] = (int)round($cy + $rr * sin($a));
        }
        imagefilledpolygon($img, $sPts, $alloc($colors[1]));

    } elseif ($type === 'pall') {
        $jx    = (int)(($f['pall_x']     ?? 0.45) * $w);
        $jy    = (int)($h / 2);
        $phw   = (int)(($f['pall_width'] ?? 0.17) * $h / 2);
        $diag2 = sqrt($w * $w + $h * $h);
        $leftC   = $f['pall_left']   ?? $colors[0];
        $borderC = $f['pall_border'] ?? null;
        imagefilledrectangle($img, 0, 0,   $w-1, $jy-1, $alloc($colors[1]));
        imagefilledrectangle($img, 0, $jy, $w-1, $h-1,  $alloc($colors[2]));
        imagefilledpolygon($img, [0, 0, $jx, $jy, 0, $h], $alloc($leftC));
        $arms = [M_PI, atan2(-$jy, $w - $jx), atan2($h - $jy, $w - $jx)];
        $drawPallArmGD = function($hw, $col) use ($img, $jx, $jy, $diag2, $arms, &$diagBand) {
            foreach ($arms as $a) { $diagBand($jx, $jy, $a, $diag2, $hw, $col); }
        };
        if ($borderC) $drawPallArmGD($phw + ($f['pall_border_width'] ?? 4), $alloc($borderC));
        $drawPallArmGD($phw, $alloc($colors[0]));

    } else {
        // Default: horizontal stripes
        $sh = $h / max(1, $n);
        foreach ($colors as $i => $c) {
            imagefilledrectangle($img, 0, (int)($i*$sh), $w-1, (int)(($i+1)*$sh)-1, $alloc($c));
        }
    }

    return $img;
}

// ── SVG output ────────────────────────────────────────────────────────────────

if ($format === 'svg') {
    header('Content-Type: image/svg+xml; charset=UTF-8');
    $fontSize = max(7, (int)($labelH * 0.55));

    $out  = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    $out .= '<svg xmlns="http://www.w3.org/2000/svg"'
          . ' width="' . $totalW . '" height="' . $totalH . '">' . "\n";
    $out .= '<rect width="' . $totalW . '" height="' . $totalH . '" fill="#ffffff"/>' . "\n";

    $col = 0; $x = $padL; $y = $padT;
    foreach ($flags as $f) {
        // Flag in its own nested SVG viewport
        $out .= sprintf('<svg x="%d" y="%d" width="%d" height="%d" viewBox="0 0 %d %d">' . "\n",
            $x, $y, $flagW, $flagH, $flagW, $flagH);
        $out .= flagBodySVG($f, $flagW, $flagH) . "\n";
        $out .= '</svg>' . "\n";

        // Label below flag
        $label = xe($f['name'] ?? 'Unknown');
        if (!empty($f['iso'])) $label .= ' (' . xe($f['iso']) . ')';
        $out .= sprintf('<text x="%d" y="%d" font-family="sans-serif" font-size="%d"'
              . ' text-anchor="middle" fill="#222">%s</text>' . "\n",
            $x + (int)($flagW / 2),
            $y + $flagH + (int)($labelH * 0.72),
            $fontSize, $label);

        $col++;
        if ($col >= $cols) { $col = 0; $x = $padL; $y += $cellH; }
        else                { $x += $cellW; }
    }

    $out .= '</svg>';
    echo $out;
    exit;
}

// ── PNG output ────────────────────────────────────────────────────────────────

header('Content-Type: image/png');

$im    = imagecreatetruecolor($totalW, $totalH);
$white = imagecolorallocate($im, 255, 255, 255);
$black = imagecolorallocate($im, 0, 0, 0);
imagefill($im, 0, 0, $white);

$fontSize = max(1, (int)($labelH * 0.35));
$col = 0; $x = $padL; $y = $padT;

foreach ($flags as $f) {
    $flagImg = createFlagImage($f, $flagW, $flagH);
    imagecopy($im, $flagImg, $x, $y, 0, 0, $flagW, $flagH);
    imagedestroy($flagImg);

    $label = ($f['name'] ?? 'Unknown');
    if (!empty($f['iso'])) $label .= ' (' . $f['iso'] . ')';
    $tw = imagefontwidth($fontSize) * strlen($label);
    imagestring($im, $fontSize, $x + (int)(($flagW - $tw) / 2), $y + $flagH + $scale, $label, $black);

    $col++;
    if ($col >= $cols) { $col = 0; $x = $padL; $y += $cellH; }
    else                { $x += $cellW; }
}

imagepng($im);
imagedestroy($im);
