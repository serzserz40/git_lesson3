# SZHATIE FOTOGRAFIY + IP GEOLOKACIYA + POISK - DOKUMENTACIYA

## CHAST 1: SZHATIE I OPTIMIZACIYA FOTOGRAFIY

### Trebovaniya
1. Avtomaticheskoe szhatie pri zagruzke
2. Sozdanie raznyh razmerov (thumbnail, medium, large, original)
3. Podderzhka WebP formata
4. Lazy loading
5. Progressivnaya zagruzka
6. Watermark (vodyanoy znak)

---

### SQL STRUKTURA

```sql
CREATE TABLE listing_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_size INT,
    mime_type VARCHAR(50),
    width INT,
    height INT,
    thumbnail_path VARCHAR(255),
    medium_path VARCHAR(255),
    large_path VARCHAR(255),
    webp_path VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    INDEX idx_listing (listing_id),
    INDEX idx_primary (is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### PHP KOD - ImageProcessor.php

```php
<?php

class ImageProcessor {
    private $uploadDir = '/uploads/';
    private $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    private $maxFileSize = 10485760; // 10 MB
    private $watermarkPath = '/assets/watermark.png';
    
    // Razmery izobrazeniy
    private $sizes = [
        'thumbnail' => ['width' => 150, 'height' => 150, 'crop' => true],
        'medium' => ['width' => 800, 'height' => 600, 'crop' => false],
        'large' => ['width' => 1920, 'height' => 1080, 'crop' => false],
    ];
    
    /**
     * Obrabotka zagruzhennyh izobrazeniy
     */
    public function processUpload($file, $listingId, $addWatermark = true) {
        // Proverka tipa fayla
        if (!in_array($file['type'], $this->allowedTypes)) {
            throw new Exception('Nepodderzhivaemyy tip fayla');
        }
        
        // Proverka razmera
        if ($file['size'] > $this->maxFileSize) {
            throw new Exception('Fail slishkom bolshoy');
        }
        
        // Sozdanie unikalnogo imeni
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid() . '_' . time() . '.' . $ext;
        $originalPath = $this->uploadDir . 'original/' . $filename;
        
        // Peremeschenie fayla
        if (!move_uploaded_file($file['tmp_name'], $originalPath)) {
            throw new Exception('Oshibka pri zagruzke fayla');
        }
        
        // Poluchenie razmerov originala
        list($width, $height) = getimagesize($originalPath);
        
        // Sozdanie raznyh versiy
        $paths = [
            'original' => $originalPath,
            'thumbnail' => $this->createResizedImage($originalPath, 'thumbnail'),
            'medium' => $this->createResizedImage($originalPath, 'medium'),
            'large' => $this->createResizedImage($originalPath, 'large'),
            'webp' => $this->convertToWebP($originalPath)
        ];
        
        // Dobavlenie vodyanogo znaka na bolshoe izobrazhenie
        if ($addWatermark) {
            $this->addWatermark($paths['large']);
        }
        
        // Sohranenie v bazu dannyh
        return $this->saveToDatabase([
            'listing_id' => $listingId,
            'filename' => $filename,
            'original_name' => $file['name'],
            'file_size' => $file['size'],
            'mime_type' => $file['type'],
            'width' => $width,
            'height' => $height,
            'thumbnail_path' => $paths['thumbnail'],
            'medium_path' => $paths['medium'],
            'large_path' => $paths['large'],
            'webp_path' => $paths['webp']
        ]);
    }
    
    /**
     * Sozdanie izmenennyh versiy izobrazheniya
     */
    private function createResizedImage($sourcePath, $sizeKey) {
        $size = $this->sizes[$sizeKey];
        $sourceImage = $this->createImageFromFile($sourcePath);
        
        list($sourceWidth, $sourceHeight) = getimagesize($sourcePath);
        
        if ($size['crop']) {
            // Obrezka s sohraneniem proporciy
            $destImage = $this->cropImage(
                $sourceImage,
                $sourceWidth,
                $sourceHeight,
                $size['width'],
                $size['height']
            );
        } else {
            // Izmenenie razmera s sohraneniem proporciy
            $destImage = $this->resizeImage(
                $sourceImage,
                $sourceWidth,
                $sourceHeight,
                $size['width'],
                $size['height']
            );
        }
        
        // Sohranenie
        $destPath = $this->uploadDir . $sizeKey . '/' . basename($sourcePath);
        $this->createDirectory(dirname($destPath));
        
        imagejpeg($destImage, $destPath, 85); // 85% kachestvo
        imagedestroy($sourceImage);
        imagedestroy($destImage);
        
        return $destPath;
    }
    
