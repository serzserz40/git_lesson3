# ПОЛНЫЙ ФУНКЦИОНАЛ: ФУТЕР, БЕЗОПАСНОСТЬ, РЕГИСТРАЦИЯ, МОДЕРАЦИЯ, SEO

## 📋 СОДЕРЖАНИЕ

1. **Футер с ссылками**
2. **Cookie Banner на 10 языках**
3. **GDPR Согласие на обработку данных**
4. **Пользовательское соглашение (Terms) на 10 языках**
5. **Регистрация (Физ лица + Юр лица)**
6. **Восстановление пароля через email**
7. **Защита от хакеров (SQL Injection, XSS, CSRF)**
8. **Защита от ботов (reCAPTCHA)**
9. **Автоматическая модерация**
10. **Автоматическое SEO**
11. **Мастер подачи объявлений**
12. **Логотип и Фавикон**
13. **Структура проекта (как всё организовать)**

---

## 1️⃣ ФУТЕР С ССЫЛКАМИ

### footer.php (HTML + PHP)

```php
<footer class="footer">
    <div class="container">
        <!-- Верхняя часть футера -->
        <div class="footer-grid">
            <!-- О компании -->
            <div class="footer-column">
                <h4 class="footer-title"><?php echo __('about_company'); ?></h4>
                <ul class="footer-links">
                    <li><a href="/<?php echo $lang; ?>/about"><?php echo __('about_us'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/press"><?php echo __('press'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/careers"><?php echo __('careers'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/contact"><?php echo __('contact'); ?></a></li>
                </ul>
            </div>
            
            <!-- Помощь -->
            <div class="footer-column">
                <h4 class="footer-title"><?php echo __('help'); ?></h4>
                <ul class="footer-links">
                    <li><a href="/<?php echo $lang; ?>/faq"><?php echo __('faq'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/guide"><?php echo __('buying_guide'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/selling-guide"><?php echo __('selling_guide'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/safety"><?php echo __('safety_tips'); ?></a></li>
                </ul>
            </div>
            
            <!-- Для дилеров -->
            <div class="footer-column">
                <h4 class="footer-title"><?php echo __('for_dealers'); ?></h4>
                <ul class="footer-links">
                    <li><a href="/<?php echo $lang; ?>/dealer-registration"><?php echo __('become_dealer'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/packages"><?php echo __('packages'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/advertising"><?php echo __('advertising'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/api"><?php echo __('api_integration'); ?></a></li>
                </ul>
            </div>
            
            <!-- Правовая информация -->
            <div class="footer-column">
                <h4 class="footer-title"><?php echo __('legal'); ?></h4>
                <ul class="footer-links">
                    <li><a href="/<?php echo $lang; ?>/terms"><?php echo __('terms_conditions'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/privacy"><?php echo __('privacy_policy'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/imprint"><?php echo __('imprint'); ?></a></li>
                    <li><a href="/<?php echo $lang; ?>/cookie-policy"><?php echo __('cookie_policy'); ?></a></li>
                </ul>
            </div>
        </div>
        
        <!-- Социальные сети -->
        <div class="footer-social">
            <a href="https://facebook.com/yourpage" class="social-link" target="_blank" rel="noopener">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
            </a>
            <a href="https://instagram.com/yourpage" class="social-link" target="_blank" rel="noopener">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                </svg>
            </a>
            <a href="https://twitter.com/yourpage" class="social-link" target="_blank" rel="noopener">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                </svg>
            </a>
            <a href="https://youtube.com/yourchannel" class="social-link" target="_blank" rel="noopener">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                </svg>
            </a>
        </div>
        
        <!-- Нижняя часть -->
        <div class="footer-bottom">
            <div class="footer-bottom-content">
                <div class="footer-logo">
                    <img src="/assets/images/logo-white.svg" alt="AutoMarket" height="30">
                </div>
                <div class="footer-copyright">
                    © <?php echo date('Y'); ?> AutoMarket. <?php echo __('all_rights_reserved'); ?>
                </div>
                <div class="footer-language">
                    <!-- Переключатель языка -->
                    <button class="language-selector-footer" id="langSelectorFooter">
                        <?php echo $supportedLanguages[$currentLang]['flag']; ?>
                        <?php echo strtoupper($currentLang); ?> ▼
                    </button>
                </div>
            </div>
        </div>
    </div>
</footer>

<!-- CSS для футера -->
<style>
.footer {
    background: #1f2937;
    color: #f9fafb;
    padding: 4rem 0 2rem;
    margin-top: 6rem;
}

.footer-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 3rem;
    margin-bottom: 3rem;
}

.footer-column {}

.footer-title {
    font-size: 1.125rem;
    font-weight: 600;
    margin-bottom: 1.25rem;
    color: #ffffff;
}

.footer-links {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}

.footer-links a {
    color: #d1d5db;
    text-decoration: none;
    transition: color 0.3s ease;
    font-size: 0.9375rem;
}

.footer-links a:hover {
    color: #ff6500;
}

.footer-social {
    display: flex;
    justify-content: center;
    gap: 1.5rem;
    padding: 2rem 0;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.social-link {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    color: #f9fafb;
    transition: all 0.3s ease;
}

.social-link:hover {
    background: #ff6500;
    transform: translateY(-3px);
}

.footer-bottom {
    padding-top: 2rem;
}

.footer-bottom-content {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
}

.footer-copyright {
    font-size: 0.875rem;
    color: #9ca3af;
}

@media (max-width: 768px) {
    .footer-bottom-content {
        flex-direction: column;
        text-align: center;
    }
}
</style>
```

