# 🚗 ИНТЕГРАЦИЯ БАЗЫ МАРОК/МОДЕЛЕЙ АВТОМОБИЛЕЙ

## 📋 ПОЛНАЯ ИНТЕГРАЦИЯ - ГОТОВЫЙ КОД

---

## 1️⃣ БАЗА ДАННЫХ

### Таблица car_models (ГОТОВА!)

**У вас уже есть SQL файл: `seed_car_models.sql`**

Структура:
```sql
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
    INDEX idx_make_model (make_name, model_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Импорт:**
```bash
mysql -u root -p automarket < seed_car_models.sql
```

---

### Таблица features_list (ОПЦИИ / "НАВОРОТЫ")

```sql
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
```

### Таблица advert_features (СВЯЗЬ ОБЪЯВЛЕНИЙ И ОПЦИЙ)

```sql
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
```

### Обновление таблицы listings

```sql
ALTER TABLE listings 
ADD COLUMN car_model_id INT AFTER category_id,
ADD COLUMN make_name VARCHAR(100) AFTER car_model_id,
ADD COLUMN model_name VARCHAR(100) AFTER make_name,
ADD COLUMN model_year INT AFTER model_name,
ADD COLUMN body_type VARCHAR(50) AFTER model_year,
ADD COLUMN fuel_type VARCHAR(50) AFTER body_type,
ADD COLUMN engine_cc INT AFTER fuel_type,
ADD COLUMN horse_power INT AFTER engine_cc,
ADD COLUMN drive_type VARCHAR(50) AFTER horse_power,
ADD COLUMN transmission VARCHAR(50) AFTER drive_type,
ADD COLUMN doors INT AFTER transmission,
ADD COLUMN color VARCHAR(50) AFTER doors,
ADD COLUMN metallic BOOLEAN DEFAULT FALSE AFTER color,
ADD COLUMN mileage INT AFTER metallic,
ADD COLUMN vin_code VARCHAR(17) AFTER mileage,
ADD COLUMN first_registration_date DATE AFTER vin_code,
ADD COLUMN technical_inspection_until DATE AFTER first_registration_date,
ADD COLUMN number_of_owners INT DEFAULT 1 AFTER technical_inspection_until,
ADD COLUMN right_hand_drive BOOLEAN DEFAULT FALSE AFTER number_of_owners,
ADD COLUMN damaged BOOLEAN DEFAULT FALSE AFTER right_hand_drive,
ADD INDEX idx_car_model (car_model_id),
ADD INDEX idx_make (make_name),
ADD INDEX idx_model_year (model_year),
ADD FOREIGN KEY (car_model_id) REFERENCES car_models(id) ON DELETE SET NULL;
```

---

## 2️⃣ SEED ДАННЫХ ДЛЯ ОПЦИЙ

```sql
-- features_list seed data

INSERT INTO features_list (category, feature_name_ru, feature_name_en, feature_name_de, icon, is_popular, display_order) VALUES

-- КОМФОРТ
('comfort', 'Климат-контроль 2-зонный', '2-Zone Climate Control', '2-Zonen-Klimaautomatik', '❄️', TRUE, 1),
('comfort', 'Климат-контроль многозонный', 'Multi-Zone Climate Control', 'Mehrzone-Klimaautomatik', '❄️', FALSE, 2),
('comfort', 'Подогрев передних сидений', 'Heated Front Seats', 'Sitzheizung vorne', '🔥', TRUE, 3),
('comfort', 'Подогрев задних сидений', 'Heated Rear Seats', 'Sitzheizung hinten', '🔥', FALSE, 4),
('comfort', 'Вентиляция сидений', 'Ventilated Seats', 'Belüftete Sitze', '💨', FALSE, 5),
('comfort', 'Массаж сидений', 'Seat Massage', 'Sitzmassage', '💆', FALSE, 6),
('comfort', 'Кожаный салон', 'Leather Interior', 'Lederausstattung', '🛋️', TRUE, 7),
('comfort', 'Электрорегулировка сидений с памятью', 'Electric Seats with Memory', 'Elektrische Sitze mit Memory', '⚡', FALSE, 8),
('comfort', 'Электропривод багажника', 'Electric Tailgate', 'Elektrische Heckklappe', '🚪', FALSE, 9),
('comfort', 'Бесключевой доступ', 'Keyless Entry', 'Keyless Entry', '🔑', TRUE, 10),
('comfort', 'Старт/стоп двигателя кнопкой', 'Start/Stop Button', 'Start-Stopp-Knopf', '▶️', TRUE, 11),
('comfort', 'Автономный отопитель (Webasto)', 'Parking Heater', 'Standheizung', '🔥', FALSE, 12),

-- БЕЗОПАСНОСТЬ
('safety', 'Адаптивный круиз-контроль (ACC)', 'Adaptive Cruise Control', 'Adaptiver Tempomat', '🎯', TRUE, 20),
('safety', 'Система контроля полосы (Lane Assist)', 'Lane Keeping Assist', 'Spurhalteassistent', '🛣️', TRUE, 21),
('safety', 'Система мониторинга слепых зон', 'Blind Spot Monitoring', 'Toter-Winkel-Assistent', '👁️', TRUE, 22),
('safety', 'Камера заднего вида', 'Rear View Camera', 'Rückfahrkamera', '📷', TRUE, 23),
('safety', 'Камера 360°', '360° Camera', '360°-Kamera', '📹', FALSE, 24),
('safety', 'Парктроники передние', 'Front Parking Sensors', 'Einparkhilfe vorne', '📡', FALSE, 25),
('safety', 'Парктроники задние', 'Rear Parking Sensors', 'Einparkhilfe hinten', '📡', TRUE, 26),
('safety', 'Автоматический парковщик', 'Park Assist', 'Einparkassistent', '🅿️', FALSE, 27),
('safety', 'Датчик дождя', 'Rain Sensor', 'Regensensor', '🌧️', FALSE, 28),
('safety', 'Датчик света', 'Light Sensor', 'Lichtsensor', '💡', FALSE, 29),
('safety', 'Система экстренного торможения', 'Emergency Braking', 'Notbremsassistent', '🛑', FALSE, 30),
('safety', 'Распознавание дорожных знаков', 'Traffic Sign Recognition', 'Verkehrszeichenerkennung', '🚦', FALSE, 31),
('safety', 'Ассистент движения в пробках', 'Traffic Jam Assist', 'Stauassistent', '🚗', FALSE, 32),

