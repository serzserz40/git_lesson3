# SISTEMA UVEDOMLENIY + ANALITIKA + OTZYVY - POLNAYA DOKUMENTACIYA

## CHAST 1: SISTEMA UVEDOMLENIY (Email + SMS + Push)

### SQL STRUKTURA

```sql
-- Tablica uvedomleniy
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSON,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    status ENUM('pending', 'sent', 'delivered', 'failed') DEFAULT 'pending',
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_type (type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tablica nastroyek uvedomleniy polzovatelya
CREATE TABLE user_notification_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    push_enabled BOOLEAN DEFAULT TRUE,
    frequency ENUM('immediately', 'hourly', 'daily', 'weekly') DEFAULT 'immediately',
    quiet_hours_start TIME NULL,
    quiet_hours_end TIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_category (user_id, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Push-tokeny ustroystv
CREATE TABLE user_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_type ENUM('ios', 'android', 'web') NOT NULL,
    device_token VARCHAR(255) UNIQUE NOT NULL,
    device_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_token (device_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Shablony uvedomleniy
CREATE TABLE notification_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    subject_de TEXT,
    subject_en TEXT,
    subject_ru TEXT,
    body_de TEXT,
    body_en TEXT,
    body_ru TEXT,
    sms_template TEXT,
    variables JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### PHP KOD - NotificationManager.php

```php
<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use Twilio\Rest\Client as TwilioClient;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging;

class NotificationManager {
    private $db;
    private $mailer;
    private $twilio;
    private $firebase;
    
    public function __construct($database) {
        $this->db = $database;
        $this->setupMailer();
        $this->setupTwilio();
        $this->setupFirebase();
    }
    