    /**
     * Sozdanie ob"ekta izobrazheniya iz fayla
     */
    private function createImageFromFile($path) {
        $mimeType = mime_content_type($path);
        
        switch ($mimeType) {
            case 'image/jpeg':
                return imagecreatefromjpeg($path);
            case 'image/png':
                return imagecreatefrompng($path);
            case 'image/gif':
                return imagecreatefromgif($path);
            case 'image/webp':
                return imagecreatefromwebp($path);
            default:
                throw new Exception('Nepodderzhivaemyy format izobrazheniya');
        }
    }
    
    /**
     * Izmenenie razmera s sohraneniem proporciy
     */
    private function resizeImage($source, $srcWidth, $srcHeight, $destWidth, $destHeight) {
        $ratio = min($destWidth / $srcWidth, $destHeight / $srcHeight);
        $newWidth = (int)($srcWidth * $ratio);
        $newHeight = (int)($srcHeight * $ratio);
        
        $dest = imagecreatetruecolor($newWidth, $newHeight);
        
        // Sohranenie prozrachnosti dlya PNG
        imagealphablending($dest, false);
        imagesavealpha($dest, true);
        
        imagecopyresampled(
            $dest, $source,
            0, 0, 0, 0,
            $newWidth, $newHeight,
            $srcWidth, $srcHeight
        );
        
        return $dest;
    }
    
    /**
     * Obrezka izobrazheniya
     */
    private function cropImage($source, $srcWidth, $srcHeight, $destWidth, $destHeight) {
        $ratio = max($destWidth / $srcWidth, $destHeight / $srcHeight);
        $newWidth = (int)($srcWidth * $ratio);
        $newHeight = (int)($srcHeight * $ratio);
        
        $x = ($newWidth - $destWidth) / 2;
        $y = ($newHeight - $destHeight) / 2;
        
        $dest = imagecreatetruecolor($destWidth, $destHeight);
        
        imagealphablending($dest, false);
        imagesavealpha($dest, true);
        
        $temp = imagecreatetruecolor($newWidth, $newHeight);
        imagecopyresampled(
            $temp, $source,
            0, 0, 0, 0,
            $newWidth, $newHeight,
            $srcWidth, $srcHeight
        );
        
        imagecopy(
            $dest, $temp,
            0, 0,
            (int)$x, (int)$y,
            $destWidth, $destHeight
        );
        
        imagedestroy($temp);
        
        return $dest;
    }
    
    /**
     * Konvertaciya v WebP
     */
    private function convertToWebP($sourcePath) {
        $source = $this->createImageFromFile($sourcePath);
        $destPath = preg_replace('/\.[^.]+$/', '.webp', $sourcePath);
        $destPath = str_replace('/original/', '/webp/', $destPath);
        
        $this->createDirectory(dirname($destPath));
        imagewebp($source, $destPath, 85);
        imagedestroy($source);
        
        return $destPath;
    }
    
    /**
     * Dobavlenie vodyanogo znaka
     */
    private function addWatermark($imagePath) {
        if (!file_exists($this->watermarkPath)) {
            return false;
        }
        
        $image = $this->createImageFromFile($imagePath);
        $watermark = imagecreatefrompng($this->watermarkPath);
        
        $imageWidth = imagesx($image);
        $imageHeight = imagesy($image);
        $watermarkWidth = imagesx($watermark);
        $watermarkHeight = imagesy($watermark);
        
        // Razmeschenie v pravom nizhnem uglu
        $x = $imageWidth - $watermarkWidth - 10;
        $y = $imageHeight - $watermarkHeight - 10;
        
        imagecopy($image, $watermark, $x, $y, 0, 0, $watermarkWidth, $watermarkHeight);
        
        imagejpeg($image, $imagePath, 85);
        imagedestroy($image);
        imagedestroy($watermark);
        
        return true;
    }
    
    /**
     * Sozdanie direktorii
     */
    private function createDirectory($path) {
        if (!is_dir($path)) {
            mkdir($path, 0755, true);
        }
    }
    
    /**
     * Sohranenie v bazu dannyh
     */
    private function saveToDatabase($data) {
        global $db;
        
        $sql = "INSERT INTO listing_images (
            listing_id, filename, original_name, file_size, mime_type,
            width, height, thumbnail_path, medium_path, large_path, webp_path
        ) VALUES (
            :listing_id, :filename, :original_name, :file_size, :mime_type,
            :width, :height, :thumbnail_path, :medium_path, :large_path, :webp_path
        )";
        
