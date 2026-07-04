<?php
require_once __DIR__ . '/../../core/config.php';
header('Content-Type: application/json; charset=utf-8');

$user = authenticate();
$userId = $user['id'];

$stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
$stmt->execute([$userId]);

jsonResponse(['success' => true]);