<?php
require_once __DIR__ . '/../../core/config.php';

// GET — получить комментарии к посту
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $postId = (int)($_GET['post_id'] ?? 0);
    if (!$postId) jsonResponse(['error' => 'post_id обязателен'], 400);

    $stmt = $pdo->prepare("SELECT c.*, u.username, u.emoji FROM comments c JOIN users u ON c.user_id = u.id WHERE c.post_id = ? ORDER BY c.created_at ASC");
    $stmt->execute([$postId]);
    $comments = $stmt->fetchAll();

    foreach ($comments as &$c) {
        $c['likes'] = json_decode($c['likes'] ?? '[]', true) ?: [];
        $c['images'] = $c['images'] ?? '[]';
        // Ответы (вложенные комментарии)
        $stmt2 = $pdo->prepare("SELECT c2.*, u2.username, u2.emoji FROM comments c2 JOIN users u2 ON c2.user_id = u2.id WHERE c2.parent_id = ? ORDER BY c2.created_at ASC");
        $stmt2->execute([$c['id']]);
        $replies = $stmt2->fetchAll();
        foreach ($replies as &$r) {
            $r['likes'] = json_decode($r['likes'] ?? '[]', true) ?: [];
            $r['images'] = $r['images'] ?? '[]';
        }
        $c['replies'] = $replies;
    }

    jsonResponse($comments);
}

// POST — добавить комментарий (или ответ)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $auth = authenticate();
    $userId = (int)$auth['id'];
    $input = getJsonInput();

    $postId = (int)($input['post_id'] ?? 0);
    $text = trim($input['text'] ?? '');
    $parentId = $input['parent_id'] ?? null; // если это ответ
    $images = $input['images'] ?? [];

    if (!$postId) jsonResponse(['error' => 'post_id обязателен'], 400);
    if ($text === '' && empty($images)) jsonResponse(['error' => 'Комментарий не может быть пустым'], 400);

    // Загрузка изображений
    $imagePaths = [];
    if (!empty($images)) {
        $uploadDir     = __DIR__ . '/../../uploads/comments/' . $userId . '/';
        $uploadWebPath = 'uploads/comments/' . $userId . '/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
        foreach ($images as $base64) {
            if (preg_match('/^data:image\/(\w+);base64,/', $base64, $matches)) {
                $ext = $matches[1];
                $data = base64_decode(substr($base64, strpos($base64, ',') + 1));
                $filename = uniqid() . '.' . $ext;
                file_put_contents($uploadDir . $filename, $data);
                $imagePaths[] = $uploadWebPath . $filename;
            }
        }
    }

    $imagesJson = json_encode($imagePaths, JSON_UNESCAPED_UNICODE);

    $stmt = $pdo->prepare("INSERT INTO comments (post_id, user_id, text, images, likes, parent_id) VALUES (?, ?, ?, ?, '[]', ?)");
    $stmt->execute([$postId, $userId, $text, $imagesJson, $parentId]);

    jsonResponse(['id' => $pdo->lastInsertId()], 201);
}