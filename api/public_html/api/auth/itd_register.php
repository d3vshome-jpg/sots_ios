<?php
require_once __DIR__.'/../../core/config.php';
require_once __DIR__.'/../../core/rate_limit.php';

rateLimit('itd_register', 5, 300);

header('Content-Type: application/json; charset=utf-8');

function out($d,$c=200){
    http_response_code($c);
    echo json_encode($d,JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode(file_get_contents('php://input'),true);

$username = trim($input['username'] ?? '');
$emoji = $input['emoji'] ?? '😊';
$itd_id = $input['itd_id'] ?? null;
$password = $input['password'] ?? '';

if(!$username || !$itd_id){
    out(['error'=>'invalid'],400);
}

if(strlen($username)>32){
    out(['error'=>'username too long'],400);
}

$stmt=$pdo->prepare("SELECT id FROM users WHERE username=?");
$stmt->execute([$username]);
if($stmt->fetch()){
    out(['error'=>'username taken'],409);
}

if($password===''){
    $password_hash = '';
}else{
    $password_hash = password_hash($password,PASSWORD_DEFAULT);
}

$token = bin2hex(random_bytes(32));
$tokenHash = hash('sha256',$token);

$stmt=$pdo->prepare("INSERT INTO users (username,password,emoji,itd_id,token) VALUES (?,?,?,?,?)");
$stmt->execute([$username,$password_hash,$emoji,$itd_id,$tokenHash]);

out(['token'=>$token,'id'=>$pdo->lastInsertId()]);