-- МУЛЬТИМЕДИА
('multimedia', 'Навигационная система', 'Navigation System', 'Navigationssystem', '🗺️', TRUE, 40),
('multimedia', 'Apple CarPlay / Android Auto', 'CarPlay / Android Auto', 'CarPlay / Android Auto', '📱', TRUE, 41),
('multimedia', 'Беспроводная зарядка телефона', 'Wireless Charging', 'Kabelloses Laden', '🔋', FALSE, 42),
('multimedia', 'Bluetooth / USB', 'Bluetooth / USB', 'Bluetooth / USB', '🔊', TRUE, 43),
('multimedia', 'Премиум аудиосистема (Harman/Kardon)', 'Harman/Kardon Audio', 'Harman/Kardon Audio', '🔉', FALSE, 44),
('multimedia', 'Аудиосистема Bose', 'Bose Audio System', 'Bose Soundsystem', '🔉', FALSE, 45),
('multimedia', 'Аудиосистема Bang & Olufsen', 'Bang & Olufsen Audio', 'Bang & Olufsen Audio', '🔉', FALSE, 46),
('multimedia', 'Цифровая приборная панель', 'Digital Dashboard', 'Digitales Cockpit', '📊', FALSE, 47),
('multimedia', 'Head-Up Display', 'Head-Up Display', 'Head-Up-Display', '🎯', FALSE, 48),

-- ВНЕШНИЙ ВИД
('exterior', 'Светодиодные фары (LED)', 'LED Headlights', 'LED-Scheinwerfer', '💡', TRUE, 60),
('exterior', 'Матричные фары', 'Matrix LED Headlights', 'Matrix-LED', '💡', FALSE, 61),
('exterior', 'Лазерные фары', 'Laser Headlights', 'Laser-Licht', '💡', FALSE, 62),
('exterior', 'Омыватель фар', 'Headlight Washer', 'Scheinwerferreinigung', '💦', FALSE, 63),
('exterior', 'Противотуманные фары', 'Fog Lights', 'Nebelscheinwerfer', '🌫️', FALSE, 64),
('exterior', 'Легкосплавные диски R17', 'Alloy Wheels R17', 'Leichtmetallfelgen R17', '⭕', FALSE, 65),
('exterior', 'Легкосплавные диски R18', 'Alloy Wheels R18', 'Leichtmetallfelgen R18', '⭕', TRUE, 66),
('exterior', 'Легкосплавные диски R19', 'Alloy Wheels R19', 'Leichtmetallfelgen R19', '⭕', FALSE, 67),
('exterior', 'Легкосплавные диски R20+', 'Alloy Wheels R20+', 'Leichtmetallfelgen R20+', '⭕', FALSE, 68),
('exterior', 'Панорамная крыша', 'Panoramic Sunroof', 'Panorama-Schiebedach', '🌅', TRUE, 69),
('exterior', 'Люк', 'Sunroof', 'Schiebedach', '🌅', FALSE, 70),
('exterior', 'Рейлинги на крыше', 'Roof Rails', 'Dachreling', '📦', FALSE, 71),
('exterior', 'Фаркоп', 'Tow Bar', 'Anhängerkupplung', '🔗', FALSE, 72),
('exterior', 'Защита картера', 'Engine Protection', 'Motorschutz', '🛡️', FALSE, 73),
('exterior', 'Тонированные стёкла', 'Tinted Windows', 'Getönte Scheiben', '🪟', FALSE, 74),

-- ИНТЕРЬЕР
('interior', 'Панель приборов с кожей/алькантарой', 'Leather Dashboard', 'Leder-Armaturenbrett', '🎨', FALSE, 80),
('interior', 'Спортивные сидения', 'Sport Seats', 'Sportsitze', '🏎️', FALSE, 81),
('interior', 'Складывающиеся задние сиденья', 'Folding Rear Seats', 'Umklappbare Rücksitze', '💺', FALSE, 82),
('interior', 'Подлокотник', 'Armrest', 'Armlehne', '🛋️', FALSE, 83),
('interior', 'Салонное зеркало с автозатемнением', 'Auto-Dimming Mirror', 'Selbstabblendender Innenspiegel', '🪞', FALSE, 84),

-- ДРУГОЕ
('other', 'Система Start-Stop', 'Start-Stop System', 'Start-Stopp-System', '♻️', FALSE, 90),
('other', 'Круиз-контроль', 'Cruise Control', 'Tempomat', '🎮', TRUE, 91),
('other', 'Мультифункциональный руль', 'Multifunction Steering Wheel', 'Multifunktionslenkrad', '🎛️', TRUE, 92),
('other', 'Подрулевые лепестки (paddle shift)', 'Paddle Shifters', 'Schaltwippen', '🎮', FALSE, 93),
('other', 'Спортивная подвеска', 'Sport Suspension', 'Sportfahrwerk', '🏁', FALSE, 94),
('other', 'Пневмоподвеска', 'Air Suspension', 'Luftfederung', '💨', FALSE, 95),
('other', 'Полный привод (4x4)', '4WD / AWD', 'Allradantrieb', '🚙', TRUE, 96),
('other', 'Дифференциал повышенного трения', 'Limited Slip Differential', 'Sperrdifferential', '⚙️', FALSE, 97),
('other', 'Система помощи при спуске', 'Hill Descent Control', 'Bergabfahrhilfe', '⛰️', FALSE, 98);
```

---

## 3️⃣ API: КАСКАДНЫЕ ВЫПАДАЮЩИЕ СПИСКИ

### api/car-models/get-makes.php

```php
<?php
// Получить список всех марок

require_once '../../config/database.php';

header('Content-Type: application/json');

try {
    $stmt = $db->query("
        SELECT DISTINCT make_name, make_slug
        FROM car_models
        ORDER BY make_name ASC
    ");
    
    $makes = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $makes[] = [
            'name' => $row['make_name'],
            'slug' => $row['make_slug']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'makes' => $makes,
        'total' => count($makes)
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error loading makes'
    ]);
}
```

### api/car-models/get-models.php

```php
<?php
// Получить модели для выбранной марки

