<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('post', 10, 60);
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$auth   = authenticate();
$userId = $auth['id'];

// ID поста может прийти через JSON
$input  = getJsonInput();
$postId = (int)($input['post_id'] ?? 0);

if (!$postId) {
    jsonResponse(['error' => 'post_id обязателен'], 400);
}

$stmt = $pdo->prepare("SELECT user_id FROM posts WHERE id = ?");
$stmt->execute([$postId]);
$post = $stmt->fetch();

if (!$post) {
    jsonResponse(['error' => 'Пост не найден'], 404);
}
if ($post['user_id'] != $userId) {
    jsonResponse(['error' => 'Недостаточно прав'], 403);
}

$stmt = $pdo->prepare("DELETE FROM posts WHERE id = ?");
$stmt->execute([$postId]);

jsonResponse(['success' => true]);