-- =====================================================
-- AUTOMARKT.DE - COMPLETE DATABASE SCHEMA
-- Сайт объявлений б/у автомобилей для Германии
-- =====================================================
-- Version: 2.0
-- Date: 2025-11-15
-- Description: Complete database schema with all tables
-- Market: Germany / Europe
-- Currency: EUR (€)
-- =====================================================

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS automarkt 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE automarkt;

-- =====================================================
-- ТАБЛИЦА: users (Пользователи)
-- =====================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT FALSE,
    avatar VARCHAR(255),
    user_type ENUM('individual', 'dealer', 'admin') DEFAULT 'individual',
    status ENUM('active', 'suspended', 'banned') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_user_type (user_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: categories (Категории)
-- =====================================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT,
    name_en VARCHAR(255) NOT NULL,
    name_ru VARCHAR(255),
    name_de VARCHAR(255),
    name_lv VARCHAR(255),
    slug VARCHAR(255) NOT NULL UNIQUE,
    icon VARCHAR(100),
    description_en TEXT,
    level INT DEFAULT 1,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    requires_vehicle_info BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_parent (parent_id),
    INDEX idx_slug (slug),
    INDEX idx_level (level),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: car_models (Модели автомобилей)
-- =====================================================
CREATE TABLE car_models (
    id INT AUTO_INCREMENT PRIMARY KEY,
    make_name VARCHAR(100) NOT NULL,
    make_slug VARCHAR(100) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    model_slug VARCHAR(100) NOT NULL,
    model_year INT NOT NULL,
    vehicle_type VARCHAR(50),
    body_type VARCHAR(50),
    fuel_type VARCHAR(50),
    engine_type VARCHAR(50),
    engine_cc INT,
    horse_power INT,
    drive_type VARCHAR(50),
    transmission VARCHAR(50),
    doors INT,
    source VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_make (make_name),
    INDEX idx_model (model_name),
    INDEX idx_year (model_year),
    INDEX idx_make_model (make_name, model_name),
    INDEX idx_make_model_year (make_name, model_name, model_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ПРИМЕЧАНИЕ: Данные для car_models импортируются из seed_car_models.sql
-- 38,806 записей!

-- =====================================================
-- ТАБЛИЦА: features_list (Опции оборудования)
-- =====================================================
CREATE TABLE features_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category ENUM('comfort', 'safety', 'multimedia', 'exterior', 'interior', 'other') NOT NULL,
    feature_name_ru VARCHAR(255) NOT NULL,
    feature_name_en VARCHAR(255) NOT NULL,
    feature_name_de VARCHAR(255),
    feature_name_lv VARCHAR(255),
    icon VARCHAR(100),
    is_popular BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_popular (is_popular)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: listings (Объявления)
-- =====================================================
CREATE TABLE listings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    
    -- Vehicle Information
    car_model_id INT,
    make_name VARCHAR(100),
    model_name VARCHAR(100),
    model_year INT,
    body_type VARCHAR(50),
    fuel_type VARCHAR(50),
    engine_cc INT,
    horse_power INT,
    drive_type VARCHAR(50),
    transmission VARCHAR(50),
    doors INT,
    color VARCHAR(50),
    metallic BOOLEAN DEFAULT FALSE,
    mileage INT,
    vin_code VARCHAR(17),
    first_registration_date DATE,
    technical_inspection_until DATE,
    number_of_owners INT DEFAULT 1,
    right_hand_drive BOOLEAN DEFAULT FALSE,
    damaged BOOLEAN DEFAULT FALSE,
    damage_description TEXT,
    
    -- Listing Details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'EUR',
    price_negotiable BOOLEAN DEFAULT FALSE,
    
    -- Location
    location_country VARCHAR(100) DEFAULT 'Germany',
    location_city VARCHAR(100),
    location_postcode VARCHAR(20),
    location_address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Status & Visibility
    status ENUM('draft', 'pending', 'active', 'sold', 'expired', 'removed') DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    is_urgent BOOLEAN DEFAULT FALSE,
    is_top BOOLEAN DEFAULT FALSE,
    
    -- Payment & Pricing
    featured_until DATETIME,
    top_until DATETIME,
    urgent_until DATETIME,
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    
    -- Statistics
    view_count INT DEFAULT 0,
    contact_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    
    -- Timestamps
    published_at DATETIME,
    expires_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (car_model_id) REFERENCES car_models(id) ON DELETE SET NULL,
    
    INDEX idx_user (user_id),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_price (price),
    INDEX idx_location (location_city, location_postcode),
    INDEX idx_make_model (make_name, model_name),
    INDEX idx_created (created_at),
    INDEX idx_expires (expires_at),
    FULLTEXT INDEX ft_search (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: advert_features (Связь объявлений и опций)
-- =====================================================
CREATE TABLE advert_features (
    id INT AUTO_INCREMENT PRIMARY KEY,
    advert_id INT NOT NULL,
    feature_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (advert_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (feature_id) REFERENCES features_list(id) ON DELETE CASCADE,
    UNIQUE KEY unique_advert_feature (advert_id, feature_id),
    INDEX idx_advert (advert_id),
    INDEX idx_feature (feature_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: listing_photos (Фотографии объявлений)
-- =====================================================
CREATE TABLE listing_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: messages (Сообщения между пользователями)
-- =====================================================
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: transactions (Платежи)
-- =====================================================
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    listing_id INT,
    transaction_type ENUM('listing_fee', 'featured', 'top', 'urgent', 'refund') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'EUR',
    payment_method ENUM('stripe', 'paypal', 'bank_transfer', 'gocardless') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_id VARCHAR(255),
    payment_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_listing (listing_id),
    INDEX idx_status (payment_status),
    INDEX idx_type (transaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- АУКЦИОН УДАЛЁН - НЕ ТРЕБУЕТСЯ
-- =====================================================

-- =====================================================
-- ТАБЛИЦА: reviews (Отзывы)
-- =====================================================
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    reviewed_user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_reviewed_user (reviewed_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: favorites (Избранное)
-- =====================================================
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

-- =====================================================
-- ТАБЛИЦА: saved_searches (Сохранённые поиски)
-- =====================================================
CREATE TABLE saved_searches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    search_name VARCHAR(255),
    search_params JSON NOT NULL,
    email_alerts BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: notifications (Уведомления)
-- =====================================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('message', 'listing_expired', 'review', 'payment', 'system') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    link VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ТАБЛИЦА: admin_logs (Логи администратора)
-- =====================================================
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    details JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_admin (admin_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ГОТОВО!
-- =====================================================
-- Следующие шаги:
-- 1. Импортировать seed_car_models.sql (38,806 записей)
-- 2. Импортировать seed_features_list.sql (98+ опций)
-- 3. Добавить базовые категории
-- 
-- ТАБЛИЦ СОЗДАНО: 17
-- АУКЦИОН: УДАЛЁН (не требуется)
-- =====================================================
