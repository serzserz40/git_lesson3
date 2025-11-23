# ФУНКЦИОНАЛ ЧАСТЬ 2: МОДЕРАЦИЯ, SEO, МАСТЕР ОБЪЯВЛЕНИЙ, ЛОГОТИП

## 📋 СОДЕРЖАНИЕ ЧАСТИ 2

9. **Автоматическая модерация**
10. **Автоматическое SEO**
11. **Мастер подачи объявлений (Wizard)**
12. **Логотип и Фавикон**
13. **Структура проекта (как всё организовать)**
14. **Инструкция по созданию сайта**

---

## 9️⃣ АВТОМАТИЧЕСКАЯ МОДЕРАЦИЯ

### AutoModerationSystem.php

```php
<?php

class AutoModerationSystem {
    private $db;
    private $bannedWords = [];
    private $suspiciousPatterns = [];
    
    public function __construct($database) {
        $this->db = $database;
        $this->loadBannedWords();
        $this->loadSuspiciousPatterns();
    }
    
    /**
     * Загрузить запрещённые слова из БД
     */
    private function loadBannedWords() {
        $stmt = $this->db->query("SELECT word FROM banned_words WHERE is_active = 1");
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $this->bannedWords[] = $row['word'];
        }
    }
    
    /**
     * Загрузить подозрительные паттерны
     */
    private function loadSuspiciousPatterns() {
        $this->suspiciousPatterns = [
            '/\b(viagra|cialis|casino|porn|xxx)\b/i',
            '/\b(whatsapp|telegram|viber)[\s:+\d]{10,}/i', // Номера телефонов
            '/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/', // Email в тексте
            '/\b(http|https|www)\b/i', // URL в описании
            '/\b(купи[тмл]|продам|дешево|срочно|акция|скидка)\b/i',
            '/(.)\1{5,}/', // Повторяющиеся символы (ааааааа)
        ];
    }
    
    /**
     * Главная функция модерации объявления
     */
    public function moderateListing($listingData) {
        $score = 0;
        $flags = [];
        $autoAction = 'approve'; // approve, review, reject
        
        // 1. Проверка на запрещённые слова
        $bannedWordCheck = $this->checkBannedWords($listingData['title'] . ' ' . $listingData['description']);
        if ($bannedWordCheck['found']) {
            $score += 50;
            $flags[] = [
                'type' => 'banned_words',
                'severity' => 'high',
                'details' => $bannedWordCheck['words']
            ];
        }
        
        // 2. Проверка на подозрительные паттерны
        $patternCheck = $this->checkSuspiciousPatterns($listingData['description']);
        if ($patternCheck['found']) {
            $score += 30;
            $flags[] = [
                'type' => 'suspicious_pattern',
                'severity' => 'medium',
                'details' => $patternCheck['patterns']
            ];
        }
        
        // 3. Проверка на дубликаты
        $duplicateCheck = $this->checkDuplicates($listingData);
        if ($duplicateCheck['found']) {
            $score += 40;
            $flags[] = [
                'type' => 'duplicate',
                'severity' => 'high',
                'details' => $duplicateCheck['similar_ids']
            ];
        }
        
        // 4. Проверка цены (слишком низкая или высокая)
        $priceCheck = $this->checkPrice($listingData['price'], $listingData['category_id'], $listingData['year']);
        if ($priceCheck['suspicious']) {
            $score += 25;
            $flags[] = [
                'type' => 'suspicious_price',
                'severity' => 'medium',
                'details' => $priceCheck['reason']
            ];
        }
        
        // 5. Проверка изображений
        if (isset($listingData['images'])) {
            $imageCheck = $this->checkImages($listingData['images']);
            if ($imageCheck['suspicious']) {
                $score += 20;
                $flags[] = [
                    'type' => 'image_issue',
                    'severity' => 'low',
                    'details' => $imageCheck['issues']
                ];
            }
        }
        
        // 6. Проверка истории пользователя
        $userHistoryCheck = $this->checkUserHistory($listingData['user_id']);
        if ($userHistoryCheck['suspicious']) {
            $score += 30;
            $flags[] = [
                'type' => 'user_history',
                'severity' => 'medium',
                'details' => $userHistoryCheck['reasons']
            ];
        }
        
        // 7. Проверка VIN номера (если есть)
        if (isset($listingData['vin']) && !empty($listingData['vin'])) {
            $vinCheck = $this->checkVIN($listingData['vin']);
            if (!$vinCheck['valid']) {
                $score += 35;
                $flags[] = [
                    'type' => 'invalid_vin',
                    'severity' => 'high',
                    'details' => 'VIN validation failed'
                ];
            }
        }
        
        // 8. Принять решение на основе score
        if ($score >= 70) {
            $autoAction = 'reject';
        } elseif ($score >= 40) {
            $autoAction = 'review';
        } else {
            $autoAction = 'approve';
        }
        
        // 9. Сохранить результат модерации
        $this->saveModerationResult($listingData['id'], $score, $flags, $autoAction);
        
        return [
            'action' => $autoAction,
            'score' => $score,
            'flags' => $flags
        ];
    }
    
    /**
     * Проверка на запрещённые слова
     */
    private function checkBannedWords($text) {
        $text = mb_strtolower($text);
        $foundWords = [];
        
        foreach ($this->bannedWords as $word) {
            if (strpos($text, mb_strtolower($word)) !== false) {
                $foundWords[] = $word;
            }
        }
        
        return [
            'found' => !empty($foundWords),
            'words' => $foundWords
        ];
    }
    
    /**
     * Проверка на подозрительные паттерны
     */
    private function checkSuspiciousPatterns($text) {
        $foundPatterns = [];
        
        foreach ($this->suspiciousPatterns as $pattern) {
            if (preg_match($pattern, $text)) {
                $foundPatterns[] = $pattern;
            }
        }
        
        return [
            'found' => !empty($foundPatterns),
            'patterns' => $foundPatterns
        ];
    }
    
    /**
     * Проверка на дубликаты (похожие объявления)
     */
    private function checkDuplicates($listingData) {
        // Поиск похожих объявлений по:
        // - тому же пользователю
        // - той же модели и году
        // - похожему описанию (Levenshtein distance)
        
        $stmt = $this->db->prepare("
            SELECT id, title, description 
            FROM listings 
            WHERE user_id = ? 
            AND category_id = ?
            AND year = ?
            AND status != 'deleted'
            AND id != ?
            LIMIT 10
        ");
        
        $stmt->execute([
            $listingData['user_id'],
            $listingData['category_id'],
            $listingData['year'],
            $listingData['id'] ?? 0
        ]);
        
        $similarIds = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Проверить похожесть описания
            $similarity = 0;
            similar_text($listingData['description'], $row['description'], $similarity);
            
            if ($similarity > 80) {
                $similarIds[] = $row['id'];
            }
        }
        
        return [
            'found' => !empty($similarIds),
            'similar_ids' => $similarIds
        ];
    }
    
    /**
     * Проверка подозрительной цены
     */
    private function checkPrice($price, $categoryId, $year) {
        // Получить среднюю цену для этой категории и года
        $stmt = $this->db->prepare("
            SELECT AVG(price) as avg_price, MIN(price) as min_price, MAX(price) as max_price
            FROM listings
            WHERE category_id = ?
            AND year = ?
            AND status = 'active'
            AND price > 0
        ");
        
        $stmt->execute([$categoryId, $year]);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$stats || !$stats['avg_price']) {
            return ['suspicious' => false];
        }
        
        $avgPrice = $stats['avg_price'];
        $minPrice = $stats['min_price'];
        $maxPrice = $stats['max_price'];
        
        // Цена слишком низкая (меньше 50% от средней)
        if ($price < $avgPrice * 0.5 && $price < $minPrice * 1.2) {
            return [
                'suspicious' => true,
                'reason' => 'Price too low compared to market average'
            ];
        }
        
        // Цена слишком высокая (больше 200% от средней)
        if ($price > $avgPrice * 2 && $price > $maxPrice * 0.8) {
            return [
                'suspicious' => true,
                'reason' => 'Price too high compared to market average'
            ];
        }
        
        return ['suspicious' => false];
    }
    
    /**
     * Проверка изображений
     */
    private function checkImages($images) {
        $issues = [];
        
        // Мало изображений (меньше 3)
        if (count($images) < 3) {
            $issues[] = 'Too few images';
        }
        
        // Проверить размеры изображений
        foreach ($images as $image) {
            if (filesize($image) < 50000) { // Меньше 50KB
                $issues[] = 'Low quality image detected';
            }
        }
        
        return [
            'suspicious' => !empty($issues),
            'issues' => $issues
        ];
    }
    
    /**
     * Проверка истории пользователя
     */
    private function checkUserHistory($userId) {
        $reasons = [];
        
        // 1. Проверить количество отклонённых объявлений
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as rejected_count
            FROM listings
            WHERE user_id = ?
            AND status = 'rejected'
            AND created_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
        ");
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result['rejected_count'] >= 3) {
            $reasons[] = 'Multiple rejected listings in past 30 days';
        }
        
        // 2. Проверить жалобы на пользователя
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as complaint_count
            FROM reports
            WHERE reported_user_id = ?
            AND created_at > DATE_SUB(NOW(), INTERVAL 60 DAY)
        ");
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result['complaint_count'] >= 2) {
            $reasons[] = 'Multiple complaints in past 60 days';
        }
        
        // 3. Проверить новый аккаунт
        $stmt = $this->db->prepare("
            SELECT DATEDIFF(NOW(), created_at) as account_age
            FROM users
            WHERE id = ?
        ");
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result['account_age'] < 7) {
            $reasons[] = 'New account (less than 7 days old)';
        }
        
        return [
            'suspicious' => !empty($reasons),
            'reasons' => $reasons
        ];
    }
    
    /**
     * Проверка VIN номера
     */
    private function checkVIN($vin) {
        // Проверить длину (17 символов)
        if (strlen($vin) !== 17) {
            return ['valid' => false];
        }
        
        // Проверить символы (без I, O, Q)
        if (!preg_match('/^[A-HJ-NPR-Z0-9]{17}$/', $vin)) {
            return ['valid' => false];
        }
        
        // Проверить check digit (позиция 9)
        // ... реализация алгоритма проверки VIN
        
        // Проверить в базе данных на дубликаты
        $stmt = $this->db->prepare("
            SELECT id FROM listings
            WHERE vin = ?
            AND status != 'deleted'
        ");
        $stmt->execute([$vin]);
        
        if ($stmt->fetch()) {
            return ['valid' => false, 'reason' => 'VIN already exists'];
        }
        
        return ['valid' => true];
    }
    
    /**
     * Сохранить результат модерации
     */
    private function saveModerationResult($listingId, $score, $flags, $action) {
        $stmt = $this->db->prepare("
            INSERT INTO moderation_results (listing_id, moderation_score, flags, auto_action, moderated_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([
            $listingId,
            $score,
            json_encode($flags),
            $action
        ]);
        
        // Обновить статус объявления
        if ($action === 'approve') {
            $newStatus = 'active';
        } elseif ($action === 'review') {
            $newStatus = 'pending_review';
        } else {
            $newStatus = 'rejected';
        }
        
        $stmt = $this->db->prepare("
            UPDATE listings
            SET status = ?
            WHERE id = ?
        ");
        $stmt->execute([$newStatus, $listingId]);
        
        // Отправить уведомление пользователю
        if ($action === 'rejected') {
            $this->notifyUserRejection($listingId, $flags);
        }
    }
    
    /**
     * Уведомить пользователя об отклонении
     */
    private function notifyUserRejection($listingId, $flags) {
        // Получить email пользователя
        $stmt = $this->db->prepare("
            SELECT u.email, l.title
            FROM listings l
            JOIN users u ON l.user_id = u.id
            WHERE l.id = ?
        ");
        $stmt->execute([$listingId]);
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Отправить email
        $reasons = array_map(function($flag) {
            return $flag['type'];
        }, $flags);
        
        // ... отправка email через PHPMailer
    }
}
?>
```

