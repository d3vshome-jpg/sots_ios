<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('profile', 10, 60);
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$user = authenticate();
$userId = $user['id'];
$input = getJsonInput();

$newUsername = trim($input['username'] ?? '');
$newBio = trim($input['bio'] ?? '');
$newPin = $input['pin'] ?? null;   // 'pin.png', 'pin2.png' или null

// Если передан новый username, проверяем уникальность
if ($newUsername !== '') {
    if (strlen($newUsername) > 32) {
        jsonResponse(['error' => 'Юзернейм не более 32 символов'], 400);
    }
    if (!preg_match('/^[a-zA-Z][a-zA-Z]*$/', $newUsername)) {
        jsonResponse(['error' => 'Юзернейм: только английские буквы, не начинается с цифры'], 400);
    }
    if (stripos($newUsername, 'bot') === 0 || stripos($newUsername, 'zerka') === 0) {
        jsonResponse(['error' => 'Это имя зарезервировано'], 400);
    }
    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
    $stmt->execute([$newUsername, $userId]);
    if ($stmt->fetch()) {
        jsonResponse(['error' => 'Этот юзернейм уже занят'], 409);
    }
    $stmt = $pdo->prepare("UPDATE users SET username = ? WHERE id = ?");
    $stmt->execute([$newUsername, $userId]);
}

// Обновляем bio
$stmt = $pdo->prepare("UPDATE users SET bio = ? WHERE id = ?");
$stmt->execute([$newBio, $userId]);

// Обновляем пин (если передан)
if ($newPin !== null) {
    $allowedPins = ['pin.png', 'pin2.png', null];
    if (!in_array($newPin, $allowedPins, true)) {
        jsonResponse(['error' => 'Недопустимый пин'], 400);
    }
    $stmt = $pdo->prepare("UPDATE users SET pin = ? WHERE id = ?");
    $stmt->execute([$newPin, $userId]);
}

jsonResponse(['success' => true]);