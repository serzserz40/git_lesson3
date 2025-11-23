# 🔧 ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ AUTOMARKET

## 📋 СОДЕРЖАНИЕ

1. Система закладок (Favorites)
2. Цензура и фильтрация чата
3. Управление чатом (отключение, блокировка)
4. Бан и разбан пользователей
5. Архив объявлений
6. Автоудаление неактивных пользователей
7. Гибкое ценообразование (по категориям и условиям)
8. Страницы футера (About, Terms, Privacy, Contact)
9. CMS для редактирования контента
10. Список всех файлов для скачивания

---

## 1️⃣ СИСТЕМА ЗАКЛАДОК (FAVORITES)

### SQL таблица

```sql
CREATE TABLE user_favorites (
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

### API Endpoints

#### Добавить в закладки

**POST** `/api/v1/favorites`

```json
{
  "listing_id": 789
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Added to favorites"
}
```

#### Удалить из закладок

**DELETE** `/api/v1/favorites/{listing_id}`

**Response 200:**
```json
{
  "success": true,
  "message": "Removed from favorites"
}
```

#### Получить все закладки

**GET** `/api/v1/favorites`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "id": 789,
        "title": "BMW 3 Series 320d",
        "price": 25000,
        "main_photo": "...",
        "added_at": "2024-01-20T15:00:00Z"
      }
    ]
  }
}
```

### Frontend реализация

```php
// views/user/favorites.php

<?php
require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];

// Получить все закладки
$stmt = $db->prepare("
    SELECT l.*, lp.url as main_photo
    FROM user_favorites uf
    JOIN listings l ON uf.listing_id = l.id
    LEFT JOIN listing_photos lp ON l.id = lp.listing_id AND lp.is_main = TRUE
    WHERE uf.user_id = ?
    ORDER BY uf.created_at DESC
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
    <div class="container">
        <h1>❤️ My Favorites</h1>
        
        <?php if (empty($favorites)): ?>
            <div class="empty-state">
                <p>You haven't added any favorites yet.</p>
                <a href="/search" class="btn btn-primary">Browse Listings</a>
            </div>
        <?php else: ?>
            <div class="listings-grid">
                <?php foreach ($favorites as $listing): ?>
                <div class="listing-card">
                    <div class="listing-card-image">
                        <img src="<?php echo htmlspecialchars($listing['main_photo']); ?>" alt="">
                        <button class="favorite-btn active" 
                                onclick="removeFavorite(<?php echo $listing['id']; ?>)">
                            ❤️
                        </button>
                    </div>
                    <div class="listing-card-body">
                        <h3><?php echo htmlspecialchars($listing['title']); ?></h3>
                        <p class="price">€<?php echo number_format($listing['price']); ?></p>
                        <a href="/listing/<?php echo $listing['id']; ?>" class="btn btn-outline">
                            View Details
                        </a>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
    
    <script>
    async function removeFavorite(listingId) {
        if (!confirm('Remove from favorites?')) return;
        
        const response = await fetch(`/api/v1/favorites/${listingId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-Token': getCsrfToken()
            }
        });
        
        if (response.ok) {
            location.reload();
        }
    }
    </script>
