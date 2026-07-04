<?php
require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('search', 30, 60);

authenticate();

$q = trim($_GET['q'] ?? '');
if (strlen($q) < 1) {
    jsonResponse(['users' => [], 'posts' => [], 'hashtags' => []]);
}

$stmt = $pdo->prepare("SELECT id, username, emoji, friends, verified FROM users WHERE username LIKE ? LIMIT 5");
$stmt->execute(["%$q%"]);
$users = $stmt->fetchAll();
foreach ($users as &$u) {
    $u['friends'] = json_decode($u['friends'] ?? '[]', true) ?: [];
}

$stmt = $pdo->prepare("SELECT p.id, p.caption, p.images, p.videos, p.user_id, u.username, u.emoji, u.verified FROM posts p JOIN users u ON p.user_id = u.id WHERE p.caption LIKE ? ORDER BY p.id DESC LIMIT 10");
$stmt->execute(["%$q%"]);
$posts = $stmt->fetchAll();
foreach ($posts as &$post) {
    $post['images'] = json_decode($post['images'] ?? '[]', true) ?: [];
    $post['videos'] = json_decode($post['videos'] ?? '[]', true) ?: [];
}
unset($post);

$hashtags = [];
try {
    $stmt = $pdo->prepare("SELECT name, post_count FROM hashtags WHERE name LIKE ? LIMIT 5");
    $stmt->execute(["%$q%"]);
    $hashtags = $stmt->fetchAll();
} catch (Exception $e) {}

jsonResponse(['users' => $users, 'posts' => $posts, 'hashtags' => $hashtags]);