---

## 2️⃣ COOKIE BANNER НА 10 ЯЗЫКАХ

### cookie-banner.php

```php
<!-- Cookie Banner -->
<div id="cookieBanner" class="cookie-banner" style="display: none;">
    <div class="cookie-content">
        <div class="cookie-icon">🍪</div>
        <div class="cookie-text">
            <h3 class="cookie-title"><?php echo __('cookie_title'); ?></h3>
            <p class="cookie-description"><?php echo __('cookie_description'); ?></p>
        </div>
        <div class="cookie-buttons">
            <button onclick="acceptCookies()" class="btn btn-primary btn-sm">
                <?php echo __('accept_all'); ?>
            </button>
            <button onclick="showCookieSettings()" class="btn btn-outline btn-sm">
                <?php echo __('cookie_settings'); ?>
            </button>
            <button onclick="declineCookies()" class="btn btn-ghost btn-sm">
                <?php echo __('decline'); ?>
            </button>
        </div>
    </div>
</div>

<!-- Cookie Settings Modal -->
<div id="cookieSettingsModal" class="modal-overlay" style="display: none;">
    <div class="modal cookie-settings-modal">
        <div class="modal-header">
            <h2 class="modal-title"><?php echo __('cookie_settings'); ?></h2>
            <button onclick="closeCookieSettings()" class="modal-close">×</button>
        </div>
        <div class="modal-body">
            <div class="cookie-category">
                <div class="cookie-category-header">
                    <div>
                        <h4><?php echo __('necessary_cookies'); ?></h4>
                        <p class="text-muted"><?php echo __('necessary_cookies_desc'); ?></p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" checked disabled>
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>
            
            <div class="cookie-category">
                <div class="cookie-category-header">
                    <div>
                        <h4><?php echo __('functional_cookies'); ?></h4>
                        <p class="text-muted"><?php echo __('functional_cookies_desc'); ?></p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" id="functionalCookies">
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>
            
            <div class="cookie-category">
                <div class="cookie-category-header">
                    <div>
                        <h4><?php echo __('analytics_cookies'); ?></h4>
                        <p class="text-muted"><?php echo __('analytics_cookies_desc'); ?></p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" id="analyticsCookies">
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>
            
            <div class="cookie-category">
                <div class="cookie-category-header">
                    <div>
                        <h4><?php echo __('marketing_cookies'); ?></h4>
                        <p class="text-muted"><?php echo __('marketing_cookies_desc'); ?></p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" id="marketingCookies">
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button onclick="saveCookieSettings()" class="btn btn-primary">
                <?php echo __('save_settings'); ?>
            </button>
        </div>
    </div>
</div>

<!-- CSS -->
<style>
.cookie-banner {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: #ffffff;
    box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.1);
    z-index: 10000;
    animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
    from {
        transform: translateY(100%);
    }
    to {
        transform: translateY(0);
    }
}

.cookie-content {
    max-width: 1280px;
    margin: 0 auto;
    padding: 2rem;
    display: flex;
    align-items: center;
    gap: 2rem;
    flex-wrap: wrap;
}

.cookie-icon {
    font-size: 3rem;
}

.cookie-text {
    flex: 1;
    min-width: 250px;
}

.cookie-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
}

.cookie-description {
    font-size: 0.9375rem;
    color: #6b7280;
    margin: 0;
}

.cookie-buttons {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
}

.cookie-category {
    padding: 1.5rem 0;
    border-bottom: 1px solid #e5e7eb;
}

.cookie-category:last-child {
    border-bottom: none;
}

.cookie-category-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 2rem;
}

.cookie-category h4 {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
}

/* Toggle Switch */
.toggle-switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 24px;
}

.toggle-switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

.toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #cbd5e0;
    transition: 0.3s;
    border-radius: 24px;
}

.toggle-slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
}

.toggle-switch input:checked + .toggle-slider {
    background-color: #ff6500;
}

.toggle-switch input:checked + .toggle-slider:before {
    transform: translateX(26px);
}

.toggle-switch input:disabled + .toggle-slider {
    opacity: 0.5;
    cursor: not-allowed;
}

@media (max-width: 768px) {
    .cookie-content {
        flex-direction: column;
        text-align: center;
    }
    
    .cookie-buttons {
        flex-direction: column;
        width: 100%;
    }
    
    .cookie-buttons .btn {
        width: 100%;
    }
}
</style>

<!-- JavaScript -->
<script>
// Показать cookie banner если не принят
document.addEventListener('DOMContentLoaded', function() {
    if (!getCookie('cookies_accepted')) {
        setTimeout(() => {
            document.getElementById('cookieBanner').style.display = 'block';
        }, 1000);
    }
});

function acceptCookies() {
    setCookie('cookies_accepted', 'all', 365);
    setCookie('cookies_functional', 'true', 365);
    setCookie('cookies_analytics', 'true', 365);
    setCookie('cookies_marketing', 'true', 365);
    document.getElementById('cookieBanner').style.display = 'none';
    
    // Загрузить Google Analytics
    loadGoogleAnalytics();
}

function declineCookies() {
    setCookie('cookies_accepted', 'necessary', 365);
    setCookie('cookies_functional', 'false', 365);
    setCookie('cookies_analytics', 'false', 365);
    setCookie('cookies_marketing', 'false', 365);
    document.getElementById('cookieBanner').style.display = 'none';
}

function showCookieSettings() {
    document.getElementById('cookieSettingsModal').style.display = 'flex';
}

function closeCookieSettings() {
    document.getElementById('cookieSettingsModal').style.display = 'none';
}

function saveCookieSettings() {
    const functional = document.getElementById('functionalCookies').checked;
    const analytics = document.getElementById('analyticsCookies').checked;
    const marketing = document.getElementById('marketingCookies').checked;
    
    setCookie('cookies_accepted', 'custom', 365);
    setCookie('cookies_functional', functional, 365);
    setCookie('cookies_analytics', analytics, 365);
    setCookie('cookies_marketing', marketing, 365);
    
    if (analytics) {
        loadGoogleAnalytics();
    }
    
    document.getElementById('cookieBanner').style.display = 'none';
    document.getElementById('cookieSettingsModal').style.display = 'none';
}

function setCookie(name, value, days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    const expires = "expires=" + date.toUTCString();
    document.cookie = name + "=" + value + ";" + expires + ";path=/;SameSite=Strict";
}

function getCookie(name) {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for(let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

function loadGoogleAnalytics() {
    // Google Analytics код
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-XXXXXXXXXX'); // Ваш GA ID
}
</script>
```

