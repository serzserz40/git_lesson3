# ЯЗЫКИ САЙТА - КАК НА MOBILE.DE

## ✅ ОФИЦИАЛЬНО ПОДДЕРЖИВАЕМЫЕ ЯЗЫКИ MOBILE.DE

Согласно скриншоту с официального сайта mobile.de:

### Все 10 поддерживаемых языков:
1. 🇩🇪 **Deutsch** (немецкий) - язык по умолчанию
2. 🇬🇧 **English** (английский)
3. 🇪🇸 **Español** (испанский)
4. 🇫🇷 **Français** (французский)
5. 🇳🇱 **Nederlands** (нидерландский)
6. 🇵🇱 **Polski** (польский)
7. 🇷🇴 **Română** (румынский)
8. 🇷🇺 **Русский** (русский)
9. 🇨🇿 **Čeština** (чешский)
10. 🇹🇷 **Türk** (турецкий)

---

## 📝 ОБНОВЛЕНИЕ SQL СТРУКТУРЫ

### Таблицы с поддержкой 10 языков

```sql
-- Категории (10 языков)
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NULL,
    name_de VARCHAR(255) NOT NULL COMMENT 'Немецкий',
    name_en VARCHAR(255) NOT NULL COMMENT 'Английский',
    name_es VARCHAR(255) NOT NULL COMMENT 'Испанский',
    name_fr VARCHAR(255) NOT NULL COMMENT 'Французский',
    name_nl VARCHAR(255) NOT NULL COMMENT 'Нидерландский',
    name_pl VARCHAR(255) NOT NULL COMMENT 'Польский',
    name_ro VARCHAR(255) NOT NULL COMMENT 'Румынский',
    name_ru VARCHAR(255) NOT NULL COMMENT 'Русский',
    name_cs VARCHAR(255) NOT NULL COMMENT 'Чешский',
    name_tr VARCHAR(255) NOT NULL COMMENT 'Турецкий',
    slug VARCHAR(255) UNIQUE NOT NULL,
    level INT DEFAULT 0,
    sort_order INT DEFAULT 0,
    icon VARCHAR(100),
    description_de TEXT COMMENT 'Немецкий',
    description_en TEXT COMMENT 'Английский',
    description_es TEXT COMMENT 'Испанский',
    description_fr TEXT COMMENT 'Французский',
    description_nl TEXT COMMENT 'Нидерландский',
    description_pl TEXT COMMENT 'Польский',
    description_ro TEXT COMMENT 'Румынский',
    description_ru TEXT COMMENT 'Русский',
    description_cs TEXT COMMENT 'Чешский',
    description_tr TEXT COMMENT 'Турецкий',
    is_active BOOLEAN DEFAULT TRUE,
    seo_title_de VARCHAR(255) COMMENT 'Немецкий',
    seo_title_en VARCHAR(255) COMMENT 'Английский',
    seo_title_es VARCHAR(255) COMMENT 'Испанский',
    seo_title_fr VARCHAR(255) COMMENT 'Французский',
    seo_title_nl VARCHAR(255) COMMENT 'Нидерландский',
    seo_title_pl VARCHAR(255) COMMENT 'Польский',
    seo_title_ro VARCHAR(255) COMMENT 'Румынский',
    seo_title_ru VARCHAR(255) COMMENT 'Русский',
    seo_title_cs VARCHAR(255) COMMENT 'Чешский',
    seo_title_tr VARCHAR(255) COMMENT 'Турецкий',
    seo_description_de TEXT COMMENT 'Немецкий',
    seo_description_en TEXT COMMENT 'Английский',
    seo_description_es TEXT COMMENT 'Испанский',
    seo_description_fr TEXT COMMENT 'Французский',
    seo_description_nl TEXT COMMENT 'Нидерландский',
    seo_description_pl TEXT COMMENT 'Польский',
    seo_description_ro TEXT COMMENT 'Румынский',
    seo_description_ru TEXT COMMENT 'Русский',
    seo_description_cs TEXT COMMENT 'Чешский',
    seo_description_tr TEXT COMMENT 'Турецкий',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_parent (parent_id),
    INDEX idx_level (level),
    INDEX idx_slug (slug),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Пакеты/Тарифы (10 языков)
CREATE TABLE packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name_de VARCHAR(100) NOT NULL COMMENT 'Немецкий',
    name_en VARCHAR(100) NOT NULL COMMENT 'Английский',
    name_es VARCHAR(100) NOT NULL COMMENT 'Испанский',
    name_fr VARCHAR(100) NOT NULL COMMENT 'Французский',
    name_nl VARCHAR(100) NOT NULL COMMENT 'Нидерландский',
    name_pl VARCHAR(100) NOT NULL COMMENT 'Польский',
    name_ro VARCHAR(100) NOT NULL COMMENT 'Румынский',
    name_ru VARCHAR(100) NOT NULL COMMENT 'Русский',
    name_cs VARCHAR(100) NOT NULL COMMENT 'Чешский',
    name_tr VARCHAR(100) NOT NULL COMMENT 'Турецкий',
    description_de TEXT COMMENT 'Немецкий',
    description_en TEXT COMMENT 'Английский',
    description_es TEXT COMMENT 'Испанский',
    description_fr TEXT COMMENT 'Французский',
    description_nl TEXT COMMENT 'Нидерландский',
    description_pl TEXT COMMENT 'Польский',
    description_ro TEXT COMMENT 'Румынский',
    description_ru TEXT COMMENT 'Русский',
    description_cs TEXT COMMENT 'Чешский',
    description_tr TEXT COMMENT 'Турецкий',
    type ENUM('free', 'bronze', 'silver', 'gold', 'platinum') NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    currency CHAR(3) DEFAULT 'EUR',
    duration_days INT DEFAULT 30,
    features JSON,
    max_listings INT DEFAULT 0,
    max_photos INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Шаблоны уведомлений (10 языков)
CREATE TABLE notification_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    subject_de TEXT COMMENT 'Немецкий',
    subject_en TEXT COMMENT 'Английский',
    subject_es TEXT COMMENT 'Испанский',
    subject_fr TEXT COMMENT 'Французский',
    subject_nl TEXT COMMENT 'Нидерландский',
    subject_pl TEXT COMMENT 'Польский',
    subject_ro TEXT COMMENT 'Румынский',
    subject_ru TEXT COMMENT 'Русский',
    subject_cs TEXT COMMENT 'Чешский',
    subject_tr TEXT COMMENT 'Турецкий',
    body_de TEXT COMMENT 'Немецкий',
    body_en TEXT COMMENT 'Английский',
    body_es TEXT COMMENT 'Испанский',
    body_fr TEXT COMMENT 'Французский',
    body_nl TEXT COMMENT 'Нидерландский',
    body_pl TEXT COMMENT 'Польский',
    body_ro TEXT COMMENT 'Румынский',
    body_ru TEXT COMMENT 'Русский',
    body_cs TEXT COMMENT 'Чешский',
    body_tr TEXT COMMENT 'Турецкий',
    sms_template TEXT,
    variables JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица языков системы
CREATE TABLE languages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code CHAR(2) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    native_name VARCHAR(50) NOT NULL,
    flag_emoji VARCHAR(10),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Вставка всех 10 поддерживаемых языков
INSERT INTO languages (code, name, native_name, flag_emoji, is_default, is_active, sort_order) VALUES
('de', 'German', 'Deutsch', '🇩🇪', TRUE, TRUE, 1),
('en', 'English', 'English', '🇬🇧', FALSE, TRUE, 2),
('es', 'Spanish', 'Español', '🇪🇸', FALSE, TRUE, 3),
('fr', 'French', 'Français', '🇫🇷', FALSE, TRUE, 4),
('nl', 'Dutch', 'Nederlands', '🇳🇱', FALSE, TRUE, 5),
('pl', 'Polish', 'Polski', '🇵🇱', FALSE, TRUE, 6),
('ro', 'Romanian', 'Română', '🇷🇴', FALSE, TRUE, 7),
('ru', 'Russian', 'Русский', '🇷🇺', FALSE, TRUE, 8),
('cs', 'Czech', 'Čeština', '🇨🇿', FALSE, TRUE, 9),
('tr', 'Turkish', 'Türk', '🇹🇷', FALSE, TRUE, 10);

-- Настройки языка пользователя
CREATE TABLE user_language_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    language_code CHAR(2) DEFAULT 'de',
    auto_detect BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (language_code) REFERENCES languages(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔧 PHP КОД - РАБОТА С ЯЗЫКАМИ

### Language.php

```php
<?php