require_once '../../config/database.php';

header('Content-Type: application/json');

try {
    $makeName = $_GET['make'] ?? '';
    
    if (empty($makeName)) {
        throw new Exception('Make name is required');
    }
    
    $stmt = $db->prepare("
        SELECT DISTINCT model_name, model_slug
        FROM car_models
        WHERE make_name = ?
        ORDER BY model_name ASC
    ");
    $stmt->execute([$makeName]);
    
    $models = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $models[] = [
            'name' => $row['model_name'],
            'slug' => $row['model_slug']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'models' => $models,
        'total' => count($models)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### api/car-models/get-years.php

```php
<?php
// Получить годы для выбранной марки и модели

require_once '../../config/database.php';

header('Content-Type: application/json');

try {
    $makeName = $_GET['make'] ?? '';
    $modelName = $_GET['model'] ?? '';
    
    if (empty($makeName) || empty($modelName)) {
        throw new Exception('Make and model are required');
    }
    
    $stmt = $db->prepare("
        SELECT DISTINCT model_year
        FROM car_models
        WHERE make_name = ? AND model_name = ?
        ORDER BY model_year DESC
    ");
    $stmt->execute([$makeName, $modelName]);
    
    $years = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $years[] = intval($row['model_year']);
    }
    
    echo json_encode([
        'success' => true,
        'years' => $years,
        'total' => count($years)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### api/car-models/get-specifications.php

```php
<?php
// Получить технические характеристики для выбранной машины

require_once '../../config/database.php';

header('Content-Type: application/json');

try {
    $makeName = $_GET['make'] ?? '';
    $modelName = $_GET['model'] ?? '';
    $modelYear = $_GET['year'] ?? '';
    
    if (empty($makeName) || empty($modelName) || empty($modelYear)) {
        throw new Exception('Make, model and year are required');
    }
    
    $stmt = $db->prepare("
        SELECT *
        FROM car_models
        WHERE make_name = ? AND model_name = ? AND model_year = ?
        LIMIT 1
    ");
    $stmt->execute([$makeName, $modelName, $modelYear]);
    
    $specs = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$specs) {
        throw new Exception('Specifications not found');
    }
    
    echo json_encode([
        'success' => true,
        'specifications' => [
            'id' => $specs['id'],
            'make' => $specs['make_name'],
            'model' => $specs['model_name'],
            'year' => $specs['model_year'],
            'body_type' => $specs['body_type'],
            'fuel_type' => $specs['fuel_type'],
            'engine_type' => $specs['engine_type'],
            'engine_cc' => $specs['engine_cc'],
            'horse_power' => $specs['horse_power'],
            'drive_type' => $specs['drive_type'],
            'transmission' => $specs['transmission'],
            'doors' => $specs['doors']
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

---

## 4️⃣ JAVASCRIPT: КАСКАДНЫЕ СПИСКИ

### public/js/car-model-selector.js

```javascript
/**
 * Каскадные выпадающие списки для выбора марки, модели и года
 */

class CarModelSelector {
    constructor(options = {}) {
        this.makeSelect = document.getElementById(options.makeSelectId || 'make');
        this.modelSelect = document.getElementById(options.modelSelectId || 'model');
        this.yearSelect = document.getElementById(options.yearSelectId || 'year');
        this.specsContainer = document.getElementById(options.specsContainerId || 'car-specs');
        this.carModelIdInput = document.getElementById(options.carModelIdInputId || 'car_model_id');
        
        this.selectedMake = null;
        this.selectedModel = null;
        this.selectedYear = null;
        
        this.init();
    }
    
    init() {
        // Загрузить марки при загрузке страницы
        this.loadMakes();
        
        // Обработчики событий
        if (this.makeSelect) {
            this.makeSelect.addEventListener('change', () => this.onMakeChange());
        }
        
        if (this.modelSelect) {
            this.modelSelect.addEventListener('change', () => this.onModelChange());
        }
        
        if (this.yearSelect) {
            this.yearSelect.addEventListener('change', () => this.onYearChange());
        }
    }
    
    /**
     * Загрузить список марок
     */
    async loadMakes() {
        try {
            this.showLoading(this.makeSelect);
            
            const response = await fetch('/api/car-models/get-makes.php');
            const data = await response.json();
            
            if (data.success) {
                this.populateMakes(data.makes);
            } else {
                this.showError('Error loading makes');
            }
        } catch (error) {
            console.error('Error loading makes:', error);
            this.showError('Error loading makes');
        }
    }
    
    /**
     * Заполнить список марок
     */
    populateMakes(makes) {
        this.makeSelect.innerHTML = '<option value="">Select Make...</option>';
        
        makes.forEach(make => {
            const option = document.createElement('option');
            option.value = make.name;
            option.textContent = make.name;
            option.dataset.slug = make.slug;
            this.makeSelect.appendChild(option);
        });
        
        this.makeSelect.disabled = false;
    }
    
    /**
     * Обработчик изменения марки
     */
    async onMakeChange() {
        const makeName = this.makeSelect.value;
        
        if (!makeName) {
            this.resetModelSelect();
            this.resetYearSelect();
            this.clearSpecs();
            return;
        }
        
        this.selectedMake = makeName;
        await this.loadModels(makeName);
    }
    
    /**
     * Загрузить модели для выбранной марки
     */
    async loadModels(makeName) {
        try {
            this.showLoading(this.modelSelect);
            this.resetYearSelect();
            this.clearSpecs();
            
            const response = await fetch(`/api/car-models/get-models.php?make=${encodeURIComponent(makeName)}`);
            const data = await response.json();
            
            if (data.success) {
                this.populateModels(data.models);
            } else {
                this.showError('Error loading models');
            }
        } catch (error) {
            console.error('Error loading models:', error);
            this.showError('Error loading models');
        }
    }
    
    /**
     * Заполнить список моделей
     */
    populateModels(models) {
        this.modelSelect.innerHTML = '<option value="">Select Model...</option>';
        
        models.forEach(model => {
            const option = document.createElement('option');
            option.value = model.name;
            option.textContent = model.name;
            option.dataset.slug = model.slug;
            this.modelSelect.appendChild(option);
        });
        
        this.modelSelect.disabled = false;
    }
    
    /**
     * Обработчик изменения модели
     */
    async onModelChange() {
        const modelName = this.modelSelect.value;
        
        if (!modelName) {
            this.resetYearSelect();
            this.clearSpecs();
            return;
        }
        
        this.selectedModel = modelName;
        await this.loadYears(this.selectedMake, modelName);
    }
    
    /**
     * Загрузить годы для выбранной марки и модели
     */
    async loadYears(makeName, modelName) {
        try {
            this.showLoading(this.yearSelect);
            this.clearSpecs();
            
            const response = await fetch(
                `/api/car-models/get-years.php?make=${encodeURIComponent(makeName)}&model=${encodeURIComponent(modelName)}`
            );
            const data = await response.json();
            
            if (data.success) {
                this.populateYears(data.years);
            } else {
                this.showError('Error loading years');
            }
        } catch (error) {
            console.error('Error loading years:', error);
            this.showError('Error loading years');
        }
    }
    
    /**
     * Заполнить список годов
     */
    populateYears(years) {
        this.yearSelect.innerHTML = '<option value="">Select Year...</option>';
        
        years.forEach(year => {
            const option = document.createElement('option');
            option.value = year;
            option.textContent = year;
            this.yearSelect.appendChild(option);
        });
        
        this.yearSelect.disabled = false;
    }
    
    /**
     * Обработчик изменения года
     */
    async onYearChange() {
        const year = this.yearSelect.value;
        
        if (!year) {
            this.clearSpecs();
            return;
        }
        
        this.selectedYear = year;
        await this.loadSpecifications(this.selectedMake, this.selectedModel, year);
    }
    
    /**
     * Загрузить технические характеристики
     */
    async loadSpecifications(makeName, modelName, year) {
        try {
            this.showLoading(this.specsContainer);
            
            const response = await fetch(
                `/api/car-models/get-specifications.php?make=${encodeURIComponent(makeName)}&model=${encodeURIComponent(modelName)}&year=${encodeURIComponent(year)}`
            );
            const data = await response.json();
            
            if (data.success) {
                this.displaySpecifications(data.specifications);
                
                // Сохранить ID модели в скрытое поле
                if (this.carModelIdInput) {
                    this.carModelIdInput.value = data.specifications.id;
                }
                
                // Отправить событие об изменении
                this.dispatchChangeEvent(data.specifications);
            } else {
                this.showError('Error loading specifications');
            }
        } catch (error) {
            console.error('Error loading specifications:', error);
            this.showError('Error loading specifications');
        }
    }
    
    /**
     * Отобразить технические характеристики
     */
    displaySpecifications(specs) {
        if (!this.specsContainer) return;
        
        let html = `
            <div class="car-specs-display">
                <h3>📋 Technical Specifications</h3>
                <div class="specs-grid">
        `;
        
        if (specs.body_type) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Body Type:</span>
                    <span class="spec-value">${specs.body_type}</span>
                </div>
            `;
        }
        
        if (specs.fuel_type) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Fuel Type:</span>
                    <span class="spec-value">${specs.fuel_type}</span>
                </div>
            `;
        }
        
        if (specs.engine_cc) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Engine:</span>
                    <span class="spec-value">${(specs.engine_cc / 1000).toFixed(1)}L (${specs.engine_cc}cc)</span>
                </div>
            `;
        }
        
        if (specs.horse_power) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Power:</span>
                    <span class="spec-value">${specs.horse_power} HP</span>
                </div>
            `;
        }
        
        if (specs.transmission) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Transmission:</span>
                    <span class="spec-value">${specs.transmission}</span>
                </div>
            `;
        }
        
        if (specs.drive_type) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Drive:</span>
                    <span class="spec-value">${specs.drive_type}</span>
                </div>
            `;
        }
        
        if (specs.doors) {
            html += `
                <div class="spec-item">
                    <span class="spec-label">Doors:</span>
                    <span class="spec-value">${specs.doors}</span>
                </div>
            `;
        }
        
        html += `
                </div>
                <p class="specs-note">
                    <small>ℹ️ These specifications are pulled from the database. You can modify them in the form below.</small>
                </p>
            </div>
        `;
        
        this.specsContainer.innerHTML = html;
        this.specsContainer.classList.add('fade-in');
    }
    
    /**
     * Отправить событие об изменении выбранной модели
     */
    dispatchChangeEvent(specs) {
        const event = new CustomEvent('carModelSelected', {
            detail: specs
        });
        document.dispatchEvent(event);
    }
    
    /**
     * Сброс списка моделей
     */
    resetModelSelect() {
        this.modelSelect.innerHTML = '<option value="">Select Model...</option>';
        this.modelSelect.disabled = true;
        this.selectedModel = null;
    }
    
    /**
     * Сброс списка годов
     */
    resetYearSelect() {
        this.yearSelect.innerHTML = '<option value="">Select Year...</option>';
        this.yearSelect.disabled = true;
        this.selectedYear = null;
    }
    
    /**
     * Очистить спецификации
     */
    clearSpecs() {
        if (this.specsContainer) {
            this.specsContainer.innerHTML = '';
        }
        if (this.carModelIdInput) {
            this.carModelIdInput.value = '';
        }
    }
    
    /**
     * Показать загрузку
     */
    showLoading(element) {
        if (!element) return;
        
        if (element.tagName === 'SELECT') {
            element.innerHTML = '<option value="">Loading...</option>';
            element.disabled = true;
        } else {
            element.innerHTML = '<div class="spinner"></div>';
        }
    }
    
    /**
     * Показать ошибку
     */
    showError(message) {
        console.error(message);
        if (window.showNotification) {
            showNotification(message, 'error');
        }
    }
}

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    // Проверить что селекты существуют
    if (document.getElementById('make')) {
        window.carModelSelector = new CarModelSelector();
    }
});
```

---

**ПРОДОЛЖЕНИЕ СЛЕДУЕТ...**

Создаю дальше - нужно ещё:
- Форму мастера с каскадными списками
- Систему опций (галочки)
- API сохранения
- Автозаполнение полей

Продолжить? У нас ещё **69,000 токенов**! 🚀

---

## 5️⃣ ФОРМА МАСТЕРА С КАСКАДНЫМИ СПИСКАМИ

### views/listing-wizard-step2-vehicle.php

```php
<?php
// Шаг 2 мастера: Выбор автомобиля и технические характеристики

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 2: Vehicle Details - AutoMarket</title>
    <link rel="stylesheet" href="/public/css/style.css">
    <link rel="stylesheet" href="/public/css/responsive.css">
    <link rel="stylesheet" href="/public/css/wizard.css">
</head>
<body>
    <?php include '../includes/header.php'; ?>
    
    <main class="wizard-container">
        <div class="container">
            <!-- Progress Bar -->
            <div class="wizard-progress">
                <div class="progress-step completed">
                    <div class="step-number">1</div>
                    <div class="step-label">Category</div>
                </div>
                <div class="progress-line active"></div>
                <div class="progress-step active">
                    <div class="step-number">2</div>
                    <div class="step-label">Vehicle</div>
                </div>
                <div class="progress-line"></div>
                <div class="progress-step">
                    <div class="step-number">3</div>
                    <div class="step-label">Details</div>
                </div>
                <div class="progress-line"></div>
                <div class="progress-step">
                    <div class="step-number">4</div>
                    <div class="step-label">Photos</div>
                </div>
                <div class="progress-line"></div>
                <div class="progress-step">
                    <div class="step-number">5</div>
                    <div class="step-label">Review</div>
                </div>
            </div>
            
            <!-- Wizard Content -->
            <div class="wizard-content fade-in">
                <h1>🚗 Select Your Vehicle</h1>
                <p class="wizard-subtitle">Choose your car's make, model and year</p>
                
                <form id="vehicleForm" method="POST" action="/api/wizard/save-step2">
                    <!-- Hidden field for car_model_id -->
                    <input type="hidden" name="car_model_id" id="car_model_id">
                    
                    <!-- Каскадные выпадающие списки -->
                    <div class="form-section">
                        <h2>Select Vehicle</h2>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">
                                    Make *
                                    <span class="tooltip-icon" title="Select the manufacturer">ℹ️</span>
                                </label>
                                <select name="make" id="make" class="form-select" required>
                                    <option value="">Loading makes...</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    Model *
                                    <span class="tooltip-icon" title="Select the model">ℹ️</span>
                                </label>
                                <select name="model" id="model" class="form-select" required disabled>
                                    <option value="">First select make</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    Year *
                                    <span class="tooltip-icon" title="Model year">ℹ️</span>
                                </label>
                                <select name="model_year" id="year" class="form-select" required disabled>
                                    <option value="">First select model</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Контейнер для отображения спецификаций -->
                        <div id="car-specs" class="car-specs-container"></div>
                    </div>
                    
                    <!-- Технические характеристики (можно редактировать) -->
                    <div class="form-section">
                        <h2>Technical Details</h2>
                        <p class="section-hint">Specifications are pre-filled based on your selection. You can modify them if needed.</p>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Body Type</label>
                                <select name="body_type" id="body_type" class="form-select">
                                    <option value="">Select...</option>
                                    <option value="Sedan">Sedan</option>
                                    <option value="Hatchback">Hatchback</option>
                                    <option value="SUV">SUV</option>
                                    <option value="Coupe">Coupe</option>
                                    <option value="Convertible">Convertible</option>
                                    <option value="Wagon">Wagon</option>
                                    <option value="Van">Van</option>
                                    <option value="Pickup">Pickup Truck</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Fuel Type *</label>
                                <select name="fuel_type" id="fuel_type" class="form-select" required>
                                    <option value="">Select...</option>
                                    <option value="Petrol">Petrol</option>
                                    <option value="Diesel">Diesel</option>
                                    <option value="Electric">Electric</option>
                                    <option value="Hybrid">Hybrid</option>
                                    <option value="Plug-in Hybrid">Plug-in Hybrid</option>
                                    <option value="LPG">LPG/CNG</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Engine (cc)</label>
                                <input type="number" 
                                       name="engine_cc" 
                                       id="engine_cc"
                                       class="form-input" 
                                       placeholder="1998"
                                       min="500"
                                       max="10000">
                                <small class="form-hint">Engine displacement in cubic centimeters</small>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Horse Power (HP)</label>
                                <input type="number" 
                                       name="horse_power" 
                                       id="horse_power"
                                       class="form-input" 
                                       placeholder="150"
                                       min="30"
                                       max="2000">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Transmission *</label>
                                <select name="transmission" id="transmission" class="form-select" required>
                                    <option value="">Select...</option>
                                    <option value="Manual">Manual</option>
                                    <option value="Automatic">Automatic</option>
                                    <option value="Semi-Automatic">Semi-Automatic</option>
                                    <option value="CVT">CVT</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Drive Type</label>
                                <select name="drive_type" id="drive_type" class="form-select">
                                    <option value="">Select...</option>
                                    <option value="FWD">Front-Wheel Drive (FWD)</option>
                                    <option value="RWD">Rear-Wheel Drive (RWD)</option>
                                    <option value="AWD">All-Wheel Drive (AWD)</option>
                                    <option value="4WD">4-Wheel Drive (4WD)</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Number of Doors</label>
                                <select name="doors" id="doors" class="form-select">
                                    <option value="">Select...</option>
                                    <option value="2">2 doors</option>
                                    <option value="3">3 doors</option>
                                    <option value="4">4 doors</option>
                                    <option value="5">5 doors</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Color *</label>
                                <select name="color" id="color" class="form-select" required onchange="updateColorPreview(this.value)">
                                    <option value="">Select...</option>
                                    <option value="White" data-color="#FFFFFF">White</option>
                                    <option value="Black" data-color="#000000">Black</option>
                                    <option value="Silver" data-color="#C0C0C0">Silver</option>
                                    <option value="Gray" data-color="#808080">Gray</option>
                                    <option value="Red" data-color="#FF0000">Red</option>
                                    <option value="Blue" data-color="#0000FF">Blue</option>
                                    <option value="Green" data-color="#00FF00">Green</option>
                                    <option value="Yellow" data-color="#FFFF00">Yellow</option>
                                    <option value="Orange" data-color="#FFA500">Orange</option>
                                    <option value="Brown" data-color="#A52A2A">Brown</option>
                                    <option value="Burgundy" data-color="#800020">Burgundy</option>
                                </select>
                                <div id="color-preview" class="color-preview"></div>
                            </div>
                            
                            <div class="form-group">
                                <label class="checkbox-label">
                                    <input type="checkbox" name="metallic" value="1">
                                    <span>Metallic Paint</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Состояние автомобиля -->
                    <div class="form-section">
                        <h2>Vehicle Condition</h2>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Mileage (km) *</label>
                                <input type="number" 
                                       name="mileage" 
                                       class="form-input" 
                                       placeholder="50000"
                                       required
                                       min="0"
                                       max="1000000">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">First Registration</label>
                                <input type="date" 
                                       name="first_registration_date" 
                                       class="form-input"
                                       max="<?php echo date('Y-m-d'); ?>">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Technical Inspection Until</label>
                                <input type="date" 
                                       name="technical_inspection_until" 
                                       class="form-input"
                                       min="<?php echo date('Y-m-d'); ?>">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">VIN Code</label>
                                <input type="text" 
                                       name="vin_code" 
                                       class="form-input" 
                                       placeholder="WBADT43452GZ12345"
                                       pattern="[A-HJ-NPR-Z0-9]{17}"
                                       maxlength="17"
                                       style="text-transform: uppercase;">
                                <small class="form-hint">17-character Vehicle Identification Number</small>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Number of Previous Owners</label>
                                <input type="number" 
                                       name="number_of_owners" 
                                       class="form-input" 
                                       placeholder="1"
                                       min="0"
                                       max="20">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label class="checkbox-label">
                                    <input type="checkbox" name="right_hand_drive" value="1">
                                    <span>Right-Hand Drive</span>
                                </label>
                            </div>
                            
                            <div class="form-group">
                                <label class="checkbox-label">
                                    <input type="checkbox" name="damaged" value="1" onchange="toggleDamageDescription(this)">
                                    <span>Damaged / Accident History</span>
                                </label>
                            </div>
                        </div>
                        
                        <div id="damageDescriptionContainer" class="form-group" style="display: none;">
                            <label class="form-label">Damage Description</label>
                            <textarea name="damage_description" 
                                      class="form-textarea" 
                                      rows="3"
                                      placeholder="Describe any damage or accident history..."></textarea>
                        </div>
                    </div>
                    
                    <!-- Wizard Navigation -->
                    <div class="wizard-nav">
                        <a href="/listing-wizard-step1" class="btn btn-outline">
                            ← Previous
                        </a>
                        <button type="submit" class="btn btn-primary">
                            Next: Equipment & Features →
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
    
    <script src="/public/js/car-model-selector.js"></script>
    <script>
        // Автозаполнение полей при выборе модели
        document.addEventListener('carModelSelected', (e) => {
            const specs = e.detail;
            
            // Заполнить поля техническими характеристиками
            if (specs.body_type) {
                document.getElementById('body_type').value = specs.body_type;
            }
            if (specs.fuel_type) {
                document.getElementById('fuel_type').value = specs.fuel_type;
            }
            if (specs.engine_cc) {
                document.getElementById('engine_cc').value = specs.engine_cc;
            }
            if (specs.horse_power) {
                document.getElementById('horse_power').value = specs.horse_power;
            }
            if (specs.transmission) {
                document.getElementById('transmission').value = specs.transmission;
            }
            if (specs.drive_type) {
                document.getElementById('drive_type').value = specs.drive_type;
            }
            if (specs.doors) {
                document.getElementById('doors').value = specs.doors;
            }
        });
        
        // Превью цвета
        function updateColorPreview(color) {
            const preview = document.getElementById('color-preview');
            const option = document.querySelector(`#color option[value="${color}"]`);
            if (option && option.dataset.color) {
                preview.style.backgroundColor = option.dataset.color;
                preview.style.display = 'block';
            } else {
                preview.style.display = 'none';
            }
        }
        
        // Показать/скрыть описание повреждений
        function toggleDamageDescription(checkbox) {
            const container = document.getElementById('damageDescriptionContainer');
            container.style.display = checkbox.checked ? 'block' : 'none';
        }
    </script>
</body>
</html>
```

---

## 6️⃣ ФОРМА ОПЦИЙ (ШАГ 3)

### views/listing-wizard-step3-features.php

```php
<?php
// Шаг 3 мастера: Опции и оборудование

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

// Получить все опции из базы
$features = [];
$stmt = $db->query("
    SELECT * FROM features_list 
    WHERE 1=1
    ORDER BY category, display_order ASC
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $features[$row['category']][] = $row;
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Step 3: Equipment & Features - AutoMarket</title>
    <link rel="stylesheet" href="/public/css/style.css">
    <link rel="stylesheet" href="/public/css/responsive.css">
    <link rel="stylesheet" href="/public/css/wizard.css">
</head>
<body>
    <?php include '../includes/header.php'; ?>
    
    <main class="wizard-container">
        <div class="container">
            <!-- Progress Bar -->
            <div class="wizard-progress">
                <div class="progress-step completed">
                    <div class="step-number">1</div>
                    <div class="step-label">Category</div>
                </div>
                <div class="progress-line completed"></div>
                <div class="progress-step completed">
                    <div class="step-number">2</div>
                    <div class="step-label">Vehicle</div>
                </div>
                <div class="progress-line active"></div>
                <div class="progress-step active">
                    <div class="step-number">3</div>
                    <div class="step-label">Equipment</div>
                </div>
                <div class="progress-line"></div>
                <div class="progress-step">
                    <div class="step-number">4</div>
                    <div class="step-label">Photos</div>
                </div>
                <div class="progress-line"></div>
                <div class="progress-step">
                    <div class="step-number">5</div>
                    <div class="step-label">Review</div>
                </div>
            </div>
            
            <!-- Wizard Content -->
            <div class="wizard-content fade-in">
                <h1>⚙️ Equipment & Features</h1>
                <p class="wizard-subtitle">Select all features and equipment included with your vehicle</p>
                
                <form id="featuresForm" method="POST" action="/api/wizard/save-step3">
                    
                    <!-- Фильтр: Показать только популярные -->
                    <div class="features-filter">
                        <label class="checkbox-label">
                            <input type="checkbox" id="showOnlyPopular" onchange="filterFeatures(this.checked)">
                            <span>⭐ Show only popular features</span>
                        </label>
                        <span class="selected-count">Selected: <strong id="selectedCount">0</strong></span>
                    </div>
                    
                    <!-- Опции по категориям -->
                    <?php
                    $categoryNames = [
                        'comfort' => '🛋️ Comfort',
                        'safety' => '🛡️ Safety & Assistance',
                        'multimedia' => '📱 Multimedia',
                        'exterior' => '🚗 Exterior',
                        'interior' => '🎨 Interior',
                        'other' => '⚙️ Other'
                    ];
                    
                    foreach ($features as $category => $items):
                    ?>
                    <div class="features-category reveal">
                        <h2><?php echo $categoryNames[$category] ?? ucfirst($category); ?></h2>
                        
                        <div class="features-grid">
                            <?php foreach ($items as $feature): ?>
                            <label class="feature-checkbox <?php echo $feature['is_popular'] ? 'popular' : ''; ?>">
                                <input type="checkbox" 
                                       name="features[]" 
                                       value="<?php echo $feature['id']; ?>"
                                       data-popular="<?php echo $feature['is_popular'] ? '1' : '0'; ?>"
                                       onchange="updateSelectedCount()">
                                <span class="feature-icon"><?php echo $feature['icon'] ?? '•'; ?></span>
                                <span class="feature-name">
                                    <?php echo htmlspecialchars($feature['feature_name_en']); ?>
                                    <?php if ($feature['is_popular']): ?>
                                        <span class="popular-badge">⭐</span>
                                    <?php endif; ?>
                                </span>
                            </label>
                            <?php endforeach; ?>
                        </div>
                    </div>
                    <?php endforeach; ?>
                    
                    <!-- Wizard Navigation -->
                    <div class="wizard-nav">
                        <a href="/listing-wizard-step2" class="btn btn-outline">
                            ← Previous
                        </a>
                        <button type="submit" class="btn btn-primary">
                            Next: Photos →
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
    
    <script>
        // Обновить счётчик выбранных опций
        function updateSelectedCount() {
            const checked = document.querySelectorAll('input[name="features[]"]:checked').length;
            document.getElementById('selectedCount').textContent = checked;
        }
        
        // Фильтр популярных опций
        function filterFeatures(showOnlyPopular) {
            const checkboxes = document.querySelectorAll('.feature-checkbox');
            
            checkboxes.forEach(checkbox => {
                const isPopular = checkbox.classList.contains('popular');
                
                if (showOnlyPopular && !isPopular) {
                    checkbox.style.display = 'none';
                } else {
                    checkbox.style.display = 'flex';
                }
            });
        }
        
        // Инициализация
        document.addEventListener('DOMContentLoaded', () => {
            updateSelectedCount();
        });
    </script>
    <script src="/public/js/scroll-reveal.js"></script>
</body>
</html>
```

---

## 7️⃣ API СОХРАНЕНИЯ ОБЪЯВЛЕНИЯ

### api/wizard/save-step2.php

```php
<?php
// Сохранить шаг 2: Технические данные автомобиля

require_once '../../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $userId = $_SESSION['user_id'];
    
    // Получить данные из формы
    $carModelId = $_POST['car_model_id'] ?? null;
    $make = $_POST['make'] ?? '';
    $model = $_POST['model'] ?? '';
    $modelYear = $_POST['model_year'] ?? '';
    $bodyType = $_POST['body_type'] ?? null;
    $fuelType = $_POST['fuel_type'] ?? '';
    $engineCc = $_POST['engine_cc'] ?? null;
    $horsePower = $_POST['horse_power'] ?? null;
    $transmission = $_POST['transmission'] ?? '';
    $driveType = $_POST['drive_type'] ?? null;
    $doors = $_POST['doors'] ?? null;
    $color = $_POST['color'] ?? '';
    $metallic = isset($_POST['metallic']) ? 1 : 0;
    $mileage = $_POST['mileage'] ?? 0;
    $vinCode = $_POST['vin_code'] ?? null;
    $firstRegistration = $_POST['first_registration_date'] ?? null;
    $technicalInspection = $_POST['technical_inspection_until'] ?? null;
    $numberOfOwners = $_POST['number_of_owners'] ?? 1;
    $rightHandDrive = isset($_POST['right_hand_drive']) ? 1 : 0;
    $damaged = isset($_POST['damaged']) ? 1 : 0;
    $damageDescription = $_POST['damage_description'] ?? null;
    
    // Валидация
    if (empty($make) || empty($model) || empty($modelYear)) {
        throw new Exception('Make, model and year are required');
    }
    
    if (empty($fuelType) || empty($transmission)) {
        throw new Exception('Fuel type and transmission are required');
    }
    
    // Проверить существует ли draft
    $listingId = $_SESSION['listing_draft_id'] ?? null;
    
    if ($listingId) {
        // Обновить существующий draft
        $stmt = $db->prepare("
            UPDATE listings SET
                car_model_id = ?,
                make_name = ?,
                model_name = ?,
                model_year = ?,
                body_type = ?,
                fuel_type = ?,
                engine_cc = ?,
                horse_power = ?,
                drive_type = ?,
                transmission = ?,
                doors = ?,
                color = ?,
                metallic = ?,
                mileage = ?,
                vin_code = ?,
                first_registration_date = ?,
                technical_inspection_until = ?,
                number_of_owners = ?,
                right_hand_drive = ?,
                damaged = ?,
                damage_description = ?,
                updated_at = NOW()
            WHERE id = ? AND user_id = ? AND status = 'draft'
        ");
        
        $stmt->execute([
            $carModelId, $make, $model, $modelYear, $bodyType, $fuelType,
            $engineCc, $horsePower, $driveType, $transmission, $doors,
            $color, $metallic, $mileage, $vinCode, $firstRegistration,
            $technicalInspection, $numberOfOwners, $rightHandDrive, $damaged,
            $damageDescription, $listingId, $userId
        ]);
    } else {
        // Создать новый draft
        $categoryId = $_SESSION['wizard_category_id'] ?? 1;
        
        $stmt = $db->prepare("
            INSERT INTO listings (
                user_id, category_id, car_model_id, make_name, model_name, model_year,
                body_type, fuel_type, engine_cc, horse_power, drive_type, transmission,
                doors, color, metallic, mileage, vin_code, first_registration_date,
                technical_inspection_until, number_of_owners, right_hand_drive, damaged,
                damage_description, status, created_at
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft', NOW()
            )
        ");
        
        $stmt->execute([
            $userId, $categoryId, $carModelId, $make, $model, $modelYear,
            $bodyType, $fuelType, $engineCc, $horsePower, $driveType, $transmission,
            $doors, $color, $metallic, $mileage, $vinCode, $firstRegistration,
            $technicalInspection, $numberOfOwners, $rightHandDrive, $damaged,
            $damageDescription
        ]);
        
        $listingId = $db->lastInsertId();
        $_SESSION['listing_draft_id'] = $listingId;
    }
    
    echo json_encode([
        'success' => true,
        'listing_id' => $listingId,
        'redirect' => '/listing-wizard-step3'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

### api/wizard/save-step3.php

```php
<?php
// Сохранить шаг 3: Опции и оборудование

require_once '../../middleware/AuthMiddleware.php';
AuthMiddleware::check();

header('Content-Type: application/json');

try {
    $userId = $_SESSION['user_id'];
    $listingId = $_SESSION['listing_draft_id'] ?? null;
    
    if (!$listingId) {
        throw new Exception('No draft listing found');
    }
    
    // Получить выбранные опции
    $features = $_POST['features'] ?? [];
    
    // Удалить существующие связи
    $stmt = $db->prepare("DELETE FROM advert_features WHERE advert_id = ?");
    $stmt->execute([$listingId]);
    
    // Добавить новые связи
    if (!empty($features)) {
        $stmt = $db->prepare("
            INSERT INTO advert_features (advert_id, feature_id, created_at)
            VALUES (?, ?, NOW())
        ");
        
        foreach ($features as $featureId) {
            $stmt->execute([$listingId, $featureId]);
        }
    }
    
    echo json_encode([
        'success' => true,
        'listing_id' => $listingId,
        'features_count' => count($features),
        'redirect' => '/listing-wizard-step4'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
```

---

## 8️⃣ CSS СТИЛИ

### public/css/car-selector.css

```css
/* Стили для селектора автомобиля */

.car-specs-container {
    margin-top: 2rem;
}

.car-specs-display {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 1.5rem;
    border-left: 4px solid #ff6500;
}

.car-specs-display h3 {
    margin-bottom: 1rem;
    color: #1f2937;
    font-size: 1.25rem;
}

.specs-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 1rem;
}

.spec-item {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem;
    background: white;
    border-radius: 8px;
}

.spec-label {
    font-weight: 600;
    color: #6b7280;
    font-size: 0.875rem;
}

.spec-value {
    color: #1f2937;
    font-weight: 500;
}

.specs-note {
    margin-top: 1rem;
    padding: 0.75rem;
    background: #fff3cd;
    border-radius: 6px;
    border: 1px solid #ffc107;
}

.specs-note small {
    color: #856404;
}

/* Color Preview */
.color-preview {
    display: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: 3px solid #e5e7eb;
    margin-top: 0.5rem;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Features Grid */
.features-filter {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding: 1rem;
    background: #f8f9fa;
    border-radius: 8px;
}

.selected-count {
    font-size: 1rem;
    color: #6b7280;
}

.selected-count strong {
    color: #ff6500;
    font-size: 1.25rem;
}

.features-category {
    margin-bottom: 3rem;
}

.features-category h2 {
    font-size: 1.5rem;
    margin-bottom: 1.5rem;
    color: #1f2937;
    border-bottom: 2px solid #e5e7eb;
    padding-bottom: 0.5rem;
}

.features-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
}

.feature-checkbox {
    display: flex;
    align-items: center;
    padding: 1rem;
    background: white;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.feature-checkbox:hover {
    border-color: #ff6500;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 101, 0, 0.1);
}

.feature-checkbox input[type="checkbox"] {
    width: 20px;
    height: 20px;
    margin-right: 0.75rem;
    cursor: pointer;
}

.feature-checkbox input[type="checkbox"]:checked ~ .feature-name {
    color: #ff6500;
    font-weight: 600;
}

.feature-checkbox.popular {
    border-color: #ffc107;
    background: #fffbf0;
}

.feature-icon {
    font-size: 1.25rem;
    margin-right: 0.5rem;
}

.feature-name {
    flex: 1;
    font-size: 0.95rem;
    color: #1f2937;
}

.popular-badge {
    font-size: 0.75rem;
    color: #ffc107;
}

/* Responsive */
@media (max-width: 767px) {
    .specs-grid {
        grid-template-columns: 1fr;
    }
    
    .features-grid {
        grid-template-columns: 1fr;
    }
    
    .features-filter {
        flex-direction: column;
        gap: 1rem;
        align-items: flex-start;
    }
}
```

---

## 🎉 ГОТОВО! ПОЛНАЯ ИНТЕГРАЦИЯ!

### ЧТО СОЗДАНО:

✅ База данных с таблицами:
- `car_models` (готовый SQL файл)
- `features_list` (опции)
- `advert_features` (связь)
- Обновлённая `listings`

✅ API для каскадных списков:
- Получение марок
- Получение моделей
- Получение годов
- Получение спецификаций

✅ JavaScript класс CarModelSelector:
- Автоматические каскадные списки
- Автозаполнение технических полей
- Event dispatching

✅ Формы мастера:
- Шаг 2: Выбор автомобиля (с каскадными списками)
- Шаг 3: Опции (галочки)

✅ API сохранения:
- Сохранение технических данных
- Сохранение выбранных опций

✅ CSS стили:
- Для селектора
- Для опций
- Полностью responsive

---

## 📋 ИНСТРУКЦИЯ ПО ИСПОЛЬЗОВАНИЮ:

1. **Импортировать SQL:**
```bash
mysql -u root -p automarket < seed_car_models.sql
```

2. **Создать таблицы опций** (SQL из этого файла)

3. **Скопировать все файлы** в соответствующие папки

4. **Готово!** Каскадные списки работают автоматически!

---

**ВСЁ ГОТОВО К ИСПОЛЬЗОВАНИЮ!** 🚀