### Переводы для cookies (добавить в файлы переводов):

```php
// Немецкий (de)
'cookie_title' => 'Wir verwenden Cookies',
'cookie_description' => 'Wir verwenden Cookies, um Ihnen die bestmögliche Erfahrung auf unserer Website zu bieten.',
'accept_all' => 'Alle akzeptieren',
'cookie_settings' => 'Cookie-Einstellungen',
'decline' => 'Ablehnen',
'necessary_cookies' => 'Notwendige Cookies',
'necessary_cookies_desc' => 'Diese Cookies sind für den Betrieb der Website erforderlich.',
'functional_cookies' => 'Funktionale Cookies',
'functional_cookies_desc' => 'Diese Cookies ermöglichen erweiterte Funktionen.',
'analytics_cookies' => 'Analyse-Cookies',
'analytics_cookies_desc' => 'Diese Cookies helfen uns, die Website zu verbessern.',
'marketing_cookies' => 'Marketing-Cookies',
'marketing_cookies_desc' => 'Diese Cookies werden für personalisierte Werbung verwendet.',
'save_settings' => 'Einstellungen speichern',

// Английский (en)
'cookie_title' => 'We use cookies',
'cookie_description' => 'We use cookies to provide you with the best possible experience on our website.',
'accept_all' => 'Accept all',
'cookie_settings' => 'Cookie settings',
'decline' => 'Decline',
'necessary_cookies' => 'Necessary cookies',
'necessary_cookies_desc' => 'These cookies are required for the website to function.',
'functional_cookies' => 'Functional cookies',
'functional_cookies_desc' => 'These cookies enable advanced features.',
'analytics_cookies' => 'Analytics cookies',
'analytics_cookies_desc' => 'These cookies help us improve the website.',
'marketing_cookies' => 'Marketing cookies',
'marketing_cookies_desc' => 'These cookies are used for personalized advertising.',
'save_settings' => 'Save settings',

// И так далее для всех 10 языков...
```

---

## 3️⃣ GDPR СОГЛАСИЕ НА ОБРАБОТКУ ДАННЫХ

### gdpr-consent.php

```php
<div class="gdpr-consent-section">
    <label class="checkbox-label gdpr-checkbox">
        <input type="checkbox" name="gdpr_consent" id="gdprConsent" required class="checkbox-input">
        <span>
            <?php echo __('i_agree_to'); ?>
            <a href="/<?php echo $lang; ?>/privacy" target="_blank"><?php echo __('privacy_policy'); ?></a>
            <?php echo __('and'); ?>
            <a href="/<?php echo $lang; ?>/terms" target="_blank"><?php echo __('terms_conditions'); ?></a>
        </span>
    </label>
    
    <label class="checkbox-label">
        <input type="checkbox" name="marketing_consent" id="marketingConsent" class="checkbox-input">
        <span><?php echo __('marketing_consent_text'); ?></span>
    </label>
</div>

<style>
.gdpr-consent-section {
    margin: 1.5rem 0;
    padding: 1.5rem;
    background: #f9fafb;
    border-radius: 0.5rem;
    border: 1px solid #e5e7eb;
}

.gdpr-checkbox {
    padding: 1rem;
    background: white;
    border-radius: 0.375rem;
    margin-bottom: 1rem;
}

.gdpr-checkbox a {
    color: #ff6500;
    text-decoration: underline;
    font-weight: 500;
}

.gdpr-checkbox a:hover {
    color: #ea580c;
}
</style>
```

### SQL для хранения согласий:

```sql
CREATE TABLE user_consents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    consent_type ENUM('gdpr', 'marketing', 'cookies') NOT NULL,
    consent_given BOOLEAN DEFAULT FALSE,
    consent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_consent (user_id, consent_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 4️⃣ ПОЛЬЗОВАТЕЛЬСКОЕ СОГЛАШЕНИЕ НА 10 ЯЗЫКАХ

### terms.php (Генератор для всех языков)

```php
<?php
// Получить текст соглашения на нужном языке
$termsContent = getTermsContent($currentLang);
?>

<!DOCTYPE html>
<html lang="<?php echo $currentLang; ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo __('terms_conditions'); ?> - AutoMarket</title>
</head>
<body>
    <div class="container terms-container">
        <h1><?php echo __('terms_conditions'); ?></h1>
        <p class="last-updated"><?php echo __('last_updated'); ?>: <?php echo date('d.m.Y'); ?></p>
        
        <div class="terms-content">
            <?php echo $termsContent; ?>
        </div>
    </div>