</body>
</html>
```

---

## 2️⃣ ЦЕНЗУРА И ФИЛЬТРАЦИЯ ЧАТА

### Таблица запрещённых слов

```sql
CREATE TABLE chat_censored_words (
    id INT AUTO_INCREMENT PRIMARY KEY,
    word VARCHAR(255) NOT NULL,
    replacement VARCHAR(255) DEFAULT '***',
    language VARCHAR(5) DEFAULT 'all',
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_word (word),
    INDEX idx_language (language)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Система фильтрации

```php
<?php
// src/services/ChatCensorService.php

class ChatCensorService {
    private $db;
    private $censoredWords = [];
    
    public function __construct($db) {
        $this->db = $db;
        $this->loadCensoredWords();
    }
    
    private function loadCensoredWords() {
        $stmt = $this->db->query("
            SELECT word, replacement, severity 
            FROM chat_censored_words 
            WHERE is_active = TRUE
        ");
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $this->censoredWords[] = $row;
        }
    }
    
    /**
     * Фильтровать сообщение
     */
    public function filterMessage($message) {
        $filtered = $message;
        $violations = [];
        
        foreach ($this->censoredWords as $word) {
            $pattern = '/\b' . preg_quote($word['word'], '/') . '\b/iu';
            
            if (preg_match($pattern, $filtered)) {
                $filtered = preg_replace($pattern, $word['replacement'], $filtered);
                $violations[] = [
                    'word' => $word['word'],
                    'severity' => $word['severity']
                ];
            }
        }
        
        return [
            'original' => $message,
            'filtered' => $filtered,
            'violations' => $violations,
            'is_clean' => empty($violations)
        ];
    }
    
    /**
     * Проверить на критические слова
     */
    public function hasCriticalViolations($message) {
        $result = $this->filterMessage($message);
        
        foreach ($result['violations'] as $violation) {
            if ($violation['severity'] === 'critical') {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Заблокировать пользователя за критические нарушения
     */
    public function handleCriticalViolation($userId, $message) {
        // Записать нарушение
        $stmt = $this->db->prepare("
            INSERT INTO chat_violations (user_id, message, violation_type, created_at)
            VALUES (?, ?, 'critical_language', NOW())
        ");
        $stmt->execute([$userId, $message]);
        
        // Проверить количество нарушений
        $stmt = $this->db->prepare("
            SELECT COUNT(*) 
            FROM chat_violations 
            WHERE user_id = ? 
            AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ");
        $stmt->execute([$userId]);
        $violationCount = $stmt->fetchColumn();
        
        // Заблокировать после 3 нарушений
        if ($violationCount >= 3) {
            $stmt = $this->db->prepare("
                UPDATE users 
                SET status = 'suspended',
                    suspended_until = DATE_ADD(NOW(), INTERVAL 7 DAY),
                    suspension_reason = 'Multiple chat violations'
                WHERE id = ?
            ");
            $stmt->execute([$userId]);
            
            return [
                'action' => 'suspended',
                'duration' => '7 days'
            ];
        }
        
        return [
            'action' => 'warning',
            'violations_count' => $violationCount
        ];
    }
}
```

### Интеграция в чат

```php
<?php
// api/chat/send-message.php

require_once '../../services/ChatCensorService.php';

$censor = new ChatCensorService($db);

// Получить сообщение
$message = $_POST['message'];
$userId = $_SESSION['user_id'];

// Фильтровать
$result = $censor->filterMessage($message);

// Если есть критические нарушения
if ($censor->hasCriticalViolations($message)) {
    $action = $censor->handleCriticalViolation($userId, $message);
    
    if ($action['action'] === 'suspended') {
        echo json_encode([
            'success' => false,
            'error' => 'Your account has been suspended for violating chat rules.',
            'suspended_until' => $action['duration']
        ]);
        exit;
    }
}

// Сохранить отфильтрованное сообщение
$stmt = $db->prepare("
    INSERT INTO messages (sender_id, recipient_id, message, original_message, created_at)
    VALUES (?, ?, ?, ?, NOW())
");
$stmt->execute([
    $userId,
    $_POST['recipient_id'],
    $result['filtered'],
    $result['original']
]);

echo json_encode([
    'success' => true,
    'message_id' => $db->lastInsertId(),
    'filtered_message' => $result['filtered'],
    'has_violations' => !$result['is_clean']
]);
```

### Админ-панель для управления цензурой

```php
// admin/chat/censored-words.php

<?php
AdminMiddleware::requireAdmin();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Chat Censorship - AutoMarket Admin</title>
</head>
<body class="admin-panel">
    <div class="admin-content">
        <div class="page-header">
            <h1>🚫 Chat Censored Words</h1>
            <button class="btn btn-primary" onclick="openAddWordModal()">
                ➕ Add Word
            </button>
        </div>
        
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Word</th>
                        <th>Replacement</th>
                        <th>Language</th>
                        <th>Severity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $words = $db->query("SELECT * FROM chat_censored_words ORDER BY severity DESC, word ASC");
                    while ($word = $words->fetch()):
                    ?>
                    <tr>
                        <td><code><?php echo htmlspecialchars($word['word']); ?></code></td>
                        <td><?php echo htmlspecialchars($word['replacement']); ?></td>
                        <td><?php echo strtoupper($word['language']); ?></td>
                        <td>
                            <span class="badge badge-<?php echo $word['severity']; ?>">
                                <?php echo ucfirst($word['severity']); ?>
                            </span>
                        </td>
                        <td>
                            <label class="toggle-switch">
                                <input type="checkbox" 
                                       <?php echo $word['is_active'] ? 'checked' : ''; ?>
                                       onchange="toggleWord(<?php echo $word['id']; ?>, this.checked)">
                                <span class="toggle-slider"></span>
                            </label>
                        </td>
                        <td>
                            <button class="btn btn-sm btn-danger" 
                                    onclick="deleteWord(<?php echo $word['id']; ?>)">
                                Delete
                            </button>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
```

---

## 3️⃣ УПРАВЛЕНИЕ ЧАТОМ

### Настройки уведомлений

```sql
CREATE TABLE user_chat_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    sound_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Блокировка пользователей

```sql
CREATE TABLE user_blocked_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT 'Кто блокирует',
    blocked_user_id INT NOT NULL COMMENT 'Кого блокируют',
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_block (user_id, blocked_user_id),
    INDEX idx_user (user_id),
    INDEX idx_blocked (blocked_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Настройки чата

```php
// views/user/chat-settings.php

<?php
AuthMiddleware::check();
$userId = $_SESSION['user_id'];

// Получить настройки
$stmt = $db->prepare("
    SELECT * FROM user_chat_settings WHERE user_id = ?
");
$stmt->execute([$userId]);
$settings = $stmt->fetch(PDO::FETCH_ASSOC);

// Если нет настроек - создать дефолтные
if (!$settings) {
    $db->prepare("INSERT INTO user_chat_settings (user_id) VALUES (?)")->execute([$userId]);
    $settings = $db->prepare("SELECT * FROM user_chat_settings WHERE user_id = ?")->execute([$userId])->fetch();
}

// Получить заблокированных пользователей
$stmt = $db->prepare("
    SELECT u.id, u.first_name, u.last_name, u.avatar, ub.created_at, ub.reason
    FROM user_blocked_users ub
    JOIN users u ON ub.blocked_user_id = u.id
    WHERE ub.user_id = ?
    ORDER BY ub.created_at DESC
");
$stmt->execute([$userId]);
$blockedUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>Chat Settings - AutoMarket</title>
    <link rel="stylesheet" href="/public/css/style.css">
</head>
<body>
    <div class="container">
        <h1>💬 Chat Settings</h1>
        
        <!-- Настройки уведомлений -->
        <div class="settings-card">
            <h2>Notifications</h2>
            <form id="chatSettingsForm">
                <div class="form-group">
                    <label class="toggle-label">
                        <input type="checkbox" 
                               name="notifications_enabled"
                               <?php echo $settings['notifications_enabled'] ? 'checked' : ''; ?>>
                        <span>Enable chat notifications</span>
                    </label>
                </div>
                
                <div class="form-group">
                    <label class="toggle-label">
                        <input type="checkbox" 
                               name="email_notifications"
                               <?php echo $settings['email_notifications'] ? 'checked' : ''; ?>>
                        <span>Email notifications for new messages</span>
                    </label>
                </div>
                
                <div class="form-group">
                    <label class="toggle-label">
                        <input type="checkbox" 
                               name="sms_notifications"
                               <?php echo $settings['sms_notifications'] ? 'checked' : ''; ?>>
                        <span>SMS notifications (additional charges may apply)</span>
                    </label>
                </div>
                
                <div class="form-group">
                    <label class="toggle-label">
                        <input type="checkbox" 
                               name="sound_enabled"
                               <?php echo $settings['sound_enabled'] ? 'checked' : ''; ?>>
                        <span>Play sound for new messages</span>
                    </label>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    💾 Save Settings
                </button>
            </form>
        </div>
        
        <!-- Заблокированные пользователи -->
        <div class="settings-card">
            <h2>🚫 Blocked Users</h2>
            
            <?php if (empty($blockedUsers)): ?>
                <p class="text-muted">You haven't blocked any users.</p>
            <?php else: ?>
                <div class="blocked-users-list">
                    <?php foreach ($blockedUsers as $blocked): ?>
                    <div class="blocked-user-item">
                        <img src="<?php echo $blocked['avatar']; ?>" 
                             alt="" 
                             class="user-avatar">
                        <div class="user-info">
                            <div class="user-name">
                                <?php echo htmlspecialchars($blocked['first_name'] . ' ' . $blocked['last_name']); ?>
                            </div>
                            <?php if ($blocked['reason']): ?>
                                <div class="block-reason">
                                    Reason: <?php echo htmlspecialchars($blocked['reason']); ?>
                                </div>
                            <?php endif; ?>
                            <div class="block-date">
                                Blocked <?php echo time_ago($blocked['created_at']); ?>
                            </div>
                        </div>
                        <button class="btn btn-sm btn-outline" 
                                onclick="unblockUser(<?php echo $blocked['id']; ?>)">
                            Unblock
                        </button>
                    </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </div>
    
    <script>
    // Сохранить настройки
    document.getElementById('chatSettingsForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        
        const response = await fetch('/api/v1/chat/settings', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': getCsrfToken()
            },
            body: JSON.stringify({
                notifications_enabled: formData.get('notifications_enabled') === 'on',
                email_notifications: formData.get('email_notifications') === 'on',
                sms_notifications: formData.get('sms_notifications') === 'on',
                sound_enabled: formData.get('sound_enabled') === 'on'
            })
        });
        
        if (response.ok) {
            showNotification('Settings saved successfully!', 'success');
        }
    });
    
    // Разблокировать пользователя
    async function unblockUser(userId) {
        if (!confirm('Unblock this user?')) return;
        
        const response = await fetch(`/api/v1/chat/unblock/${userId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-Token': getCsrfToken()
            }
        });
        
        if (response.ok) {
            location.reload();
        }
    }
    </script>
</body>
</html>
```

### Кнопка блокировки в чате

```html
<!-- В окне чата -->
<div class="chat-header">
    <div class="chat-user-info">
        <img src="..." alt="">
        <span>John Doe</span>
    </div>
    <div class="chat-actions">
        <button class="btn btn-sm btn-outline" onclick="blockUser(<?php echo $recipientId; ?>)">
            🚫 Block User
        </button>
    </div>
</div>

<script>
async function blockUser(userId) {
    const reason = prompt('Reason for blocking (optional):');
    
    const response = await fetch('/api/v1/chat/block', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': getCsrfToken()
        },
        body: JSON.stringify({
            user_id: userId,
            reason: reason
        })
    });
    
    if (response.ok) {
        showNotification('User blocked successfully', 'success');
        window.location.href = '/messages';
    }
}
</script>
```

---

**ПРОДОЛЖЕНИЕ СЛЕДУЕТ...**

Создаю остальные функции (бан/разбан, архив, автоудаление, ценообразование, страницы футера, CMS)...

**Токенов осталось:** 66,311

**Продолжить?** 🚀