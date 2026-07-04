<?php
require_once __DIR__ . '/../../core/config.php';

$input = json_decode(file_get_contents('php://input'), true);
$code = $input['code'] ?? '';
$deviceId = $input['device_id'] ?? '';

if (!$code || !$deviceId) {
    jsonResponse(['error' => 'Не передан код или device_id'], 400);
}

// Обмен кода на токен через VK API
$vkAppId = 54634717;
$vkSecret = 'ВАШ_ЗАЩИЩЕННЫЙ_КЛЮЧ'; // получите в настройках приложения VK
$redirectUri = 'https://www.sots.pw';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://id.vk.com/oauth2/auth');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
    'grant_type' => 'authorization_code',
    'code' => $code,
    'client_id' => $vkAppId,
    'client_secret' => $vkSecret,
    'redirect_uri' => $redirectUri,
    'device_id' => $deviceId,
]));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$tokenData = json_decode($response, true);
if (!isset($tokenData['access_token'])) {
    jsonResponse(['error' => 'Не удалось получить токен VK'], 500);
}

// Получаем данные пользователя VK
$accessToken = $tokenData['access_token'];
$userIdVk = $tokenData['user_id'];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://api.vk.com/method/users.get?v=5.131&access_token=' . $accessToken . '&user_ids=' . $userIdVk);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$userData = json_decode(curl_exec($ch), true);
curl_close($ch);

$vkUser = $userData['response'][0] ?? null;
if (!$vkUser) {
    jsonResponse(['error' => 'Не удалось получить данные VK'], 500);
}

$vkId = $vkUser['id'];
$firstName = $vkUser['first_name'];
$lastName = $vkUser['last_name'];
$username = 'vk_' . $vkId; // генерируем логин, можно предложить пользователю сменить

// Ищем пользователя по vk_id (нужно поле vk_id в таблице users)
$stmt = $pdo->prepare("SELECT id FROM users WHERE vk_id = ?");
$stmt->execute([$vkId]);
$existing = $stmt->fetch();

if ($existing) {
    $userId = $existing['id'];
} else {
    // Создаём нового пользователя
    $emoji = '😊'; // эмодзи по умолчанию, можно случайно из доступных
    $token = bin2hex(random_bytes(32));
    $stmt = $pdo->prepare("INSERT INTO users (username, password, emoji, vk_id, token) VALUES (?, '', ?, ?, ?)");
    $stmt->execute([$username, $emoji, $vkId, $token]);
    $userId = $pdo->lastInsertId();
}

// Генерируем наш токен (если ещё нет)
$token = bin2hex(random_bytes(32));
$stmt = $pdo->prepare("UPDATE users SET token = ? WHERE id = ?");
$stmt->execute([$token, $userId]);

// Возвращаем токен и id
jsonResponse(['token' => $token, 'id' => $userId, 'user' => ['username' => $username, 'emoji' => $emoji]]);