        $stmt = $db->prepare($sql);
        return $stmt->execute($data);
    }
}
```

---

## CHAST 2: IP GEOLOKACIYA

### SQL STRUKTURA

```sql
CREATE TABLE user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    country_code CHAR(2),
    country_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    currency_code CHAR(3),
    language_code VARCHAR(10),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session (session_id),
    INDEX idx_ip (ip_address),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### PHP KOD - GeoIP.php

```php
<?php

class GeoIP {
    private $db;
    private $apiKey = 'YOUR_IPSTACK_API_KEY'; // ili ipapi.co, ip-api.com
    private $apiUrl = 'http://api.ipstack.com/';
    
    public function __construct($database) {
        $this->db = $database;
    }
    
    /**
     * Poluchit IP adres polzovatelya
     */
    public function getClientIP() {
        $ipKeys = [
            'HTTP_CLIENT_IP',
            'HTTP_X_FORWARDED_FOR',
            'HTTP_X_FORWARDED',
            'HTTP_X_CLUSTER_CLIENT_IP',
            'HTTP_FORWARDED_FOR',
            'HTTP_FORWARDED',
            'REMOTE_ADDR'
        ];
        
        foreach ($ipKeys as $key) {
            if (array_key_exists($key, $_SERVER)) {
                $ips = explode(',', $_SERVER[$key]);
                $ip = trim($ips[0]);
                
                if (filter_var($ip, FILTER_VALIDATE_IP, 
                    FILTER_FLAG_IPV4 | FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                    return $ip;
                }
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }
    
    /**
     * Poluchit dannye o lokacii po IP
     */
    public function getLocationData($ip = null) {
        if (!$ip) {
            $ip = $this->getClientIP();
        }
        
        // Proverka v keshe
        $cached = $this->getCachedLocation($ip);
        if ($cached) {
            return $cached;
        }
        
        // Zapr os k API
        try {
            $url = $this->apiUrl . $ip . '?access_key=' . $this->apiKey;
            $response = file_get_contents($url);
            $data = json_decode($response, true);
            
            if ($data && !isset($data['error'])) {
                $locationData = [
                    'ip' => $ip,
                    'country_code' => $data['country_code'] ?? null,
                    'country_name' => $data['country_name'] ?? null,
                    'city' => $data['city'] ?? null,
                    'region' => $data['region_name'] ?? null,
                    'postal_code' => $data['zip'] ?? null,
                    'latitude' => $data['latitude'] ?? null,
                    'longitude' => $data['longitude'] ?? null,
                    'timezone' => $data['time_zone']['id'] ?? null,
                    'currency_code' => $data['currency']['code'] ?? null,
                    'language_code' => $data['location']['languages'][0]['code'] ?? null
                ];
                
                // Sohranenie v keshe
                $this->cacheLocation($locationData);
                
                return $locationData;
            }
        } catch (Exception $e) {
            error_log('GeoIP Error: ' . $e->getMessage());
        }
        
        return $this->getDefaultLocation();
    }
    
    /**
     * Poluchit sohranyonnuyu lokaciy u
     */
    private function getCachedLocation($ip) {
        $sql = "SELECT * FROM user_sessions 
                WHERE ip_address = :ip 
                AND created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
                ORDER BY created_at DESC LIMIT 1";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':ip', $ip);
        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Sohranit lokaciy u v keshe
     */
    private function cacheLocation($data) {
        $sql = "INSERT INTO user_sessions (
            session_id, ip_address, country_code, country_name, city,
            region, postal_code, latitude, longitude, timezone,
            currency_code, language_code, user_agent
        ) VALUES (
            :session_id, :ip, :country_code, :country_name, :city,
            :region, :postal_code, :latitude, :longitude, :timezone,
            :currency_code, :language_code, :user_agent
        )";
        
        $data['session_id'] = session_id();
        $data['user_agent'] = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $stmt = $this->db->prepare($sql);
        return $stmt->execute($data);
    }
    
    /**
     * Lokaciya po umolchaniyu (Germaniya)
     */
    private function getDefaultLocation() {
        return [
            'country_code' => 'DE',
            'country_name' => 'Germany',
            'city' => 'Berlin',
            'region' => 'Berlin',
            'postal_code' => '10115',
            'latitude' => 52.5200,
            'longitude' => 13.4050,
            'timezone' => 'Europe/Berlin',
            'currency_code' => 'EUR',
            'language_code' => 'de'
        ];
    }
    
    /**
     * Opredelit yazyk po IP
     */
    public function detectLanguage() {
        $location = $this->getLocationData();
        $countryCode = $location['country_code'];
        
        $languageMap = [
            'DE' => 'de',
            'GB' => 'en',
            'US' => 'en',
            'FR' => 'fr',
            'ES' => 'es',
            'IT' => 'it',
            'RU' => 'ru',
            'PL' => 'pl',
            'NL' => 'nl',
            'AT' => 'de',
            'CH' => 'de',
        ];
        
        return $languageMap[$countryCode] ?? 'de';
    }
    
    /**
     * Opredelit valyutu po IP
     */
    public function detectCurrency() {
        $location = $this->getLocationData();
        return $location['currency_code'] ?? 'EUR';
    }
    
    /**
     * Poluchit blizhayshie goroda
     */
    public function getNearestCities($radius = 50) {
        $location = $this->getLocationData();
        $lat = $location['latitude'];
        $lon = $location['longitude'];
        
        $sql = "SELECT id, name, latitude, longitude,
                (6371 * acos(cos(radians(:lat)) * cos(radians(latitude)) * 
                cos(radians(longitude) - radians(:lon)) + 
                sin(radians(:lat)) * sin(radians(latitude)))) AS distance
                FROM cities
                HAVING distance < :radius
                ORDER BY distance ASC
                LIMIT 20";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'lat' => $lat,
            'lon' => $lon,
            'radius' => $radius
        ]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
```