</body>
</html>

<?php
function getTermsContent($lang) {
    $terms = [
        'de' => '
            <h2>1. Geltungsbereich</h2>
            <p>Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für alle Verträge zwischen AutoMarket und seinen Nutzern...</p>
            
            <h2>2. Vertragsschluss</h2>
            <p>Der Vertrag kommt durch die Registrierung auf unserer Plattform zustande...</p>
            
            <h2>3. Leistungsumfang</h2>
            <p>AutoMarket stellt eine Online-Plattform zum Kauf und Verkauf von Fahrzeugen bereit...</p>
            
            <h2>4. Nutzerkonten</h2>
            <p>Zur Nutzung bestimmter Funktionen ist eine Registrierung erforderlich...</p>
            
            <h2>5. Pflichten der Nutzer</h2>
            <p>Nutzer verpflichten sich, wahre und vollständige Angaben zu machen...</p>
            
            <h2>6. Zahlungsbedingungen</h2>
            <p>Die Preise für Premium-Funktionen sind auf der Website angegeben...</p>
            
            <h2>7. Haftung</h2>
            <p>AutoMarket haftet nur für vorsätzliche oder grob fahrlässige Pflichtverletzungen...</p>
            
            <h2>8. Datenschutz</h2>
            <p>Der Schutz Ihrer persönlichen Daten ist uns wichtig. Details finden Sie in unserer Datenschutzerklärung...</p>
            
            <h2>9. Änderungen der AGB</h2>
            <p>Wir behalten uns das Recht vor, diese AGB jederzeit zu ändern...</p>
            
            <h2>10. Schlussbestimmungen</h2>
            <p>Es gilt das Recht der Bundesrepublik Deutschland...</p>
        ',
        
        'en' => '
            <h2>1. Scope of Application</h2>
            <p>These General Terms and Conditions (GTC) apply to all contracts between AutoMarket and its users...</p>
            
            <h2>2. Conclusion of Contract</h2>
            <p>The contract is concluded by registration on our platform...</p>
            
            <h2>3. Scope of Services</h2>
            <p>AutoMarket provides an online platform for buying and selling vehicles...</p>
            
            <h2>4. User Accounts</h2>
            <p>Registration is required to use certain functions...</p>
            
            <h2>5. User Obligations</h2>
            <p>Users undertake to provide true and complete information...</p>
            
            <h2>6. Payment Terms</h2>
            <p>Prices for premium features are stated on the website...</p>
            
            <h2>7. Liability</h2>
            <p>AutoMarket is only liable for intentional or grossly negligent breaches of duty...</p>
            
            <h2>8. Privacy</h2>
            <p>Protecting your personal data is important to us. Details can be found in our privacy policy...</p>
            
            <h2>9. Changes to GTC</h2>
            <p>We reserve the right to change these GTC at any time...</p>
            
            <h2>10. Final Provisions</h2>
            <p>The law of the Federal Republic of Germany applies...</p>
        ',
        
        'ru' => '
            <h2>1. Область применения</h2>
            <p>Настоящие Общие условия использования применяются ко всем договорам между AutoMarket и его пользователями...</p>
            
            <h2>2. Заключение договора</h2>
            <p>Договор заключается путем регистрации на нашей платформе...</p>
            
            <h2>3. Объем услуг</h2>
            <p>AutoMarket предоставляет онлайн-платформу для покупки и продажи транспортных средств...</p>
            
            <h2>4. Учетные записи пользователей</h2>
            <p>Для использования определенных функций требуется регистрация...</p>
            
            <h2>5. Обязанности пользователей</h2>
            <p>Пользователи обязуются предоставлять правдивую и полную информацию...</p>
            
            <h2>6. Условия оплаты</h2>
            <p>Цены на премиум-функции указаны на сайте...</p>
            
            <h2>7. Ответственность</h2>
            <p>AutoMarket несет ответственность только за умышленные или грубо небрежные нарушения обязательств...</p>
            
            <h2>8. Конфиденциальность</h2>
            <p>Защита ваших персональных данных важна для нас. Подробности см. в нашей политике конфиденциальности...</p>
            
            <h2>9. Изменения условий</h2>
            <p>Мы оставляем за собой право изменять настоящие Условия в любое время...</p>
            
            <h2>10. Заключительные положения</h2>
            <p>Применяется законодательство Федеративной Республики Германия...</p>
        ',
        
        // И так далее для всех 10 языков...
    ];
    
    return $terms[$lang] ?? $terms['en'];
}
?>

<style>
.terms-container {
    max-width: 900px;
    margin: 3rem auto;
    padding: 2rem;
}

.terms-container h1 {
    font-size: 2.5rem;
    margin-bottom: 1rem;
}

.last-updated {
    color: #6b7280;
    font-size: 0.875rem;
    margin-bottom: 2rem;
}

.terms-content h2 {
    font-size: 1.5rem;
    margin-top: 2rem;
    margin-bottom: 1rem;
    color: #1f2937;
}