### SQL для модерации:

```sql
-- Таблица запрещённых слов
CREATE TABLE banned_words (
    id INT AUTO_INCREMENT PRIMARY KEY,
    word VARCHAR(255) NOT NULL,
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_word (word)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Вставить базовые запрещённые слова
INSERT INTO banned_words (word, category) VALUES
('viagra', 'spam'),
('cialis', 'spam'),
('casino', 'spam'),
('porn', 'adult'),
('xxx', 'adult'),
-- ... добавить больше

-- Таблица результатов модерации
CREATE TABLE moderation_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    moderation_score INT DEFAULT 0,
    flags JSON,
    auto_action ENUM('approve', 'review', 'reject') NOT NULL,
    manual_review BOOLEAN DEFAULT FALSE,
    reviewer_id INT,
    reviewer_decision ENUM('approved', 'rejected', 'pending'),
    reviewer_notes TEXT,
    moderated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_listing (listing_id),
    INDEX idx_action (auto_action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔟 АВТОМАТИЧЕСКОЕ SEO

### SEOManager.php

```php
<?php

class SEOManager {
    private $db;
    
    public function __construct($database) {
        $this->db = $database;
    }
    
    /**
     * Автоматически генерировать SEO для объявления
     */
    public function generateListingSEO($listingData) {
        $brand = $listingData['brand'] ?? '';
        $model = $listingData['model'] ?? '';
        $year = $listingData['year'] ?? '';
        $price = $listingData['price'] ?? '';
        $city = $listingData['city'] ?? '';
        
        // Генерировать Title (55-60 символов)
        $title = $this->generateTitle($brand, $model, $year, $price, $city);
        
        // Генерировать Description (150-160 символов)
        $description = $this->generateDescription($listingData);
        
        // Генерировать Keywords
        $keywords = $this->generateKeywords($listingData);
        
        // Генерировать URL Slug
        $slug = $this->generateSlug($brand, $model, $year, $listingData['id']);
        
        // Генерировать Schema.org разметку
        $schemaMarkup = $this->generateSchemaMarkup($listingData);
        
        // Генерировать Open Graph теги
        $openGraph = $this->generateOpenGraphTags($listingData);
        
        // Сохранить в БД
        $this->saveSEOData($listingData['id'], [
            'title' => $title,
            'description' => $description,
            'keywords' => $keywords,
            'slug' => $slug,
            'schema_markup' => $schemaMarkup,
            'open_graph' => $openGraph
        ]);
        
        return [
            'title' => $title,
            'description' => $description,
            'keywords' => $keywords,
            'slug' => $slug,
            'schema' => $schemaMarkup,
            'og' => $openGraph
        ];
    }
    
