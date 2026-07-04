<?php
require_once __DIR__ . '/../../core/config.php';
$userId = authenticate();
$input = getJsonInput();
$postId = (int)($input['post_id'] ?? 0);
$rating = (int)($input['rating'] ?? 0);
if ($rating < 1 || $rating > 5) jsonResponse(['error' => 'Рейтинг от 1 до 5'], 400);
// Сохраняем рейтинг (заменяем предыдущую оценку этого пользователя)
$stmt = $pdo->prepare("SELECT id FROM ratings WHERE post_id = ? AND user_id = ?");
$stmt->execute([$postId, $userId]);
if ($stmt->fetch()) {
    $stmt = $pdo->prepare("UPDATE ratings SET rating = ? WHERE post_id = ? AND user_id = ?");
} else {
    $stmt = $pdo->prepare("INSERT INTO ratings (post_id, user_id, rating) VALUES (?, ?, ?)");
}
$stmt->execute([$rating, $postId, $userId]);
// Обновляем средний рейтинг автора
$stmt2 = $pdo->prepare("SELECT u.id, AVG(r.rating) AS avg_rating FROM ratings r JOIN posts p ON r.post_id = p.id JOIN users u ON p.user_id = u.id WHERE p.id = ? GROUP BY u.id");
$stmt2->execute([$postId]);
$row = $stmt2->fetch();
if ($row) {
    $pdo->prepare("UPDATE users SET rating = ? WHERE id = ?")->execute([$row['avg_rating'], $row['id']]);
}
jsonResponse(['success' => true]);