<?php

require_once __DIR__.'/../../core/config.php';
require_once __DIR__.'/../../core/rate_limit.php';

header('Content-Type: application/json; charset=utf-8');

rateLimit('itd_login',10,60);

function out($data,$code=200){
    http_response_code($code);
    echo json_encode($data,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
    exit;
}

if($_SERVER['REQUEST_METHOD']!=='POST'){
    out(['error'=>'Method not allowed'],405);
}

$input = json_decode(file_get_contents('php://input'), true);

$code = $input['code'] ?? '';

if(!$code){
    out(['error'=>'No code'],400);
}

/*
|--------------------------------------------------------------------------
| 1. GET TOKEN
|--------------------------------------------------------------------------
*/

$ITD_CLIENT_ID = '491396777';
$ITD_CLIENT_SECRET = 'f852c5365645a5a522b18016868dd7ae880e5e17543babdee348cc384672467e';
$ITD_AUTH_BASE = 'https://auth.итд.tech';

$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => $ITD_AUTH_BASE.'/oauth/token',
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'authorization_code',
        'code' => $code,
        'client_id' => $ITD_CLIENT_ID,
        'client_secret' => $ITD_CLIENT_SECRET,
        'redirect_uri' =>
            (isset($_SERVER['HTTPS']) ? 'https://' : 'http://')
            .$_SERVER['HTTP_HOST']
            .'/auth/callback'
    ]),
    CURLOPT_RETURNTRANSFER => true
]);

$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);

if(empty($data['token'])){
    out(['error'=>'ITD token failed','raw'=>$response],502);
}

$jwt = $data['token'];

/*
|--------------------------------------------------------------------------
| 2. DECODE JWT
|--------------------------------------------------------------------------
*/

$parts = explode('.', $jwt);

$payload = json_decode(
    base64_decode(str_replace(['-','_'],['+','/'],$parts[1])),
    true
);

$itdId = $payload['sub'] ?? null;

if(!$itdId){
    out(['error'=>'No sub in token'],500);
}

/*
|--------------------------------------------------------------------------
| 3. USER DATA
|--------------------------------------------------------------------------
*/

$username =
    $payload['preferred_username']
    ?? $payload['username']
    ?? $payload['name']
    ?? $payload['nickname']
    ?? null;

$emoji = $payload['emoji'] ?? '😊';

if(!$username){
    $username = 'user_' . substr(str_replace('-', '', $itdId), 0, 6);
}

/*
|--------------------------------------------------------------------------
| 4. FIND USER
|--------------------------------------------------------------------------
*/

$stmt = $pdo->prepare("SELECT id FROM users WHERE itd_id=?");
$stmt->execute([$itdId]);
$user = $stmt->fetch();

/*
|--------------------------------------------------------------------------
| 5. IF NOT FOUND → SETUP REQUIRED
|--------------------------------------------------------------------------
*/

if(!$user){
    out([
        'needs_setup' => true,
        'itd_user' => [
            'itd_id' => $itdId,
            'username' => $username,
            'emoji' => $emoji
        ]
    ]);
}

/*
|--------------------------------------------------------------------------
| 6. LOGIN SUCCESS
|--------------------------------------------------------------------------
*/

$userId = $user['id'];

$token = bin2hex(random_bytes(32));
$hash = hash('sha256', $token);

$pdo->prepare("
    UPDATE users
    SET token=?
    WHERE id=?
")->execute([$hash, $userId]);

out([
    'token' => $token,
    'user_id' => $userId
]);