<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('report', 5, 60);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth = authenticate();
$userId = $auth['id'];
$input = getJsonInput();

$type = trim($input['type'] ?? '');
$objectId = (int)($input['object_id'] ?? 0);

if (!in_array($type, ['post', 'user', 'message'])) {
    jsonResponse(['error' => 'Недопустимый тип жалобы'], 400);
}

if ($objectId <= 0) {
    jsonResponse(['error' => 'Некорректный object_id'], 400);
}

$stmt = $pdo->prepare("INSERT INTO reports (type, object_id, from_user_id, reason) VALUES (?, ?, ?, 'Жалоба')");
$stmt->execute([$type, $objectId, $userId]);

jsonResponse(['success' => true]);
