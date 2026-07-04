<?php
require_once __DIR__ . '/../../core/config.php';
authenticate(); // требуется авторизация

$stmt = $pdo->query("SELECT likes FROM posts");
$total = 0;
while ($row = $stmt->fetch()) {
    $likes = json_decode($row['likes'] ?? '[]', true) ?: [];
    $total += count($likes);
}
jsonResponse(['total_likes' => $total]);