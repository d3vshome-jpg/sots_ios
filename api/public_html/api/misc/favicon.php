<?php
// favicon.php
header('Content-Type: image/jpeg');

$logoPath = __DIR__ . '/logo.png';

if (!file_exists($logoPath)) {
    header('Content-Type: image/png');
    // Прозрачный пиксель 1x1
    echo base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    exit;
}

$logo = imagecreatefromjpeg($logoPath);
$size = 64; // размер favicon
$origW = imagesx($logo);
$origH = imagesy($logo);

$favicon = imagecreatetruecolor($size, $size);
$minSide = min($origW, $origH);
$srcX = ($origW - $minSide) / 2;
$srcY = ($origH - $minSide) / 2;

imagecopyresampled($favicon, $logo, 0, 0, (int)$srcX, (int)$srcY, $size, $size, (int)$minSide, (int)$minSide);

imagejpeg($favicon, null, 90);
imagedestroy($logo);
imagedestroy($favicon);