    /**
     * Генерировать SEO Title
     */
    private function generateTitle($brand, $model, $year, $price, $city) {
        $parts = array_filter([$brand, $model, $year]);
        $title = implode(' ', $parts);
        
        if ($price) {
            $formattedPrice = number_format($price, 0, ',', '.') . ' €';
            $title .= " ab $formattedPrice";
        }
        
        if ($city) {
            $title .= " in $city";
        }
        
        $title .= " | AutoMarket.de";
        
        // Ограничить до 60 символов
        if (mb_strlen($title) > 60) {
            $title = mb_substr($title, 0, 57) . '...';
        }
        
        return $title;
    }
    
    /**
     * Генерировать Meta Description
     */
    private function generateDescription($data) {
        $brand = $data['brand'] ?? '';
        $model = $data['model'] ?? '';
        $year = $data['year'] ?? '';
        $mileage = $data['mileage'] ?? '';
        $fuel = $data['fuel_type'] ?? '';
        $price = $data['price'] ?? '';
        
        $description = "Kaufen Sie $brand $model ($year) mit ";
        
        if ($mileage) {
            $description .= number_format($mileage, 0, ',', '.') . " km";
        }
        
        if ($fuel) {
            $description .= ", $fuel";
        }
        
        if ($price) {
            $description .= " für " . number_format($price, 0, ',', '.') . " €";
        }
        
        $description .= ". Geprüfte Gebrauchtwagen von privaten und gewerblichen Anbietern.";
        
        // Ограничить до 160 символов
        if (mb_strlen($description) > 160) {
            $description = mb_substr($description, 0, 157) . '...';
        }
        
        return $description;
    }
    