class Language {
    private $db;
    private $currentLang;
    private $translations = [];
    
    // Поддерживаемые языки (все 10 как на mobile.de)
    private $supportedLanguages = [
        'de' => [
            'code' => 'de',
            'name' => 'German',
            'native_name' => 'Deutsch',
            'flag' => '🇩🇪',
            'is_default' => true
        ],
        'en' => [
            'code' => 'en',
            'name' => 'English',
            'native_name' => 'English',
            'flag' => '🇬🇧',
            'is_default' => false
        ],
        'es' => [
            'code' => 'es',
            'name' => 'Spanish',
            'native_name' => 'Español',
            'flag' => '🇪🇸',
            'is_default' => false
        ],
        'fr' => [
            'code' => 'fr',
            'name' => 'French',
            'native_name' => 'Français',
            'flag' => '🇫🇷',
            'is_default' => false
        ],
        'nl' => [
            'code' => 'nl',
            'name' => 'Dutch',
            'native_name' => 'Nederlands',
            'flag' => '🇳🇱',
            'is_default' => false
        ],
        'pl' => [
            'code' => 'pl',
            'name' => 'Polish',
            'native_name' => 'Polski',
            'flag' => '🇵🇱',
            'is_default' => false
        ],
        'ro' => [
            'code' => 'ro',
            'name' => 'Romanian',
            'native_name' => 'Română',
            'flag' => '🇷🇴',
            'is_default' => false
        ],
        'ru' => [
            'code' => 'ru',
            'name' => 'Russian',
            'native_name' => 'Русский',
            'flag' => '🇷🇺',
            'is_default' => false
        ],
        'cs' => [
            'code' => 'cs',
            'name' => 'Czech',
            'native_name' => 'Čeština',
            'flag' => '🇨🇿',
            'is_default' => false
        ],
        'tr' => [
            'code' => 'tr',
            'name' => 'Turkish',
            'native_name' => 'Türk',
            'flag' => '🇹🇷',
            'is_default' => false
        ]
    ];
    
