<?php
/**
 * API для загрузки документов
 * Путь: api/documents/upload.php
 * 
 * Поддерживаемые типы:
 * - PDF (техпаспорт, СТС, сервисная книга)
 * - Изображения документов (JPG, PNG)
 */

require_once '../../config/database.php';
require_once '../../middleware/AuthMiddleware.php';

header('Content-Type: application/json');

// Проверка авторизации
AuthMiddleware::check();
$userId = $_SESSION['user_id'];

// Конфигурация
define('MAX_FILE_SIZE', 20 * 1024 * 1024); // 20MB для PDF
define('UPLOAD_DIR', __DIR__ . '/../../public/uploads/documents/');
define('ALLOWED_TYPES', [
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png'
]);

// Создание директории
if (!file_exists(UPLOAD_DIR)) {
    mkdir(UPLOAD_DIR, 0755, true);
}

// Получение данных
$listingId = $_POST['listing_id'] ?? null;
$documentType = $_POST['document_type'] ?? 'other';
$description = $_POST['description'] ?? '';
$isPublic = isset($_POST['is_public']) && $_POST['is_public'] == '1';

// Валидация listing_id
if (!$listingId) {
    echo json_encode(['success' => false, 'message' => 'Anzeigen-ID fehlt']);
    exit;
}

// Проверка прав доступа к объявлению
$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("SELECT user_id FROM listings WHERE id = ?");
$stmt->execute([$listingId]);
$listing = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$listing || $listing['user_id'] != $userId) {
    echo json_encode(['success' => false, 'message' => 'Keine Berechtigung']);
    exit;
}

// Проверка файла
if (!isset($_FILES['document']) || $_FILES['document']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Hochladen']);
    exit;
}

$file = $_FILES['document'];

// Проверка размера
if ($file['size'] > MAX_FILE_SIZE) {
    echo json_encode(['success' => false, 'message' => 'Datei zu groß (max 20MB)']);
    exit;
}

// Проверка типа
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

if (!in_array($mimeType, ALLOWED_TYPES)) {
    echo json_encode(['success' => false, 'message' => 'Ungültiges Dateiformat (nur PDF, JPG, PNG)']);
    exit;
}

// Генерация имени файла
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$originalFilename = pathinfo($file['name'], PATHINFO_FILENAME);
$filename = uniqid() . '_' . time() . '.' . $ext;
$filepath = UPLOAD_DIR . $filename;

// Перемещение файла
if (!move_uploaded_file($file['tmp_name'], $filepath)) {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Speichern']);
    exit;
}

// Извлечение текста из PDF (опционально)
$extractedText = null;
if ($mimeType === 'application/pdf') {
    try {
        // Можно использовать библиотеку для извлечения текста
        // Например: smalot/pdfparser
        // $parser = new \Smalot\PdfParser\Parser();
        // $pdf = $parser->parseFile($filepath);
        // $extractedText = $pdf->getText();
    } catch (Exception $e) {
        // Игнорируем ошибки извлечения текста
    }
}

// Сохранение в БД
try {
    $stmt = $db->prepare("
        INSERT INTO listing_documents 
        (listing_id, document_type, filename, original_filename, file_path, 
         file_size, mime_type, description, is_public)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $listingId,
        $documentType,
        $filename,
        $originalFilename,
        '/uploads/documents/' . $filename,
        $file['size'],
        $mimeType,
        $description,
        $isPublic ? 1 : 0
    ]);
    
    $documentId = $db->lastInsertId();
    
    // Логирование
    $logStmt = $db->prepare("
        INSERT INTO admin_logs (user_id, action_type, details, ip_address)
        VALUES (?, 'document_upload', ?, ?)
    ");
    
    $logStmt->execute([
        $userId,
        json_encode([
            'listing_id' => $listingId,
            'document_id' => $documentId,
            'type' => $documentType,
            'filename' => $filename
        ]),
        $_SERVER['REMOTE_ADDR']
    ]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Dokument erfolgreich hochgeladen',
        'document' => [
            'id' => $documentId,
            'filename' => $filename,
            'original_filename' => $originalFilename,
            'type' => $documentType,
            'size' => $file['size'],
            'mime_type' => $mimeType,
            'path' => '/uploads/documents/' . $filename,
            'is_public' => $isPublic
        ]
    ]);
    
} catch (PDOException $e) {
    // Удаление файла при ошибке БД
    unlink($filepath);
    
    echo json_encode([
        'success' => false,
        'message' => 'Fehler beim Speichern in Datenbank'
    ]);
}