    /**
     * Генерировать Keywords
     */
    private function generateKeywords($data) {
        $keywords = [
            $data['brand'] ?? '',
            $data['model'] ?? '',
            ($data['brand'] ?? '') . ' ' . ($data['model'] ?? ''),
            'gebrauchtwagen',
            'auto kaufen',
            'fahrzeug',
            ($data['year'] ?? '') ? $data['brand'] . ' ' . $data['year'] : '',
            $data['city'] ?? ''
        ];
        
        // Добавить тип кузова
        if (isset($data['body_type'])) {
            $keywords[] = $data['body_type'];
            $keywords[] = $data['brand'] . ' ' . $data['body_type'];
        }
        
        // Добавить тип топлива
        if (isset($data['fuel_type'])) {
            $keywords[] = $data['fuel_type'];
        }
        
        // Удалить пустые и дубликаты
        $keywords = array_filter($keywords);
        $keywords = array_unique($keywords);
        
        return implode(', ', $keywords);
    }
    
    /**
     * Генерировать URL Slug (ЧПУ)
     */
    private function generateSlug($brand, $model, $year, $id) {
        $slug = strtolower($brand . '-' . $model . '-' . $year . '-' . $id);
        
        // Заменить пробелы и специальные символы
        $slug = preg_replace('/[^a-z0-9]+/i', '-', $slug);
        $slug = trim($slug, '-');
        
        return $slug;
    }
    
