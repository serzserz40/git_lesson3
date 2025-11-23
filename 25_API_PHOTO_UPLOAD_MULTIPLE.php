<?php
/**
 * API для множественной загрузки фотографий
 * Путь: api/photos/upload-multiple.php
 * 
 * Поддержка:
 * - До 20 фотографий одновременно
 * - Поворот фотографий (0/90/180/270)
 * - Автоматическое сжатие
 * - Водяные знаки (опционально)
 * - Галерея пользователя
 */

require_once '../../config/database.php';
require_once '../../middleware/AuthMiddleware.php';

header('Content-Type: application/json');

// Проверка авторизации
AuthMiddleware::check();
$userId = $_SESSION['user_id'];

// Конфигурация
define('MAX_FILES', 20);
define('MAX_FILE_SIZE', 10 * 1024 * 1024); // 10MB
define('UPLOAD_DIR', __DIR__ . '/../../public/uploads/listings/');
define('THUMB_DIR', __DIR__ . '/../../public/uploads/thumbnails/');
define('ALLOWED_TYPES', ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']);
define('MAX_WIDTH', 1920);
define('MAX_HEIGHT', 1080);
define('THUMB_WIDTH', 300);
define('THUMB_HEIGHT', 225);

// Создание директорий
if (!file_exists(UPLOAD_DIR)) mkdir(UPLOAD_DIR, 0755, true);
if (!file_exists(THUMB_DIR)) mkdir(THUMB_DIR, 0755, true);

// Получение данных
$listingId = $_POST['listing_id'] ?? null;
$galleryId = $_POST['gallery_id'] ?? null;
$rotations = json_decode($_POST['rotations'] ?? '[]', true);
$photoTypes = json_decode($_POST['photo_types'] ?? '[]', true);
$captions = json_decode($_POST['captions'] ?? '[]', true);
$is360 = json_decode($_POST['is_360'] ?? '[]', true);
$addWatermark = $_POST['add_watermark'] ?? false;

// Проверка наличия файлов
if (empty($_FILES['photos'])) {
    echo json_encode(['success' => false, 'message' => 'Keine Dateien hochgeladen']);
    exit;
}

$files = $_FILES['photos'];
$uploadedFiles = [];
$errors = [];

// Функция поворота изображения
function rotateImage($source, $angle) {
    if ($angle == 0) return $source;
    
    $rotated = imagerotate($source, $angle, 0);
    return $rotated;
}

// Функция изменения размера
function resizeImage($source, $maxWidth, $maxHeight) {
    $srcWidth = imagesx($source);
    $srcHeight = imagesy($source);
    
    if ($srcWidth <= $maxWidth && $srcHeight <= $maxHeight) {
        return $source;
    }
    
    $ratio = min($maxWidth / $srcWidth, $maxHeight / $srcHeight);
    $newWidth = round($srcWidth * $ratio);
    $newHeight = round($srcHeight * $ratio);
    
    $dest = imagecreatetruecolor($newWidth, $newHeight);
    
    // Сохранение прозрачности для PNG
    imagealphablending($dest, false);
    imagesavealpha($dest, true);
    
    imagecopyresampled($dest, $source, 0, 0, 0, 0, $newWidth, $newHeight, $srcWidth, $srcHeight);
    
    return $dest;
}

// Функция добавления водяного знака
function addWatermark($image) {
    $watermarkText = 'AutoMarkt.de';
    $fontSize = 20;
    $textColor = imagecolorallocatealpha($image, 255, 255, 255, 50);
    
    $width = imagesx($image);
    $height = imagesy($image);
    
    // Позиция внизу справа
    $x = $width - 200;
    $y = $height - 30;
    
    imagestring($image, 5, $x, $y, $watermarkText, $textColor);
    
    return $image;
}

// Функция создания thumbnail
function createThumbnail($source, $destPath, $width, $height) {
    $thumb = resizeImage($source, $width, $height);
    
    $ext = strtolower(pathinfo($destPath, PATHINFO_EXTENSION));
    
    switch ($ext) {
        case 'jpg':
        case 'jpeg':
            imagejpeg($thumb, $destPath, 85);
            break;
        case 'png':
            imagepng($thumb, $destPath, 8);
            break;
        case 'webp':
            imagewebp($thumb, $destPath, 85);
            break;
    }
    
    imagedestroy($thumb);
}

// База данных
$db = Database::getInstance()->getConnection();

// Обработка каждого файла
$fileCount = count($files['name']);

for ($i = 0; $i < $fileCount && $i < MAX_FILES; $i++) {
    // Пропуск если ошибка загрузки
    if ($files['error'][$i] !== UPLOAD_ERR_OK) {
        $errors[] = "Fehler beim Hochladen von Datei " . ($i + 1);
        continue;
    }
    
    // Проверка размера
    if ($files['size'][$i] > MAX_FILE_SIZE) {
        $errors[] = "Datei " . ($i + 1) . " ist zu groß (max 10MB)";
        continue;
    }
    
    // Проверка типа
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $files['tmp_name'][$i]);
    finfo_close($finfo);
    
    if (!in_array($mimeType, ALLOWED_TYPES)) {
        $errors[] = "Datei " . ($i + 1) . " hat ungültiges Format";
        continue;
    }
    
    // Генерация имени файла
    $ext = strtolower(pathinfo($files['name'][$i], PATHINFO_EXTENSION));
    $filename = uniqid() . '_' . time() . '.' . $ext;
    $filepath = UPLOAD_DIR . $filename;
    $thumbPath = THUMB_DIR . 'thumb_' . $filename;
    
    // Загрузка изображения
    $source = null;
    switch ($mimeType) {
        case 'image/jpeg':
        case 'image/jpg':
            $source = imagecreatefromjpeg($files['tmp_name'][$i]);
            break;
        case 'image/png':
            $source = imagecreatefrompng($files['tmp_name'][$i]);
            break;
        case 'image/webp':
            $source = imagecreatefromwebp($files['tmp_name'][$i]);
            break;
    }
    
    if (!$source) {
        $errors[] = "Kann Datei " . ($i + 1) . " nicht verarbeiten";
        continue;
    }
    
    // Поворот
    $rotation = $rotations[$i] ?? 0;
    if ($rotation != 0) {
        $source = rotateImage($source, $rotation);
    }
    
    // Изменение размера
    $source = resizeImage($source, MAX_WIDTH, MAX_HEIGHT);
    
    // Водяной знак
    if ($addWatermark) {
        $source = addWatermark($source);
    }
    
    // Сохранение основного изображения
    switch ($ext) {
        case 'jpg':
        case 'jpeg':
            imagejpeg($source, $filepath, 90);
            break;
        case 'png':
            imagepng($source, $filepath, 8);
            break;
        case 'webp':
            imagewebp($source, $filepath, 90);
            break;
    }
    
    // Создание thumbnail
    createThumbnail($source, $thumbPath, THUMB_WIDTH, THUMB_HEIGHT);
    
    imagedestroy($source);
    
    // Сохранение в БД
    $fileSize = filesize($filepath);
    $photoType = $photoTypes[$i] ?? 'exterior';
    $caption = $captions[$i] ?? '';
    $is360View = $is360[$i] ?? false;
    
    if ($listingId) {
        // Сохранение для объявления
        $stmt = $db->prepare("
            INSERT INTO listing_photos 
            (listing_id, filename, file_path, file_size, display_order, rotation, is_360_view, photo_type, caption, uploaded_from)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'computer')
        ");
        
        $stmt->execute([
            $listingId,
            $filename,
            '/uploads/listings/' . $filename,
            $fileSize,
            $i + 1,
            $rotation,
            $is360View ? 1 : 0,
            $photoType,
            $caption
        ]);
        
        $photoId = $db->lastInsertId();
    } elseif ($galleryId) {
        // Сохранение в галерею пользователя
        $stmt = $db->prepare("
            INSERT INTO user_gallery_photos 
            (gallery_id, user_id, filename, file_path, file_size, title, display_order)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $galleryId,
            $userId,
            $filename,
            '/uploads/listings/' . $filename,
            $fileSize,
            $caption,
            $i + 1
        ]);
        
        $photoId = $db->lastInsertId();
        
        // Обновление счётчика в галерее
        $db->exec("UPDATE user_gallery SET photo_count = photo_count + 1 WHERE id = $galleryId");
    } else {
        $photoId = null;
    }
    
    $uploadedFiles[] = [
        'id' => $photoId,
        'filename' => $filename,
        'path' => '/uploads/listings/' . $filename,
        'thumb' => '/uploads/thumbnails/thumb_' . $filename,
        'size' => $fileSize,
        'type' => $photoType,
        'rotation' => $rotation
    ];
}

// Ответ
if (empty($uploadedFiles)) {
    echo json_encode([
        'success' => false,
        'message' => 'Keine Dateien wurden hochgeladen',
        'errors' => $errors
    ]);
} else {
    echo json_encode([
        'success' => true,
        'message' => count($uploadedFiles) . ' Foto(s) erfolgreich hochgeladen',
        'files' => $uploadedFiles,
        'errors' => $errors
    ]);
}