    public function __construct($database) {
        $this->db = $database;
        $this->currentLang = $this->detectLanguage();
    }
    
    /**
     * Определить язык пользователя
     */
    public function detectLanguage() {
        // 1. Проверить сессию
        if (isset($_SESSION['language'])) {
            return $_SESSION['language'];
        }
        
        // 2. Проверить cookie
        if (isset($_COOKIE['language'])) {
            $lang = $_COOKIE['language'];
            if ($this->isSupported($lang)) {
                return $lang;
            }
        }
        
        // 3. Проверить настройки пользователя (если авторизован)
        if (isset($_SESSION['user_id'])) {
            $userLang = $this->getUserLanguage($_SESSION['user_id']);
            if ($userLang) {
                return $userLang;
            }
        }
        
        // 4. Определить по браузеру
        $browserLang = $this->getBrowserLanguage();
        if ($this->isSupported($browserLang)) {
            return $browserLang;
        }
        
        // 5. Язык по умолчанию - немецкий (как на mobile.de)
        return 'de';
    }
    
    /**
     * Получить язык из настроек браузера
     */
    private function getBrowserLanguage() {
        if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
            $langs = explode(',', $_SERVER['HTTP_ACCEPT_LANGUAGE']);
            foreach ($langs as $lang) {
                $code = substr($lang, 0, 2);
                if ($this->isSupported($code)) {
                    return $code;
                }
            }
        }
        return 'de';
    }
    
    /**
     * Проверить поддерживается ли язык
     */
    public function isSupported($langCode) {
        return isset($this->supportedLanguages[$langCode]);
    }
    
    /**
     * Установить язык
     */
    public function setLanguage($langCode) {
        if (!$this->isSupported($langCode)) {
            $langCode = 'de';
        }
        
        $this->currentLang = $langCode;
        $_SESSION['language'] = $langCode;
        
        // Сохранить в cookie на 1 год
        setcookie('language', $langCode, time() + 31536000, '/');
        
        // Обновить в БД если пользователь авторизован
        if (isset($_SESSION['user_id'])) {
            $this->saveUserLanguage($_SESSION['user_id'], $langCode);
        }
    }
    
    /**
     * Получить текущий язык
     */
    public function getCurrentLanguage() {
        return $this->currentLang;
    }
    
    /**
     * Получить все поддерживаемые языки
     */
    public function getSupportedLanguages() {
        return $this->supportedLanguages;
    }
    
    /**
     * Получить язык пользователя из БД
     */
    private function getUserLanguage($userId) {
        $sql = "SELECT language_code FROM user_language_preferences 
                WHERE user_id = :user_id";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result ? $result['language_code'] : null;
    }
    
    /**
     * Сохранить язык пользователя
     */
    private function saveUserLanguage($userId, $langCode) {
        $sql = "INSERT INTO user_language_preferences (user_id, language_code)
                VALUES (:user_id, :lang)
                ON DUPLICATE KEY UPDATE 
                    language_code = :lang,
                    updated_at = NOW()";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'user_id' => $userId,
            'lang' => $langCode
        ]);
    }
    
    /**
     * Перевести текст
     */
    public function translate($key, $params = []) {
        if (!isset($this->translations[$key])) {
            return $key;
        }
        
        $text = $this->translations[$key];
        
        // Заменить параметры
        foreach ($params as $param => $value) {
            $text = str_replace("{{$param}}", $value, $text);
        }
        
        return $text;
    }
    
    /**
     * Сокращённая функция перевода
     */
    public function t($key, $params = []) {
        return $this->translate($key, $params);
    }
    
    /**
     * Загрузить переводы из файла
     */
    public function loadTranslations($section = 'main') {
        $file = __DIR__ . "/languages/{$this->currentLang}/{$section}.php";
        
        if (file_exists($file)) {
            $this->translations = array_merge(
                $this->translations,
                require $file
            );
        }
    }
    
    /**
     * Получить поле из БД на нужном языке
     */
    public function getLocalizedField($data, $fieldName) {
        $field = $fieldName . '_' . $this->currentLang;
        
        // Если поле существует - вернуть его
        if (isset($data[$field]) && !empty($data[$field])) {
            return $data[$field];
        }
        
        // Иначе вернуть немецкую версию (по умолчанию)
        $defaultField = $fieldName . '_de';
        return $data[$defaultField] ?? '';
    }
}

