# 🔧 ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ AUTOMARKET

## 📋 СОДЕРЖАНИЕ

1. Система закладок (Избранное)
2. Цензура в чате + Модерация
3. Блокировка пользователей в чате
4. Отключение уведомлений
5. Бан/Разбан в админ-панели
6. Архив объявлений
7. Автоудаление неактивных пользователей
8. Гибкое ценообразование (по категориям)
9. Автоматическое ценообразование (как на mobile.de)
10. Футер страницы (About, Terms, Privacy, Contact) на 10 языках
11. CMS - Редактирование фронтенда через админку
12. Список всех созданных файлов для скачивания

---

## 1️⃣ СИСТЕМА ЗАКЛАДОК (ИЗБРАННОЕ)

### База данных

```sql
CREATE TABLE favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    listing_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, listing_id),
    INDEX idx_user (user_id),
    INDEX idx_listing (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### API: Добавить в избранное

```php
<?php
// api/favorites/add.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $listingId = $_POST['listing_id'];
    $userId = $_SESSION['user_id'];
    
    // Проверить существование объявления
    $stmt = $db->prepare("SELECT id FROM listings WHERE id = ? AND status = 'active'");
    $stmt->execute([$listingId]);
    if (!$stmt->fetch()) {
        throw new Exception('Listing not found');
    }
    
    // Добавить в избранное
    $stmt = $db->prepare("
        INSERT IGNORE INTO favorites (user_id, listing_id, created_at)
        VALUES (?, ?, NOW())
    ");
    $stmt->execute([$userId, $listingId]);
    
    // Получить общее количество
    $stmt = $db->prepare("SELECT COUNT(*) FROM favorites WHERE listing_id = ?");
    $stmt->execute([$listingId]);
    $favoritesCount = $stmt->fetchColumn();
    
    echo json_encode([
        'success' => true,
        'message' => 'Added to favorites',
        'favorites_count' => $favoritesCount
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### API: Удалить из избранного

```php
<?php
// api/favorites/remove.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $listingId = $_POST['listing_id'];
    $userId = $_SESSION['user_id'];
    
    $stmt = $db->prepare("DELETE FROM favorites WHERE user_id = ? AND listing_id = ?");
    $stmt->execute([$userId, $listingId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Removed from favorites'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### Страница избранного

```php
<?php
// user/favorites.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];

// Получить избранное
$stmt = $db->prepare("
    SELECT 
        l.*,
        u.first_name, u.last_name,
        lp.url as main_photo
    FROM favorites f
    JOIN listings l ON f.listing_id = l.id
    JOIN users u ON l.user_id = u.id
    LEFT JOIN listing_photos lp ON l.id = lp.listing_id AND lp.is_main = TRUE
    WHERE f.user_id = ?
    ORDER BY f.created_at DESC
");
$stmt->execute([$userId]);
$favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>My Favorites - AutoMarket</title>
    <link rel="stylesheet" href="/public/css/style.css">
</head>
<body>
    <?php include '../includes/header.php'; ?>
    
    <main class="user-favorites">
        <div class="container">
            <h1>❤️ My Favorites (<?php echo count($favorites); ?>)</h1>
            
            <?php if (empty($favorites)): ?>
                <div class="empty-state">
                    <div class="empty-icon">💔</div>
                    <h2>No favorites yet</h2>
                    <p>Start adding cars to your favorites to see them here</p>
                    <a href="/search" class="btn btn-primary">Browse Listings</a>
                </div>
            <?php else: ?>
                <div class="listings-grid">
                    <?php foreach ($favorites as $listing): ?>
                        <div class="listing-card" data-listing-id="<?php echo $listing['id']; ?>">
                            <div class="listing-card-image">
                                <img src="<?php echo $listing['main_photo']; ?>" alt="">
                                <button class="favorite-btn active" onclick="toggleFavorite(<?php echo $listing['id']; ?>)">
                                    ❤️
                                </button>
                            </div>
                            <div class="listing-card-body">
                                <h3><?php echo htmlspecialchars($listing['title']); ?></h3>
                                <div class="price">€<?php echo number_format($listing['price']); ?></div>
                                <div class="meta">
                                    <span>📅 <?php echo $listing['year']; ?></span>
                                    <span>📏 <?php echo number_format($listing['mileage']); ?> km</span>
                                </div>
                                <a href="/listing/<?php echo $listing['slug']; ?>" class="btn btn-outline btn-full">
                                    View Details
                                </a>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </main>
    
    <script>
    async function toggleFavorite(listingId) {
        const card = document.querySelector(`[data-listing-id="${listingId}"]`);
        const btn = card.querySelector('.favorite-btn');
        const isActive = btn.classList.contains('active');
        
        try {
            const response = await fetch(`/api/favorites/${isActive ? 'remove' : 'add'}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': getCsrfToken()
                },
                body: JSON.stringify({ listing_id: listingId })
            });
            
            const data = await response.json();
            
            if (data.success) {
                if (isActive) {
                    // Удалить карточку с анимацией
                    card.style.animation = 'fadeOut 0.3s ease';
                    setTimeout(() => card.remove(), 300);
                    showNotification('Removed from favorites', 'success');
                } else {
                    btn.classList.add('active');
                    showNotification('Added to favorites', 'success');
                }
            }
        } catch (error) {
            showNotification('Error updating favorites', 'error');
        }
    }
    </script>
</body>
</html>
```

---

## 2️⃣ ЦЕНЗУРА В ЧАТЕ + МОДЕРАЦИЯ

### База данных

```sql
-- Запрещённые слова
CREATE TABLE chat_banned_words (
    id INT AUTO_INCREMENT PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    language VARCHAR(10) DEFAULT 'all',
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    replacement VARCHAR(100) DEFAULT '***',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_word (word),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Логи цензуры
CREATE TABLE chat_censorship_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message_id INT,
    original_text TEXT,
    censored_text TEXT,
    detected_words JSON,
    severity ENUM('low', 'medium', 'high', 'critical'),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### PHP Класс цензуры

```php
<?php
// src/services/ChatCensor.php

class ChatCensor {
    private $db;
    private $bannedWords = [];
    
    public function __construct($db) {
        $this->db = $db;
        $this->loadBannedWords();
    }
    
    private function loadBannedWords() {
        $stmt = $this->db->query("
            SELECT word, severity, replacement 
            FROM chat_banned_words 
            WHERE is_active = TRUE
        ");
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $this->bannedWords[] = $row;
        }
    }
    
    /**
     * Проверить и цензурировать сообщение
     */
    public function censorMessage($text, $userId = null) {
        $originalText = $text;
        $detectedWords = [];
        $maxSeverity = 'low';
        
        // Проверить каждое запрещённое слово
        foreach ($this->bannedWords as $banned) {
            $pattern = '/\b' . preg_quote($banned['word'], '/') . '\b/iu';
            
            if (preg_match($pattern, $text)) {
                $detectedWords[] = [
                    'word' => $banned['word'],
                    'severity' => $banned['severity']
                ];
                
                // Заменить слово
                $text = preg_replace($pattern, $banned['replacement'], $text);
                
                // Определить максимальную серьёзность
                if ($this->getSeverityLevel($banned['severity']) > $this->getSeverityLevel($maxSeverity)) {
                    $maxSeverity = $banned['severity'];
                }
            }
        }
        
        // Дополнительные проверки
        $text = $this->censorPhoneNumbers($text);
        $text = $this->censorEmails($text);
        $text = $this->censorUrls($text);
        
        // Логировать если найдены запрещённые слова
        if (!empty($detectedWords) && $userId) {
            $this->logCensorship($userId, $originalText, $text, $detectedWords, $maxSeverity);
        }
        
        return [
            'text' => $text,
            'detected' => !empty($detectedWords),
            'severity' => $maxSeverity,
            'words' => $detectedWords
        ];
    }
    
    /**
     * Цензурировать номера телефонов
     */
    private function censorPhoneNumbers($text) {
        // Паттерны для телефонов
        $patterns = [
            '/\+?\d{1,3}[\s\-]?\(?\d{1,4}\)?[\s\-]?\d{1,4}[\s\-]?\d{1,4}[\s\-]?\d{1,4}/',
            '/\d{10,}/',
        ];
        
        foreach ($patterns as $pattern) {
            $text = preg_replace($pattern, '[PHONE REMOVED]', $text);
        }
        
        return $text;
    }
    
    /**
     * Цензурировать email адреса
     */
    private function censorEmails($text) {
        $pattern = '/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/';
        return preg_replace($pattern, '[EMAIL REMOVED]', $text);
    }
    
    /**
     * Цензурировать URL
     */
    private function censorUrls($text) {
        $patterns = [
            '/https?:\/\/[^\s]+/',
            '/www\.[^\s]+/',
            '/[a-zA-Z0-9-]+\.(com|de|net|org|info)[^\s]*/i'
        ];
        
        foreach ($patterns as $pattern) {
            $text = preg_replace($pattern, '[LINK REMOVED]', $text);
        }
        
        return $text;
    }
    
    /**
     * Логировать цензуру
     */
    private function logCensorship($userId, $originalText, $censoredText, $detectedWords, $severity) {
        $stmt = $this->db->prepare("
            INSERT INTO chat_censorship_logs 
            (user_id, original_text, censored_text, detected_words, severity, ip_address, created_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([
            $userId,
            $originalText,
            $censoredText,
            json_encode($detectedWords),
            $severity,
            $_SERVER['REMOTE_ADDR']
        ]);
        
        // Если критическая серьёзность - уведомить админов
        if ($severity === 'critical') {
            $this->notifyAdmins($userId, $originalText);
        }
    }
    
    /**
     * Получить числовой уровень серьёзности
     */
    private function getSeverityLevel($severity) {
        $levels = [
            'low' => 1,
            'medium' => 2,
            'high' => 3,
            'critical' => 4
        ];
        return $levels[$severity] ?? 1;
    }
    
    /**
     * Уведомить админов о критическом нарушении
     */
    private function notifyAdmins($userId, $text) {
        // Создать уведомление для админов
        $stmt = $this->db->prepare("
            INSERT INTO admin_notifications (type, severity, message, data, created_at)
            VALUES ('chat_violation', 'high', ?, ?, NOW())
        ");
        
        $stmt->execute([
            'Critical chat violation detected',
            json_encode([
                'user_id' => $userId,
                'text' => $text
            ])
        ]);
    }
}
```

### Использование в чате

```php
<?php
// api/chat/send-message.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$censor = new ChatCensor($db);

$messageText = $_POST['message'];
$recipientId = $_POST['recipient_id'];
$listingId = $_POST['listing_id'];
$userId = $_SESSION['user_id'];

// Цензурировать сообщение
$result = $censor->censorMessage($messageText, $userId);

if ($result['detected']) {
    // Если найдены нарушения
    if ($result['severity'] === 'critical') {
        // Критическое нарушение - заблокировать отправку
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Your message contains prohibited content and cannot be sent.',
            'severity' => 'critical'
        ]);
        exit;
    } else {
        // Менее серьёзное - показать предупреждение
        echo json_encode([
            'success' => true,
            'warning' => 'Some content has been modified due to our community guidelines.',
            'original' => $messageText,
            'censored' => $result['text']
        ]);
    }
}

// Сохранить сообщение
$stmt = $db->prepare("
    INSERT INTO messages (sender_id, recipient_id, listing_id, message_text, created_at)
    VALUES (?, ?, ?, ?, NOW())
");
$stmt->execute([$userId, $recipientId, $listingId, $result['text']]);

echo json_encode([
    'success' => true,
    'message_id' => $db->lastInsertId()
]);
```

### Админ-панель: Управление запрещёнными словами

```php
<?php
// admin/chat/banned-words.php

require_once '../middleware/AdminMiddleware.php';
AdminMiddleware::requireAdmin();
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>Banned Words - AutoMarket Admin</title>
</head>
<body class="admin-panel">
    <?php include '../includes/sidebar.php'; ?>
    
    <div class="admin-main">
        <div class="admin-content">
            <div class="page-header">
                <h1>🚫 Banned Words Management</h1>
                <button class="btn btn-primary" onclick="openAddWordModal()">
                    ➕ Add Banned Word
                </button>
            </div>
            
            <!-- Список запрещённых слов -->
            <div class="data-table">
                <table>
                    <thead>
                        <tr>
                            <th>Word</th>
                            <th>Language</th>
                            <th>Severity</th>
                            <th>Replacement</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        $stmt = $db->query("SELECT * FROM chat_banned_words ORDER BY severity DESC, word ASC");
                        while ($word = $stmt->fetch()):
                        ?>
                        <tr>
                            <td><code><?php echo htmlspecialchars($word['word']); ?></code></td>
                            <td><?php echo strtoupper($word['language']); ?></td>
                            <td>
                                <span class="badge badge-<?php 
                                    echo $word['severity'] === 'critical' ? 'danger' : 
                                        ($word['severity'] === 'high' ? 'warning' : 'default'); 
                                ?>">
                                    <?php echo ucfirst($word['severity']); ?>
                                </span>
                            </td>
                            <td><?php echo htmlspecialchars($word['replacement']); ?></td>
                            <td>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           <?php echo $word['is_active'] ? 'checked' : ''; ?>
                                           onchange="toggleWord(<?php echo $word['id']; ?>, this.checked)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-outline" onclick="editWord(<?php echo $word['id']; ?>)">
                                    Edit
                                </button>
                                <button class="btn btn-sm btn-danger" onclick="deleteWord(<?php echo $word['id']; ?>)">
                                    Delete
                                </button>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    </tbody>
                </table>
            </div>
            
            <!-- Статистика цензуры -->
            <div class="censorship-stats">
                <h2>Censorship Statistics (Last 30 Days)</h2>
                <?php
                $stats = $db->query("
                    SELECT 
                        severity,
                        COUNT(*) as count
                    FROM chat_censorship_logs
                    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                    GROUP BY severity
                ")->fetchAll(PDO::FETCH_KEY_PAIR);
                ?>
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-value"><?php echo $stats['low'] ?? 0; ?></div>
                        <div class="stat-label">Low Severity</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?php echo $stats['medium'] ?? 0; ?></div>
                        <div class="stat-label">Medium Severity</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?php echo $stats['high'] ?? 0; ?></div>
                        <div class="stat-label">High Severity</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?php echo $stats['critical'] ?? 0; ?></div>
                        <div class="stat-label">Critical</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
```

---

## 3️⃣ БЛОКИРОВКА ПОЛЬЗОВАТЕЛЕЙ В ЧАТЕ

### База данных

```sql
CREATE TABLE user_blocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    blocker_id INT NOT NULL,
    blocked_id INT NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_block (blocker_id, blocked_id),
    INDEX idx_blocker (blocker_id),
    INDEX idx_blocked (blocked_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### API: Заблокировать пользователя

```php
<?php
// api/users/block.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $blockedUserId = $_POST['user_id'];
    $blockerId = $_SESSION['user_id'];
    $reason = $_POST['reason'] ?? '';
    
    // Нельзя заблокировать самого себя
    if ($blockedUserId == $blockerId) {
        throw new Exception('You cannot block yourself');
    }
    
    // Заблокировать
    $stmt = $db->prepare("
        INSERT IGNORE INTO user_blocks (blocker_id, blocked_id, reason, created_at)
        VALUES (?, ?, ?, NOW())
    ");
    $stmt->execute([$blockerId, $blockedUserId, $reason]);
    
    // Удалить все активные беседы
    $stmt = $db->prepare("
        UPDATE conversations SET is_active = FALSE
        WHERE (user1_id = ? AND user2_id = ?)
           OR (user1_id = ? AND user2_id = ?)
    ");
    $stmt->execute([$blockerId, $blockedUserId, $blockedUserId, $blockerId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'User blocked successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### API: Разблокировать пользователя

```php
<?php
// api/users/unblock.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $blockedUserId = $_POST['user_id'];
    $blockerId = $_SESSION['user_id'];
    
    $stmt = $db->prepare("
        DELETE FROM user_blocks 
        WHERE blocker_id = ? AND blocked_id = ?
    ");
    $stmt->execute([$blockerId, $blockedUserId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'User unblocked successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### Проверка блокировки при отправке сообщения

```php
<?php
// В api/chat/send-message.php добавить проверку:

// Проверить блокировку
$stmt = $db->prepare("
    SELECT id FROM user_blocks 
    WHERE (blocker_id = ? AND blocked_id = ?)
       OR (blocker_id = ? AND blocked_id = ?)
");
$stmt->execute([$userId, $recipientId, $recipientId, $userId]);

if ($stmt->fetch()) {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'message' => 'You cannot send messages to this user'
    ]);
    exit;
}
```

### Страница заблокированных пользователей

```php
<?php
// user/blocked-users.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];

$stmt = $db->prepare("
    SELECT 
        ub.*,
        u.first_name, u.last_name, u.avatar
    FROM user_blocks ub
    JOIN users u ON ub.blocked_id = u.id
    WHERE ub.blocker_id = ?
    ORDER BY ub.created_at DESC
");
$stmt->execute([$userId]);
$blockedUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>Blocked Users - AutoMarket</title>
</head>
<body>
    <div class="container">
        <h1>🚫 Blocked Users</h1>
        
        <?php if (empty($blockedUsers)): ?>
            <p>You haven't blocked anyone yet.</p>
        <?php else: ?>
            <div class="blocked-users-list">
                <?php foreach ($blockedUsers as $blocked): ?>
                <div class="blocked-user-item">
                    <img src="<?php echo $blocked['avatar']; ?>" alt="Avatar" class="avatar">
                    <div class="user-info">
                        <h3><?php echo htmlspecialchars($blocked['first_name'] . ' ' . $blocked['last_name']); ?></h3>
                        <?php if ($blocked['reason']): ?>
                            <p class="reason">Reason: <?php echo htmlspecialchars($blocked['reason']); ?></p>
                        <?php endif; ?>
                        <small>Blocked <?php echo time_ago($blocked['created_at']); ?></small>
                    </div>
                    <button class="btn btn-outline" onclick="unblockUser(<?php echo $blocked['blocked_id']; ?>)">
                        Unblock
                    </button>
                </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
```

---

## 4️⃣ ОТКЛЮЧЕНИЕ УВЕДОМЛЕНИЙ

### База данных

```sql
CREATE TABLE user_notification_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    
    -- Email уведомления
    email_new_message BOOLEAN DEFAULT TRUE,
    email_listing_approved BOOLEAN DEFAULT TRUE,
    email_listing_rejected BOOLEAN DEFAULT FALSE,
    email_listing_expired BOOLEAN DEFAULT TRUE,
    email_new_favorite BOOLEAN DEFAULT FALSE,
    email_price_drop BOOLEAN DEFAULT TRUE,
    email_newsletter BOOLEAN DEFAULT FALSE,
    
    -- Push уведомления
    push_new_message BOOLEAN DEFAULT TRUE,
    push_listing_approved BOOLEAN DEFAULT TRUE,
    push_new_favorite BOOLEAN DEFAULT TRUE,
    
    -- SMS уведомления
    sms_new_message BOOLEAN DEFAULT FALSE,
    sms_important_only BOOLEAN DEFAULT TRUE,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Страница настроек уведомлений

```php
<?php
// user/settings/notifications.php

require_once '../../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];

// Получить текущие настройки
$stmt = $db->prepare("SELECT * FROM user_notification_settings WHERE user_id = ?");
$stmt->execute([$userId]);
$settings = $stmt->fetch(PDO::FETCH_ASSOC);

// Создать настройки если не существуют
if (!$settings) {
    $db->prepare("INSERT INTO user_notification_settings (user_id) VALUES (?)")->execute([$userId]);
    $stmt->execute([$userId]);
    $settings = $stmt->fetch(PDO::FETCH_ASSOC);
}

// Сохранить изменения
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fields = [
        'email_new_message', 'email_listing_approved', 'email_listing_rejected',
        'email_listing_expired', 'email_new_favorite', 'email_price_drop', 'email_newsletter',
        'push_new_message', 'push_listing_approved', 'push_new_favorite',
        'sms_new_message', 'sms_important_only'
    ];
    
    $updates = [];
    $values = [];
    
    foreach ($fields as $field) {
        $updates[] = "$field = ?";
        $values[] = isset($_POST[$field]) ? 1 : 0;
    }
    
    $values[] = $userId;
    
    $sql = "UPDATE user_notification_settings SET " . implode(', ', $updates) . " WHERE user_id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute($values);
    
    $success = "Settings saved successfully!";
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>Notification Settings - AutoMarket</title>
    <link rel="stylesheet" href="/public/css/style.css">
</head>
<body>
    <?php include '../../includes/header.php'; ?>
    
    <main class="user-settings">
        <div class="container">
            <div class="settings-layout">
                <?php include 'sidebar.php'; ?>
                
                <div class="settings-content">
                    <h1>🔔 Notification Settings</h1>
                    
                    <?php if (isset($success)): ?>
                        <div class="alert alert-success"><?php echo $success; ?></div>
                    <?php endif; ?>
                    
                    <form method="POST">
                        <!-- Email Notifications -->
                        <div class="settings-section">
                            <h2>📧 Email Notifications</h2>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>New Messages</h3>
                                    <p>Receive email when someone sends you a message</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_new_message"
                                           <?php echo $settings['email_new_message'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Listing Approved</h3>
                                    <p>Notification when your listing is approved</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_listing_approved"
                                           <?php echo $settings['email_listing_approved'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Listing Rejected</h3>
                                    <p>Notification when your listing needs changes</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_listing_rejected"
                                           <?php echo $settings['email_listing_rejected'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Listing Expiring</h3>
                                    <p>Reminder when your listing is about to expire</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_listing_expired"
                                           <?php echo $settings['email_listing_expired'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>New Favorite</h3>
                                    <p>Notification when someone favorites your listing</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_new_favorite"
                                           <?php echo $settings['email_new_favorite'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Price Drops</h3>
                                    <p>Alerts when favorited cars drop in price</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_price_drop"
                                           <?php echo $settings['email_price_drop'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Newsletter</h3>
                                    <p>Weekly digest with new cars and tips</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="email_newsletter"
                                           <?php echo $settings['email_newsletter'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                        
                        <!-- Push Notifications -->
                        <div class="settings-section">
                            <h2>📱 Push Notifications</h2>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>New Messages</h3>
                                    <p>Push notification for new messages</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="push_new_message"
                                           <?php echo $settings['push_new_message'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Listing Status</h3>
                                    <p>Push notification for listing updates</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="push_listing_approved"
                                           <?php echo $settings['push_listing_approved'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>New Favorites</h3>
                                    <p>Push notification when someone favorites your listing</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="push_new_favorite"
                                           <?php echo $settings['push_new_favorite'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                        
                        <!-- SMS Notifications -->
                        <div class="settings-section">
                            <h2>💬 SMS Notifications</h2>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>New Messages</h3>
                                    <p>SMS alert for new messages</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="sms_new_message"
                                           <?php echo $settings['sms_new_message'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Important Only</h3>
                                    <p>Only critical notifications via SMS</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" 
                                           name="sms_important_only"
                                           <?php echo $settings['sms_important_only'] ? 'checked' : ''; ?>>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-lg">
                            💾 Save Settings
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
```

---

**ПРОДОЛЖЕНИЕ В СЛЕДУЮЩЕЙ ЧАСТИ...**

У нас ещё **71,017 токенов!** Продолжить создание остальных функций? 🚀

Осталось добавить:
5. Бан/Разбан
6. Архив объявлений
7. Автоудаление
8. Ценообразование
9. Футер страницы
10. CMS
11. Список файлов для скачивания