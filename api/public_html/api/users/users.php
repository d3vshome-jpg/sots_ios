<?php
require_once __DIR__ . '/../../core/config.php';
header('Content-Type: application/json; charset=utf-8');

$user = authenticate();
$currentUserId = $user['id'];
$isAdmin = (bool)($user['is_admin'] ?? false);

$id = $_GET['id'] ?? null;
$search = $_GET['search'] ?? null;
$all = $_GET['all'] ?? null;

if ($all === 'true') {
    if (!$isAdmin) {
        jsonResponse(['error' => 'Доступ запрещён'], 403);
    }
    // СТАВИМ ЛИМИТ НА 50 ЮЗЕРОВ ЗА РАЗ И ОФФСЕТ С НУЛЯ
    $limit = (int)($_GET['limit'] ?? 50);
    $offset = (int)($_GET['offset'] ?? 0);
    if ($limit > 100) $limit = 100; // НЕЛЬЗЯ СДЕЛАТЬ ЗАПРОС LIMIT=100000
    if ($limit < 1) $limit = 50;
    if ($offset < 0) $offset = 0;

    $stmt = $pdo->prepare("SELECT id, username, emoji, bio, friends, verified, is_admin, pin FROM users LIMIT :limit OFFSET :offset");

    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $users = $stmt->fetchAll();

    foreach ($users as &$u) {
        $u['friends'] = json_decode($u['friends'] ?? '[]', true) ?: [];
    }
    unset($u); // УБИЙСТВО ССЫЛКИ НУ ЭТО БАЗА

    // ОТДАЁМ ИНФУ О ПАГИНАЦИИ - фронт нужно переписать будет
    jsonResponse([
        'users' => $users,
        'limit' => $limit,
        'offset' => $offset
    ]);
}

if ($search !== null) {
    $stmt = $pdo->prepare("SELECT id, username, emoji, bio, friends, verified, pin FROM users WHERE username LIKE ?");
    $stmt->execute(["%$search%"]);
    $users = $stmt->fetchAll();
    foreach ($users as &$u) {
        $u['friends'] = json_decode($u['friends'] ?? '[]', true) ?: [];
    }
    jsonResponse($users);
}

if ($id !== null) {
    $id = (int)$id;
    if ($id !== $currentUserId && !$isAdmin) {
        jsonResponse(['error' => 'Доступ запрещён'], 403);
    }
    $stmt = $pdo->prepare("SELECT id, username, emoji, bio, friends, verified, pin FROM users WHERE id = ?");
    $stmt->execute([$id]);
    $userData = $stmt->fetch();
    if (!$userData) jsonResponse(['error' => 'Пользователь не найден'], 404);
    $userData['friends'] = json_decode($userData['friends'] ?? '[]', true) ?: [];
    jsonResponse($userData);
}

$stmt = $pdo->prepare("SELECT id, username, emoji, bio, friends, verified, pin FROM users WHERE id = ?");
$stmt->execute([$currentUserId]);
$userData = $stmt->fetch();
$userData['friends'] = json_decode($userData['friends'] ?? '[]', true) ?: [];
jsonResponse($userData);