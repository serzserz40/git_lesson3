# 📝 ПРОДОЛЖЕНИЕ ФОРМЫ ШАГА 2 - ЧАСТЬ 2

## РАЗДЕЛ 6-12: Все оставшиеся поля

```php
<!-- ========== РАЗДЕЛ 6: KILOMETERSTAND & ZUSTAND ========== -->
<div class="form-section">
    <h2>📊 Kilometerstand & Zustand</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label required">Kilometerstand (km) *</label>
            <input type="number" 
                   name="mileage" 
                   id="mileage"
                   class="form-input" 
                   placeholder="50000"
                   min="0" max="999999"
                   required>
        </div>
        
        <div class="form-group">
            <label class="form-label">Anzahl Vorbesitzer</label>
            <input type="number" 
                   name="number_of_owners" 
                   class="form-input" 
                   placeholder="1"
                   min="0" max="20">
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Letzter Service bei (km)</label>
            <input type="number" 
                   name="last_service_km" 
                   class="form-input" 
                   placeholder="45000"
                   min="0">
        </div>
        
        <div class="form-group">
            <label class="form-label">Letzter Service (Datum)</label>
            <input type="date" 
                   name="last_service_date" 
                   class="form-input">
        </div>
    </div>
    
    <div class="form-row checkboxes">
        <label class="checkbox-label">
            <input type="checkbox" name="timing_belt_replaced" value="1">
            <span>🔧 Zahnriemen gewechselt</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="original_paint" value="1" checked>
            <span>🎨 Originallackierung</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="tuned" value="1">
            <span>⚙️ Tuning / Modifiziert</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="right_hand_drive" value="1">
            <span>🚗 Rechtslenker</span>
        </label>
    </div>
    
    <div id="timing-belt-km" style="display:none;">
        <div class="form-group">
            <label class="form-label">Zahnriemen gewechselt bei (km)</label>
            <input type="number" 
                   name="timing_belt_km" 
                   class="form-input" 
                   placeholder="120000"
                   min="0">
        </div>
    </div>
</div>

<!-- ========== РАЗДЕЛ 7: REGISTRIERUNG & DOKUMENTE ========== -->
<div class="form-section">
    <h2>📄 Zulassung & Dokumente</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Erstzulassung (Jahr)</label>
            <select name="first_registration_year" id="reg_year" class="form-select">
                <option value="">Bitte wählen...</option>
                <?php for($y = date('Y')+1; $y >= 1950; $y--): ?>
                <option value="<?= $y ?>"><?= $y ?></option>
                <?php endfor; ?>
            </select>
        </div>
        
        <div class="form-group">
            <label class="form-label">Monat</label>
            <select name="first_registration_month" class="form-select">
                <option value="">-</option>
                <option value="1">Januar</option>
                <option value="2">Februar</option>
                <option value="3">März</option>
                <option value="4">April</option>
                <option value="5">Mai</option>
                <option value="6">Juni</option>
                <option value="7">Juli</option>
                <option value="8">August</option>
                <option value="9">September</option>
                <option value="10">Oktober</option>
                <option value="11">November</option>
                <option value="12">Dezember</option>
            </select>
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Kennzeichen</label>
            <input type="text" 
                   name="license_plate" 
                   class="form-input" 
                   placeholder="B-MW 1234"
                   maxlength="20"
                   style="text-transform: uppercase;">
            <small class="form-hint">Optional - wird nicht öffentlich angezeigt</small>
        </div>
        
        <div class="form-group">
            <label class="form-label">VIN / FIN-Nummer</label>
            <input type="text" 
                   name="vin_code" 
                   id="vin_code"
                   class="form-input" 
                   placeholder="WBADT43452G123456"
                   maxlength="17"
                   style="text-transform: uppercase;">
            <button type="button" id="check-vin" class="btn-vin-check">
                🔍 VIN prüfen
            </button>
            <div id="vin-result"></div>
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">HU (TÜV) gültig bis</label>
            <input type="date" 
                   name="technical_inspection_until" 
                   class="form-input"
                   min="<?= date('Y-m-d') ?>">
        </div>
        
        <div class="form-group">
            <label class="form-label">Garantie (Monate)</label>
            <input type="number" 
                   name="warranty_months" 
                   class="form-input" 
                   placeholder="12"
                   min="0" max="120">
        </div>
    </div>
    
    <div class="form-row checkboxes">
        <label class="checkbox-label">
            <input type="checkbox" name="registered" value="1" checked>
            <span>✅ Zugelassen</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="roadworthy" value="1" checked>
            <span>✅ Fahrtüchtig</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="dealer_warranty" value="1">
            <span>🏪 Händlergarantie</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="manufacturer_warranty" value="1">
            <span>🏭 Herstellergarantie</span>
        </label>
    </div>
</div>

<!-- ========== РАЗДЕЛ 8: HERKUNFT & HISTORIE ========== -->
<div class="form-section">
    <h2>🌍 Herkunft & Historie</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Fahrzeugstandort (Land)</label>
            <select name="location_country" class="form-select">
                <option value="DE" selected>Deutschland</option>
                <option value="AT">Österreich</option>
                <option value="CH">Schweiz</option>
                <option value="NL">Niederlande</option>
                <option value="BE">Belgien</option>
                <option value="FR">Frankreich</option>
                <option value="IT">Italien</option>
                <option value="ES">Spanien</option>
            </select>
        </div>
        
        <div class="form-group">
            <label class="checkbox-label">
                <input type="checkbox" name="imported" id="imported" value="1">
                <span>Import aus dem Ausland</span>
            </label>
        </div>
    </div>
    
    <div id="import-country" style="display:none;">
        <div class="form-group">
            <label class="form-label">Importiert aus</label>
            <select name="import_country" class="form-select">
                <option value="">Bitte wählen...</option>
                <option value="USA">USA</option>
                <option value="Japan">Japan</option>
                <option value="Italien">Italien</option>
                <option value="Frankreich">Frankreich</option>
                <option value="Spanien">Spanien</option>
                <option value="UK">Großbritannien</option>
                <option value="Andere">Andere</option>
            </select>
        </div>
    </div>
    
    <div class="form-row checkboxes">
        <label class="checkbox-label">
            <input type="checkbox" name="taxi_use" value="1">
            <span>🚕 Ex-Taxi</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="rental_use" value="1">
            <span>🚗 Ex-Mietwagen</span>
        </label>
    </div>
</div>

<!-- ========== РАЗДЕЛ 9: FARBE & INNENRAUM ========== -->
<div class="form-section">
    <h2>🎨 Farbe & Innenraum</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label required">Außenfarbe *</label>
            <select name="color" class="form-select" required>
                <option value="">Bitte wählen...</option>
                <option value="Schwarz">Schwarz</option>
                <option value="Weiß">Weiß</option>
                <option value="Grau">Grau</option>
                <option value="Silber">Silber</option>
                <option value="Blau">Blau</option>
                <option value="Rot">Rot</option>
                <option value="Grün">Grün</option>
                <option value="Gelb">Gelb</option>
                <option value="Orange">Orange</option>
                <option value="Braun">Braun</option>
                <option value="Beige">Beige</option>
                <option value="Gold">Gold</option>
                <option value="Bronze">Bronze</option>
                <option value="Violett">Violett</option>
            </select>
        </div>
        
        <div class="form-group">
            <label class="checkbox-label">
                <input type="checkbox" name="metallic" value="1">
                <span>✨ Metallic-Lackierung</span>
            </label>
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Innenfarbe</label>
            <select name="interior_color" class="form-select">
                <option value="">-</option>
                <option value="Schwarz">Schwarz</option>
                <option value="Grau">Grau</option>
                <option value="Beige">Beige</option>
                <option value="Braun">Braun</option>
                <option value="Rot">Rot</option>
                <option value="Weiß">Weiß</option>
            </select>
        </div>
        
        <div class="form-group">
            <label class="form-label">Polsterung</label>
            <select name="upholstery_material" class="form-select">
                <option value="">-</option>
                <option value="fabric">Stoff</option>
                <option value="leather">Leder</option>
                <option value="alcantara">Alcantara</option>
                <option value="vinyl">Kunstleder</option>
                <option value="combination">Teilleder</option>
            </select>
        </div>
        
        <div class="form-group">
            <label class="form-label">Innenausstattung</label>
            <select name="interior_type" class="form-select">
                <option value="">-</option>
                <option value="Standard">Standard</option>
                <option value="Sport">Sport</option>
                <option value="Luxury">Luxus</option>
            </select>
        </div>
    </div>
</div>

<!-- ========== РАЗДЕЛ 10: GEWICHTE ========== -->
<div class="form-section">
    <h2>⚖️ Gewichte & Maße</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">Leergewicht (kg)</label>
            <input type="number" 
                   name="curb_weight" 
                   class="form-input" 
                   placeholder="1500"
                   min="0">
        </div>
        
        <div class="form-group">
            <label class="form-label">Zulässiges Gesamtgewicht (kg)</label>
            <input type="number" 
                   name="gross_vehicle_weight" 
                   class="form-input" 
                   placeholder="2000"
                   min="0">
        </div>
        
        <div class="form-group">
            <label class="form-label">Nutzlast (kg)</label>
            <input type="number" 
                   name="payload_capacity" 
                   class="form-input" 
                   placeholder="500"
                   min="0">
        </div>
    </div>
</div>

<!-- ========== РАЗДЕЛ 11: PREIS & FINANZIERUNG ========== -->
<div class="form-section">
    <h2>💰 Preis & Finanzierung</h2>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label required">Preis (€) *</label>
            <input type="number" 
                   name="price" 
                   id="price"
                   class="form-input" 
                   placeholder="25000"
                   min="100"
                   step="100"
                   required>
        </div>
        
        <div class="form-group">
            <label class="checkbox-label">
                <input type="checkbox" name="price_negotiable" value="1" checked>
                <span>💬 Verhandlungsbasis</span>
            </label>
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-group">
            <label class="form-label">MwSt. ausweisbar</label>
            <select name="tax_included" class="form-select">
                <option value="0">Nein</option>
                <option value="1">Ja, 19% MwSt. im Preis</option>
            </select>
        </div>
        
        <div class="form-group">
            <label class="form-label">Kfz-Steuer (€/Jahr)</label>
            <input type="number" 
                   name="tax_annual" 
                   class="form-input" 
                   placeholder="250"
                   min="0"
                   step="10">
        </div>
    </div>
    
    <div class="form-row checkboxes">
        <label class="checkbox-label">
            <input type="checkbox" name="trade_in_possible" value="1">
            <span>🔄 Inzahlungnahme möglich</span>
        </label>
        
        <label class="checkbox-label">
            <input type="checkbox" name="financing_available" id="financing" value="1">
            <span>💳 Finanzierung möglich</span>
        </label>
    </div>
    
    <div id="financing-details" style="display:none;">
        <div class="form-group">
            <label class="form-label">Leasingrate (€/Monat)</label>
            <input type="number" 
                   name="leasing_rate" 
                   class="form-input" 
                   placeholder="299"
                   min="0"
                   step="10">
            <small class="form-hint">z.B. ab 299 € monatlich</small>
        </div>
    </div>
</div>

<!-- ========== РАЗДЕЛ 12: BESCHÄDIGUNG ========== -->
<div class="form-section">
    <h2>⚠️ Beschädigungen</h2>
    
    <div class="form-group">
        <label class="checkbox-label">
            <input type="checkbox" name="damaged" id="damaged" value="1">
            <span>⚠️ Fahrzeug ist beschädigt</span>
        </label>
    </div>
    
    <div id="damage-details" style="display:none;">
        <div class="form-group">
            <label class="form-label">Beschreibung der Schäden</label>
            <textarea name="damage_description" 
                      class="form-textarea" 
                      rows="4"
                      placeholder="Bitte beschreiben Sie die Schäden..."></textarea>
        </div>
    </div>
</div>

<!-- ========== NAVIGATION ========== -->
<div class="wizard-nav">
    <a href="/listing-wizard-step1" class="btn btn-outline">
        ← Zurück
    </a>
    <button type="button" id="save-draft" class="btn btn-secondary">
        💾 Zwischenspeichern
    </button>
    <button type="submit" class="btn btn-primary">
        Weiter: Ausstattung →
    </button>
</div>

<!-- ========== JAVASCRIPT ========== -->
<script>
// Показать/скрыть секцию электро
document.getElementById('fuel_type').addEventListener('change', function() {
    const electricSection = document.getElementById('electric-section');
    const value = this.value;
    if (value === 'Elektro' || value.includes('Hybrid')) {
        electricSection.style.display = 'block';
    } else {
        electricSection.style.display = 'none';
    }
});

// Показать поле км замены ГРМ
document.querySelector('[name="timing_belt_replaced"]').addEventListener('change', function() {
    document.getElementById('timing-belt-km').style.display = this.checked ? 'block' : 'none';
});

// Показать поле страны импорта
document.getElementById('imported').addEventListener('change', function() {
    document.getElementById('import-country').style.display = this.checked ? 'block' : 'none';
});

// Показать детали финансирования
document.getElementById('financing').addEventListener('change', function() {
    document.getElementById('financing-details').style.display = this.checked ? 'block' : 'none';
});

// Показать описание повреждений
document.getElementById('damaged').addEventListener('change', function() {
    document.getElementById('damage-details').style.display = this.checked ? 'block' : 'none';
});

// Проверка VIN
document.getElementById('check-vin').addEventListener('click', function() {
    const vinInput = document.getElementById('vin_code');
    const vin = vinInput.value.trim().toUpperCase();
    const resultDiv = document.getElementById('vin-result');
    
    if (vin.length !== 17) {
        resultDiv.innerHTML = '<span class="error">❌ VIN muss 17 Zeichen lang sein</span>';
        return;
    }
    
    resultDiv.innerHTML = '<span class="loading">🔄 Prüfe VIN...</span>';
    
    fetch('/api/vin/check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ vin: vin })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            resultDiv.innerHTML = `<span class="success">✅ VIN gültig - ${data.manufacturer} ${data.model_year}</span>`;
            // Автозаполнение полей
            if (data.model_year) document.getElementById('reg_year').value = data.model_year;
        } else {
            resultDiv.innerHTML = `<span class="error">❌ ${data.message}</span>`;
        }
    })
    .catch(err => {
        resultDiv.innerHTML = '<span class="error">❌ Fehler bei der Prüfung</span>';
    });
});

// Сохранить черновик
document.getElementById('save-draft').addEventListener('click', function() {
    const formData = new FormData(document.getElementById('vehicleFormFull'));
    formData.append('is_draft', '1');
    
    fetch('/api/wizard/save-draft', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            alert('✅ Entwurf gespeichert!');
        }
    });
});

// Отправка формы
document.getElementById('vehicleFormFull').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // Валидация
    const price = document.getElementById('price').value;
    const mileage = document.getElementById('mileage').value;
    
    if (price < 100) {
        alert('Preis muss mindestens 100 € sein');
        return;
    }
    
    if (mileage < 0 || mileage > 999999) {
        alert('Bitte geben Sie einen gültigen Kilometerstand ein');
        return;
    }
    
    // Отправка
    this.submit();
});
</script>
```

**ГОТОВО! ПОЛНАЯ ФОРМА ШАГА 2!** ✅
