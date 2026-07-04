<?php
require_once __DIR__ . '/../../core/config.php';
$userId = authenticate();

// Получить список уникальных собеседников
$stmt = $pdo->prepare("
    SELECT DISTINCT u.id, u.username, u.emoji,
    (SELECT text FROM messages WHERE (from_user_id = u.id AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = u.id) ORDER BY created_at DESC LIMIT 1) as last_message,
    (SELECT created_at FROM messages WHERE (from_user_id = u.id AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = u.id) ORDER BY created_at DESC LIMIT 1) as last_time
    FROM users u
    INNER JOIN messages m ON (m.from_user_id = u.id AND m.to_user_id = ?) OR (m.to_user_id = u.id AND m.from_user_id = ?)
    WHERE u.id != ?
    ORDER BY last_time DESC
");
$stmt->execute([$userId, $userId, $userId, $userId, $userId, $userId, $userId]);
$chats = $stmt->fetchAll();

jsonResponse($chats);