    /**
     * Генерировать Schema.org разметку (JSON-LD)
     */
    private function generateSchemaMarkup($data) {
        $schema = [
            '@context' => 'https://schema.org/',
            '@type' => 'Car',
            'name' => ($data['brand'] ?? '') . ' ' . ($data['model'] ?? ''),
            'brand' => [
                '@type' => 'Brand',
                'name' => $data['brand'] ?? ''
            ],
            'model' => $data['model'] ?? '',
            'vehicleModelDate' => $data['year'] ?? '',
            'mileageFromOdometer' => [
                '@type' => 'QuantitativeValue',
                'value' => $data['mileage'] ?? 0,
                'unitCode' => 'KMT'
            ],
            'fuelType' => $data['fuel_type'] ?? '',
            'vehicleTransmission' => $data['transmission'] ?? '',
            'bodyType' => $data['body_type'] ?? '',
            'offers' => [
                '@type' => 'Offer',
                'price' => $data['price'] ?? 0,
                'priceCurrency' => 'EUR',
                'availability' => 'https://schema.org/InStock',
                'url' => 'https://yoursite.com/' . $data['slug']
            ]
        ];
        
        if (!empty($data['images'])) {
            $schema['image'] = $data['images'][0];
        }
        
        return json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    }
    
    /**
     * Генерировать Open Graph теги
     */
    private function generateOpenGraphTags($data) {
        $og = [
            'og:type' => 'product',
            'og:title' => ($data['brand'] ?? '') . ' ' . ($data['model'] ?? '') . ' (' . ($data['year'] ?? '') . ')',
            'og:description' => $data['description'] ?? '',
            'og:url' => 'https://yoursite.com/' . $data['slug'],
            'og:site_name' => 'AutoMarket',
            'product:price:amount' => $data['price'] ?? 0,
            'product:price:currency' => 'EUR'
        ];
        
        if (!empty($data['images'])) {
            $og['og:image'] = $data['images'][0];
            $og['og:image:width'] = '1200';
            $og['og:image:height'] = '630';
        }
        
        return $og;
    }
    
