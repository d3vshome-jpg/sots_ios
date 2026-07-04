<?php
require_once __DIR__ . '/../../core/config.php';
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth   = authenticate();
$userId = $auth['id'];
$input  = getJsonInput();

$msgId = (int)($input['message_id'] ?? 0);
$text  = trim($input['text'] ?? '');

if (!$msgId) {
    jsonResponse(['error' => 'message_id обязателен'], 400);
}

// Проверяем владельца
$stmt = $pdo->prepare("SELECT from_user_id FROM messages WHERE id = ?");
$stmt->execute([$msgId]);
$msg = $stmt->fetch();

if (!$msg) {
    jsonResponse(['error' => 'Сообщение не найдено'], 404);
}
if ($msg['from_user_id'] != $userId) {
    jsonResponse(['error' => 'Недостаточно прав'], 403);
}

$stmt = $pdo->prepare("UPDATE messages SET text = ? WHERE id = ?");
$stmt->execute([$text, $msgId]);

jsonResponse(['success' => true]);