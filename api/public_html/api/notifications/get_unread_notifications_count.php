<?php
require_once __DIR__ . '/../../core/config.php';
header('Content-Type: application/json; charset=utf-8');

$auth = authenticate();
$userId = $auth['id'];

$stmt = $pdo->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
$stmt->execute([$userId]);
$count = (int)$stmt->fetchColumn();

jsonResponse(['count' => $count]);