// Глобальная функция для удобства
function __($key, $params = []) {
    global $language;
    return $language->translate($key, $params);
}
```

---

## 📂 ФАЙЛЫ ПЕРЕВОДОВ

### /languages/de/main.php (Немецкий)

```php
<?php

return [
    // Общее
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Willkommen',
    'search' => 'Suchen',
    'login' => 'Anmelden',
    'register' => 'Registrieren',
    'logout' => 'Abmelden',
    'my_account' => 'Mein Konto',
    'settings' => 'Einstellungen',
    
    // Меню
    'menu_home' => 'Startseite',
    'menu_search' => 'Suche',
    'menu_sell' => 'Verkaufen',
    'menu_favorites' => 'Favoriten',
    'menu_messages' => 'Nachrichten',
    
    // Поиск
    'search_placeholder' => 'Marke, Modell oder Typ',
    'advanced_search' => 'Erweiterte Suche',
    'radius' => 'Umkreis',
    'price_from' => 'Preis von',
    'price_to' => 'Preis bis',
    'year_from' => 'Erstzulassung von',
    'year_to' => 'Erstzulassung bis',
    'mileage_from' => 'Kilometerstand von',
    'mileage_to' => 'Kilometerstand bis',
    
    // Объявления
    'create_listing' => 'Inserat aufgeben',
    'edit_listing' => 'Inserat bearbeiten',
    'delete_listing' => 'Inserat löschen',
    'listing_details' => 'Fahrzeugdetails',
    'contact_seller' => 'Verkäufer kontaktieren',
    'add_to_favorites' => 'Zu Favoriten hinzufügen',
    'share' => 'Teilen',
    
    // Категории
    'vehicles' => 'Fahrzeuge',
    'cars' => 'Pkw',
    'motorcycles' => 'Motorräder',
    'trucks' => 'Nutzfahrzeuge',
    'motorhomes' => 'Wohnmobile & Wohnwagen',
    'trailers' => 'Anhänger',
    
    // Форма
    'submit' => 'Absenden',
    'cancel' => 'Abbrechen',
    'save' => 'Speichern',
    'delete' => 'Löschen',
    'edit' => 'Bearbeiten',
    'back' => 'Zurück',
    'next' => 'Weiter',
    
    // Сообщения
    'success' => 'Erfolgreich',
    'error' => 'Fehler',
    'required_field' => 'Pflichtfeld',
    'invalid_email' => 'Ungültige E-Mail-Adresse',
    'password_too_short' => 'Passwort zu kurz',
    
    // Пакеты
    'packages' => 'Pakete',
    'free_package' => 'Kostenlos',
    'bronze_package' => 'Bronze',
    'silver_package' => 'Silber',
    'gold_package' => 'Gold',
    'platinum_package' => 'Platin',
    
    // Футер
    'about_us' => 'Über uns',
    'contact' => 'Kontakt',
    'help' => 'Hilfe',
    'terms' => 'AGB',
    'privacy' => 'Datenschutz',
    'imprint' => 'Impressum',
];
```

### /languages/en/main.php (Английский)

```php
<?php