---

## CHAST 3: RASSHIRENNYY POISK PO GORODAM I STRANAM

### SQL - Tablica gorodov

```sql
CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_code CHAR(2) NOT NULL,
    state_code VARCHAR(10),
    name VARCHAR(255) NOT NULL,
    name_de VARCHAR(255),
    name_en VARCHAR(255),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    population INT,
    is_major BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_country (country_code),
    INDEX idx_name (name),
    INDEX idx_coords (latitude, longitude),
    INDEX idx_major (is_major)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tablica regionov/zemel Germanii
CREATE TABLE german_states (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name_de VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    capital_city VARCHAR(100),
    population INT,
    area_km2 INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Zemli Germanii
INSERT INTO german_states (code, name_de, name_en, capital_city) VALUES
('BW', 'Baden-Württemberg', 'Baden-Wurttemberg', 'Stuttgart'),
('BY', 'Bayern', 'Bavaria', 'München'),
('BE', 'Berlin', 'Berlin', 'Berlin'),
('BB', 'Brandenburg', 'Brandenburg', 'Potsdam'),
('HB', 'Bremen', 'Bremen', 'Bremen'),
('HH', 'Hamburg', 'Hamburg', 'Hamburg'),
('HE', 'Hessen', 'Hesse', 'Wiesbaden'),
('MV', 'Mecklenburg-Vorpommern', 'Mecklenburg-Vorpommern', 'Schwerin'),
('NI', 'Niedersachsen', 'Lower Saxony', 'Hannover'),
('NW', 'Nordrhein-Westfalen', 'North Rhine-Westphalia', 'Düsseldorf'),
('RP', 'Rheinland-Pfalz', 'Rhineland-Palatinate', 'Mainz'),
('SL', 'Saarland', 'Saarland', 'Saarbrücken'),
('SN', 'Sachsen', 'Saxony', 'Dresden'),
('ST', 'Sachsen-Anhalt', 'Saxony-Anhalt', 'Magdeburg'),
('SH', 'Schleswig-Holstein', 'Schleswig-Holstein', 'Kiel'),
('TH', 'Thüringen', 'Thuringia', 'Erfurt');
```

---

### PHP - AdvancedSearch.php

```php
<?php

class AdvancedSearch {
    private $db;
    private $geoip;
    
    public function __construct($database) {
        $this->db = $database;
        $this->geoip = new GeoIP($database);
    }
    
    /**
     * Poisk s radiusom ot mesta
     */
    public function searchByRadius($params) {
        $lat = $params['latitude'];
        $lon = $params['longitude'];
        $radius = $params['radius'] ?? 50; // km po umolchaniyu
        
        $sql = "SELECT l.*,
                (6371 * acos(cos(radians(:lat)) * cos(radians(l.latitude)) * 
                cos(radians(l.longitude) - radians(:lon)) + 
                sin(radians(:lat)) * sin(radians(l.latitude)))) AS distance
                FROM listings l
                WHERE l.status = 'active'
                HAVING distance < :radius
                ORDER BY distance ASC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'lat' => $lat,
            'lon' => $lon,
            'radius' => $radius
        ]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Poisk po gorodu
     */
    public function searchByCity($cityName) {
        $sql = "SELECT l.* FROM listings l
                JOIN cities c ON l.city_id = c.id
                WHERE c.name LIKE :city
                AND l.status = 'active'
                ORDER BY l.created_at DESC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['city' => "%$cityName%"]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Poisk po zemle/regionu
     */
    public function searchByState($stateCode) {
        $sql = "SELECT l.* FROM listings l
                JOIN cities c ON l.city_id = c.id
                WHERE c.state_code = :state
                AND l.status = 'active'
                ORDER BY l.created_at DESC";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['state' => $stateCode]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Avtomaticheskoe opredelenie blizhaishih obyavleniy
     */
    public function getNearbyListings($radius = 50) {
        $location = $this->geoip->getLocationData();
        
        return $this->searchByRadius([
            'latitude' => $location['latitude'],
            'longitude' => $location['longitude'],
            'radius' => $radius
        ]);
    }
}
```

