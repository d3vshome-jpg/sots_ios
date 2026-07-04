<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('message', 20, 60);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth   = authenticate();
$userId = $auth['id'];
$input  = getJsonInput();

$text    = trim($input['text'] ?? '');
$images  = $input['images'] ?? [];
$replyTo = $input['reply_to'] ?? null;

if (!is_array($images)) $images = [];

if ($text === '' && empty($images)) {
    jsonResponse(['error' => 'Сообщение не может быть пустым'], 400);
}

$stmt = $pdo->prepare("INSERT INTO messages (from_user_id, text, images, reply_to) VALUES (?, ?, ?, ?)");
$stmt->execute([$userId, $text, json_encode($images), $replyTo]);

jsonResponse(['success' => true]);