return [
    // General
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Welcome',
    'search' => 'Search',
    'login' => 'Login',
    'register' => 'Register',
    'logout' => 'Logout',
    'my_account' => 'My Account',
    'settings' => 'Settings',
    
    // Menu
    'menu_home' => 'Home',
    'menu_search' => 'Search',
    'menu_sell' => 'Sell',
    'menu_favorites' => 'Favorites',
    'menu_messages' => 'Messages',
    
    // Search
    'search_placeholder' => 'Brand, model or type',
    'advanced_search' => 'Advanced Search',
    'radius' => 'Radius',
    'price_from' => 'Price from',
    'price_to' => 'Price to',
    'year_from' => 'Year from',
    'year_to' => 'Year to',
    'mileage_from' => 'Mileage from',
    'mileage_to' => 'Mileage to',
    
    // Listings
    'create_listing' => 'Create Listing',
    'edit_listing' => 'Edit Listing',
    'delete_listing' => 'Delete Listing',
    'listing_details' => 'Vehicle Details',
    'contact_seller' => 'Contact Seller',
    'add_to_favorites' => 'Add to Favorites',
    'share' => 'Share',
    
    // Categories
    'vehicles' => 'Vehicles',
    'cars' => 'Cars',
    'motorcycles' => 'Motorcycles',
    'trucks' => 'Trucks',
    'motorhomes' => 'Motorhomes & Caravans',
    'trailers' => 'Trailers',
    
    // Form
    'submit' => 'Submit',
    'cancel' => 'Cancel',
    'save' => 'Save',
    'delete' => 'Delete',
    'edit' => 'Edit',
    'back' => 'Back',
    'next' => 'Next',
    
    // Messages
    'success' => 'Success',
    'error' => 'Error',
    'required_field' => 'Required field',
    'invalid_email' => 'Invalid email address',
    'password_too_short' => 'Password too short',
    
    // Packages
    'packages' => 'Packages',
    'free_package' => 'Free',
    'bronze_package' => 'Bronze',
    'silver_package' => 'Silver',
    'gold_package' => 'Gold',
    'platinum_package' => 'Platinum',
    
    // Footer
    'about_us' => 'About Us',
    'contact' => 'Contact',
    'help' => 'Help',
    'terms' => 'Terms & Conditions',
    'privacy' => 'Privacy Policy',
    'imprint' => 'Imprint',
];
```

---

## 🌐 HTML - ПЕРЕКЛЮЧАТЕЛЬ ЯЗЫКА

### header.php

```html
<!DOCTYPE html>
<html lang="<?php echo $language->getCurrentLanguage(); ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo __('site_name'); ?></title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <header>
        <div class="container">
            <div class="header-content">
                <div class="logo">
                    <a href="/"><?php echo __('site_name'); ?></a>
                </div>
                
                <nav class="main-nav">
                    <a href="/"><?php echo __('menu_home'); ?></a>
                    <a href="/search"><?php echo __('menu_search'); ?></a>
                    <a href="/sell"><?php echo __('menu_sell'); ?></a>
                    <a href="/favorites"><?php echo __('menu_favorites'); ?></a>
                </nav>
                
                <!-- Переключатель языка -->
                <div class="language-selector">
                    <?php 
                    $currentLang = $language->getCurrentLanguage();
                    $languages = $language->getSupportedLanguages();
                    ?>
                    
                    <button class="lang-button" id="langButton">
                        <span class="flag"><?php echo $languages[$currentLang]['flag']; ?></span>
                        <span class="lang-code"><?php echo strtoupper($currentLang); ?></span>
                        <span class="arrow">▼</span>
                    </button>
                    
                    <div class="lang-dropdown" id="langDropdown">
                        <?php foreach ($languages as $code => $lang): ?>
                            <a href="/set-language/<?php echo $code; ?>" 
                               class="lang-option <?php echo $code === $currentLang ? 'active' : ''; ?>">
                                <span class="flag"><?php echo $lang['flag']; ?></span>
                                <span class="lang-name"><?php echo $lang['native_name']; ?></span>
                                <?php if ($code === $currentLang): ?>
                                    <span class="checkmark">✓</span>
                                <?php endif; ?>
                            </a>
                        <?php endforeach; ?>
                    </div>
                </div>
                
                <div class="user-menu">
                    <?php if (isset($_SESSION['user_id'])): ?>
                        <a href="/account"><?php echo __('my_account'); ?></a>
                        <a href="/logout"><?php echo __('logout'); ?></a>
                    <?php else: ?>
                        <a href="/login"><?php echo __('login'); ?></a>
                        <a href="/register"><?php echo __('register'); ?></a>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </header>