.terms-content p {
    line-height: 1.75;
    margin-bottom: 1rem;
    color: #4b5563;
}
</style>
```

---

## 5️⃣ РЕГИСТРАЦИЯ (ФИЗЛИЦА + ЮРЛИЦА)

### register.php

```php
<div class="registration-container">
    <h1><?php echo __('register'); ?></h1>
    
    <!-- Выбор типа аккаунта -->
    <div class="account-type-selector">
        <button class="account-type-btn active" onclick="selectAccountType('individual')">
            <span class="icon">👤</span>
            <span><?php echo __('individual'); ?></span>
        </button>
        <button class="account-type-btn" onclick="selectAccountType('business')">
            <span class="icon">🏢</span>
            <span><?php echo __('business'); ?></span>
        </button>
    </div>
    
    <form id="registrationForm" method="POST" action="/register" onsubmit="return validateRegistration(event)">
        <input type="hidden" name="account_type" id="accountType" value="individual">
        
        <!-- Общие поля -->
        <div class="form-group">
            <label class="form-label"><?php echo __('email'); ?> *</label>
            <input type="email" name="email" id="email" class="form-input" required>
        </div>
        
        <div class="form-group">
            <label class="form-label"><?php echo __('password'); ?> *</label>
            <input type="password" name="password" id="password" class="form-input" required minlength="8">
            <div class="password-strength" id="passwordStrength"></div>
        </div>
        
        <div class="form-group">
            <label class="form-label"><?php echo __('confirm_password'); ?> *</label>
            <input type="password" name="password_confirm" id="passwordConfirm" class="form-input" required>
        </div>
        
        <!-- Поля для физлица -->
        <div id="individualFields">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label"><?php echo __('first_name'); ?> *</label>
                    <input type="text" name="first_name" class="form-input">
                </div>
                <div class="form-group">
                    <label class="form-label"><?php echo __('last_name'); ?> *</label>
                    <input type="text" name="last_name" class="form-input">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label"><?php echo __('phone'); ?></label>
                <input type="tel" name="phone" class="form-input">
            </div>
        </div>
        
        <!-- Поля для юрлица -->
        <div id="businessFields" style="display: none;">
            <div class="form-group">
                <label class="form-label"><?php echo __('company_name'); ?> *</label>
                <input type="text" name="company_name" class="form-input">
            </div>
            
            <div class="form-group">
                <label class="form-label"><?php echo __('tax_id'); ?> *</label>
                <input type="text" name="tax_id" class="form-input" placeholder="DE123456789">
            </div>
            
            <div class="form-group">
                <label class="form-label"><?php echo __('company_address'); ?> *</label>
                <input type="text" name="company_address" class="form-input">
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label"><?php echo __('company_phone'); ?> *</label>
                    <input type="tel" name="company_phone" class="form-input">
                </div>
                <div class="form-group">
                    <label class="form-label"><?php echo __('website'); ?></label>
                    <input type="url" name="website" class="form-input" placeholder="https://...">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label"><?php echo __('contact_person'); ?> *</label>
                <input type="text" name="contact_person" class="form-input">
            </div>
        </div>
        
        <!-- GDPR Согласие -->
        <?php include 'gdpr-consent.php'; ?>
        
        <!-- reCAPTCHA -->
        <div class="form-group">
            <div class="g-recaptcha" data-sitekey="YOUR_RECAPTCHA_SITE_KEY"></div>
        </div>
        
        <!-- Кнопка регистрации -->
        <button type="submit" class="btn btn-primary btn-full btn-lg">
            <?php echo __('create_account'); ?>
        </button>
        
        <!-- Альтернативный вход -->
        <div class="divider">
            <span><?php echo __('or'); ?></span>
        </div>
        
        <div class="social-login">
            <button type="button" class="btn btn-outline" onclick="loginWithGoogle()">
                <img src="/assets/images/google.svg" alt="Google" width="20">
                Google
            </button>
            <button type="button" class="btn btn-outline" onclick="loginWithFacebook()">
                <img src="/assets/images/facebook.svg" alt="Facebook" width="20">
                Facebook
            </button>
        </div>
        
        <p class="text-center mt-4">
            <?php echo __('already_have_account'); ?>
            <a href="/login"><?php echo __('login_here'); ?></a>
        </p>
    </form>
</div>

<!-- JavaScript -->
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script>
function selectAccountType(type) {
    document.getElementById('accountType').value = type;
    
    // Переключить активные кнопки
    document.querySelectorAll('.account-type-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.closest('.account-type-btn').classList.add('active');
    
    // Показать/скрыть поля
    if (type === 'individual') {
        document.getElementById('individualFields').style.display = 'block';
        document.getElementById('businessFields').style.display = 'none';
        
        // Сделать поля обязательными
        document.querySelector('[name="first_name"]').required = true;
        document.querySelector('[name="last_name"]').required = true;
        document.querySelector('[name="company_name"]').required = false;
        document.querySelector('[name="tax_id"]').required = false;
    } else {
        document.getElementById('individualFields').style.display = 'none';
        document.getElementById('businessFields').style.display = 'block';
        
        // Сделать поля обязательными
        document.querySelector('[name="first_name"]').required = false;
        document.querySelector('[name="last_name"]').required = false;
        document.querySelector('[name="company_name"]').required = true;
        document.querySelector('[name="tax_id"]').required = true;
    }
}

// Проверка силы пароля
document.getElementById('password').addEventListener('input', function() {
    const password = this.value;
    const strengthDiv = document.getElementById('passwordStrength');
    
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.match(/[a-z]/)) strength++;
    if (password.match(/[A-Z]/)) strength++;
    if (password.match(/[0-9]/)) strength++;
    if (password.match(/[^a-zA-Z0-9]/)) strength++;
    
    const labels = ['', 'Sehr schwach', 'Schwach', 'Mittel', 'Stark', 'Sehr stark'];
    const colors = ['', '#ef4444', '#f59e0b', '#eab308', '#10b981', '#059669'];
    
    strengthDiv.textContent = labels[strength];
    strengthDiv.style.color = colors[strength];
});

