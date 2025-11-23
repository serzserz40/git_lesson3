# 🚀 ПОЛНАЯ УСТАНОВКА AUTOMARKET ОТ А ДО Я

## 📋 СОДЕРЖАНИЕ

1. Требования к серверу
2. Установка на чистый Ubuntu/Debian сервер
3. Установка на Windows (XAMPP/WAMP)
4. Настройка базы данных
5. Установка всех зависимостей
6. Копирование файлов
7. Настройка конфигурации
8. Запуск WebSocket сервера
9. Настройка cron задач
10. Настройка SSL (HTTPS)
11. Первый запуск и тестирование
12. Решение проблем

---

## 1️⃣ ТРЕБОВАНИЯ К СЕРВЕРУ

### Минимальные требования:
- **OS**: Ubuntu 20.04+ / Debian 11+ / Windows Server 2019+
- **CPU**: 2 ядра
- **RAM**: 4GB
- **Диск**: 50GB SSD
- **PHP**: 8.2+
- **MySQL**: 8.0+ / MariaDB 10.6+
- **Node.js**: 18.x+
- **Apache**: 2.4+ / Nginx 1.18+

### Рекомендуемые требования:
- **CPU**: 4 ядра
- **RAM**: 8GB
- **Диск**: 100GB SSD
- **Bandwidth**: 1Gbps

---

## 2️⃣ УСТАНОВКА НА UBUNTU/DEBIAN

### ШАГ 1: Обновление системы

```bash
# Обновить списки пакетов
sudo apt update
sudo apt upgrade -y

# Установить базовые утилиты
sudo apt install -y software-properties-common curl wget git unzip
```

### ШАГ 2: Установка Apache

```bash
# Установить Apache
sudo apt install -y apache2

# Включить необходимые модули
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel

# Запустить Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Проверить статус
sudo systemctl status apache2
```

### ШАГ 3: Установка PHP 8.2

```bash
# Добавить репозиторий PHP
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Установить PHP и расширения
sudo apt install -y php8.2 \
    php8.2-fpm \
    php8.2-cli \
    php8.2-common \
    php8.2-mysql \
    php8.2-gd \
    php8.2-curl \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-bcmath \
    php8.2-json \
    php8.2-intl \
    php8.2-soap \
    php8.2-imagick \
    libapache2-mod-php8.2

# Проверить версию PHP
php -v

# Настроить PHP
sudo nano /etc/php/8.2/apache2/php.ini
```

### Важные настройки в php.ini:

```ini
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 300
max_input_time = 300
date.timezone = Europe/Berlin

# Для безопасности
expose_php = Off
display_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
```

### ШАГ 4: Установка MySQL

```bash
# Установить MySQL Server
sudo apt install -y mysql-server

# Запустить и включить MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Безопасная установка
sudo mysql_secure_installation
```

Ответы на вопросы:
- **Set root password?** Yes → введите надёжный пароль
- **Remove anonymous users?** Yes
- **Disallow root login remotely?** Yes
- **Remove test database?** Yes
- **Reload privilege tables?** Yes

### ШАГ 5: Установка Composer

```bash
# Скачать установщик
curl -sS https://getcomposer.org/installer -o composer-setup.php

# Проверить хеш (опционально)
HASH=$(curl -sS https://composer.github.io/installer.sig)
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

# Установить Composer глобально
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Удалить установщик
rm composer-setup.php

# Проверить версию
composer --version
```

### ШАГ 6: Установка Node.js и NPM

```bash
# Добавить репозиторий NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Установить Node.js
sudo apt install -y nodejs

# Проверить версии
node -v
npm -v
```

### ШАГ 7: Создание структуры проекта

```bash
# Перейти в директорию веб-сервера
cd /var/www

# Создать директорию проекта
sudo mkdir automarket
cd automarket

# Создать все необходимые папки
sudo mkdir -p public/{assets/{images,uploads/{listings,avatars,documents},fonts},css,js}
sudo mkdir -p src/{config,controllers,models,views/{layouts,pages,auth,user},services,middleware,helpers,languages/{de,en,es,fr,nl,pl,ro,ru,cs,tr}}
sudo mkdir -p database/{migrations,seeds}
sudo mkdir -p storage/{logs,cache/{views,data}}
sudo mkdir -p tests/{Unit,Feature}

# Установить права доступа
sudo chown -R www-data:www-data /var/www/automarket
sudo chmod -R 755 /var/www/automarket
sudo chmod -R 775 storage public/assets/uploads
```