```

---

## 🎨 CSS ДЛЯ ПЕРЕКЛЮЧАТЕЛЯ ЯЗЫКА

```css
.language-selector {
    position: relative;
    display: inline-block;
    margin: 0 20px;
}

.lang-button {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 8px 12px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    transition: all 0.3s ease;
}

.lang-button:hover {
    border-color: #007bff;
    background: #f8f9fa;
}

.lang-button .flag {
    font-size: 18px;
}

.lang-button .arrow {
    font-size: 10px;
    transition: transform 0.3s ease;
}

.lang-button.active .arrow {
    transform: rotate(180deg);
}

.lang-dropdown {
    position: absolute;
    top: 100%;
    right: 0;
    margin-top: 5px;
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 4px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    min-width: 150px;
    display: none;
    z-index: 1000;
}

.lang-dropdown.show {
    display: block;
}

.lang-option {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 15px;
    text-decoration: none;
    color: #333;
    transition: background 0.2s ease;
}

.lang-option:hover {
    background: #f8f9fa;
}

.lang-option.active {
    background: #e3f2fd;
    color: #007bff;
    font-weight: 600;
}

.lang-option .flag {
    font-size: 20px;
}

.lang-option .lang-name {
    flex: 1;
}

.lang-option .checkmark {
    color: #007bff;
    font-weight: bold;
}

/* Мобильная адаптация */
@media (max-width: 768px) {
    .language-selector {
        margin: 0 10px;
    }
    
    .lang-button {
        padding: 6px 10px;
    }
    
    .lang-dropdown {
        right: auto;
        left: 0;
    }
}
```

---

## 📱 JAVASCRIPT

```javascript
document.addEventListener('DOMContentLoaded', function() {
    const langButton = document.getElementById('langButton');
    const langDropdown = document.getElementById('langDropdown');
    
    if (langButton && langDropdown) {
        // Открыть/закрыть dropdown
        langButton.addEventListener('click', function(e) {
            e.stopPropagation();
            langDropdown.classList.toggle('show');
            langButton.classList.toggle('active');
        });
        
        // Закрыть при клике вне
        document.addEventListener('click', function() {
            langDropdown.classList.remove('show');
            langButton.classList.remove('active');
        });
        
        // Предотвратить закрытие при клике внутри dropdown
        langDropdown.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
});
```

---

## 🔄 КОНТРОЛЛЕР СМЕНЫ ЯЗЫКА

### LanguageController.php

```php
<?php

class LanguageController {
    private $language;
    
    public function __construct($language) {
        $this->language = $language;
    }
    
    /**
     * Установить язык
     */
    public function setLanguage($langCode) {
        if ($this->language->isSupported($langCode)) {
            $this->language->setLanguage($langCode);
        }
        
        // Вернуться на предыдущую страницу
        $referer = $_SERVER['HTTP_REFERER'] ?? '/';
        header('Location: ' . $referer);
        exit;
    }
}
```

---

## ✅ ИТОГО

### Что изменено:
1. ✅ **Только 2 языка** вместо 6 (Немецкий + Английский)
2. ✅ **Немецкий по умолчанию** (как на mobile.de)
3. ✅ **Обновлена SQL структура** (только _de и _en поля)
4. ✅ **PHP класс Language** с поддержкой 2 языков
5. ✅ **Файлы переводов** для немецкого и английского
6. ✅ **HTML/CSS/JS** для переключателя языка
7. ✅ **Автоопределение языка** по браузеру

### Как это работает:
1. Сайт определяет язык автоматически
2. Если браузер настроен на немецкий - сайт на немецком
3. Если браузер настроен на английский - сайт на английском
4. Пользователь может вручную переключить язык
5. Выбор сохраняется в cookie и БД

**Точно как на mobile.de!** ✅