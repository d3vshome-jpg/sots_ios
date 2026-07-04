<?php
require_once __DIR__ . '/../../core/config.php';
$userId = authenticate();
$input = getJsonInput();
$commentId = (int)($input['comment_id'] ?? 0);
if (!$commentId) jsonResponse(['error' => 'comment_id обязателен'], 400);
$stmt = $pdo->prepare("SELECT user_id FROM comments WHERE id = ?");
$stmt->execute([$commentId]);
$comment = $stmt->fetch();
if (!$comment || $comment['user_id'] != $userId) jsonResponse(['error' => 'Нельзя удалить чужой комментарий'], 403);
$pdo->prepare("DELETE FROM comments WHERE id = ?")->execute([$commentId]);
jsonResponse(['success' => true]);