### ШАГ 8: Настройка виртуального хоста Apache

```bash
# Создать конфиг виртуального хоста
sudo nano /etc/apache2/sites-available/automarket.conf
```

Вставить следующий конфиг:

```apache
<VirtualHost *:80>
    ServerName automarket.local
    ServerAlias www.automarket.local
    DocumentRoot /var/www/automarket/public

    <Directory /var/www/automarket/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # WebSocket Proxy
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyPass /ws ws://localhost:8080/
    ProxyPassReverse /ws ws://localhost:8080/

    # Логи
    ErrorLog ${APACHE_LOG_DIR}/automarket_error.log
    CustomLog ${APACHE_LOG_DIR}/automarket_access.log combined

    # Security Headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</VirtualHost>
```

```bash
# Включить сайт
sudo a2ensite automarket.conf

# Отключить дефолтный сайт
sudo a2dissite 000-default.conf

# Перезапустить Apache
sudo systemctl restart apache2

# Проверить конфигурацию
sudo apache2ctl configtest
```

### ШАГ 9: Настройка /etc/hosts (для локальной разработки)

```bash
# Редактировать hosts
sudo nano /etc/hosts

# Добавить строку:
127.0.0.1   automarket.local www.automarket.local
```

### ШАГ 10: Создание .htaccess

```bash
# Создать .htaccess в public/
sudo nano /var/www/automarket/public/.htaccess
```

Вставить:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Принудительный HTTPS (раскомментировать после настройки SSL)
    # RewriteCond %{HTTPS} off
    # RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    # Перенаправление на public/
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteRule ^(.*)$ /public/$1 [L]
    
    # Роутинг через index.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>

# Защита файлов
<FilesMatch "\.(htaccess|htpasswd|ini|log|sh|sql)$">
    Require all denied
</FilesMatch>

# Отключить листинг директорий
Options -Indexes

# Кеширование
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

---

## 3️⃣ УСТАНОВКА НА WINDOWS (XAMPP)

### ШАГ 1: Скачать и установить XAMPP

1. Скачать XAMPP с https://www.apachefriends.org/
2. Запустить установщик
3. Выбрать компоненты: Apache, MySQL, PHP, Perl
4. Установить в `C:\xampp`

### ШАГ 2: Настроить XAMPP

1. Запустить XAMPP Control Panel
2. Запустить Apache и MySQL
3. Открыть `C:\xampp\apache\conf\extra\httpd-vhosts.conf`

Добавить:

```apache
<VirtualHost *:80>
    ServerName automarket.local
    DocumentRoot "C:/xampp/htdocs/automarket/public"
    <Directory "C:/xampp/htdocs/automarket/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

4. Открыть `C:\Windows\System32\drivers\etc\hosts` (как Администратор)

Добавить:
```
127.0.0.1   automarket.local
```

### ШАГ 3: Установить Composer для Windows

1. Скачать с https://getcomposer.org/Composer-Setup.exe
2. Запустить установщик
3. Выбрать путь к PHP: `C:\xampp\php\php.exe`

### ШАГ 4: Установить Node.js для Windows

1. Скачать с https://nodejs.org/
2. Запустить установщик
3. Перезапустить компьютер

### ШАГ 5: Создать проект

```cmd
cd C:\xampp\htdocs
mkdir automarket
cd automarket

REM Создать структуру
mkdir public\assets\images public\assets\uploads public\css public\js
mkdir src\config src\controllers src\models src\views
mkdir database\migrations storage\logs
```

---

## 4️⃣ НАСТРОЙКА БАЗЫ ДАННЫХ

### Создание БД и пользователя

```bash
# Войти в MySQL
sudo mysql -u root -p
```

```sql
-- Создать базу данных
CREATE DATABASE automarket CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Создать пользователя
CREATE USER 'automarket_user'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';

-- Дать права
GRANT ALL PRIVILEGES ON automarket.* TO 'automarket_user'@'localhost';

-- Применить изменения
FLUSH PRIVILEGES;

-- Проверить
SHOW DATABASES;
SHOW GRANTS FOR 'automarket_user'@'localhost';

-- Выйти
EXIT;
```

### Проверка подключения

```bash
mysql -u automarket_user -p automarket
```

---

## 5️⃣ УСТАНОВКА ЗАВИСИМОСТЕЙ

### Установка PHP зависимостей через Composer

```bash
cd /var/www/automarket

