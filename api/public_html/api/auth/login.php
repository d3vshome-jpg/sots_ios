<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('login', 5, 60);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = getJsonInput();
$username = trim($input['username'] ?? '');
$password = $input['password'] ?? '';

if ($username === '' || $password === '') {
    jsonResponse(['error' => 'Логин и пароль обязательны'], 400);
}

if (strlen($username) > 32 || strlen($password) > 128) {
    jsonResponse(['error' => 'Неверный логин или пароль'], 401);
}

$stmt = $pdo->prepare("SELECT id, password FROM users WHERE username = ?");
$stmt->execute([$username]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    jsonResponse(['error' => 'Неверный логин или пароль'], 401);
}

$token = bin2hex(random_bytes(32));
$tokenHash = hash('sha256', $token);

$stmt = $pdo->prepare("UPDATE users SET token = ? WHERE id = ?");
$stmt->execute([$tokenHash, $user['id']]);

setcookie('sotspw_token', $token, time() + 60*60*24*30, '/', '', true, true);

jsonResponse(['token' => $token, 'id' => $user['id']]);