    /**
     * Nastroyka PHPMailer dlya Email
     */
    private function setupMailer() {
        $this->mailer = new PHPMailer(true);
        $this->mailer->isSMTP();
        $this->mailer->Host = $_ENV['SMTP_HOST'];
        $this->mailer->SMTPAuth = true;
        $this->mailer->Username = $_ENV['SMTP_USERNAME'];
        $this->mailer->Password = $_ENV['SMTP_PASSWORD'];
        $this->mailer->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $this->mailer->Port = $_ENV['SMTP_PORT'];
        $this->mailer->CharSet = 'UTF-8';
        $this->mailer->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);
    }
    
    /**
     * Nastroyka Twilio dlya SMS
     */
    private function setupTwilio() {
        $this->twilio = new TwilioClient(
            $_ENV['TWILIO_SID'],
            $_ENV['TWILIO_AUTH_TOKEN']
        );
    }
    
    /**
     * Nastroyka Firebase dlya Push uvedomleniy
     */
    private function setupFirebase() {
        $factory = (new \Kreait\Firebase\Factory)
            ->withServiceAccount($_ENV['FIREBASE_CREDENTIALS_PATH']);
        $this->firebase = $factory->createMessaging();
    }
    
    /**
     * OTPRAVKA EMAIL
     */
    public function sendEmail($userId, $category, $subject, $body, $data = []) {
        try {
            // Proverit nastroyki polzovatelya
            if (!$this->canSendNotification($userId, $category, 'email')) {
                return ['success' => false, 'reason' => 'disabled'];
            }
            
            // Poluchit dannye polzovatelya
            $user = $this->getUser($userId);
            
            // Podgotovit pisma
            $this->mailer->clearAddresses();
            $this->mailer->addAddress($user['email'], $user['first_name'] . ' ' . $user['last_name']);
            $this->mailer->Subject = $subject;
            $this->mailer->isHTML(true);
            $this->mailer->Body = $this->renderEmailTemplate($body, $data, $user);
            
            // Otpravit
            $sent = $this->mailer->send();
            
            // Sohranit v BD
            $notificationId = $this->saveNotification([
                'user_id' => $userId,
                'type' => 'email',
                'category' => $category,
                'title' => $subject,
                'message' => strip_tags($body),
                'data' => json_encode($data),
                'status' => $sent ? 'sent' : 'failed',
                'sent_at' => date('Y-m-d H:i:s')
            ]);
            
            return ['success' => true, 'notification_id' => $notificationId];
            
        } catch (Exception $e) {
            $this->logError('Email error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * OTPRAVKA SMS
     */
    public function sendSMS($userId, $category, $message) {
        try {
            // Proverit nastroyki
            if (!$this->canSendNotification($userId, $category, 'sms')) {
                return ['success' => false, 'reason' => 'disabled'];
            }
            
            $user = $this->getUser($userId);
            
            if (!$user['phone']) {
                return ['success' => false, 'reason' => 'no_phone'];
            }
            
            // Otpravit SMS cherez Twilio
            $twilioMessage = $this->twilio->messages->create(
                $user['phone'],
                [
                    'from' => $_ENV['TWILIO_PHONE_NUMBER'],
                    'body' => $message
                ]
            );
            
            // Sohranit
            $notificationId = $this->saveNotification([
                'user_id' => $userId,
                'type' => 'sms',
                'category' => $category,
                'title' => 'SMS',
                'message' => $message,
                'status' => $twilioMessage->status === 'queued' ? 'sent' : 'failed',
                'sent_at' => date('Y-m-d H:i:s')
            ]);
            
            return ['success' => true, 'notification_id' => $notificationId];
            
        } catch (Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * OTPRAVKA PUSH UVEDOMLENIY
     */
    public function sendPushNotification($userId, $category, $title, $body, $data = []) {
        try {
            // Proverit nastroyki
            if (!$this->canSendNotification($userId, $category, 'push')) {
                return ['success' => false, 'reason' => 'disabled'];
            }
            
            // Poluchit vse tokeny ustroystv polzovatelya
            $devices = $this->getUserDevices($userId);
            
            if (empty($devices)) {
                return ['success' => false, 'reason' => 'no_devices'];
            }
            
            $results = [];
            
            foreach ($devices as $device) {
                try {
                    $message = CloudMessage::withTarget('token', $device['device_token'])
                        ->withNotification([
                            'title' => $title,
                            'body' => $body
                        ])
                        ->withData($data);
                    
                    $this->firebase->send($message);
                    $results[] = ['device_id' => $device['id'], 'success' => true];
                    
                } catch (Exception $e) {
                    $results[] = [
                        'device_id' => $device['id'],
                        'success' => false,
                        'error' => $e->getMessage()
                    ];
                }
            }
            
            // Sohranit
            $notificationId = $this->saveNotification([
                'user_id' => $userId,
                'type' => 'push',
                'category' => $category,
                'title' => $title,
                'message' => $body,
                'data' => json_encode($data),
                'status' => 'sent',
                'sent_at' => date('Y-m-d H:i:s')
            ]);
            
            return [
                'success' => true,
                'notification_id' => $notificationId,
                'results' => $results
            ];
            
        } catch (Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * VNUTRENNEE UVEDOMLENIYE (v prilozhenii)
     */
    public function createInAppNotification($userId, $category, $title, $message, $data = []) {
        return $this->saveNotification([
            'user_id' => $userId,
            'type' => 'in_app',
            'category' => $category,
            'title' => $title,
            'message' => $message,
            'data' => json_encode($data),
            'status' => 'sent'
        ]);
    }
    
    /**
     * MASSOVAYA OTPRAVKA
     */
    public function sendBulkNotification($userIds, $category, $title, $message, $types = ['email', 'push']) {
        $results = [];
        
        foreach ($userIds as $userId) {
            foreach ($types as $type) {
                switch ($type) {
                    case 'email':
                        $results[] = $this->sendEmail($userId, $category, $title, $message);
                        break;
                    case 'sms':
                        $results[] = $this->sendSMS($userId, $category, $message);
                        break;
                    case 'push':
                        $results[] = $this->sendPushNotification($userId, $category, $title, $message);
                        break;
                }
            }
        }
        
        return $results;
    }
    
    /**
     * PREDOPREDELENNYE UVEDOMLENIYA
     */
    
    // Novoe obyavlenie po sohranennomu poisku
    public function notifyNewListingMatch($userId, $listingId, $searchId) {
        $listing = $this->getListing($listingId);
        $search = $this->getSearch($searchId);
        
        $title = 'Novoe obyavlenie po vashemu poisku!';
        $message = "Novyy {$listing['make']} {$listing['model']} za {$listing['price']}€";
        
        $this->sendEmail($userId, 'new_listing', $title, $message, [
            'listing_id' => $listingId,
            'listing_url' => "/listing/{$listingId}"
        ]);
        
        $this->sendPushNotification($userId, 'new_listing', $title, $message, [
            'listing_id' => $listingId
        ]);
    }
    
    // Novoe soobschenie
    public function notifyNewMessage($userId, $senderId, $messageText) {
        $sender = $this->getUser($senderId);
        $title = "Novoe soobschenie ot {$sender['first_name']}";
        
        $this->sendEmail($userId, 'new_message', $title, $messageText);
        $this->sendPushNotification($userId, 'new_message', $title, substr($messageText, 0, 100));
        $this->sendSMS($userId, 'new_message', $title);
    }
    
    // Izmenenie ceny
    public function notifyPriceChange($userId, $listingId, $oldPrice, $newPrice) {
        $listing = $this->getListing($listingId);
        $discount = round((($oldPrice - $newPrice) / $oldPrice) * 100);
        
        $title = "Cena snizhena na {$discount}%!";
        $message = "{$listing['make']} {$listing['model']}: {$oldPrice}€ → {$newPrice}€";
        
        $this->sendEmail($userId, 'price_change', $title, $message);
        $this->sendPushNotification($userId, 'price_change', $title, $message);
    }
    
    // Podtverzhdenie registracii
    public function sendRegistrationConfirmation($userId, $verificationToken) {
        $user = $this->getUser($userId);
        $verificationLink = $_ENV['APP_URL'] . "/verify-email?token={$verificationToken}";
        
        $title = 'Podtverdite vashu registraciyu';
        $message = "Nazhmite na ssylku dlya podtverzhdeniya: <a href='{$verificationLink}'>Podtverdit email</a>";
        
        $this->sendEmail($userId, 'registration', $title, $message);
    }
    
    // Vosstanovlenie parolya
    public function sendPasswordReset($userId, $resetToken) {
        $resetLink = $_ENV['APP_URL'] . "/reset-password?token={$resetToken}";
        
        $title = 'Vosstanovlenie parolya';
        $message = "Nazhmite na ssylku dlya vosstanovleniya: <a href='{$resetLink}'>Vosstanovit parol</a>";
        
        $this->sendEmail($userId, 'password_reset', $title, $message);
    }
    
    /**
     * VSPOMOGATELNYE METODY
     */
    
    private function canSendNotification($userId, $category, $type) {
        $sql = "SELECT {$type}_enabled FROM user_notification_settings 
                WHERE user_id = :user_id AND category = :category";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId, 'category' => $category]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$result) {
            return true; // Po umolchaniyu vklyucheno
        }
        
        return (bool)$result[$type . '_enabled'];
    }
    
    private function saveNotification($data) {
        $sql = "INSERT INTO notifications (
            user_id, type, category, title, message, data, status, sent_at
        ) VALUES (
            :user_id, :type, :category, :title, :message, :data, :status, :sent_at
        )";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        
        return $this->db->lastInsertId();
    }
    
    private function renderEmailTemplate($body, $data, $user) {
        // Prostoу shablon
        $html = '
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: #007bff; color: white; padding: 20px; text-align: center; }
                .content { padding: 20px; background: #f9f9f9; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
                .button { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Auto Marketplace</h1>
                </div>
                <div class="content">
                    ' . $body . '
                </div>
                <div class="footer">
                    <p>&copy; 2025 Auto Marketplace. Alle Rechte vorbehalten.</p>
                    <p><a href="' . $_ENV['APP_URL'] . '/unsubscribe">Abbestellen</a></p>
                </div>
            </div>
        </body>
        </html>';
        
        return $html;
    }
    
    private function getUser($userId) {
        $sql = "SELECT * FROM users WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    private function getUserDevices($userId) {
        $sql = "SELECT * FROM user_devices WHERE user_id = :user_id AND is_active = 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    private function getListing($listingId) {
        $sql = "SELECT * FROM listings WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $listingId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    private function getSearch($searchId) {
        $sql = "SELECT * FROM saved_searches WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $searchId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    private function logError($message) {
        error_log($message);
    }
}
```

---

## CHAST 2: ANALITIKA I STATISTIKA

### SQL STRUKTURA

```sql
-- Statistika prosmotra obyavleniy
CREATE TABLE listing_views (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    user_id INT NULL,
    session_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    referer VARCHAR(255),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_listing (listing_id),
    INDEX idx_user (user_id),
    INDEX idx_date (viewed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statistika kontaktov
CREATE TABLE listing_contacts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    user_id INT NULL,
    contact_type ENUM('phone', 'email', 'message', 'whatsapp') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_listing (listing_id),
    INDEX idx_user (user_id),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statistika poiskov
CREATE TABLE search_analytics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    session_id VARCHAR(255),
    search_query TEXT,
    filters JSON,
    results_count INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dashboard dannyye
CREATE TABLE user_analytics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 2),
    metric_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, metric_date),
    INDEX idx_metric (metric_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### PHP - AnalyticsManager.php

```php
<?php

class AnalyticsManager {
    private $db;
    
    public function __construct($database) {
        $this->db = $database;
    }
    
    /**
     * Zapisat prosmotr obyavleniya
     */
    public function trackListingView($listingId, $userId = null) {
        $sql = "INSERT INTO listing_views (
            listing_id, user_id, session_id, ip_address, user_agent, referer
        ) VALUES (
            :listing_id, :user_id, :session_id, :ip_address, :user_agent, :referer
        )";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'listing_id' => $listingId,
            'user_id' => $userId,
            'session_id' => session_id(),
            'ip_address' => $_SERVER['REMOTE_ADDR'] ?? '',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'referer' => $_SERVER['HTTP_REFERER'] ?? ''
        ]);
    }
    
    /**
     * Statistika dlya polzovatelya (dashboard)
     */
    public function getUserStats($userId, $dateFrom = null, $dateTo = null) {
        if (!$dateFrom) {
            $dateFrom = date('Y-m-d', strtotime('-30 days'));
        }
        if (!$dateTo) {
            $dateTo = date('Y-m-d');
        }
        
        // Prosmotrы
        $views = $this->getListingViews($userId, $dateFrom, $dateTo);
        
        // Kontakty
        $contacts = $this->getListingContacts($userId, $dateFrom, $dateTo);
        
        // Izbrannye
        $favorites = $this->getFavoritesCount($userId);
        
        // Konversiya (kontakty / prosmotrы)
        $conversion = $views > 0 ? round(($contacts / $views) * 100, 2) : 0;
        
        return [
            'views' => $views,
            'contacts' => $contacts,
            'favorites' => $favorites,
            'conversion_rate' => $conversion,
            'active_listings' => $this->getActiveListingsCount($userId),
            'chart_data' => $this->getChartData($userId, $dateFrom, $dateTo)
        ];
    }
    
    /**
     * Grafik prosmotra po dnyam
     */
    private function getChartData($userId, $dateFrom, $dateTo) {
        $sql = "SELECT 
                    DATE(lv.viewed_at) as date,
                    COUNT(DISTINCT lv.id) as views,
                    COUNT(DISTINCT lc.id) as contacts
                FROM listings l
                LEFT JOIN listing_views lv ON l.id = lv.listing_id
                LEFT JOIN listing_contacts lc ON l.id = lc.listing_id
                WHERE l.user_id = :user_id
                AND DATE(lv.viewed_at) BETWEEN :date_from AND :date_to
                GROUP BY DATE(lv.viewed_at)
                ORDER BY date ASC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'user_id' => $userId,
            'date_from' => $dateFrom,
            'date_to' => $dateTo
        ]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    private function getListingViews($userId, $dateFrom, $dateTo) {
        $sql = "SELECT COUNT(DISTINCT lv.id) as count
                FROM listings l
                JOIN listing_views lv ON l.id = lv.listing_id
                WHERE l.user_id = :user_id
                AND DATE(lv.viewed_at) BETWEEN :date_from AND :date_to";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId, 'date_from' => $dateFrom, 'date_to' => $dateTo]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] ?? 0;
    }
    
    private function getListingContacts($userId, $dateFrom, $dateTo) {
        $sql = "SELECT COUNT(DISTINCT lc.id) as count
                FROM listings l
                JOIN listing_contacts lc ON l.id = lc.listing_id
                WHERE l.user_id = :user_id
                AND DATE(lc.created_at) BETWEEN :date_from AND :date_to";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId, 'date_from' => $dateFrom, 'date_to' => $dateTo]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] ?? 0;
    }
    
    private function getFavoritesCount($userId) {
        $sql = "SELECT COUNT(*) as count FROM favorites 
                WHERE listing_id IN (SELECT id FROM listings WHERE user_id = :user_id)";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] ?? 0;
    }
    
    private function getActiveListingsCount($userId) {
        $sql = "SELECT COUNT(*) as count FROM listings 
                WHERE user_id = :user_id AND status = 'active'";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] ?? 0;
    }
}
```

---

## CHAST 3: SISTEMA OTZYV OV I REYTINGOV

### SQL STRUKTURA

```sql
-- Otzyvy
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    buyer_id INT NOT NULL,
    listing_id INT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    pros TEXT,
    cons TEXT,
    verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    seller_response TEXT NULL,
    responded_at TIMESTAMP NULL,
    helpful_count INT DEFAULT 0,
    unhelpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL,
    INDEX idx_seller (seller_id),
    INDEX idx_buyer (buyer_id),
    INDEX idx_rating (rating),
    INDEX idx_approved (is_approved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reytingi prodavcov (agregirovannye dannye)
CREATE TABLE seller_ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    total_reviews INT DEFAULT 0,
    rating_5_count INT DEFAULT 0,
    rating_4_count INT DEFAULT 0,
    rating_3_count INT DEFAULT 0,
    rating_2_count INT DEFAULT 0,
    rating_1_count INT DEFAULT 0,
    response_rate DECIMAL(5, 2) DEFAULT 0,
    average_response_time INT DEFAULT 0, -- v minutah
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Poleznost otzyv ov
CREATE TABLE review_votes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    vote_type ENUM('helpful', 'unhelpful') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_review (user_id, review_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### PHP - ReviewManager.php

```php
<?php

class ReviewManager {
    private $db;
    
    public function __construct($database) {
        $this->db = $database;
    }
    
    /**
     * Dobavit otzyv
     */
    public function addReview($sellerId, $buyerId, $listingId, $rating, $data) {
        // Proverit mozhet li pokupatel ostavit otzyv
        if (!$this->canReview($buyerId, $sellerId)) {
            return ['success' => false, 'error' => 'Already reviewed'];
        }
        
        $sql = "INSERT INTO reviews (
            seller_id, buyer_id, listing_id, rating, title, comment,
            pros, cons, verified_purchase
        ) VALUES (
            :seller_id, :buyer_id, :listing_id, :rating, :title, :comment,
            :pros, :cons, :verified
        )";
        
        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            'seller_id' => $sellerId,
            'buyer_id' => $buyerId,
            'listing_id' => $listingId,
            'rating' => $rating,
            'title' => $data['title'] ?? '',
            'comment' => $data['comment'] ?? '',
            'pros' => $data['pros'] ?? '',
            'cons' => $data['cons'] ?? '',
            'verified' => $this->verifyPurchase($buyerId, $listingId)
        ]);
        
        if ($result) {
            $reviewId = $this->db->lastInsertId();
            
            // Obnovit reyting prodavca
            $this->updateSellerRating($sellerId);
            
            return ['success' => true, 'review_id' => $reviewId];
        }
        
        return ['success' => false];
    }
    
    /**
     * Otvet prodavca na otzyv
     */
    public function addSellerResponse($reviewId, $sellerId, $response) {
        // Proverit chto otzyv prinadlezhit etomu prodavcu
        $review = $this->getReview($reviewId);
        
        if ($review['seller_id'] != $sellerId) {
            return ['success' => false, 'error' => 'Unauthorized'];
        }
        
        $sql = "UPDATE reviews 
                SET seller_response = :response, responded_at = NOW()
                WHERE id = :review_id";
        
        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            'response' => $response,
            'review_id' => $reviewId
        ]);
        
        // Obnovit response_rate
        $this->updateSellerRating($sellerId);
        
        return ['success' => $result];
    }
    
    /**
     * Poluchit otzyvy prodavca
     */
    public function getSellerReviews($sellerId, $page = 1, $perPage = 10) {
        $offset = ($page - 1) * $perPage;
        
        $sql = "SELECT r.*, 
                       u.first_name, u.last_name, u.avatar
                FROM reviews r
                JOIN users u ON r.buyer_id = u.id
                WHERE r.seller_id = :seller_id
                AND r.is_approved = 1
                ORDER BY r.created_at DESC
                LIMIT :limit OFFSET :offset";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':seller_id', $sellerId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Poluchit sredny reytimg prodavca
     */
    public function getSellerRating($sellerId) {
        $sql = "SELECT * FROM seller_ratings WHERE user_id = :user_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $sellerId]);
        
        $rating = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$rating) {
            return [
                'average_rating' => 0,
                'total_reviews' => 0
            ];
        }
        
        return $rating;
    }
    
    /**
     * Otmetit otzyv kak poleznyy/bespoleznyy
     */
    public function voteReview($reviewId, $userId, $voteType) {
        try {
            $sql = "INSERT INTO review_votes (review_id, user_id, vote_type)
                    VALUES (:review_id, :user_id, :vote_type)
                    ON DUPLICATE KEY UPDATE vote_type = :vote_type";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                'review_id' => $reviewId,
                'user_id' => $userId,
                'vote_type' => $voteType
            ]);
            
            // Obnovit schyotchiki
            $this->updateReviewVoteCount($reviewId);
            
            return ['success' => true];
            
        } catch (Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * Obnovit reyting prodavca
     */
    private function updateSellerRating($sellerId) {
        // Podschitat vse otzyvy
        $sql = "SELECT 
                    AVG(rating) as avg_rating,
                    COUNT(*) as total,
                    SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as r5,
                    SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as r4,
                    SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as r3,
                    SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as r2,
                    SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as r1
                FROM reviews
                WHERE seller_id = :seller_id AND is_approved = 1";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['seller_id' => $sellerId]);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Podschitat response_rate
        $responseRate = $this->calculateResponseRate($sellerId);
        
        // Sohranit ili obnovit
        $sql = "INSERT INTO seller_ratings (
                    user_id, average_rating, total_reviews,
                    rating_5_count, rating_4_count, rating_3_count,
                    rating_2_count, rating_1_count, response_rate
                ) VALUES (
                    :user_id, :avg, :total, :r5, :r4, :r3, :r2, :r1, :response_rate
                ) ON DUPLICATE KEY UPDATE
                    average_rating = :avg,
                    total_reviews = :total,
                    rating_5_count = :r5,
                    rating_4_count = :r4,
                    rating_3_count = :r3,
                    rating_2_count = :r2,
                    rating_1_count = :r1,
                    response_rate = :response_rate";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'user_id' => $sellerId,
            'avg' => $stats['avg_rating'],
            'total' => $stats['total'],
            'r5' => $stats['r5'],
            'r4' => $stats['r4'],
            'r3' => $stats['r3'],
            'r2' => $stats['r2'],
            'r1' => $stats['r1'],
            'response_rate' => $responseRate
        ]);
    }
    
    private function calculateResponseRate($sellerId) {
        $sql = "SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN seller_response IS NOT NULL THEN 1 ELSE 0 END) as responded
                FROM reviews
                WHERE seller_id = :seller_id AND is_approved = 1";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['seller_id' => $sellerId]);
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($data['total'] == 0) return 0;
        
        return round(($data['responded'] / $data['total']) * 100, 2);
    }
    
    private function canReview($buyerId, $sellerId) {
        $sql = "SELECT COUNT(*) as count FROM reviews 
                WHERE buyer_id = :buyer_id AND seller_id = :seller_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['buyer_id' => $buyerId, 'seller_id' => $sellerId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] == 0;
    }
    
    private function verifyPurchase($buyerId, $listingId) {
        // Proverit est li u pokupatelya zavershennyy platezh za eto obyavlenie
        $sql = "SELECT COUNT(*) as count FROM payments 
                WHERE user_id = :buyer_id 
                AND listing_id = :listing_id 
                AND status = 'completed'";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['buyer_id' => $buyerId, 'listing_id' => $listingId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result['count'] > 0;
    }
    
    private function getReview($reviewId) {
        $sql = "SELECT * FROM reviews WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $reviewId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    private function updateReviewVoteCount($reviewId) {
        $sql = "UPDATE reviews r SET
                helpful_count = (SELECT COUNT(*) FROM review_votes WHERE review_id = r.id AND vote_type = 'helpful'),
                unhelpful_count = (SELECT COUNT(*) FROM review_votes WHERE review_id = r.id AND vote_type = 'unhelpful')
                WHERE r.id = :review_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['review_id' => $reviewId]);
    }
}
```

---

**Status:** Gotovo! ✅
- Email uvedomleniya ✅
- SMS uvedomleniya ✅
- Push uvedomleniya ✅
- Analitika i dashboard ✅
- Sistema otzyv ov i reytingov ✅