# Создать composer.json
sudo nano composer.json
```

```json
{
    "name": "automarket/automarket",
    "description": "Auto marketplace like mobile.de",
    "type": "project",
    "require": {
        "php": "^8.2",
        "stripe/stripe-php": "^13.0",
        "paypal/rest-api-sdk-php": "^1.14",
        "twilio/sdk": "^7.0",
        "cboden/ratchet": "^0.4",
        "phpmailer/phpmailer": "^6.8",
        "vlucas/phpdotenv": "^5.5",
        "guzzlehttp/guzzle": "^7.8",
        "intervention/image": "^2.7"
    },
    "require-dev": {
        "phpunit/phpunit": "^10.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    }
}
```

```bash
# Установить зависимости
sudo composer install

# Если ошибки с правами:
sudo chown -R $USER:$USER /var/www/automarket
composer install
sudo chown -R www-data:www-data /var/www/automarket
```

### Установка NPM зависимостей

```bash
cd /var/www/automarket

# Создать package.json
nano package.json
```

```json
{
  "name": "automarket",
  "version": "1.0.0",
  "description": "AutoMarket Frontend",
  "scripts": {
    "build:css": "tailwindcss -i ./src/input.css -o ./public/css/style.css --minify",
    "watch:css": "tailwindcss -i ./src/input.css -o ./public/css/style.css --watch",
    "build": "npm run build:css"
  },
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "@tailwindcss/typography": "^0.5.10",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.4.0"
  },
  "dependencies": {
    "axios": "^1.6.2",
    "chart.js": "^4.4.1",
    "socket.io-client": "^4.6.0"
  }
}
```

```bash
# Установить зависимости
npm install
```

### Настройка Tailwind CSS

```bash
# Создать tailwind.config.js
npx tailwindcss init
```

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/views/**/*.php",
    "./public/**/*.html",
    "./public/js/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        primary: '#ff6500',
        secondary: '#1f2937'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

```bash
# Создать input.css
nano src/input.css
```

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Ваши кастомные стили */
```

```bash
# Собрать CSS
npm run build:css
```

---

## 6️⃣ КОПИРОВАНИЕ ФАЙЛОВ

### Создание всех основных файлов

```bash
cd /var/www/automarket

# Создать .env файл
sudo nano .env
```

```env
# Database
DB_HOST=localhost
DB_NAME=automarket
DB_USER=automarket_user
DB_PASS=YourStrongPassword123!
DB_CHARSET=utf8mb4

# App
APP_URL=http://automarket.local
APP_ENV=development
APP_DEBUG=true
APP_TIMEZONE=Europe/Berlin

# Security
APP_KEY=base64:GENERATE_THIS_WITH_RANDOM_32_BYTES
SESSION_LIFETIME=120
CSRF_TOKEN_EXPIRY=7200

# Stripe
STRIPE_PUBLIC_KEY=pk_test_YOUR_KEY
STRIPE_SECRET_KEY=sk_test_YOUR_KEY
STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET

# PayPal
PAYPAL_CLIENT_ID=YOUR_CLIENT_ID
PAYPAL_CLIENT_SECRET=YOUR_SECRET
PAYPAL_MODE=sandbox
PAYPAL_WEBHOOK_ID=YOUR_WEBHOOK_ID

# Klarna
KLARNA_USERNAME=YOUR_USERNAME
KLARNA_PASSWORD=YOUR_PASSWORD
KLARNA_REGION=eu

# Twilio (SMS)
TWILIO_SID=YOUR_SID
TWILIO_AUTH_TOKEN=YOUR_TOKEN
TWILIO_PHONE_NUMBER=+491234567890

# reCAPTCHA
RECAPTCHA_SITE_KEY=YOUR_SITE_KEY
RECAPTCHA_SECRET_KEY=YOUR_SECRET_KEY

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your@email.com
SMTP_PASSWORD=your_app_password
SMTP_FROM_ADDRESS=noreply@automarket.com
SMTP_FROM_NAME=AutoMarket

# WebSocket
WEBSOCKET_HOST=0.0.0.0
WEBSOCKET_PORT=8080

# File Upload
MAX_UPLOAD_SIZE=5242880
ALLOWED_IMAGE_TYPES=jpg,jpeg,png,webp
```

### Создать базовый index.php

