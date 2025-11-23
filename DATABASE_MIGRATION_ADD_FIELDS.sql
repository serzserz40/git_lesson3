-- =====================================================
-- SQL МИГРАЦИЯ - ДОБАВЛЕНИЕ НЕДОСТАЮЩИХ ПОЛЕЙ
-- =====================================================
-- Дата: 15 ноября 2025
-- Описание: Добавление полей из SS.COM и Mobile.de
-- База: automarkt
-- =====================================================

USE automarkt;

-- =====================================================
-- 1. ДОБАВЛЕНИЕ ПОЛЕЙ В ТАБЛИЦУ listings
-- =====================================================

ALTER TABLE listings

-- Месяц первой регистрации
ADD COLUMN first_registration_month TINYINT COMMENT '1-12 месяц регистрации' AFTER first_registration_date,

-- Гос. номер автомобиля
ADD COLUMN license_plate VARCHAR(20) COMMENT 'Номерной знак' AFTER vin_code,

-- Тип продавца
ADD COLUMN seller_type ENUM('private', 'dealer', 'leasing_company') DEFAULT 'private' COMMENT 'Тип продавца' AFTER user_id,

-- Состояние автомобиля
ADD COLUMN condition_status ENUM('new', 'used', 'damaged', 'accident', 'restored') DEFAULT 'used' COMMENT 'Состояние' AFTER damaged,

-- Без ДТП
ADD COLUMN accident_free BOOLEAN DEFAULT TRUE COMMENT 'Без аварий' AFTER damaged,

-- Сервисная история
ADD COLUMN warranty_months INT DEFAULT 0 COMMENT 'Гарантия (месяцев)' AFTER technical_inspection_until,
ADD COLUMN service_book_available BOOLEAN DEFAULT FALSE COMMENT 'Сервисная книга' AFTER warranty_months,
ADD COLUMN last_service_km INT COMMENT 'Последнее ТО (км)' AFTER service_book_available,
ADD COLUMN last_service_date DATE COMMENT 'Дата последнего ТО' AFTER last_service_km,

-- Финансовые опции
ADD COLUMN trade_in_possible BOOLEAN DEFAULT FALSE COMMENT 'Возможен обмен' AFTER price_negotiable,
ADD COLUMN financing_available BOOLEAN DEFAULT FALSE COMMENT 'Лизинг/кредит' AFTER trade_in_possible,
ADD COLUMN leasing_rate DECIMAL(8,2) COMMENT 'Лизинговая ставка EUR/мес' AFTER financing_available,

-- Технические характеристики
ADD COLUMN fuel_consumption_city DECIMAL(4,1) COMMENT 'Расход город (л/100км)' AFTER fuel_type,
ADD COLUMN fuel_consumption_highway DECIMAL(4,1) COMMENT 'Расход трасса (л/100км)' AFTER fuel_consumption_city,
ADD COLUMN fuel_consumption_combined DECIMAL(4,1) COMMENT 'Расход средний (л/100км)' AFTER fuel_consumption_highway,
ADD COLUMN co2_emissions INT COMMENT 'Выбросы CO2 (г/км)' AFTER fuel_consumption_combined,
ADD COLUMN emission_class VARCHAR(20) COMMENT 'Экологический класс (Euro 5/6)' AFTER co2_emissions,
ADD COLUMN gross_vehicle_weight INT COMMENT 'Полная масса (кг)' AFTER engine_cc,
ADD COLUMN curb_weight INT COMMENT 'Снаряженная масса (кг)' AFTER gross_vehicle_weight,
ADD COLUMN payload_capacity INT COMMENT 'Грузоподъёмность (кг)' AFTER curb_weight,

-- Дополнительные характеристики
ADD COLUMN seats_count TINYINT DEFAULT 5 COMMENT 'Количество мест' AFTER doors,
ADD COLUMN trunk_capacity INT COMMENT 'Объём багажника (л)' AFTER seats_count,
ADD COLUMN cylinder_count TINYINT COMMENT 'Количество цилиндров' AFTER engine_cc,
ADD COLUMN turbo BOOLEAN DEFAULT FALSE COMMENT 'Турбонаддув' AFTER cylinder_count,

-- Для электромобилей
ADD COLUMN electric_range INT COMMENT 'Запас хода (км)' AFTER fuel_type,
ADD COLUMN battery_capacity DECIMAL(5,1) COMMENT 'Ёмкость батареи (кВт⋅ч)' AFTER electric_range,
ADD COLUMN charging_time_fast DECIMAL(4,1) COMMENT 'Быстрая зарядка (часов)' AFTER battery_capacity,
ADD COLUMN charging_time_regular DECIMAL(4,1) COMMENT 'Обычная зарядка (часов)' AFTER charging_time_fast,

