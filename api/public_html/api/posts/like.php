<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('like', 30, 60);
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth = authenticate();
$userId = $auth['id'];
$input = getJsonInput();
$postId = (int)($input['post_id'] ?? 0);

if (!$postId) {
    jsonResponse(['error' => 'Нет данных'], 400);
}

// Получаем пост
$stmt = $pdo->prepare("SELECT likes, user_id FROM posts WHERE id = ?");
$stmt->execute([$postId]);
$post = $stmt->fetch();

if (!$post) {
    jsonResponse(['error' => 'Пост не найден'], 404);
}

$likes = json_decode($post['likes'] ?? '[]', true) ?: [];
$index = array_search($userId, $likes);
$isLiking = ($index === false);

if ($isLiking) {
    $likes[] = $userId;
} else {
    array_splice($likes, $index, 1);
}

// Обновляем лайки
$stmt = $pdo->prepare("UPDATE posts SET likes = ? WHERE id = ?");
$stmt->execute([json_encode($likes), $postId]);

// Если это новый лайк и не свой пост, создаём уведомление
if ($isLiking && $post['user_id'] != $userId) {
    // Создаём уведомление в отдельной таблице notifications
    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, from_user_id, type, object_id, created_at, is_read) 
        VALUES (?, ?, 'like', ?, NOW(), 0)
    ");
    $stmt->execute([$post['user_id'], $userId, $postId]);
}

jsonResponse(['likes' => $likes]);