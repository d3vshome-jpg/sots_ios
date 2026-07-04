# Sotspw iOS App - Инструкция

## 📱 Запуск на appetize.io

### Шаг 1: Сборка приложения в Xcode

1. Откройте проект в Xcode:
   ```bash
   open iosApp/iosApp.xcodeproj
   ```

2. Выберите симулятор (например, iPhone 15 Pro)

3. Соберите проект (Product → Build или Cmd+B)

4. Запустите на симуляторе (Product → Run или Cmd+R)

5. Убедитесь, что приложение работает корректно

### Шаг 2: Экспорт .ipa файла для appetize.io

1. В Xcode выберите схему проекта (iosApp)

2. Product → Archive

3. После завершения архивации откроется Organizer

4. Выберите архив и нажмите "Distribute App"

5. Выберите "Ad Hoc" или "Development"

6. Следуйте инструкциям для создания .ipa файла

### Шаг 3: Загрузка на appetize.io

1. Перейдите на https://appetize.io

2. Войдите или зарегистрируйтесь

3. Нажмите "Upload" и выберите ваш .ipa файл

4. После загрузки приложение будет доступно для тестирования в браузере

## 🔗 Синхронизация с базой данных

### Текущие данные подключения:
```
DB_HOST=localhost
DB_NAME=cb868718_glavnaya
DB_USER=cb868718_glavnaya
DB_PASS=Oleg5225!
DB_CHARSET=utf8mb4
```

### Что нужно сделать на сервере:

#### 1. Создать API endpoints

Вам нужно создать PHP API на вашем сервере со следующими endpoints:

**Посты:**
- `GET /api/posts` - получить все посты
- `POST /api/posts` - создать новый пост
- `POST /api/posts/{id}/like` - лайкнуть пост

**Поиск:**
- `GET /api/search/posts?q={query}` - поиск постов
- `GET /api/search/users?q={query}` - поиск пользователей
- `GET /api/search/hashtags?q={query}` - поиск хештегов

**Уведомления:**
- `GET /api/notifications` - получить уведомления

**Пользователи:**
- `GET /api/users/{id}` - получить профиль пользователя
- `POST /api/users/{id}/follow` - подписаться на пользователя

#### 2. Пример PHP кода для API:

```php
<?php
// api/posts.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$host = 'localhost';
$db   = 'cb868718_glavnaya';
$user = 'cb868718_glavnaya';
$pass = 'Oleg5225!';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
try {
    $pdo = new PDO($dsn, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
    exit;
}

// GET /api/posts
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->query("SELECT * FROM posts ORDER BY created_at DESC");
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($posts);
}

// POST /api/posts
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO posts (content, author_id) VALUES (?, ?)");
    $stmt->execute([$data['content'], $data['author_id']]);
    echo json_encode(['success' => true]);
}
?>
```

#### 3. Обновить baseURL в приложении

В файле `iosApp/iosApp/Services/APIManager.swift` замените:

```swift
private let baseURL = "https://ваш-сайт.ru/api"
```

на ваш реальный URL API.

### Структура базы данных (рекомендуемая)

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    avatar VARCHAR(255),
    bio TEXT,
    followers INT DEFAULT 0,
    following INT DEFAULT 0,
    posts_count INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_id INT NOT NULL,
    content TEXT NOT NULL,
    media_url VARCHAR(255),
    media_type VARCHAR(20),
    likes INT DEFAULT 0,
    comments INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id),
    UNIQUE KEY unique_like (user_id, post_id)
);

CREATE TABLE followers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (follower_id) REFERENCES users(id),
    FOREIGN KEY (following_id) REFERENCES users(id),
    UNIQUE KEY unique_follow (follower_id, following_id)
);

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(20) NOT NULL,
    from_user_id INT NOT NULL,
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (from_user_id) REFERENCES users(id)
);
```

## 🎨 Особенности дизайна

- **Liquid Glass TabBar** - стеклянный эффект с размытием и градиентами
- **Цветовая схема**: 
  - Акцентный: #ff4d6a (розовый)
  - Вторичный: #6c5ce7 (фиолетовый)
  - Фон: системный группированный фон
- **Шрифты**: системный шрифт Apple (San Francisco)
- **Анимации**: плавные переходы и spring-анимации

## 📁 Структура проекта

```
iosApp/
├── iosApp/
│   ├── Models/
│   │   └── Post.swift          # Модели данных
│   ├── Views/
│   │   ├── FeedView.swift       # Экран ленты
│   │   ├── SearchView.swift    # Экран поиска
│   │   ├── NotificationsView.swift  # Экран уведомлений
│   │   └── ProfileView.swift   # Экран профиля
│   ├── Components/
│   │   └── LiquidGlassTabBar.swift  # TabBar с liquid glass эффектом
│   ├── Services/
│   │   └── APIManager.swift     # API клиент
│   ├── Assets.xcassets/         # Изображения
│   ├── ContentView.swift       # Главный view
│   ├── iOSApp.swift            # Entry point
│   └── Info.plist              # Настройки приложения
```

## 🔧 Требования

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+

## 🚀 Быстрый старт

1. Откройте проект в Xcode
2. Выберите симулятор iPhone
3. Нажмите Cmd+R для запуска
4. Приложение готово к тестированию!

## 📝 TODO для полной функциональности

- [ ] Авторизация/регистрация пользователей
- [ ] Загрузка изображений и видео
- [ ] Комментирование постов
- [ ] Личные сообщения
- [ ] Push-уведомления
- [ ] Редактирование профиля
- [ ] Настройки приложения
- [ ] Темная тема