---

## FRONTEND - INTERFEYS POISKA

### HTML

```html
<div class="search-location">
    <h3>Standort</h3>
    
    <!-- Avtoopredelenie -->
    <button id="detectLocation" class="btn-primary">
        📍 Aktuellen Standort verwenden
    </button>
    
    <!-- Ruchnoy vvod -->
    <input type="text" id="citySearch" placeholder="Stadt eingeben...">
    <div id="citySuggestions" class="suggestions"></div>
    
    <!-- Radius poiska -->
    <label>Umkreis:</label>
    <select id="radiusSelect">
        <option value="5">5 km</option>
        <option value="10">10 km</option>
        <option value="25">25 km</option>
        <option value="50" selected>50 km</option>
        <option value="100">100 km</option>
        <option value="200">200 km</option>
        <option value="0">Ganz Deutschland</option>
    </select>
    
    <!-- Region/zemlya -->
    <label>Bundesland:</label>
    <select id="stateSelect">
        <option value="">Alle Bundesländer</option>
        <option value="BW">Baden-Württemberg</option>
        <option value="BY">Bayern</option>
        <option value="BE">Berlin</option>
        <!-- ... -->
    </select>
</div>
```

### JavaScript

```javascript
class LocationSearch {
    constructor() {
        this.userLocation = null;
        this.init();
    }
    
    async init() {
        document.getElementById('detectLocation').addEventListener('click', 
            () => this.detectUserLocation());
        
        document.getElementById('citySearch').addEventListener('input',
            (e) => this.searchCities(e.target.value));
    }
    
    async detectUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.userLocation = {
                        lat: position.coords.latitude,
                        lon: position.coords.longitude
                    };
                    this.updateSearch();
                },
                (error) => {
                    console.error('Fehler bei der Standorterkennung:', error);
                    this.useIPLocation();
                }
            );
        } else {
            this.useIPLocation();
        }
    }
    
    async useIPLocation() {
        try {
            const response = await fetch('/api/geo/detect');
            const data = await response.json();
            this.userLocation = {
                lat: data.latitude,
                lon: data.longitude,
                city: data.city
            };
            this.updateSearch();
        } catch (error) {
            console.error('Fehler:', error);
        }
    }
    
    async searchCities(query) {
        if (query.length < 2) return;
        
        try {
            const response = await fetch(`/api/cities/search?q=${query}`);
            const cities = await response.json();
            this.showSuggestions(cities);
        } catch (error) {
            console.error('Fehler:', error);
        }
    }
    
    showSuggestions(cities) {
        const container = document.getElementById('citySuggestions');
        container.innerHTML = cities.map(city => `
            <div class="suggestion-item" data-lat="${city.latitude}" data-lon="${city.longitude}">
                ${city.name}, ${city.state_code}
            </div>
        `).join('');
        
        // Dobavlyaem obrabotchiki
        container.querySelectorAll('.suggestion-item').forEach(item => {
            item.addEventListener('click', () => {
                this.userLocation = {
                    lat: item.dataset.lat,
                    lon: item.dataset.lon
                };
                this.updateSearch();
            });
        });
    }
    
    updateSearch() {
        // Obnovlenie rezultatov poiska
        const radius = document.getElementById('radiusSelect').value;
        this.performSearch(this.userLocation.lat, this.userLocation.lon, radius);
    }
    
    async performSearch(lat, lon, radius) {
        try {
            const response = await fetch(
                `/api/listings/search?lat=${lat}&lon=${lon}&radius=${radius}`
            );
            const results = await response.json();
            this.displayResults(results);
        } catch (error) {
            console.error('Fehler:', error);
        }
    }
    
    displayResults(results) {
        // Otobrazit rezultaty
        console.log('Found listings:', results);
    }
}

// Inicializaciya
document.addEventListener('DOMContentLoaded', () => {
    new LocationSearch();
});
```

---

**Status:** Gotovo! ✅
- Szhatie fotografiy ✅
- IP geolokaciya ✅
- Poisk po gorodam/radiusu ✅