<?php
require_once __DIR__ . '/../../core/config.php';

$userId = authenticate();
$input = getJsonInput();
$postId = (int)($input['post_id'] ?? 0);
$newCaption = $input['caption'] ?? '';

$stmt = $pdo->prepare("SELECT user_id FROM posts WHERE id = ?");
$stmt->execute([$postId]);
$post = $stmt->fetch();
if (!$post || $post['user_id'] != $userId) {
    jsonResponse(['error' => 'Пост не найден или нет прав'], 403);
}

$stmt = $pdo->prepare("UPDATE posts SET caption = ? WHERE id = ?");
$stmt->execute([$newCaption, $postId]);
jsonResponse(['success' => true]);