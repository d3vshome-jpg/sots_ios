<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('friend', 20, 60);
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth = authenticate();
$userId = $auth['id'];
$input = getJsonInput();
$friendId = (int)($input['friend_id'] ?? 0);

if (!$friendId || $friendId == $userId) {
    jsonResponse(['error' => 'Некорректный friend_id'], 400);
}

// Проверяем, существует ли пользователь
$stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
$stmt->execute([$friendId]);
if (!$stmt->fetch()) {
    jsonResponse(['error' => 'Пользователь не найден'], 404);
}

// Проверяем, не друзья ли уже
$stmt = $pdo->prepare("SELECT COUNT(*) FROM friends WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)");
$stmt->execute([$userId, $friendId, $friendId, $userId]);
if ($stmt->fetchColumn() > 0) {
    jsonResponse(['error' => 'Вы уже друзья'], 400);
}

function updateFriendsField($pdo, $uid) {
    $stmt = $pdo->prepare("SELECT friend_id FROM friends WHERE user_id = ?");
    $stmt->execute([$uid]);
    $friends = $stmt->fetchAll(PDO::FETCH_COLUMN);
    $pdo->prepare("UPDATE users SET friends = ? WHERE id = ?")->execute([json_encode($friends), $uid]);
}

$pdo->beginTransaction();
try {
    $stmt = $pdo->prepare("INSERT IGNORE INTO friends (user_id, friend_id) VALUES (?, ?), (?, ?)");
    $stmt->execute([$userId, $friendId, $friendId, $userId]);

    updateFriendsField($pdo, $userId);
    updateFriendsField($pdo, $friendId);

    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, from_user_id, type, object_id, created_at, is_read)
        VALUES (?, ?, 'friend', ?, NOW(), 0)
    ");
    $stmt->execute([$friendId, $userId, $userId]);
    $pdo->commit();
} catch (Exception $e) {
    $pdo->rollBack();
    jsonResponse(['error' => 'Ошибка сервера'], 500);
}

jsonResponse(['success' => true]);