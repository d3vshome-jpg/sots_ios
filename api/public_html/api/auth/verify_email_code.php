<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('verify_email_code', 10, 300);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

session_start();

$input = getJsonInput();
$code = trim($input['code'] ?? '');
$email = trim($input['email'] ?? '');

if (!isset($_SESSION['email_code'], $_SESSION['email_code_email'], $_SESSION['email_code_expires'])) {
    jsonResponse(['error' => 'Сначала запросите код'], 400);
}

if ($_SESSION['email_code_email'] !== $email) {
    jsonResponse(['error' => 'Email не совпадает'], 400);
}

if (time() > $_SESSION['email_code_expires']) {
    unset($_SESSION['email_code'], $_SESSION['email_code_email'], $_SESSION['email_code_expires'], $_SESSION['email_code_attempts']);
    jsonResponse(['error' => 'Код истёк. Запросите новый'], 400);
}

$_SESSION['email_code_attempts'] = ($_SESSION['email_code_attempts'] ?? 0) + 1;
if ($_SESSION['email_code_attempts'] > 5) {
    unset($_SESSION['email_code'], $_SESSION['email_code_email'], $_SESSION['email_code_expires'], $_SESSION['email_code_attempts']);
    jsonResponse(['error' => 'Слишком много попыток. Запросите новый код'], 429);
}

if (!hash_equals($_SESSION['email_code'], hash('sha256', $code))) {
    jsonResponse(['error' => 'Неверный код'], 400);
}

// Код верный — помечаем email как подтверждённый в сессии
$_SESSION['email_verified'] = $email;
unset($_SESSION['email_code'], $_SESSION['email_code_email'], $_SESSION['email_code_expires'], $_SESSION['email_code_attempts']);

jsonResponse(['success' => true, 'verified_email' => $email]);
