# 🔧 ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ - ЧАСТЬ 2

## ПРОДОЛЖЕНИЕ...

## 5️⃣ БАН/РАЗБАН В АДМИН-ПАНЕЛИ

### База данных (добавить в таблицу users)

```sql
-- Уже есть в users:
-- status ENUM('pending', 'active', 'suspended', 'banned') DEFAULT 'active'

CREATE TABLE ban_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    admin_id INT NOT NULL,
    action ENUM('ban', 'unban', 'suspend') NOT NULL,
    reason TEXT,
    duration_days INT, -- NULL = permanent
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### API: Забанить пользователя

```php
<?php
// admin/api/users/ban.php

require_once '../../../middleware/AdminMiddleware.php';
AdminMiddleware::requireAdmin();

header('Content-Type: application/json');

try {
    $userId = $_POST['user_id'];
    $reason = $_POST['reason'];
    $duration = $_POST['duration'] ?? null; // days, null = permanent
    $adminId = $_SESSION['admin_id'];
    
    // Проверить что не банит самого себя
    if ($userId == $adminId) {
        throw new Exception('You cannot ban yourself');
    }
    
    // Проверить что не банит другого админа
    $stmt = $db->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    if (in_array($user['role'], ['admin', 'superadmin'])) {
        throw new Exception('You cannot ban administrators');
    }
    
    // Рассчитать дату окончания бана
    $expiresAt = null;
    if ($duration) {
        $expiresAt = date('Y-m-d H:i:s', strtotime("+$duration days"));
    }
    
    // Обновить статус пользователя
    $stmt = $db->prepare("
        UPDATE users 
        SET status = 'banned', 
            locked_until = ?
        WHERE id = ?
    ");
    $stmt->execute([$expiresAt, $userId]);
    
    // Записать в историю
    $stmt = $db->prepare("
        INSERT INTO ban_history 
        (user_id, admin_id, action, reason, duration_days, expires_at, created_at)
        VALUES (?, ?, 'ban', ?, ?, ?, NOW())
    ");
    $stmt->execute([$userId, $adminId, $reason, $duration, $expiresAt]);
    
    // Деактивировать все объявления пользователя
    $stmt = $db->prepare("
        UPDATE listings 
        SET status = 'suspended'
        WHERE user_id = ? AND status = 'active'
    ");
    $stmt->execute([$userId]);
    
    // Закрыть все активные сессии
    $stmt = $db->prepare("DELETE FROM user_sessions WHERE user_id = ?");
    $stmt->execute([$userId]);
    
    // Отправить email уведомление
    sendEmail($user['email'], 'Account Banned', "
        Your account has been banned.
        Reason: $reason
        " . ($duration ? "Duration: $duration days" : "This ban is permanent.") . "
        
        If you believe this is a mistake, please contact support.
    ");
    
    echo json_encode([
        'success' => true,
        'message' => $duration ? "User banned for $duration days" : 'User permanently banned'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### API: Разбанить пользователя

```php
<?php
// admin/api/users/unban.php

require_once '../../../middleware/AdminMiddleware.php';
AdminMiddleware::requireAdmin();

header('Content-Type: application/json');

try {
    $userId = $_POST['user_id'];
    $adminId = $_SESSION['admin_id'];
    
    // Обновить статус
    $stmt = $db->prepare("
        UPDATE users 
        SET status = 'active',
            locked_until = NULL
        WHERE id = ?
    ");
    $stmt->execute([$userId]);
    
    // Записать в историю
    $stmt = $db->prepare("
        INSERT INTO ban_history 
        (user_id, admin_id, action, created_at)
        VALUES (?, ?, 'unban', NOW())
    ");
    $stmt->execute([$userId, $adminId]);
    
    // Активировать объявления
    $stmt = $db->prepare("
        UPDATE listings 
        SET status = 'active'
        WHERE user_id = ? AND status = 'suspended'
    ");
    $stmt->execute([$userId]);
    
    // Получить email пользователя
    $stmt = $db->prepare("SELECT email FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $email = $stmt->fetchColumn();
    
    // Отправить уведомление
    sendEmail($email, 'Account Unbanned', "
        Your account has been unbanned.
        You can now log in and use the platform again.
    ");
    
    echo json_encode([
        'success' => true,
        'message' => 'User unbanned successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### Админ-панель: Модальное окно бана

```html
<!-- Modal: Ban User -->
<div id="banModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h2>🚫 Ban User</h2>
            <button class="modal-close" onclick="closeBanModal()">×</button>
        </div>
        <form id="banForm" onsubmit="banUser(event)">
            <div class="modal-body">
                <input type="hidden" id="ban_user_id" name="user_id">
                
                <div class="form-group">
                    <label class="form-label">Reason *</label>
                    <textarea name="reason" 
                              class="form-textarea" 
                              required
                              rows="4"
                              placeholder="Explain why this user is being banned..."></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Ban Duration</label>
                    <select name="duration" class="form-select">
                        <option value="">Permanent</option>
                        <option value="1">1 day</option>
                        <option value="3">3 days</option>
                        <option value="7">7 days</option>
                        <option value="14">14 days</option>
                        <option value="30">30 days</option>
                        <option value="90">90 days</option>
                    </select>
                </div>
                
                <div class="alert alert-warning">
                    <strong>⚠️ Warning:</strong> This will:
                    <ul>
                        <li>Suspend all user's listings</li>
                        <li>Close all active sessions</li>
                        <li>Send email notification to user</li>
                    </ul>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeBanModal()">
                    Cancel
                </button>
                <button type="submit" class="btn btn-danger">
                    🚫 Ban User
                </button>
            </div>
        </form>
    </div>
</div>

<script>
async function banUser(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    
    try {
        const response = await fetch('/admin/api/users/ban', {
            method: 'POST',
            headers: { 'X-CSRF-Token': getCsrfToken() },
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification(data.message, 'success');
            closeBanModal();
            location.reload();
        } else {
            showNotification(data.message, 'error');
        }
    } catch (error) {
        showNotification('Error banning user', 'error');
    }
}
</script>
```

---

## 6️⃣ АРХИВ ОБЪЯВЛЕНИЙ

### База данных

```sql
-- Добавить статус 'archived'
ALTER TABLE listings 
MODIFY COLUMN status ENUM('draft', 'pending_review', 'active', 'sold', 'expired', 'rejected', 'suspended', 'archived') DEFAULT 'draft';

CREATE TABLE archived_listings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    original_listing_id INT NOT NULL,
    user_id INT NOT NULL,
    listing_data JSON NOT NULL, -- Все данные объявления
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archived_by INT, -- NULL = автоматически, иначе admin_id
    reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_original (original_listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Функция архивирования

```php
<?php
// src/services/ListingArchiver.php

class ListingArchiver {
    private $db;
    
    public function __construct($db) {
        $this->db = $db;
    }
    
    /**
     * Архивировать объявление
     */
    public function archiveListing($listingId, $reason = null, $archivedBy = null) {
        try {
            // Получить все данные объявления
            $stmt = $this->db->prepare("
                SELECT 
                    l.*,
                    GROUP_CONCAT(lp.url) as photos,
                    GROUP_CONCAT(lf.feature_name) as features
                FROM listings l
                LEFT JOIN listing_photos lp ON l.id = lp.listing_id
                LEFT JOIN listing_features lf ON l.id = lf.listing_id
                WHERE l.id = ?
                GROUP BY l.id
            ");
            $stmt->execute([$listingId]);
            $listing = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$listing) {
                throw new Exception('Listing not found');
            }
            
            // Сохранить в архив
            $stmt = $this->db->prepare("
                INSERT INTO archived_listings 
                (original_listing_id, user_id, listing_data, archived_at, archived_by, reason)
                VALUES (?, ?, ?, NOW(), ?, ?)
            ");
            
            $stmt->execute([
                $listingId,
                $listing['user_id'],
                json_encode($listing),
                $archivedBy,
                $reason
            ]);
            
            // Обновить статус
            $stmt = $this->db->prepare("
                UPDATE listings 
                SET status = 'archived', updated_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$listingId]);
            
            return true;
            
        } catch (Exception $e) {
            error_log("Error archiving listing $listingId: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Восстановить из архива
     */
    public function restoreListing($archivedId) {
        try {
            // Получить архивные данные
            $stmt = $this->db->prepare("
                SELECT * FROM archived_listings WHERE id = ?
            ");
            $stmt->execute([$archivedId]);
            $archived = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$archived) {
                throw new Exception('Archived listing not found');
            }
            
            $listingData = json_decode($archived['listing_data'], true);
            
            // Восстановить объявление
            $stmt = $this->db->prepare("
                UPDATE listings 
                SET status = 'active', updated_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$archived['original_listing_id']]);
            
            // Удалить из архива
            $stmt = $this->db->prepare("
                DELETE FROM archived_listings WHERE id = ?
            ");
            $stmt->execute([$archivedId]);
            
            return true;
            
        } catch (Exception $e) {
            error_log("Error restoring listing: " . $e->getMessage());
            return false;
        }
    }
}
```

### Cron: Автоматическое архивирование

```php
<?php
// src/cron/auto-archive-listings.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../services/ListingArchiver.php';

$archiver = new ListingArchiver($db);

// Архивировать объявления старше 90 дней после истечения
$stmt = $db->query("
    SELECT id FROM listings 
    WHERE status = 'expired' 
    AND expires_at < DATE_SUB(NOW(), INTERVAL 90 DAY)
");

$count = 0;
while ($listing = $stmt->fetch()) {
    if ($archiver->archiveListing($listing['id'], 'Auto-archived after 90 days', null)) {
        $count++;
    }
}

echo "Archived $count listings\n";
```

### Страница архива пользователя

```php
<?php
// user/my-archive.php

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];

$stmt = $db->prepare("
    SELECT * FROM archived_listings 
    WHERE user_id = ?
    ORDER BY archived_at DESC
");
$stmt->execute([$userId]);
$archived = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>My Archive - AutoMarket</title>
</head>
<body>
    <div class="container">
        <h1>📦 My Archive</h1>
        
        <?php if (empty($archived)): ?>
            <p>No archived listings</p>
        <?php else: ?>
            <div class="archived-list">
                <?php foreach ($archived as $item): ?>
                    <?php $listing = json_decode($item['listing_data'], true); ?>
                    <div class="archived-item">
                        <div class="archived-info">
                            <h3><?php echo htmlspecialchars($listing['title']); ?></h3>
                            <p>Archived: <?php echo date('d.m.Y', strtotime($item['archived_at'])); ?></p>
                            <?php if ($item['reason']): ?>
                                <p>Reason: <?php echo htmlspecialchars($item['reason']); ?></p>
                            <?php endif; ?>
                        </div>
                        <div class="archived-actions">
                            <button class="btn btn-outline" onclick="viewArchivedListing(<?php echo $item['id']; ?>)">
                                👁️ View
                            </button>
                            <button class="btn btn-primary" onclick="restoreListing(<?php echo $item['id']; ?>)">
                                ↩️ Restore
                            </button>
                            <button class="btn btn-danger" onclick="deleteArchived(<?php echo $item['id']; ?>)">
                                🗑️ Delete
                            </button>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
```

---

## 7️⃣ АВТОУДАЛЕНИЕ НЕАКТИВНЫХ ПОЛЬЗОВАТЕЛЕЙ

### База данных

```sql
CREATE TABLE inactive_user_warnings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    warning_sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delete_scheduled_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_scheduled (delete_scheduled_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Cron: Проверка неактивных пользователей

```php
<?php
// src/cron/check-inactive-users.php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../services/EmailService.php';

$emailService = new EmailService();

// Найти пользователей неактивных 330 дней (11 месяцев)
// Отправить предупреждение за 30 дней до удаления
$stmt = $db->query("
    SELECT id, email, first_name, last_name, last_login_at
    FROM users
    WHERE role = 'user'
    AND status = 'active'
    AND last_login_at < DATE_SUB(NOW(), INTERVAL 330 DAY)
    AND id NOT IN (SELECT user_id FROM inactive_user_warnings)
");

$warningsSent = 0;

while ($user = $stmt->fetch(PDO::FETCH_ASSOC)) {
    // Отправить предупреждение
    $emailService->send([
        'to' => $user['email'],
        'subject' => 'Account Inactivity Warning - AutoMarket',
        'template' => 'inactive_warning',
        'data' => [
            'first_name' => $user['first_name'],
            'last_login' => date('d.m.Y', strtotime($user['last_login_at'])),
            'delete_date' => date('d.m.Y', strtotime('+30 days'))
        ]
    ]);
    
    // Записать предупреждение
    $stmt2 = $db->prepare("
        INSERT INTO inactive_user_warnings 
        (user_id, warning_sent_at, delete_scheduled_at)
        VALUES (?, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))
    ");
    $stmt2->execute([$user['id']]);
    
    $warningsSent++;
}

echo "Sent $warningsSent inactivity warnings\n";

// Удалить пользователей которых предупредили 30 дней назад
$stmt = $db->query("
    SELECT w.user_id, u.email, u.first_name
    FROM inactive_user_warnings w
    JOIN users u ON w.user_id = u.id
    WHERE w.delete_scheduled_at <= NOW()
    AND u.last_login_at < w.warning_sent_at
");

$deleted = 0;

while ($user = $stmt->fetch(PDO::FETCH_ASSOC)) {
    // Архивировать все объявления
    $stmt2 = $db->prepare("
        SELECT id FROM listings WHERE user_id = ?
    ");
    $stmt2->execute([$user['user_id']]);
    
    $archiver = new ListingArchiver($db);
    while ($listing = $stmt2->fetch()) {
        $archiver->archiveListing($listing['id'], 'User account deleted due to inactivity', null);
    }
    
    // Отправить финальное уведомление
    $emailService->send([
        'to' => $user['email'],
        'subject' => 'Account Deleted - AutoMarket',
        'template' => 'account_deleted',
        'data' => [
            'first_name' => $user['first_name'],
            'reason' => 'Account was inactive for more than 12 months'
        ]
    ]);
    
    // Удалить пользователя
    $stmt2 = $db->prepare("DELETE FROM users WHERE id = ?");
    $stmt2->execute([$user['user_id']]);
    
    $deleted++;
}

echo "Deleted $deleted inactive accounts\n";
```

### Email шаблон предупреждения

```html
<!-- email/templates/inactive_warning.html -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Account Inactivity Warning</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #ff6500;">⚠️ Account Inactivity Warning</h1>
        
        <p>Hello {{first_name}},</p>
        
        <p>We noticed that you haven't logged into your AutoMarket account since <strong>{{last_login}}</strong>.</p>
        
        <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
            <strong>Important:</strong> Your account will be automatically deleted on <strong>{{delete_date}}</strong> if you don't log in.
        </div>
        
        <p>To keep your account active, simply log in:</p>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="https://automarket.com/login" 
               style="background: #ff6500; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                Log In Now
            </a>
        </div>
        
        <h3>What happens if my account is deleted?</h3>
        <ul>
            <li>All your listings will be archived</li>
            <li>Your personal data will be permanently removed</li>
            <li>Your favorites and messages will be deleted</li>
            <li>This action cannot be undone</li>
        </ul>
        
        <p>If you no longer wish to use AutoMarket, you can ignore this email.</p>
        
        <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
        
        <p style="font-size: 12px; color: #666;">
            This is an automated message. Please do not reply to this email.
        </p>
    </div>
</body>
</html>
```

---

## 8️⃣ ГИБКОЕ ЦЕНООБРАЗОВАНИЕ (ПО КАТЕГОРИЯМ)

### База данных

```sql
CREATE TABLE pricing_rules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    rule_type ENUM('fixed', 'percentage', 'tiered', 'dynamic') DEFAULT 'fixed',
    base_price DECIMAL(10,2),
    
    -- Для tiered pricing
    tier_rules JSON,
    
    -- Для dynamic pricing (как на mobile.de)
    dynamic_rules JSON,
    
    -- Настройки
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_category (category_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Админ-панель: Управление ценами

```php
<?php
// admin/pricing/index.php

require_once '../middleware/AdminMiddleware.php';
AdminMiddleware::requireSuperAdmin();
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <title>Pricing Management - AutoMarket Admin</title>
</head>
<body class="admin-panel">
    <?php include '../includes/sidebar.php'; ?>
    
    <div class="admin-main">
        <div class="admin-content">
            <div class="page-header">
                <h1>💰 Pricing Management</h1>
                <button class="btn btn-primary" onclick="openAddRuleModal()">
                    ➕ Add Pricing Rule
                </button>
            </div>
            
            <!-- Pricing Rules по категориям -->
            <div class="pricing-rules">
                <?php
                $categories = $db->query("SELECT * FROM categories WHERE parent_id IS NULL");
                while ($category = $categories->fetch()):
                    $stmt = $db->prepare("SELECT * FROM pricing_rules WHERE category_id = ?");
                    $stmt->execute([$category['id']]);
                    $rule = $stmt->fetch();
                ?>
                <div class="pricing-card">
                    <div class="pricing-header">
                        <h3><?php echo htmlspecialchars($category['name']); ?></h3>
                        <?php if ($rule): ?>
                            <span class="badge badge-success">Active Rule</span>
                        <?php else: ?>
                            <span class="badge badge-default">No Rule</span>
                        <?php endif; ?>
                    </div>
                    
                    <?php if ($rule): ?>
                    <div class="pricing-body">
                        <div class="pricing-info">
                            <div class="pricing-type">
                                <strong>Type:</strong> 
                                <?php echo ucfirst($rule['rule_type']); ?>
                            </div>
                            
                            <?php if ($rule['rule_type'] === 'fixed'): ?>
                                <div class="pricing-amount">
                                    <strong>Price:</strong> 
                                    €<?php echo number_format($rule['base_price'], 2); ?>
                                </div>
                            <?php endif; ?>
                            
                            <?php if ($rule['rule_type'] === 'tiered'): ?>
                                <div class="pricing-tiers">
                                    <strong>Tiers:</strong>
                                    <?php
                                    $tiers = json_decode($rule['tier_rules'], true);
                                    foreach ($tiers as $tier):
                                    ?>
                                    <div class="tier-item">
                                        Price €<?php echo number_format($tier['price_min']); ?> - 
                                        €<?php echo number_format($tier['price_max']); ?>: 
                                        €<?php echo number_format($tier['fee'], 2); ?>
                                    </div>
                                    <?php endforeach; ?>
                                </div>
                            <?php endif; ?>
                            
                            <?php if ($rule['rule_type'] === 'dynamic'): ?>
                                <div class="pricing-dynamic">
                                    <strong>Dynamic Rules:</strong>
                                    <?php
                                    $rules = json_decode($rule['dynamic_rules'], true);
                                    ?>
                                    <pre><?php echo json_encode($rules, JSON_PRETTY_PRINT); ?></pre>
                                </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="pricing-actions">
                            <button class="btn btn-outline" onclick="editRule(<?php echo $rule['id']; ?>)">
                                ✏️ Edit
                            </button>
                            <button class="btn btn-danger" onclick="deleteRule(<?php echo $rule['id']; ?>)">
                                🗑️ Delete
                            </button>
                        </div>
                    </div>
                    <?php else: ?>
                    <div class="pricing-empty">
                        <p>No pricing rule set for this category</p>
                        <button class="btn btn-primary" onclick="addRuleForCategory(<?php echo $category['id']; ?>)">
                            Add Rule
                        </button>
                    </div>
                    <?php endif; ?>
                </div>
                <?php endwhile; ?>
            </div>
        </div>
    </div>
    
    <!-- Modal: Add/Edit Rule -->
    <div id="ruleModal" class="modal" style="display: none;">
        <div class="modal-content modal-large">
            <div class="modal-header">
                <h2>Add Pricing Rule</h2>
                <button class="modal-close" onclick="closeRuleModal()">×</button>
            </div>
            <form id="ruleForm" onsubmit="saveRule(event)">
                <div class="modal-body">
                    <input type="hidden" name="rule_id" id="rule_id">
                    
                    <div class="form-group">
                        <label class="form-label">Category *</label>
                        <select name="category_id" id="category_id" class="form-select" required>
                            <option value="">Select category...</option>
                            <?php
                            $categories = $db->query("SELECT * FROM categories");
                            while ($cat = $categories->fetch()):
                            ?>
                            <option value="<?php echo $cat['id']; ?>">
                                <?php echo htmlspecialchars($cat['name']); ?>
                            </option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Pricing Type *</label>
                        <select name="rule_type" id="rule_type" class="form-select" required onchange="updateRuleTypeFields()">
                            <option value="fixed">Fixed Price</option>
                            <option value="tiered">Tiered Pricing</option>
                            <option value="dynamic">Dynamic Pricing (like mobile.de)</option>
                        </select>
                    </div>
                    
                    <!-- Fixed Price -->
                    <div id="fixedPriceSection" class="rule-section">
                        <div class="form-group">
                            <label class="form-label">Price (€) *</label>
                            <input type="number" 
                                   name="base_price" 
                                   id="base_price"
                                   class="form-input" 
                                   step="0.01"
                                   min="0">
                        </div>
                    </div>
                    
                    <!-- Tiered Pricing -->
                    <div id="tieredPriceSection" class="rule-section" style="display: none;">
                        <h3>Price Tiers</h3>
                        <div id="tiersList">
                            <!-- Будет заполнено динамически -->
                        </div>
                        <button type="button" class="btn btn-outline btn-sm" onclick="addTier()">
                            ➕ Add Tier
                        </button>
                    </div>
                    
                    <!-- Dynamic Pricing -->
                    <div id="dynamicPriceSection" class="rule-section" style="display: none;">
                        <h3>Dynamic Pricing Rules</h3>
                        <p class="form-hint">Set rules based on vehicle price and year (like mobile.de)</p>
                        
                        <div class="form-group">
                            <label class="form-label">Base Fee (€)</label>
                            <input type="number" 
                                   name="dynamic_base_fee" 
                                   class="form-input" 
                                   step="0.01"
                                   value="49.99">
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="dynamic_year_multiplier" value="1">
                                <span>Apply year multiplier (newer cars = higher fee)</span>
                            </label>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="dynamic_price_percentage" value="1">
                                <span>Apply percentage of vehicle price</span>
                            </label>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Percentage Rate (%)</label>
                            <input type="number" 
                                   name="dynamic_percentage" 
                                   class="form-input" 
                                   step="0.01"
                                   value="0.5"
                                   min="0"
                                   max="100">
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeRuleModal()">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary">
                        💾 Save Rule
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script src="/public/js/admin-pricing.js"></script>
</body>
</html>
```

---

**ПРОДОЛЖЕНИЕ В СЛЕДУЮЩЕЙ ЧАСТИ...**

У нас ещё **56,671 токенов!** Продолжить? 🚀

Осталось добавить:
9. Автоматическое ценообразование (алгоритм как на mobile.de)
10. Футер страницы (About, Terms, Privacy, Contact) на 10 языках
11. CMS - Редактирование фронтенда
12. Полный список файлов для скачивания