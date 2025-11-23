# 📝 ОБНОВЛЁННАЯ ФОРМА ШАГА 2 - СО ВСЕМИ ПОЛЯМИ

## views/listing-wizard-step2-vehicle-FULL.php

```php
<?php
// Шаг 2 мастера: ПОЛНАЯ версия с ВСЕМИ полями из SS.COM и Mobile.de

require_once '../middleware/AuthMiddleware.php';
AuthMiddleware::check();

$userId = $_SESSION['user_id'];
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schritt 2: Fahrzeugdaten - AutoMarkt.de</title>
    <link rel="stylesheet" href="/public/css/style.css">
    <link rel="stylesheet" href="/public/css/wizard.css">
</head>
<body>
    <?php include '../includes/header.php'; ?>
    
    <main class="wizard-container">
        <div class="container">
            <h1>🚗 Fahrzeugdaten eingeben</h1>
            <p class="wizard-subtitle">Alle Informationen über Ihr Fahrzeug</p>
            
            <form id="vehicleFormFull" method="POST" action="/api/wizard/save-step2-full">
                <input type="hidden" name="car_model_id" id="car_model_id">
                
                <!-- ========== РАЗДЕЛ 1: ВЫБОР АВТОМОБИЛЯ ========== -->
                <div class="form-section">
                    <h2>🔍 Fahrzeug auswählen</h2>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label required">Marke *</label>
                            <select name="make" id="make" class="form-select" required>
                                <option value="">Bitte wählen...</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label required">Modell *</label>
                            <select name="model" id="model" class="form-select" required disabled>
                                <option value="">Zuerst Marke wählen</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label required">Jahr *</label>
                            <select name="model_year" id="year" class="form-select" required disabled>
                                <option value="">Zuerst Modell wählen</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Ausstattungslinie</label>
                        <input type="text" 
                               name="trim_level" 
                               class="form-input" 
                               placeholder="z.B. Ambition, Style, Sport Line">
                        <small class="form-hint">z.B. VW Golf GTI, BMW M-Paket, Audi S-Line</small>
                    </div>
                    
                    <!-- Спецификации отобразятся здесь -->
                    <div id="car-specs" class="car-specs-container"></div>
                </div>
                
                <!-- ========== РАЗДЕЛ 2: ПРОДАВЕЦ И СОСТОЯНИЕ ========== -->
                <div class="form-section">
                    <h2>👤 Verkäufer & Zustand</h2>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label required">Verkäufertyp *</label>
                            <select name="seller_type" class="form-select" required>
                                <option value="private">Privatperson</option>
                                <option value="dealer">Händler</option>
                                <option value="leasing_company">Leasinggesellschaft</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label required">Zustand *</label>
                            <select name="condition_status" class="form-select" required>
                                <option value="used">Gebraucht</option>
                                <option value="new">Neu</option>
                                <option value="damaged">Beschädigt</option>
                                <option value="accident">Unfallfahrzeug</option>
                                <option value="restored">Restauriert</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row checkboxes">
                        <label class="checkbox-label">
                            <input type="checkbox" name="accident_free" value="1" checked>
                            <span>✅ Unfallfrei</span>
                        </label>
                        
                        <label class="checkbox-label">
                            <input type="checkbox" name="first_owner" value="1">
                            <span>👤 Erstzulassung</span>
                        </label>
                        
                        <label class="checkbox-label">
                            <input type="checkbox" name="non_smoker_vehicle" value="1" checked>
                            <span>🚭 Nichtraucherfahrzeug</span>
                        </label>
                        
                        <label class="checkbox-label">
                            <input type="checkbox" name="service_book_available" value="1">
                            <span>📖 Scheckheftgepflegt</span>
                        </label>
                    </div>
                </div>
                
                <!-- ========== РАЗДЕЛ 3: ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ ========== -->
                <div class="form-section">
                    <h2>⚙️ Technische Daten</h2>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Karosserieform</label>
                            <select name="body_type" id="body_type" class="form-select">
                                <option value="">Bitte wählen...</option>
                                <option value="Limousine">Limousine</option>
                                <option value="Kombi">Kombi</option>
                                <option value="SUV">SUV / Geländewagen</option>
                                <option value="Kleinwagen">Kleinwagen</option>
                                <option value="Cabrio">Cabrio / Roadster</option>
                                <option value="Coupe">Coupé</option>
                                <option value="Van">Van / Kleinbus</option>
                                <option value="Pickup">Pick-up</option>
                                <option value="Sportwagen">Sportwagen</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label required">Kraftstoff *</label>
                            <select name="fuel_type" id="fuel_type" class="form-select" required>
                                <option value="">Bitte wählen...</option>
                                <option value="Benzin">Benzin</option>
                                <option value="Diesel">Diesel</option>
                                <option value="Elektro">Elektro</option>
                                <option value="Hybrid">Hybrid (Benzin/Elektro)</option>
                                <option value="Plug-in Hybrid">Plug-in Hybrid</option>
                                <option value="Autogas (LPG)">Autogas (LPG)</option>
                                <option value="Erdgas (CNG)">Erdgas (CNG)</option>
                                <option value="Wasserstoff">Wasserstoff</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Hubraum (cm³)</label>
                            <input type="number" 
                                   name="engine_cc" 
                                   id="engine_cc"
                                   class="form-input" 
                                   placeholder="1998"
                                   min="500" max="10000">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Leistung (PS)</label>
                            <input type="number" 
                                   name="horse_power" 
                                   id="horse_power"
                                   class="form-input" 
                                   placeholder="150"
                                   min="30" max="2000">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Zylinder</label>
                            <select name="cylinder_count" class="form-select">
                                <option value="">-</option>
                                <option value="2">2 Zylinder</option>
                                <option value="3">3 Zylinder</option>
                                <option value="4">4 Zylinder</option>
                                <option value="5">5 Zylinder</option>
                                <option value="6">6 Zylinder</option>
                                <option value="8">8 Zylinder</option>
                                <option value="10">10 Zylinder</option>
                                <option value="12">12 Zylinder</option>
                                <option value="16">16 Zylinder</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="checkbox-label">
                                <input type="checkbox" name="turbo" value="1">
                                <span>🔥 Turbo</span>
                            </label>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label required">Getriebe *</label>
                            <select name="transmission" id="transmission" class="form-select" required>
                                <option value="">Bitte wählen...</option>
                                <option value="Schaltgetriebe">Schaltgetriebe</option>
                                <option value="Automatik">Automatik</option>
                                <option value="Halbautomatik">Halbautomatik</option>
                                <option value="Direktschaltgetriebe">Direktschaltgetriebe (DSG)</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Antrieb</label>
                            <select name="drive_type" id="drive_type" class="form-select">
                                <option value="">Bitte wählen...</option>
                                <option value="Vorderradantrieb">Vorderradantrieb</option>
                                <option value="Hinterradantrieb">Hinterradantrieb</option>
                                <option value="Allrad">Allradantrieb</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Türen</label>
                            <select name="doors" id="doors" class="form-select">
                                <option value="">-</option>
                                <option value="2">2/3 Türen</option>
                                <option value="4">4/5 Türen</option>
                                <option value="6">6/7 Türen</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Sitze</label>
                            <select name="seats_count" class="form-select">
                                <option value="">-</option>
                                <option value="2">2 Sitze</option>
                                <option value="4">4 Sitze</option>
                                <option value="5">5 Sitze</option>
                                <option value="6">6 Sitze</option>
                                <option value="7">7 Sitze</option>
                                <option value="8">8 Sitze</option>
                                <option value="9">9 Sitze</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Kofferraumvolumen (L)</label>
                            <input type="number" 
                                   name="trunk_capacity" 
                                   class="form-input" 
                                   placeholder="450"
                                   min="0" max="5000">
                        </div>
                    </div>
                </div>
                
                <!-- ========== РАЗДЕЛ 4: ЭЛЕКТРОМОБИЛИ ========== -->
                <div class="form-section" id="electric-section" style="display:none;">
                    <h2>🔋 Elektro / Hybrid Details</h2>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Reichweite (km)</label>
                            <input type="number" 
                                   name="electric_range" 
                                   class="form-input" 
                                   placeholder="400"
                                   min="0" max="1000">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Batteriekapazität (kWh)</label>
                            <input type="number" 
                                   name="battery_capacity" 
                                   class="form-input" 
                                   placeholder="60.0"
                                   step="0.1"
                                   min="0" max="200">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Schnellladezeit (Std)</label>
                            <input type="number" 
                                   name="charging_time_fast" 
                                   class="form-input" 
                                   placeholder="0.5"
                                   step="0.1"
                                   min="0" max="24">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Normale Ladezeit (Std)</label>
                            <input type="number" 
                                   name="charging_time_regular" 
                                   class="form-input" 
                                   placeholder="8.0"
                                   step="0.1"
                                   min="0" max="48">
                        </div>
                    </div>
                </div>
                
                <!-- ========== РАЗДЕЛ 5: VERBRAUCH & UMWELT ========== -->
                <div class="form-section">
                    <h2>🌱 Verbrauch & Umwelt</h2>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Verbrauch Stadt (L/100km)</label>
                            <input type="number" 
                                   name="fuel_consumption_city" 
                                   class="form-input" 
                                   placeholder="8.5"
                                   step="0.1"
                                   min="0" max="30">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Verbrauch Landstraße (L/100km)</label>
                            <input type="number" 
                                   name="fuel_consumption_highway" 
                                   class="form-input" 
                                   placeholder="5.5"
                                   step="0.1"
                                   min="0" max="30">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Verbrauch kombiniert (L/100km)</label>
                            <input type="number" 
                                   name="fuel_consumption_combined" 
                                   class="form-input" 
                                   placeholder="6.5"
                                   step="0.1"
                                   min="0" max="30">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">CO₂-Emissionen (g/km)</label>
                            <input type="number" 
                                   name="co2_emissions" 
                                   class="form-input" 
                                   placeholder="150"
                                   min="0" max="500">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Emissionsklasse</label>
                            <select name="emission_class" class="form-select">
                                <option value="">Bitte wählen...</option>
                                <option value="Euro 6d-TEMP">Euro 6d-TEMP</option>
                                <option value="Euro 6d">Euro 6d</option>
                                <option value="Euro 6c">Euro 6c</option>
                                <option value="Euro 6b">Euro 6b</option>
                                <option value="Euro 6a">Euro 6a</option>
                                <option value="Euro 5">Euro 5</option>
                                <option value="Euro 4">Euro 4</option>
                                <option value="Euro 3">Euro 3</option>
                                <option value="Euro 2">Euro 2</option>
                                <option value="Euro 1">Euro 1</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <!-- ПРОДОЛЖЕНИЕ СЛЕДУЕТ... -->
                
                <!-- Wizard Navigation -->
                <div class="wizard-nav">
                    <a href="/listing-wizard-step1" class="btn btn-outline">
                        ← Zurück
                    </a>
                    <button type="submit" class="btn btn-primary">
                        Weiter: Ausstattung →
                    </button>
                </div>
            </form>
        </div>
    </main>
    
    <script src="/public/js/car-model-selector.js"></script>
    <script src="/public/js/vehicle-form-full.js"></script>
</body>
</html>
```

**ПРОДОЛЖЕНИЕ В СЛЕДУЮЩЕМ ФАЙЛЕ...**
