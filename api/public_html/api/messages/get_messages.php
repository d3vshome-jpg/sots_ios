<?php
require_once __DIR__ . '/../../core/config.php';

authenticate();

$stmt = $pdo->query("
    SELECT m.id, m.from_user_id, u.username AS from_username, u.emoji AS from_emoji,
           m.text, m.images, m.reply_to, m.created_at
    FROM messages m
    JOIN users u ON m.from_user_id = u.id
    ORDER BY m.id ASC
");
$messages = $stmt->fetchAll();

foreach ($messages as &$msg) {
    $msg['images'] = json_decode($msg['images'], true) ?? [];
}

jsonResponse($messages);
