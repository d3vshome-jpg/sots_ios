<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('register', 3, 300);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

session_start();

$input = getJsonInput();
$username = trim($input['username'] ?? '');
$password = $input['password'] ?? '';
$emoji = $input['emoji'] ?? '😊';
$email = trim($input['email'] ?? '');

// Базовые проверки
if ($username === '' || strlen($password) < 3) {
    jsonResponse(['error' => 'Логин обязателен, пароль минимум 3 символа'], 400);
}
if (strlen($username) > 32) {
    jsonResponse(['error' => 'Юзернейм не более 32 символов'], 400);
}
if (strlen($password) > 128) {
    jsonResponse(['error' => 'Пароль не более 128 символов'], 400);
}
if (stripos($username, 'bot') === 0 || stripos($username, 'zerka') === 0) {
    jsonResponse(['error' => 'Это имя зарезервировано'], 400);
}
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['error' => 'Укажите корректный email'], 400);
}

// Проверяем, что email подтверждён в этой сессии
if (empty($_SESSION['email_verified']) || $_SESSION['email_verified'] !== $email) {
    jsonResponse(['error' => 'Email не подтверждён. Пройдите верификацию'], 403);
}

// Проверка уникальности username
$stmt = $pdo->prepare("SELECT id FROM users WHERE username = ?");
$stmt->execute([$username]);
if ($stmt->fetch()) {
    jsonResponse(['error' => 'Этот логин уже занят'], 409);
}

// Проверка уникальности email
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    jsonResponse(['error' => 'Этот email уже используется'], 409);
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
$token = bin2hex(random_bytes(32));
$tokenHash = hash('sha256', $token);

$stmt = $pdo->prepare("INSERT INTO users (username, password, emoji, token, email, email_verified) VALUES (?, ?, ?, ?, ?, 1)");
$stmt->execute([$username, $hashedPassword, $emoji, $tokenHash, $email]);

$userId = $pdo->lastInsertId();

// Чистим сессию верификации
unset($_SESSION['email_verified']);

setcookie('sotspw_token', $token, time() + 60*60*24*30, '/', '', true, true);

jsonResponse(['token' => $token, 'id' => $userId]);