    /**
     * Сохранить SEO данные в БД
     */
    private function saveSEOData($listingId, $seoData) {
        $stmt = $this->db->prepare("
            INSERT INTO listing_seo (listing_id, title, description, keywords, slug, schema_markup, open_graph)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                title = VALUES(title),
                description = VALUES(description),
                keywords = VALUES(keywords),
                slug = VALUES(slug),
                schema_markup = VALUES(schema_markup),
                open_graph = VALUES(open_graph),
                updated_at = NOW()
        ");
        
        $stmt->execute([
            $listingId,
            $seoData['title'],
            $seoData['description'],
            $seoData['keywords'],
            $seoData['slug'],
            $seoData['schema_markup'],
            json_encode($seoData['open_graph'])
        ]);
    }
    
    /**
     * Генерировать Sitemap.xml
     */
    public function generateSitemap() {
        $xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>');
        
        // Добавить главную страницу
        $url = $xml->addChild('url');
        $url->addChild('loc', 'https://yoursite.com/');
        $url->addChild('changefreq', 'daily');
        $url->addChild('priority', '1.0');
        
        // Добавить категории
        $stmt = $this->db->query("SELECT slug FROM categories WHERE is_active = 1");
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $url = $xml->addChild('url');
            $url->addChild('loc', 'https://yoursite.com/category/' . $row['slug']);
            $url->addChild('changefreq', 'weekly');
            $url->addChild('priority', '0.8');
        }
        
        // Добавить объявления
        $stmt = $this->db->query("
            SELECT slug, updated_at 
            FROM listing_seo 
            WHERE listing_id IN (SELECT id FROM listings WHERE status = 'active')
            ORDER BY updated_at DESC
            LIMIT 50000
        ");
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $url = $xml->addChild('url');
            $url->addChild('loc', 'https://yoursite.com/listing/' . $row['slug']);
            $url->addChild('lastmod', date('Y-m-d', strtotime($row['updated_at'])));
            $url->addChild('changefreq', 'monthly');
            $url->addChild('priority', '0.6');
        }
        
        // Сохранить в файл
        $xml->asXML('public/sitemap.xml');
        
        return 'Sitemap generated successfully';
    }
    
    /**
     * Генерировать Robots.txt
     */
    public function generateRobotsTxt() {
        $content = "User-agent: *\n";
        $content .= "Allow: /\n";
        $content .= "Disallow: /admin/\n";
        $content .= "Disallow: /api/\n";
        $content .= "Disallow: /private/\n";
        $content .= "Disallow: /user/\n";
        $content .= "\n";
        $content .= "Sitemap: https://yoursite.com/sitemap.xml\n";
        
        file_put_contents('public/robots.txt', $content);
        
        return 'Robots.txt generated successfully';
    }
}
?>
```

### SQL для SEO:

```sql
CREATE TABLE listing_seo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT UNIQUE NOT NULL,
    title VARCHAR(255),
    description TEXT,
    keywords TEXT,
    slug VARCHAR(255) UNIQUE NOT NULL,
    schema_markup TEXT,
    open_graph JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Использование в HTML:

```html
<?php
$seo = getSEOData($listingId);
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- SEO Meta Tags -->
    <title><?php echo htmlspecialchars($seo['title']); ?></title>
    <meta name="description" content="<?php echo htmlspecialchars($seo['description']); ?>">
    <meta name="keywords" content="<?php echo htmlspecialchars($seo['keywords']); ?>">
    
    <!-- Open Graph -->
    <?php foreach ($seo['open_graph'] as $property => $content): ?>
        <meta property="<?php echo $property; ?>" content="<?php echo htmlspecialchars($content); ?>">
    <?php endforeach; ?>
    
    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<?php echo htmlspecialchars($seo['title']); ?>">
    <meta name="twitter:description" content="<?php echo htmlspecialchars($seo['description']); ?>">
    
    <!-- Canonical URL -->
    <link rel="canonical" href="https://yoursite.com/listing/<?php echo $seo['slug']; ?>">
    
    <!-- Schema.org JSON-LD -->
    <script type="application/ld+json">
    <?php echo $seo['schema_markup']; ?>
    </script>
</head>
<body>
    <!-- Content -->
</body>
</html>
```

---

Продолжение следует во второй части с:
- Мастером подачи объявлений (Wizard)
- Логотипом и Фавиконом
- Структурой проекта
- Инструкцией по созданию

Продолжить?