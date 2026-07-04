<?php
require_once __DIR__ . '/../../core/config.php';
$userId = authenticate();
$input = getJsonInput();
$commentId = (int)($input['comment_id'] ?? 0);
if (!$commentId) jsonResponse(['error' => 'comment_id обязателен'], 400);
$stmt = $pdo->prepare("SELECT likes FROM comments WHERE id = ?");
$stmt->execute([$commentId]);
$comment = $stmt->fetch();
if (!$comment) jsonResponse(['error' => 'Комментарий не найден'], 404);
$likes = json_decode($comment['likes'] ?? '[]', true) ?: [];
$index = array_search($userId, $likes);
if ($index !== false) {
    array_splice($likes, $index, 1);
} else {
    $likes[] = $userId;
}
$pdo->prepare("UPDATE comments SET likes = ? WHERE id = ?")->execute([json_encode($likes), $commentId]);
jsonResponse(['likes' => $likes]);