function validateRegistration(event) {
    event.preventDefault();
    
    const form = event.target;
    const password = form.password.value;
    const passwordConfirm = form.password_confirm.value;
    const gdprConsent = form.gdpr_consent.checked;
    
    // Проверка пароля
    if (password !== passwordConfirm) {
        alert('<?php echo __("passwords_dont_match"); ?>');
        return false;
    }
    
    // Проверка GDPR
    if (!gdprConsent) {
        alert('<?php echo __("must_accept_terms"); ?>');
        return false;
    }
    
    // Проверка reCAPTCHA
    const recaptchaResponse = grecaptcha.getResponse();
    if (!recaptchaResponse) {
        alert('<?php echo __("please_complete_captcha"); ?>');
        return false;
    }
    
    // Отправить форму
    form.submit();
    return true;
}
</script>

<style>
.registration-container {
    max-width: 600px;
    margin: 3rem auto;
    padding: 2rem;
}

.account-type-selector {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin-bottom: 2rem;
}

.account-type-btn {
    padding: 1.5rem;
    border: 2px solid #e5e7eb;
    border-radius: 0.5rem;
    background: white;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
}

.account-type-btn:hover {
    border-color: #ff6500;
    background: #fff7ed;
}

.account-type-btn.active {
    border-color: #ff6500;
    background: #ff6500;
    color: white;
}

.account-type-btn .icon {
    font-size: 2rem;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
}

.password-strength {
    font-size: 0.875rem;
    margin-top: 0.5rem;
    font-weight: 600;
}

.divider {
    text-align: center;
    margin: 2rem 0;
    position: relative;
}

.divider span {
    background: white;
    padding: 0 1rem;
    color: #6b7280;
    position: relative;
    z-index: 1;
}

.divider::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 0;
    right: 0;
    height: 1px;
    background: #e5e7eb;
}

.social-login {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
}

.social-login .btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
}