```bash
sudo nano public/index.php
```

```php
<?php
/**
 * AutoMarket - Entry Point
 */

// Автозагрузка
require_once __DIR__ . '/../vendor/autoload.php';

// Загрузить .env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Запустить сессию
session_start();

// Подключение к БД
require_once __DIR__ . '/../src/config/database.php';

// Роутинг
require_once __DIR__ . '/../src/config/routes.php';
```

---

## 7️⃣ ИМПОРТ БАЗЫ ДАННЫХ

### Импортировать все SQL миграции

```bash
# Перейти в папку миграций
cd /var/www/automarket/database/migrations

# Импортировать каждый файл
mysql -u automarket_user -p automarket < 001_create_users.sql
mysql -u automarket_user -p automarket < 002_create_categories.sql
mysql -u automarket_user -p automarket < 003_create_listings.sql
mysql -u automarket_user -p automarket < 004_create_photos.sql
mysql -u automarket_user -p automarket < 005_create_payments.sql
mysql -u automarket_user -p automarket < 006_create_messages.sql
mysql -u automarket_user -p automarket < 007_create_reviews.sql
mysql -u automarket_user -p automarket < 008_create_notifications.sql
mysql -u automarket_user -p automarket < 009_create_analytics.sql
mysql -u automarket_user -p automarket < 010_create_security.sql

# Или все сразу (если в одном файле)
mysql -u automarket_user -p automarket < full_schema.sql
```

### Импортировать начальные данные (seeds)

```bash
cd /var/www/automarket/database/seeds

mysql -u automarket_user -p automarket < categories_seed.sql
mysql -u automarket_user -p automarket < languages_seed.sql
mysql -u automarket_user -p automarket < settings_seed.sql
```

---

## 8️⃣ ЗАПУСК WEBSOCKET СЕРВЕРА

### Создать WebSocket сервер

```bash
sudo nano /var/www/automarket/chat-server.php
```

```php
<?php
require __DIR__ . '/vendor/autoload.php';

use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

class ChatServer implements \Ratchet\MessageComponentInterface {
    protected $clients;

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(\Ratchet\ConnectionInterface $conn) {
        $this->clients->attach($conn);
        echo "New connection! ({$conn->resourceId})\n";
    }

    public function onMessage(\Ratchet\ConnectionInterface $from, $msg) {
        foreach ($this->clients as $client) {
            if ($from !== $client) {
                $client->send($msg);
            }
        }
    }

    public function onClose(\Ratchet\ConnectionInterface $conn) {
        $this->clients->detach($conn);
        echo "Connection {$conn->resourceId} has disconnected\n";
    }

    public function onError(\Ratchet\ConnectionInterface $conn, \Exception $e) {
        echo "An error has occurred: {$e->getMessage()}\n";
        $conn->close();
    }
}

$server = IoServer::factory(
    new HttpServer(
        new WsServer(
            new ChatServer()
        )
    ),
    8080
);

echo "WebSocket server started on port 8080\n";
$server->run();
```

### Запустить WebSocket сервер

```bash
# В новом терминале
cd /var/www/automarket
php chat-server.php

# Или в фоне
nohup php chat-server.php > storage/logs/websocket.log 2>&1 &
```

### Создать systemd сервис (автозапуск)

```bash
sudo nano /etc/systemd/system/automarket-websocket.service
```

```ini
[Unit]
Description=AutoMarket WebSocket Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/automarket
ExecStart=/usr/bin/php /var/www/automarket/chat-server.php
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Перезагрузить systemd
sudo systemctl daemon-reload

# Запустить сервис
sudo systemctl start automarket-websocket

# Включить автозапуск
sudo systemctl enable automarket-websocket

# Проверить статус
sudo systemctl status automarket-websocket
```

---

## 9️⃣ НАСТРОЙКА CRON ЗАДАЧ

```bash
# Открыть crontab
sudo crontab -e
```

Добавить задачи:

```cron
# Очистка старых сессий (каждый час)
0 * * * * php /var/www/automarket/src/cron/cleanup-sessions.php

# Генерация sitemap (каждый день в 3:00)
0 3 * * * php /var/www/automarket/src/cron/generate-sitemap.php

# Отправка email уведомлений (каждые 5 минут)
*/5 * * * * php /var/www/automarket/src/cron/send-notifications.php

# Обновление статистики (каждые 15 минут)
*/15 * * * * php /var/www/automarket/src/cron/update-analytics.php

# Проверка истечения объявлений (каждый день в 1:00)
0 1 * * * php /var/www/automarket/src/cron/expire-listings.php

# Бэкап базы данных (каждый день в 4:00)
0 4 * * * /usr/bin/mysqldump -u automarket_user -pYourPassword automarket > /var/backups/automarket_$(date +\%Y\%m\%d).sql
```

