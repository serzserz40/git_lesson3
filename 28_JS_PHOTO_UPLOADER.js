/**
 * Множественная загрузка фотографий с drag & drop
 * Путь: public/js/photo-uploader.js
 * 
 * Функции:
 * - Drag & drop
 * - Multiple upload
 * - Предпросмотр
 * - Поворот фотографий
 * - Сортировка
 * - Прогресс загрузки
 */

class PhotoUploader {
    constructor(options = {}) {
        this.dropzone = options.dropzone || '#photo-dropzone';
        this.fileInput = options.fileInput || '#photo-input';
        this.previewContainer = options.previewContainer || '#photo-preview';
        this.maxFiles = options.maxFiles || 20;
        this.maxFileSize = options.maxFileSize || 10 * 1024 * 1024; // 10MB
        this.listingId = options.listingId || null;
        this.uploadUrl = options.uploadUrl || '/api/photos/upload-multiple';
        this.allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        
        this.files = [];
        this.rotations = {};
        this.photoTypes = {};
        this.captions = {};
        this.is360 = {};
        
        this.init();
    }
    
    init() {
        this.setupDropzone();
        this.setupFileInput();
        this.setupSortable();
    }
    
    setupDropzone() {
        const dropzone = document.querySelector(this.dropzone);
        if (!dropzone) return;
        
        // Предотвращение поведения по умолчанию
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropzone.addEventListener(eventName, (e) => {
                e.preventDefault();
                e.stopPropagation();
            });
        });
        
        // Визуальная обратная связь
        ['dragenter', 'dragover'].forEach(eventName => {
            dropzone.addEventListener(eventName, () => {
                dropzone.classList.add('drag-over');
            });
        });
        
        ['dragleave', 'drop'].forEach(eventName => {
            dropzone.addEventListener(eventName, () => {
                dropzone.classList.remove('drag-over');
            });
        });
        
        // Обработка drop
        dropzone.addEventListener('drop', (e) => {
            const files = e.dataTransfer.files;
            this.handleFiles(files);
        });
        
        // Клик для выбора файлов
        dropzone.addEventListener('click', () => {
            document.querySelector(this.fileInput).click();
        });
    }
    
    setupFileInput() {
        const input = document.querySelector(this.fileInput);
        if (!input) return;
        
        input.addEventListener('change', (e) => {
            this.handleFiles(e.target.files);
        });
    }
    
    setupSortable() {
        const container = document.querySelector(this.previewContainer);
        if (!container || typeof Sortable === 'undefined') return;
        
        new Sortable(container, {
            animation: 150,
            ghostClass: 'sortable-ghost',
            onEnd: () => {
                this.updateOrder();
            }
        });
    }
    
    handleFiles(fileList) {
        const files = Array.from(fileList);
        
        // Проверка количества
        if (this.files.length + files.length > this.maxFiles) {
            alert(`Максимум ${this.maxFiles} фотографий`);
            return;
        }
        
        files.forEach(file => {
            // Проверка типа
            if (!this.allowedTypes.includes(file.type)) {
                alert(`${file.name}: Неподдерживаемый формат`);
                return;
            }
            
            // Проверка размера
            if (file.size > this.maxFileSize) {
                alert(`${file.name}: Слишком большой файл (макс 10MB)`);
                return;
            }
            
            this.addFile(file);
        });
    }
    
    addFile(file) {
        const fileId = Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        
        this.files.push({
            id: fileId,
            file: file
        });
        
        this.rotations[fileId] = 0;
        this.photoTypes[fileId] = 'exterior';
        this.captions[fileId] = '';
        this.is360[fileId] = false;
        
        this.renderPreview(fileId, file);
    }
    
    renderPreview(fileId, file) {
        const container = document.querySelector(this.previewContainer);
        
        const preview = document.createElement('div');
        preview.className = 'photo-preview-item';
        preview.dataset.fileId = fileId;
        
        // Создание превью
        const reader = new FileReader();
        reader.onload = (e) => {
            preview.innerHTML = `
                <img src="${e.target.result}" alt="${file.name}" id="img_${fileId}">
                
                <div class="photo-controls">
                    <button type="button" class="btn-rotate-left" data-file-id="${fileId}">
                        ↺
                    </button>
                    <button type="button" class="btn-rotate-right" data-file-id="${fileId}">
                        ↻
                    </button>
                    <button type="button" class="btn-remove" data-file-id="${fileId}">
                        🗑️
                    </button>
                </div>
                
                <div class="photo-meta">
                    <select class="photo-type" data-file-id="${fileId}">
                        <option value="exterior">Außenansicht</option>
                        <option value="interior">Innenraum</option>
                        <option value="engine">Motor</option>
                        <option value="trunk">Kofferraum</option>
                        <option value="damage">Schäden</option>
                        <option value="documents">Dokumente</option>
                        <option value="other">Sonstiges</option>
                    </select>
                    
                    <input type="text" 
                           class="photo-caption" 
                           data-file-id="${fileId}"
                           placeholder="Bildunterschrift">
                    
                    <label class="photo-360">
                        <input type="checkbox" data-file-id="${fileId}">
                        360°
                    </label>
                </div>
                
                <div class="photo-progress" id="progress_${fileId}"></div>
            `;
            
            container.appendChild(preview);
            this.attachEventListeners(fileId);
        };
        
        reader.readAsDataURL(file);
    }
    
    attachEventListeners(fileId) {
        // Поворот влево
        document.querySelector(`.btn-rotate-left[data-file-id="${fileId}"]`)
            .addEventListener('click', () => this.rotateImage(fileId, -90));
        
        // Поворот вправо
        document.querySelector(`.btn-rotate-right[data-file-id="${fileId}"]`)
            .addEventListener('click', () => this.rotateImage(fileId, 90));
        
        // Удаление
        document.querySelector(`.btn-remove[data-file-id="${fileId}"]`)
            .addEventListener('click', () => this.removeFile(fileId));
        
        // Тип фото
        document.querySelector(`.photo-type[data-file-id="${fileId}"]`)
            .addEventListener('change', (e) => {
                this.photoTypes[fileId] = e.target.value;
            });
        
        // Подпись
        document.querySelector(`.photo-caption[data-file-id="${fileId}"]`)
            .addEventListener('input', (e) => {
                this.captions[fileId] = e.target.value;
            });
        
        // 360°
        document.querySelector(`.photo-360 input[data-file-id="${fileId}"]`)
            .addEventListener('change', (e) => {
                this.is360[fileId] = e.target.checked;
            });
    }
    
    rotateImage(fileId, angle) {
        this.rotations[fileId] = (this.rotations[fileId] + angle) % 360;
        if (this.rotations[fileId] < 0) this.rotations[fileId] += 360;
        
        const img = document.getElementById(`img_${fileId}`);
        img.style.transform = `rotate(${this.rotations[fileId]}deg)`;
    }
    
    removeFile(fileId) {
        this.files = this.files.filter(f => f.id !== fileId);
        delete this.rotations[fileId];
        delete this.photoTypes[fileId];
        delete this.captions[fileId];
        delete this.is360[fileId];
        
        const preview = document.querySelector(`[data-file-id="${fileId}"]`);
        if (preview) preview.remove();
    }
    
    updateOrder() {
        const previews = document.querySelectorAll('.photo-preview-item');
        const newOrder = Array.from(previews).map(p => p.dataset.fileId);
        
        this.files.sort((a, b) => {
            return newOrder.indexOf(a.id) - newOrder.indexOf(b.id);
        });
    }
    
    async upload() {
        if (this.files.length === 0) {
            alert('Keine Fotos zum Hochladen');
            return false;
        }
        
        const formData = new FormData();
        
        // Добавление файлов
        this.files.forEach((item, index) => {
            formData.append('photos[]', item.file);
        });
        
        // Добавление метаданных
        formData.append('listing_id', this.listingId);
        formData.append('rotations', JSON.stringify(
            this.files.map(f => this.rotations[f.id] || 0)
        ));
        formData.append('photo_types', JSON.stringify(
            this.files.map(f => this.photoTypes[f.id] || 'exterior')
        ));
        formData.append('captions', JSON.stringify(
            this.files.map(f => this.captions[f.id] || '')
        ));
        formData.append('is_360', JSON.stringify(
            this.files.map(f => this.is360[f.id] || false)
        ));
        
        try {
            const response = await fetch(this.uploadUrl, {
                method: 'POST',
                body: formData
            });
            
            const data = await response.json();
            
            if (data.success) {
                alert(`✅ ${data.files.length} Foto(s) erfolgreich hochgeladen!`);
                this.files = [];
                document.querySelector(this.previewContainer).innerHTML = '';
                return true;
            } else {
                alert(`❌ Fehler: ${data.message}`);
                return false;
            }
        } catch (error) {
            alert('❌ Upload-Fehler');
            console.error(error);
            return false;
        }
    }
    
    getFileCount() {
        return this.files.length;
    }
}

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    if (document.querySelector('#photo-dropzone')) {
        window.photoUploader = new PhotoUploader({
            dropzone: '#photo-dropzone',
            fileInput: '#photo-input',
            previewContainer: '#photo-preview',
            listingId: document.querySelector('[name="listing_id"]')?.value
        });
    }
});
