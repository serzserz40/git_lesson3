<?php
/**
 * API для проверки VIN кода
 * Путь: api/vin/check.php
 */

require_once '../../config/database.php';
require_once '../../middleware/AuthMiddleware.php';

header('Content-Type: application/json');

// Проверка авторизации
if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'Nicht autorisiert']);
    exit;
}

// Получение данных
$data = json_decode(file_get_contents('php://input'), true);
$vin = strtoupper(trim($data['vin'] ?? ''));

// Валидация длины VIN
if (strlen($vin) !== 17) {
    echo json_encode([
        'success' => false,
        'message' => 'VIN muss genau 17 Zeichen lang sein'
    ]);
    exit;
}

// Валидация символов (нет I, O, Q)
if (preg_match('/[IOQ]/', $vin)) {
    echo json_encode([
        'success' => false,
        'message' => 'VIN darf die Zeichen I, O und Q nicht enthalten'
    ]);
    exit;
}

// Проверка контрольной суммы VIN (для североамериканских авто)
function validateVIN($vin) {
    // Таблица весов символов
    $weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    
    // Таблица значений символов
    $values = [
        'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'F' => 6, 'G' => 7, 'H' => 8,
        'J' => 1, 'K' => 2, 'L' => 3, 'M' => 4, 'N' => 5, 'P' => 7, 'R' => 9,
        'S' => 2, 'T' => 3, 'U' => 4, 'V' => 5, 'W' => 6, 'X' => 7, 'Y' => 8, 'Z' => 9,
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
    ];
    
    $sum = 0;
    for ($i = 0; $i < 17; $i++) {
        $char = $vin[$i];
        if (!isset($values[$char])) {
            return false;
        }
        $sum += $values[$char] * $weights[$i];
    }
    
    $checkDigit = $sum % 11;
    $vinCheckDigit = $vin[8];
    
    if ($checkDigit == 10) {
        return $vinCheckDigit === 'X';
    }
    
    return $vinCheckDigit == (string)$checkDigit;
}

// Декодирование VIN
function decodeVIN($vin) {
    $decoded = [
        'manufacturer' => '',
        'country' => '',
        'vehicle_type' => '',
        'model_year' => '',
        'plant' => '',
        'serial' => substr($vin, 11, 6)
    ];
    
    // WMI (World Manufacturer Identifier) - первые 3 символа
    $wmi = substr($vin, 0, 3);
    
    // Определение производителя по WMI
    $manufacturers = [
        'WBA' => 'BMW', 'WBS' => 'BMW M', 'WBX' => 'BMW',
        'WAU' => 'Audi', 'WUA' => 'Audi Quattro',
        'WVW' => 'VW', 'WV1' => 'VW', 'WV2' => 'VW',
        'WDB' => 'Mercedes-Benz', 'WDD' => 'Mercedes-Benz', 'WDF' => 'Mercedes-Benz',
        'WP0' => 'Porsche', 'WP1' => 'Porsche',
        'VSS' => 'SEAT', 'VSX' => 'SEAT',
        'VF1' => 'Renault', 'VF3' => 'Peugeot', 'VF7' => 'Citroën',
        'ZFA' => 'Fiat', 'ZFF' => 'Ferrari', 'ZAR' => 'Alfa Romeo',
        'SAJ' => 'Jaguar', 'SAL' => 'Land Rover',
        'SCC' => 'Lotus', 'SCF' => 'Aston Martin',
        'TRU' => 'Audi Hungary', 'TMB' => 'Skoda',
        'NMT' => 'Toyota Turkey', 'NM0' => 'Ford Turkey',
        'YS3' => 'Saab', 'YV1' => 'Volvo',
        'JHM' => 'Honda', 'JT' => 'Toyota', 'JN' => 'Nissan',
        '1G' => 'General Motors USA', '1FA' => 'Ford USA',
        '1HG' => 'Honda USA', '1N' => 'Nissan USA',
        '2HG' => 'Honda Canada', '2T' => 'Toyota Canada',
        '3VW' => 'VW Mexico', '3N' => 'Nissan Mexico',
        'KMH' => 'Hyundai', 'KNA' => 'Kia',
        'LVS' => 'Ford China', 'LDC' => 'Dongfeng',
        'MAL' => 'Hyundai India', 'MEE' => 'Mitsubishi India',
        '9BW' => 'VW Brazil', '9BD' => 'Fiat Brazil'
    ];
    
    // Поиск производителя
    foreach ($manufacturers as $code => $name) {
        if (strpos($wmi, $code) === 0) {
            $decoded['manufacturer'] = $name;
            break;
        }
    }
    
    // Определение страны по первому символу
    $countryCode = $vin[0];
    $countries = [
        'W' => 'Deutschland', 'V' => 'Frankreich/Spanien',
        'Z' => 'Italien', 'S' => 'Großbritannien',
        'T' => 'Tschechien/Ungarn', 'Y' => 'Schweden/Norwegen',
        'J' => 'Japan', 'K' => 'Südkorea',
        '1' => 'USA', '2' => 'Kanada', '3' => 'Mexiko',
        '9' => 'Brasilien', 'L' => 'China', 'M' => 'Indien'
    ];
    
    $decoded['country'] = $countries[$countryCode] ?? 'Unbekannt';
    
    // Модельный год (10-й символ)
    $yearChar = $vin[9];
    $yearCodes = [
        'A' => 1980, 'B' => 1981, 'C' => 1982, 'D' => 1983, 'E' => 1984,
        'F' => 1985, 'G' => 1986, 'H' => 1987, 'J' => 1988, 'K' => 1989,
        'L' => 1990, 'M' => 1991, 'N' => 1992, 'P' => 1993, 'R' => 1994,
        'S' => 1995, 'T' => 1996, 'V' => 1997, 'W' => 1998, 'X' => 1999,
        'Y' => 2000, '1' => 2001, '2' => 2002, '3' => 2003, '4' => 2004,
        '5' => 2005, '6' => 2006, '7' => 2007, '8' => 2008, '9' => 2009,
        'A' => 2010, 'B' => 2011, 'C' => 2012, 'D' => 2013, 'E' => 2014,
        'F' => 2015, 'G' => 2016, 'H' => 2017, 'J' => 2018, 'K' => 2019,
        'L' => 2020, 'M' => 2021, 'N' => 2022, 'P' => 2023, 'R' => 2024,
        'S' => 2025
    ];
    
    if (isset($yearCodes[$yearChar])) {
        $decoded['model_year'] = $yearCodes[$yearChar];
    }
    
    return $decoded;
}