---

## 🔟 НАСТРОЙКА SSL (HTTPS)

### Установка Certbot (Let's Encrypt)

```bash
# Установить Certbot
sudo apt install -y certbot python3-certbot-apache

# Получить сертификат
sudo certbot --apache -d automarket.com -d www.automarket.com

# Автообновление (добавляется автоматически в cron)
sudo certbot renew --dry-run
```

### Проверка HTTPS

Откройте в браузере: https://automarket.com

---

## 1️⃣1️⃣ ПЕРВЫЙ ЗАПУСК

### Проверка

```bash
# Проверить Apache
sudo systemctl status apache2

# Проверить MySQL
sudo systemctl status mysql

# Проверить WebSocket
sudo systemctl status automarket-websocket

# Проверить логи
tail -f /var/log/apache2/automarket_error.log
tail -f /var/www/automarket/storage/logs/app.log
```

### Открыть сайт

1. Откройте браузер
2. Перейдите на http://automarket.local (или ваш домен)
3. Должна открыться главная страница

### Создать первого админа

```bash
cd /var/www/automarket
php src/cli/create-admin.php
```

---

## 1️⃣2️⃣ РЕШЕНИЕ ПРОБЛЕМ

### Проблема 1: Apache не запускается

```bash
# Проверить логи
sudo tail -f /var/log/apache2/error.log

# Проверить конфиг
sudo apache2ctl configtest

# Проверить порты
sudo netstat -tulpn | grep :80
```

### Проблема 2: 500 Internal Server Error

```bash
# Проверить права
sudo chown -R www-data:www-data /var/www/automarket
sudo chmod -R 755 /var/www/automarket
sudo chmod -R 775 storage public/assets/uploads

# Проверить логи PHP
tail -f /var/log/apache2/automarket_error.log
```

### Проблема 3: База данных не подключается

```bash
# Проверить MySQL
sudo systemctl status mysql

# Проверить пользователя
mysql -u automarket_user -p

# Проверить права
mysql -u root -p
SHOW GRANTS FOR 'automarket_user'@'localhost';
```

### Проблема 4: Composer ошибки

```bash
# Очистить кеш
composer clear-cache

# Переустановить
rm -rf vendor composer.lock
composer install
```

### Проблема 5: NPM ошибки

```bash
# Очистить кеш
npm cache clean --force

# Переустановить
rm -rf node_modules package-lock.json
npm install
```

---

## ✅ ЧЕКЛИСТ УСТАНОВКИ

- [ ] Система обновлена
- [ ] Apache установлен и запущен
- [ ] PHP 8.2+ установлен
- [ ] MySQL установлен
- [ ] Composer установлен
- [ ] Node.js установлен
- [ ] Структура папок создана
- [ ] Виртуальный хост настроен
- [ ] База данных создана
- [ ] .env файл настроен
- [ ] Composer зависимости установлены
- [ ] NPM зависимости установлены
- [ ] SQL миграции импортированы
- [ ] WebSocket сервер запущен
- [ ] Cron задачи настроены
- [ ] SSL сертификат установлен
- [ ] Сайт открывается в браузере
- [ ] Админ аккаунт создан

---

## 🎉 ГОТОВО!

Ваш AutoMarket установлен и готов к работе!

**Следующие шаги:**
1. Настроить платёжные системы (Stripe, PayPal)
2. Настроить SMS (Twilio)
3. Загрузить категории и модели из mobile.de
4. Создать первое тестовое объявление
5. Настроить мониторинг и бэкапы

**Полезные команды:**

```bash
# Перезапуск всех сервисов
sudo systemctl restart apache2 mysql automarket-websocket

# Просмотр логов
tail -f /var/www/automarket/storage/logs/app.log

# Обновление проекта
cd /var/www/automarket
git pull
composer install
npm install
npm run build:css
php src/cli/migrate.php
```

**Поддержка:**
- Email: support@automarket.com
- Telegram: @automarket_support
- Discord: discord.gg/automarket

🚀 **Успешного запуска!**
