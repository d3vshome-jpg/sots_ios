<?php
define('ALLOW_ACCESS', true);

require_once __DIR__ . '/../../core/config.php';
require_once __DIR__ . '/../../core/rate_limit.php';

rateLimit('post', 10, 60);

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $requestedLimit = (int)($_GET['limit'] ?? 20);
        $limit  = min(5000, max(1, $requestedLimit));
        $before = isset($_GET['before']) ? (int)$_GET['before'] : null;
        $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;

        $params = [];
        $where  = [];
        if ($before) {
            $where[] = 'p.id < ?';
            $params[] = $before;
        }
        if ($userId) {
            $where[] = 'p.user_id = ?';
            $params[] = $userId;
        }
        $whereSQL = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $stmt = $pdo->prepare("
            SELECT p.id, p.user_id, u.username, u.emoji, u.friends,
                   p.images, p.videos, p.audio, p.artist, p.title,
                   p.caption, p.likes, p.created_at
            FROM posts p
            JOIN users u ON p.user_id = u.id
            $whereSQL
            ORDER BY p.id DESC
            LIMIT ?
        ");
        $params[] = $limit;
        $stmt->execute($params);
        $posts = $stmt->fetchAll();

        foreach ($posts as &$post) {
            $post['likes']   = json_decode($post['likes'] ?? '[]', true) ?: [];
            $post['images']  = json_decode($post['images'] ?? '[]', true) ?: [];
            $post['videos']  = json_decode($post['videos'] ?? '[]', true) ?: [];
            $post['audio']   = json_decode($post['audio'] ?? '[]', true) ?: [];
            $post['friends'] = json_decode($post['friends'] ?? '[]', true) ?: [];
        }

        jsonResponse($posts);

    } catch (PDOException $e) {
        jsonResponse(['error' => 'Ошибка базы данных при получении ленты'], 500);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $auth = authenticate();
    if (!$auth || empty($auth['id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Несанкционированный доступ']);
        exit;
    }
    $userId = (int)$auth['id'];

    $input = getJsonInput();
    if (!$input) {
        http_response_code(400);
        echo json_encode(['error' => 'Некорректный формат JSON']);
        exit;
    }

    $caption = trim($input['caption'] ?? '');
    $images  = isset($input['images']) && is_array($input['images']) ? $input['images'] : [];
    $videos  = isset($input['videos']) && is_array($input['videos']) ? $input['videos'] : [];
    $audio   = isset($input['audio']) && is_array($input['audio']) ? $input['audio'] : [];
    $artist  = trim($input['artist'] ?? '');
    $title   = trim($input['title'] ?? '');

    // Валидация: для музыкального поста обязательны artist, title и аудио
    if (!empty($audio) && (empty($artist) || empty($title))) {
        http_response_code(400);
        echo json_encode(['error' => 'Для музыкального поста укажите исполнителя и название']);
        exit;
    }

    // Ограничения на количество файлов
    if (count($images) > 5 || count($videos) > 5 || count($audio) > 5) {
        http_response_code(400);
        echo json_encode(['error' => 'Максимум 5 файлов каждого типа']);
        exit;
    }

    $maxSizes = ['image' => 10 * 1024 * 1024, 'video' => 100 * 1024 * 1024, 'audio' => 30 * 1024 * 1024]; // 10MB / 100MB / 30MB

    // Если нет ни медиа, ни текста – ошибка
    if (empty($images) && empty($videos) && empty($audio) && $caption === '') {
        http_response_code(400);
        echo json_encode(['error' => 'Пост должен содержать текст или файлы']);
        exit;
    }

    $uploadDir    = __DIR__ . '/../../uploads/' . $userId . '/';
    $uploadWebPath = 'uploads/' . $userId . '/';
    if (!is_dir($uploadDir)) {
        if (!mkdir($uploadDir, 0755, true)) {
            http_response_code(500);
            echo json_encode(['error' => 'Не удалось создать директорию для загрузок']);
            exit;
        }
    }

    // Загрузка изображений (как раньше)
    $allowedImages = [
        'image/jpeg' => 'jpg',
        'image/png'  => 'png',
        'image/webp' => 'webp',
        'image/gif'  => 'gif'
    ];
    $imagePaths = [];
    foreach ($images as $img) {
        if (!is_string($img)) continue;
        if (preg_match('/^data:(image\/[\w+.\-]+);base64,/', $img, $m)) {
            $mimeType = strtolower($m[1]);
            if (!isset($allowedImages[$mimeType])) {
                http_response_code(400);
                echo json_encode(['error' => 'Недопустимый формат изображения']);
                exit;
            }
            $ext = $allowedImages[$mimeType];
            $data = base64_decode(substr($img, strpos($img, ',') + 1));
            if ($data === false) {
                http_response_code(400);
                echo json_encode(['error' => 'Ошибка декодирования изображения']);
                exit;
            }
            if (strlen($data) > $maxSizes['image']) {
                http_response_code(400);
                echo json_encode(['error' => 'Изображение превышает 10 MB']);
                exit;
            }
            $fname = uniqid('img_', true) . '.' . $ext;
            if (file_put_contents($uploadDir . $fname, $data) === false) {
                http_response_code(500);
                echo json_encode(['error' => 'Ошибка при сохранении изображения']);
                exit;
            }
            $imagePaths[] = $uploadWebPath . $fname;
        }
    }

    // Загрузка видео (аналогично)
    $allowedVideos = [
        'video/mp4'       => 'mp4',
        'video/webm'      => 'webm',
        'video/quicktime' => 'mov'
    ];
    $videoPaths = [];
    foreach ($videos as $vid) {
        if (!is_string($vid)) continue;
        if (preg_match('/^data:(video\/[\w+.\-]+);base64,/', $vid, $m)) {
            $mimeType = strtolower($m[1]);
            if (!isset($allowedVideos[$mimeType])) {
                http_response_code(400);
                echo json_encode(['error' => 'Недопустимый формат видео']);
                exit;
            }
            $ext = $allowedVideos[$mimeType];
            $data = base64_decode(substr($vid, strpos($vid, ',') + 1));
            if ($data === false) {
                http_response_code(400);
                echo json_encode(['error' => 'Ошибка декодирования видео']);
                exit;
            }
            if (strlen($data) > $maxSizes['video']) {
                http_response_code(400);
                echo json_encode(['error' => 'Видео превышает 100 MB']);
                exit;
            }
            $fname = uniqid('vid_', true) . '.' . $ext;
            if (file_put_contents($uploadDir . $fname, $data) === false) {
                http_response_code(500);
                echo json_encode(['error' => 'Ошибка при сохранении видео']);
                exit;
            }
            $videoPaths[] = $uploadWebPath . $fname;
        }
    }

    // Загрузка аудио
    $allowedAudio = [
        'audio/mpeg' => 'mp3',
        'audio/wav'  => 'wav',
        'audio/ogg'  => 'ogg',
        'audio/webm' => 'weba',
        'audio/x-m4a' => 'm4a'
    ];
    $audioPaths = [];
    foreach ($audio as $aud) {
        if (!is_string($aud)) continue;
        if (preg_match('/^data:(audio\/[\w+.\-]+);base64,/', $aud, $m)) {
            $mimeType = strtolower($m[1]);
            if (!isset($allowedAudio[$mimeType])) {
                http_response_code(400);
                echo json_encode(['error' => 'Недопустимый формат аудио. Разрешены MP3, WAV, OGG, M4A']);
                exit;
            }
            $ext = $allowedAudio[$mimeType];
            $data = base64_decode(substr($aud, strpos($aud, ',') + 1));
            if ($data === false) {
                http_response_code(400);
                echo json_encode(['error' => 'Ошибка декодирования аудио']);
                exit;
            }
            if (strlen($data) > $maxSizes['audio']) {
                http_response_code(400);
                echo json_encode(['error' => 'Аудио превышает 30 MB']);
                exit;
            }
            $fname = uniqid('aud_', true) . '.' . $ext;
            if (file_put_contents($uploadDir . $fname, $data) === false) {
                http_response_code(500);
                echo json_encode(['error' => 'Ошибка при сохранении аудио']);
                exit;
            }
            $audioPaths[] = $uploadWebPath . $fname;
        }
    }

    $imagesJson = json_encode($imagePaths, JSON_UNESCAPED_UNICODE);
    $videosJson = json_encode($videoPaths, JSON_UNESCAPED_UNICODE);
    $audioJson  = json_encode($audioPaths, JSON_UNESCAPED_UNICODE);

    $caption = htmlspecialchars($caption, ENT_QUOTES, 'UTF-8');

    try {
        $stmt = $pdo->prepare("INSERT INTO posts (user_id, images, videos, audio, artist, title, caption, likes) VALUES (?, ?, ?, ?, ?, ?, ?, '[]')");
        $stmt->execute([$userId, $imagesJson, $videosJson, $audioJson, $artist, $title, $caption]);

        http_response_code(201);
        echo json_encode(['success' => true, 'post_id' => $pdo->lastInsertId()]);
        exit;

    } catch (PDOException $e) {
        // Удаляем загруженные файлы при ошибке
        foreach (array_merge($imagePaths, $videoPaths, $audioPaths) as $failedFile) {
            if (file_exists($failedFile)) @unlink($failedFile);
        }
        http_response_code(500);
        echo json_encode(['error' => 'Не удалось сохранить пост в базу данных']);
        exit;
    }
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);