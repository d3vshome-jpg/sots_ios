<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('change_password', 5, 60);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$user = authenticate();
$input = getJsonInput();

$oldPassword = $input['old_password'] ?? '';
$newPassword = $input['new_password'] ?? '';

if ($oldPassword === '' || $newPassword === '') {
    jsonResponse(['error' => 'Заполните все поля'], 400);
}

if (strlen($newPassword) < 3) {
    jsonResponse(['error' => 'Новый пароль минимум 3 символа'], 400);
}

if (strlen($newPassword) > 128) {
    jsonResponse(['error' => 'Новый пароль не более 128 символов'], 400);
}

$stmt = $pdo->prepare("SELECT password FROM users WHERE id = ?");
$stmt->execute([$user['id']]);
$row = $stmt->fetch();

if (!$row || !password_verify($oldPassword, $row['password'])) {
    jsonResponse(['error' => 'Неверный текущий пароль'], 403);
}

$newHash = password_hash($newPassword, PASSWORD_DEFAULT);
$pdo->prepare("UPDATE users SET password = ? WHERE id = ?")->execute([$newHash, $user['id']]);

jsonResponse(['success' => true]);