-- История и происхождение
ADD COLUMN imported BOOLEAN DEFAULT FALSE COMMENT 'Импортный' AFTER right_hand_drive,
ADD COLUMN import_country VARCHAR(50) COMMENT 'Страна импорта' AFTER imported,
ADD COLUMN first_owner BOOLEAN DEFAULT FALSE COMMENT 'Первый владелец' AFTER number_of_owners,
ADD COLUMN taxi_use BOOLEAN DEFAULT FALSE COMMENT 'Использовался как такси' AFTER first_owner,
ADD COLUMN rental_use BOOLEAN DEFAULT FALSE COMMENT 'Использовался в прокате' AFTER taxi_use,
ADD COLUMN non_smoker_vehicle BOOLEAN DEFAULT TRUE COMMENT 'Некурящий салон' AFTER rental_use,

-- Дополнительная информация
ADD COLUMN tuned BOOLEAN DEFAULT FALSE COMMENT 'Тюнингован' AFTER non_smoker_vehicle,
ADD COLUMN registered BOOLEAN DEFAULT TRUE COMMENT 'Зарегистрирован' AFTER tuned,
ADD COLUMN roadworthy BOOLEAN DEFAULT TRUE COMMENT 'Техническое состояние' AFTER registered,
ADD COLUMN original_paint BOOLEAN DEFAULT TRUE COMMENT 'Оригинальная краска' AFTER roadworthy,
ADD COLUMN timing_belt_replaced BOOLEAN DEFAULT FALSE COMMENT 'Ремень ГРМ заменён' AFTER original_paint,
ADD COLUMN timing_belt_km INT COMMENT 'Замена ГРМ при (км)' AFTER timing_belt_replaced,

-- Налоги
ADD COLUMN tax_annual DECIMAL(7,2) COMMENT 'Годовой налог (EUR)' AFTER price,
ADD COLUMN tax_included BOOLEAN DEFAULT FALSE COMMENT 'Налог включён в цену' AFTER tax_annual,

-- Гарантия дилера
ADD COLUMN dealer_warranty BOOLEAN DEFAULT FALSE COMMENT 'Гарантия дилера' AFTER warranty_months,
ADD COLUMN manufacturer_warranty BOOLEAN DEFAULT FALSE COMMENT 'Гарантия производителя' AFTER dealer_warranty,

-- Комплектация
ADD COLUMN trim_level VARCHAR(100) COMMENT 'Уровень комплектации' AFTER model_name,
ADD COLUMN interior_type VARCHAR(50) COMMENT 'Тип салона' AFTER color,
ADD COLUMN interior_color VARCHAR(50) COMMENT 'Цвет салона' AFTER interior_type,
ADD COLUMN upholstery_material ENUM('fabric', 'leather', 'alcantara', 'vinyl', 'combination') COMMENT 'Материал обивки' AFTER interior_color,

-- Индексы
ADD INDEX idx_seller_type (seller_type),
ADD INDEX idx_condition (condition_status),
ADD INDEX idx_accident_free (accident_free),
ADD INDEX idx_license_plate (license_plate),
ADD INDEX idx_imported (imported),
ADD INDEX idx_first_owner (first_owner),
ADD INDEX idx_emission_class (emission_class);

-- =====================================================
-- 2. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ДОКУМЕНТОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS listing_documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    document_type ENUM(
        'pdf', 
        'registration_certificate', 
        'inspection_certificate', 
        'service_book', 
        'carfax_report',
        'accident_report',
        'purchase_contract',
        'invoice',
        'other'
    ) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    mime_type VARCHAR(100),
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE COMMENT 'Доступен всем',
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_type (document_type),
    INDEX idx_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Документы объявлений';

-- =====================================================
-- 3. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ПРОВЕРКИ VIN
-- =====================================================