@media (max-width: 640px) {
    .form-row {
        grid-template-columns: 1fr;
    }
    
    .social-login {
        grid-template-columns: 1fr;
    }
}
</style>
```

### SQL для регистрации:

```sql
-- Таблица пользователей
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    account_type ENUM('individual', 'business') DEFAULT 'individual',
    
    -- Физлицо
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(50),
    
    -- Юрлицо
    company_name VARCHAR(255),
    tax_id VARCHAR(50),
    company_address TEXT,
    company_phone VARCHAR(50),
    website VARCHAR(255),
    contact_person VARCHAR(100),
    
    -- Статус
    status ENUM('pending', 'active', 'suspended', 'banned') DEFAULT 'pending',
    email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(64),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    
    -- IP и браузер
    registration_ip VARCHAR(45),
    last_login_ip VARCHAR(45),
    user_agent TEXT,
    
    INDEX idx_email (email),
    INDEX idx_account_type (account_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### register.php (Backend)

```php
<?php
require_once 'config.php';
require_once 'SecurityManager.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $security = new SecurityManager($db);
    
    // 1. Проверить reCAPTCHA
    if (!$security->verifyRecaptcha($_POST['g-recaptcha-response'])) {
        die(json_encode(['error' => 'Invalid CAPTCHA']));
    }
    
    // 2. Валидация данных
    $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
    if (!$email) {
        die(json_encode(['error' => 'Invalid email']));
    }
    
    // 3. Проверить существование email
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        die(json_encode(['error' => 'Email already exists']));
    }
    
    // 4. Хешировать пароль
    $passwordHash = password_hash($_POST['password'], PASSWORD_ARGON2ID, [
        'memory_cost' => 65536,
        'time_cost' => 4,
        'threads' => 3
    ]);
    
    // 5. Генерировать токен подтверждения
    $verificationToken = bin2hex(random_bytes(32));
    
    // 6. Сохранить пользователя
    $stmt = $db->prepare("
        INSERT INTO users (
            email, password_hash, account_type,
            first_name, last_name, phone,
            company_name, tax_id, company_address, company_phone, website, contact_person,
            email_verification_token, registration_ip, user_agent
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email,
        $passwordHash,
        $_POST['account_type'],
        $_POST['first_name'] ?? null,
        $_POST['last_name'] ?? null,
        $_POST['phone'] ?? null,
        $_POST['company_name'] ?? null,
        $_POST['tax_id'] ?? null,
        $_POST['company_address'] ?? null,
        $_POST['company_phone'] ?? null,
        $_POST['website'] ?? null,
        $_POST['contact_person'] ?? null,
        $verificationToken,
        $_SERVER['REMOTE_ADDR'],
        $_SERVER['HTTP_USER_AGENT']
    ]);
    
    $userId = $db->lastInsertId();
    
    // 7. Сохранить согласия GDPR
    if (isset($_POST['gdpr_consent']) && $_POST['gdpr_consent']) {
        $stmt = $db->prepare("
            INSERT INTO user_consents (user_id, consent_type, consent_given, ip_address, user_agent)
            VALUES (?, 'gdpr', TRUE, ?, ?)
        ");
        $stmt->execute([$userId, $_SERVER['REMOTE_ADDR'], $_SERVER['HTTP_USER_AGENT']]);
    }
    
    if (isset($_POST['marketing_consent']) && $_POST['marketing_consent']) {
        $stmt = $db->prepare("
            INSERT INTO user_consents (user_id, consent_type, consent_given, ip_address, user_agent)
            VALUES (?, 'marketing', TRUE, ?, ?)
        ");
        $stmt->execute([$userId, $_SERVER['REMOTE_ADDR'], $_SERVER['HTTP_USER_AGENT']]);
    }
    
    // 8. Отправить email подтверждения
    $verificationLink = "https://yoursite.com/verify-email?token=$verificationToken";
    
    $mailer = new PHPMailer\PHPMailer\PHPMailer(true);
    $mailer->CharSet = 'UTF-8';
    $mailer->setFrom('noreply@yoursite.com', 'AutoMarket');
    $mailer->addAddress($email);
    $mailer->Subject = __('verify_your_email');
    $mailer->Body = __('email_verification_text', ['link' => $verificationLink]);
    $mailer->send();
    
    // 9. Перенаправить
    header('Location: /registration-success');
    exit;
}
?>
```

---

## 6️⃣ ВОССТАНОВЛЕНИЕ ПАРОЛЯ

### forgot-password.php

```php
<div class="container" style="max-width: 500px; margin: 3rem auto;">
    <h1><?php echo __('forgot_password'); ?></h1>
    <p><?php echo __('forgot_password_text'); ?></p>
    
    <form method="POST" action="/password-reset-request">
        <div class="form-group">
            <label class="form-label"><?php echo __('email'); ?></label>
            <input type="email" name="email" class="form-input" required>
        </div>
        
        <div class="g-recaptcha" data-sitekey="YOUR_SITE_KEY"></div>
        
        <button type="submit" class="btn btn-primary btn-full mt-4">
            <?php echo __('send_reset_link'); ?>
        </button>
    </form>
</div>

<?php
// password-reset-request.php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
    
    // Проверить reCAPTCHA
    // ...
    
    // Найти пользователя
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if ($user) {
        // Генерировать токен
        $token = bin2hex(random_bytes(32));
        $expires = date('Y-m-d H:i:s', strtotime('+1 hour'));
        
        // Сохранить токен
        $stmt = $db->prepare("
            INSERT INTO password_resets (user_id, token, expires_at)
            VALUES (?, ?, ?)
        ");
        $stmt->execute([$user['id'], hash('sha256', $token), $expires]);
        
        // Отправить email
        $resetLink = "https://yoursite.com/reset-password?token=$token";
        // ... send email
    }
    
    // Всегда показывать успех (безопасность)
    echo "If the email exists, you will receive a reset link.";
}
?>
```

### SQL:

```sql
CREATE TABLE password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 7️⃣ ЗАЩИТА ОТ ХАКЕРОВ (БЕЗОПАСНОСТЬ)

### SecurityManager.php

```php
<?php

class SecurityManager {
    private $db;
    private $maxLoginAttempts = 5;
    private $lockoutTime = 900; // 15 минут
    
    public function __construct($database) {
        $this->db = $database;
    }
    
    /**
     * Защита от SQL Injection
     * Используем PDO prepared statements ВСЕГДА
     */
    public function sanitizeInput($input) {
        // Удалить HTML теги
        $input = strip_tags($input);
        // Удалить пробелы
        $input = trim($input);
        // Экранировать специальные символы
        $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        return $input;
    }
    
    /**
     * Защита от XSS (Cross-Site Scripting)
     */
    public function preventXSS($data) {
        if (is_array($data)) {
            foreach ($data as $key => $value) {
                $data[$key] = $this->preventXSS($value);
            }
        } else {
            $data = htmlspecialchars($data, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        }
        return $data;
    }
    
    /**
     * CSRF Protection (Cross-Site Request Forgery)
     */
    public function generateCSRFToken() {
        if (!isset($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }
    
    public function verifyCSRFToken($token) {
        if (!isset($_SESSION['csrf_token']) || $token !== $_SESSION['csrf_token']) {
            return false;
        }
        return true;
    }
    
    /**
     * Rate Limiting - Защита от брутфорса
     */
    public function checkRateLimit($ip, $action = 'login') {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as attempts, MAX(attempted_at) as last_attempt
            FROM failed_attempts
            WHERE ip_address = ? AND action = ? AND attempted_at > DATE_SUB(NOW(), INTERVAL 15 MINUTE)
        ");
        $stmt->execute([$ip, $action]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result['attempts'] >= $this->maxLoginAttempts) {
            $lockoutRemaining = 900 - (time() - strtotime($result['last_attempt']));
            throw new Exception("Too many attempts. Try again in " . ceil($lockoutRemaining / 60) . " minutes.");
        }
        
        return true;
    }
    
    public function recordFailedAttempt($ip, $action = 'login', $details = null) {
        $stmt = $this->db->prepare("
            INSERT INTO failed_attempts (ip_address, action, details, attempted_at)
            VALUES (?, ?, ?, NOW())
        ");
        $stmt->execute([$ip, $action, json_encode($details)]);
    }
    
    public function clearFailedAttempts($ip, $action = 'login') {
        $stmt = $this->db->prepare("
            DELETE FROM failed_attempts 
            WHERE ip_address = ? AND action = ?
        ");
        $stmt->execute([$ip, $action]);
    }
    
    /**
     * reCAPTCHA v3 Verification
     */
    public function verifyRecaptcha($response) {
        $secretKey = 'YOUR_SECRET_KEY';
        
        $verify = file_get_contents('https://www.google.com/recaptcha/api/siteverify?secret=' . $secretKey . '&response=' . $response);
        $captchaSuccess = json_decode($verify);
        
        if ($captchaSuccess->success && $captchaSuccess->score >= 0.5) {
            return true;
        }
        
        return false;
    }
    
    /**
     * Защита заголовков HTTP
     */
    public function setSecurityHeaders() {
        // Защита от clickjacking
        header('X-Frame-Options: SAMEORIGIN');
        
        // Защита от XSS
        header('X-XSS-Protection: 1; mode=block');
        
        // Защита от MIME type sniffing
        header('X-Content-Type-Options: nosniff');
        
        // Content Security Policy
        header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://www.google.com https://www.gstatic.com; style-src 'self' 'unsafe-inline';");
        
        // Strict Transport Security (HTTPS)
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
        
        // Referrer Policy
        header('Referrer-Policy: strict-origin-when-cross-origin');
        
        // Permissions Policy
        header('Permissions-Policy: geolocation=(), microphone=(), camera=()');
    }
    
    /**
     * Валидация загружаемых файлов
     */
    public function validateUploadedFile($file, $allowedTypes = ['image/jpeg', 'image/png', 'image/webp']) {
        // Проверить существование
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            throw new Exception('Invalid file upload');
        }
        
        // Проверить размер (макс 5MB)
        if ($file['size'] > 5 * 1024 * 1024) {
            throw new Exception('File too large');
        }
        
        // Проверить MIME type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        
        if (!in_array($mimeType, $allowedTypes)) {
            throw new Exception('Invalid file type');
        }
        
        // Проверить расширение
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowedExt = ['jpg', 'jpeg', 'png', 'webp'];
        if (!in_array($ext, $allowedExt)) {
            throw new Exception('Invalid file extension');
        }
        
        return true;
    }
    
    /**
     * Защита от Directory Traversal
     */
    public function sanitizePath($path) {
        // Удалить ../ и ../
        $path = str_replace(['../', '..\\'], '', $path);
        // Удалить null bytes
        $path = str_replace(chr(0), '', $path);
        return $path;
    }
    
    /**
     * Secure Session Management
     */
    public function initSecureSession() {
        // Настройки сессии
        ini_set('session.cookie_httponly', 1);
        ini_set('session.use_only_cookies', 1);
        ini_set('session.cookie_secure', 1);
        ini_set('session.cookie_samesite', 'Strict');
        
        session_start();
        
        // Регенерировать ID сессии
        if (!isset($_SESSION['initiated'])) {
            session_regenerate_id(true);
            $_SESSION['initiated'] = true;
        }
        
        // Проверить IP и User Agent
        if (isset($_SESSION['ip']) && $_SESSION['ip'] !== $_SERVER['REMOTE_ADDR']) {
            session_destroy();
            session_start();
        }
        
        $_SESSION['ip'] = $_SERVER['REMOTE_ADDR'];
        $_SESSION['user_agent'] = $_SERVER['HTTP_USER_AGENT'];
    }
}
?>
```

### SQL для безопасности:

```sql
-- Таблица неудачных попыток входа
CREATE TABLE failed_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    action VARCHAR(50) NOT NULL,
    details JSON,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ip_action (ip_address, action),
    INDEX idx_attempted (attempted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица активных сессий
CREATE TABLE user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id VARCHAR(128) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session (session_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица логов безопасности
CREATE TABLE security_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    event_type VARCHAR(50) NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    ip_address VARCHAR(45),
    user_agent TEXT,
    details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_event (event_type),
    INDEX idx_severity (severity),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 8️⃣ reCAPTCHA ИНТЕГРАЦИЯ

### recaptcha.php

```php
<!-- В <head> -->
<script src="https://www.google.com/recaptcha/api.js" async defer></script>

<!-- В форме -->
<div class="g-recaptcha" 
     data-sitekey="YOUR_SITE_KEY" 
     data-callback="onRecaptchaSuccess"
     data-expired-callback="onRecaptchaExpired">
</div>

<!-- JavaScript -->
<script>
function onRecaptchaSuccess(token) {
    console.log('reCAPTCHA verified');
    document.getElementById('submitButton').disabled = false;
}

function onRecaptchaExpired() {
    console.log('reCAPTCHA expired');
    document.getElementById('submitButton').disabled = true;
}

// Для формы входа после 5 неудачных попыток
let loginAttempts = 0;
document.getElementById('loginForm').addEventListener('submit', function(e) {
    if (loginAttempts >= 5 && !grecaptcha.getResponse()) {
        e.preventDefault();
        alert('Please complete the CAPTCHA');
        // Показать CAPTCHA
        document.getElementById('recaptchaContainer').style.display = 'block';
    }
});
</script>

<!-- PHP Backend -->
<?php
function verifyRecaptcha($response) {
    $secretKey = 'YOUR_SECRET_KEY';
    $url = 'https://www.google.com/recaptcha/api/siteverify';
    
    $data = [
        'secret' => $secretKey,
        'response' => $response,
        'remoteip' => $_SERVER['REMOTE_ADDR']
    ];
    
    $options = [
        'http' => [
            'header' => "Content-type: application/x-www-form-urlencoded\r\n",
            'method' => 'POST',
            'content' => http_build_query($data)
        ]
    ];
    
    $context = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    $resultJson = json_decode($result);
    
    return $resultJson->success && $resultJson->score >= 0.5;
}
?>
```

---

Это ПЕРВАЯ ЧАСТЬ! Продолжить создавать:
- Автоматическую модерацию
- Автоматическое SEO
- Мастер подачи объявлений
- Логотип и фавикон
- Структуру проекта

Продолжить?