// Декодирование VIN
$vinData = decodeVIN($vin);

// Проверка в базе данных - не используется ли уже этот VIN
$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("SELECT id, title FROM listings WHERE vin_code = ? AND status != 'deleted'");
$stmt->execute([$vin]);
$existing = $stmt->fetch(PDO::FETCH_ASSOC);

if ($existing) {
    echo json_encode([
        'success' => false,
        'message' => 'Diese VIN-Nummer wurde bereits für eine andere Anzeige verwendet',
        'existing_listing' => $existing
    ]);
    exit;
}

// Попытка получить данные через внешний API (если доступен)
// Например, NHTSA API (бесплатный для США)
$externalData = null;
try {
    $nhtsaUrl = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/{$vin}?format=json";
    $response = @file_get_contents($nhtsaUrl);
    
    if ($response) {
        $nhtsaData = json_decode($response, true);
        if (isset($nhtsaData['Results'])) {
            foreach ($nhtsaData['Results'] as $item) {
                if ($item['Variable'] == 'Make' && !empty($item['Value'])) {
                    $vinData['manufacturer'] = $item['Value'];
                }
                if ($item['Variable'] == 'Model Year' && !empty($item['Value'])) {
                    $vinData['model_year'] = $item['Value'];
                }
                if ($item['Variable'] == 'Vehicle Type' && !empty($item['Value'])) {
                    $vinData['vehicle_type'] = $item['Value'];
                }
            }
            $externalData = $nhtsaData;
        }
    }
} catch (Exception $e) {
    // API недоступен, используем локальное декодирование
}

// Сохранение результата проверки в БД
$insertStmt = $db->prepare("
    INSERT INTO vin_checks 
    (listing_id, vin_code, check_status, check_date, check_source, manufacturer, model_year, check_data)
    VALUES (0, ?, 'verified', NOW(), 'manual', ?, ?, ?)
");

$insertStmt->execute([
    $vin,
    $vinData['manufacturer'],
    $vinData['model_year'],
    json_encode([
        'decoded' => $vinData,
        'external' => $externalData,
        'validation' => validateVIN($vin)
    ])
]);

// Ответ
echo json_encode([
    'success' => true,
    'message' => 'VIN erfolgreich geprüft',
    'vin' => $vin,
    'manufacturer' => $vinData['manufacturer'],
    'model_year' => $vinData['model_year'],
    'country' => $vinData['country'],
    'vehicle_type' => $vinData['vehicle_type'],
    'is_valid' => validateVIN($vin) || !empty($vinData['manufacturer']),
    'details' => $vinData
]);
