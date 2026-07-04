<?php
require_once __DIR__ . '/../../core/config.php';
header('Content-Type: application/json; charset=utf-8');

$user = authenticate();
$userId = $user['id'];

// Получаем уведомления пользователя
$stmt = $pdo->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC");
$stmt->execute([$userId]);
$notifications = $stmt->fetchAll();

// Формируем данные
$result = [];
foreach ($notifications as $notif) {
    // Получаем данные отправителя
    $fromStmt = $pdo->prepare("SELECT username, emoji FROM users WHERE id = ?");
    $fromStmt->execute([$notif['from_user_id']]);
    $fromUser = $fromStmt->fetch();
    
    $result[] = [
        'id' => $notif['id'],
        'type' => $notif['type'],
        'from_user_id' => $notif['from_user_id'],
        'from_username' => $fromUser['username'] ?? 'unknown',
        'from_emoji' => $fromUser['emoji'] ?? '👤',
        'object_id' => $notif['object_id'],
        'read' => (bool)$notif['is_read'],
        'created_at' => $notif['created_at']
    ];
}

jsonResponse($result);