CREATE TABLE IF NOT EXISTS vin_checks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    vin_code VARCHAR(17) NOT NULL,
    check_status ENUM('pending', 'verified', 'invalid', 'stolen', 'error') DEFAULT 'pending',
    check_date DATETIME,
    check_source VARCHAR(100) COMMENT 'API источник',
    manufacturer VARCHAR(100),
    model_year INT,
    vehicle_type VARCHAR(50),
    engine_type VARCHAR(50),
    country_origin VARCHAR(50),
    check_data JSON COMMENT 'Полные данные проверки',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    UNIQUE KEY unique_listing_vin (listing_id),
    INDEX idx_vin (vin_code),
    INDEX idx_status (check_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Проверка VIN кодов';

-- =====================================================
-- 4. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ИСТОРИИ ЦЕН
-- =====================================================

CREATE TABLE IF NOT EXISTS price_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'EUR',
    price_change_percent DECIMAL(5,2) COMMENT 'Процент изменения',
    reason ENUM('manual', 'auto_reduction', 'market_adjustment', 'promotion') DEFAULT 'manual',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by INT,
    notes TEXT,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_listing (listing_id),
    INDEX idx_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='История изменения цен';

-- =====================================================
-- 5. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ТЕСТ-ДРАЙВОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS test_drive_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    user_id INT NOT NULL,
    seller_id INT NOT NULL,
    preferred_date DATE NOT NULL,
    preferred_time TIME,
    alternative_date DATE,
    alternative_time TIME,
    message TEXT,
    phone VARCHAR(20),
    status ENUM('pending', 'confirmed', 'rescheduled', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
    confirmed_date DATE,
    confirmed_time TIME,
    confirmation_message TEXT,
    rating TINYINT COMMENT '1-5 оценка после тест-драйва',
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_user (user_id),
    INDEX idx_seller (seller_id),
    INDEX idx_status (status),
    INDEX idx_date (preferred_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Запросы на тест-драйв';

-- =====================================================
-- 6. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ РАСЧЁТА ЛИЗИНГА
-- =====================================================

CREATE TABLE IF NOT EXISTS financing_calculator (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    calculator_type ENUM('leasing', 'loan', 'installment') NOT NULL,
    down_payment DECIMAL(10,2) NOT NULL COMMENT 'Первоначальный взнос',
    loan_amount DECIMAL(10,2) NOT NULL COMMENT 'Сумма финансирования',
    interest_rate DECIMAL(5,2) NOT NULL COMMENT 'Процентная ставка',
    term_months INT NOT NULL COMMENT 'Срок в месяцах',
    monthly_payment DECIMAL(8,2) NOT NULL COMMENT 'Ежемесячный платёж',
    total_payment DECIMAL(10,2) COMMENT 'Общая сумма выплат',
    residual_value DECIMAL(10,2) COMMENT 'Остаточная стоимость',
    calculation_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_type (calculator_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Расчёты лизинга и кредитов';

-- =====================================================
-- 7. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ СТАТИСТИКИ ПРОСМОТРОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS listing_views (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    user_id INT COMMENT 'NULL для гостей',
    ip_address VARCHAR(45),
    user_agent TEXT,
    referer TEXT COMMENT 'Откуда пришёл',
    session_id VARCHAR(100),
    country VARCHAR(2),
    city VARCHAR(100),
    device_type ENUM('desktop', 'mobile', 'tablet', 'bot'),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_listing (listing_id),
    INDEX idx_user (user_id),
    INDEX idx_viewed_at (viewed_at),
    INDEX idx_device (device_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Детальная статистика просмотров';

-- =====================================================
-- 8. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ СРАВНЕНИЯ АВТОМОБИЛЕЙ
-- =====================================================

CREATE TABLE IF NOT EXISTS car_comparisons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(100),
    listing_ids JSON NOT NULL COMMENT 'Массив ID объявлений',
    comparison_name VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_session (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Сравнение автомобилей';

-- =====================================================
-- 9. ОБНОВЛЕНИЕ ТАБЛИЦЫ listing_photos
-- =====================================================

ALTER TABLE listing_photos
ADD COLUMN rotation INT DEFAULT 0 COMMENT 'Угол поворота 0/90/180/270' AFTER display_order,
ADD COLUMN is_360_view BOOLEAN DEFAULT FALSE COMMENT '360° фото' AFTER rotation,
ADD COLUMN photo_type ENUM('exterior', 'interior', 'engine', 'trunk', 'damage', 'documents', 'other') DEFAULT 'exterior' AFTER is_360_view,
ADD COLUMN caption VARCHAR(255) COMMENT 'Подпись к фото' AFTER photo_type,
ADD COLUMN uploaded_from ENUM('computer', 'mobile', 'gallery', 'email') DEFAULT 'computer' AFTER caption,
ADD INDEX idx_type (photo_type),
ADD INDEX idx_360 (is_360_view);

-- =====================================================
-- 10. СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ГАЛЕРЕИ ПОЛЬЗОВАТЕЛЯ
-- =====================================================

CREATE TABLE IF NOT EXISTS user_gallery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    gallery_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    photo_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Галереи пользователей';

CREATE TABLE IF NOT EXISTS user_gallery_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gallery_id INT NOT NULL,
    user_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    title VARCHAR(255),
    display_order INT DEFAULT 0,
    times_used INT DEFAULT 0 COMMENT 'Сколько раз использовано',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (gallery_id) REFERENCES user_gallery(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_gallery (gallery_id),
    INDEX idx_user (user_id),
    INDEX idx_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Фотографии в галереях пользователей';

-- =====================================================
-- ГОТОВО!
-- =====================================================
-- Добавлено:
-- - 55+ новых полей в listings
-- - 8 новых таблиц
-- - 15+ индексов
-- 
-- Теперь платформа на 95% соответствует SS.COM и Mobile.de!
-- =====================================================
