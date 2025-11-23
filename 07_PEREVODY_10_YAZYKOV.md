# ФАЙЛЫ ПЕРЕВОДОВ ДЛЯ ВСЕХ 10 ЯЗЫКОВ

## Структура папок:
```
/languages/
├── de/
│   └── main.php (Немецкий)
├── en/
│   └── main.php (Английский)
├── es/
│   └── main.php (Испанский)
├── fr/
│   └── main.php (Французский)
├── nl/
│   └── main.php (Нидерландский)
├── pl/
│   └── main.php (Польский)
├── ro/
│   └── main.php (Румынский)
├── ru/
│   └── main.php (Русский)
├── cs/
│   └── main.php (Чешский)
└── tr/
    └── main.php (Турецкий)
```

---

## 🇩🇪 /languages/de/main.php (НЕМЕЦКИЙ - ПО УМОЛЧАНИЮ)

```php
<?php
return [
    // Общее
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Willkommen',
    'search' => 'Suchen',
    'login' => 'Anmelden',
    'register' => 'Registrieren',
    'logout' => 'Abmelden',
    'my_account' => 'Mein Konto',
    'settings' => 'Einstellungen',
    'language' => 'Sprache',
    
    // Меню
    'menu_home' => 'Startseite',
    'menu_search' => 'Suche',
    'menu_sell' => 'Verkaufen',
    'menu_favorites' => 'Favoriten',
    'menu_messages' => 'Nachrichten',
    'menu_help' => 'Hilfe',
    
    // Поиск
    'search_placeholder' => 'Marke, Modell oder Typ',
    'advanced_search' => 'Erweiterte Suche',
    'radius' => 'Umkreis',
    'price_from' => 'Preis von',
    'price_to' => 'Preis bis',
    'year_from' => 'Erstzulassung von',
    'year_to' => 'Erstzulassung bis',
    'mileage_from' => 'Kilometerstand von',
    'mileage_to' => 'Kilometerstand bis',
    'power' => 'Leistung',
    'fuel_type' => 'Kraftstoff',
    'transmission' => 'Getriebe',
    'color' => 'Farbe',
    
    // Объявления
    'create_listing' => 'Inserat aufgeben',
    'edit_listing' => 'Inserat bearbeiten',
    'delete_listing' => 'Inserat löschen',
    'listing_details' => 'Fahrzeugdetails',
    'contact_seller' => 'Verkäufer kontaktieren',
    'add_to_favorites' => 'Zu Favoriten hinzufügen',
    'share' => 'Teilen',
    'print' => 'Drucken',
    'report' => 'Melden',
    
    // Категории
    'vehicles' => 'Fahrzeuge',
    'cars' => 'Pkw',
    'motorcycles' => 'Motorräder',
    'trucks' => 'Nutzfahrzeuge',
    'motorhomes' => 'Wohnmobile & Wohnwagen',
    'trailers' => 'Anhänger',
    
    // Кнопки
    'submit' => 'Absenden',
    'cancel' => 'Abbrechen',
    'save' => 'Speichern',
    'delete' => 'Löschen',
    'edit' => 'Bearbeiten',
    'back' => 'Zurück',
    'next' => 'Weiter',
    'close' => 'Schließen',
    'confirm' => 'Bestätigen',
    
    // Сообщения
    'success' => 'Erfolgreich',
    'error' => 'Fehler',
    'warning' => 'Warnung',
    'info' => 'Information',
    'required_field' => 'Pflichtfeld',
    'invalid_email' => 'Ungültige E-Mail-Adresse',
    'password_too_short' => 'Passwort zu kurz',
    'listing_created' => 'Inserat erfolgreich erstellt',
    'listing_updated' => 'Inserat erfolgreich aktualisiert',
    'listing_deleted' => 'Inserat erfolgreich gelöscht',
    
    // Пакеты
    'packages' => 'Pakete',
    'free_package' => 'Kostenlos',
    'bronze_package' => 'Bronze',
    'silver_package' => 'Silber',
    'gold_package' => 'Gold',
    'platinum_package' => 'Platin',
    'choose_package' => 'Paket wählen',
    'upgrade' => 'Upgraden',
    
    // Футер
    'about_us' => 'Über uns',
    'contact' => 'Kontakt',
    'help' => 'Hilfe',
    'terms' => 'AGB',
    'privacy' => 'Datenschutz',
    'imprint' => 'Impressum',
    'cookie_policy' => 'Cookie-Richtlinie',
    
    // Дни недели
    'monday' => 'Montag',
    'tuesday' => 'Dienstag',
    'wednesday' => 'Mittwoch',
    'thursday' => 'Donnerstag',
    'friday' => 'Freitag',
    'saturday' => 'Samstag',
    'sunday' => 'Sonntag',
];
```

---

## 🇬🇧 /languages/en/main.php (АНГЛИЙСКИЙ)

```php
<?php
return [
    // General
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Welcome',
    'search' => 'Search',
    'login' => 'Login',
    'register' => 'Register',
    'logout' => 'Logout',
    'my_account' => 'My Account',
    'settings' => 'Settings',
    'language' => 'Language',
    
    // Menu
    'menu_home' => 'Home',
    'menu_search' => 'Search',
    'menu_sell' => 'Sell',
    'menu_favorites' => 'Favorites',
    'menu_messages' => 'Messages',
    'menu_help' => 'Help',
    
    // Search
    'search_placeholder' => 'Brand, model or type',
    'advanced_search' => 'Advanced Search',
    'radius' => 'Radius',
    'price_from' => 'Price from',
    'price_to' => 'Price to',
    'year_from' => 'Year from',
    'year_to' => 'Year to',
    'mileage_from' => 'Mileage from',
    'mileage_to' => 'Mileage to',
    'power' => 'Power',
    'fuel_type' => 'Fuel Type',
    'transmission' => 'Transmission',
    'color' => 'Color',
    
    // Listings
    'create_listing' => 'Create Listing',
    'edit_listing' => 'Edit Listing',
    'delete_listing' => 'Delete Listing',
    'listing_details' => 'Vehicle Details',
    'contact_seller' => 'Contact Seller',
    'add_to_favorites' => 'Add to Favorites',
    'share' => 'Share',
    'print' => 'Print',
    'report' => 'Report',
    
    // Categories
    'vehicles' => 'Vehicles',
    'cars' => 'Cars',
    'motorcycles' => 'Motorcycles',
    'trucks' => 'Trucks',
    'motorhomes' => 'Motorhomes & Caravans',
    'trailers' => 'Trailers',
    
    // Buttons
    'submit' => 'Submit',
    'cancel' => 'Cancel',
    'save' => 'Save',
    'delete' => 'Delete',
    'edit' => 'Edit',
    'back' => 'Back',
    'next' => 'Next',
    'close' => 'Close',
    'confirm' => 'Confirm',
    
    // Messages
    'success' => 'Success',
    'error' => 'Error',
    'warning' => 'Warning',
    'info' => 'Information',
    'required_field' => 'Required field',
    'invalid_email' => 'Invalid email address',
    'password_too_short' => 'Password too short',
    'listing_created' => 'Listing created successfully',
    'listing_updated' => 'Listing updated successfully',
    'listing_deleted' => 'Listing deleted successfully',
    
    // Packages
    'packages' => 'Packages',
    'free_package' => 'Free',
    'bronze_package' => 'Bronze',
    'silver_package' => 'Silver',
    'gold_package' => 'Gold',
    'platinum_package' => 'Platinum',
    'choose_package' => 'Choose Package',
    'upgrade' => 'Upgrade',
    
    // Footer
    'about_us' => 'About Us',
    'contact' => 'Contact',
    'help' => 'Help',
    'terms' => 'Terms & Conditions',
    'privacy' => 'Privacy Policy',
    'imprint' => 'Imprint',
    'cookie_policy' => 'Cookie Policy',
    
    // Days of week
    'monday' => 'Monday',
    'tuesday' => 'Tuesday',
    'wednesday' => 'Wednesday',
    'thursday' => 'Thursday',
    'friday' => 'Friday',
    'saturday' => 'Saturday',
    'sunday' => 'Sunday',
];
```

---

## 🇪🇸 /languages/es/main.php (ИСПАНСКИЙ)

```php
<?php
return [
    // General
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Bienvenido',
    'search' => 'Buscar',
    'login' => 'Iniciar sesión',
    'register' => 'Registrarse',
    'logout' => 'Cerrar sesión',
    'my_account' => 'Mi cuenta',
    'settings' => 'Configuración',
    'language' => 'Idioma',
    
    // Menú
    'menu_home' => 'Inicio',
    'menu_search' => 'Buscar',
    'menu_sell' => 'Vender',
    'menu_favorites' => 'Favoritos',
    'menu_messages' => 'Mensajes',
    'menu_help' => 'Ayuda',
    
    // Búsqueda
    'search_placeholder' => 'Marca, modelo o tipo',
    'advanced_search' => 'Búsqueda avanzada',
    'radius' => 'Radio',
    'price_from' => 'Precio desde',
    'price_to' => 'Precio hasta',
    'year_from' => 'Año desde',
    'year_to' => 'Año hasta',
    'mileage_from' => 'Kilometraje desde',
    'mileage_to' => 'Kilometraje hasta',
    'power' => 'Potencia',
    'fuel_type' => 'Tipo de combustible',
    'transmission' => 'Transmisión',
    'color' => 'Color',
    
    // Anuncios
    'create_listing' => 'Crear anuncio',
    'edit_listing' => 'Editar anuncio',
    'delete_listing' => 'Eliminar anuncio',
    'listing_details' => 'Detalles del vehículo',
    'contact_seller' => 'Contactar vendedor',
    'add_to_favorites' => 'Añadir a favoritos',
    'share' => 'Compartir',
    'print' => 'Imprimir',
    'report' => 'Reportar',
    
    // Categorías
    'vehicles' => 'Vehículos',
    'cars' => 'Coches',
    'motorcycles' => 'Motocicletas',
    'trucks' => 'Camiones',
    'motorhomes' => 'Autocaravanas',
    'trailers' => 'Remolques',
    
    // Botones
    'submit' => 'Enviar',
    'cancel' => 'Cancelar',
    'save' => 'Guardar',
    'delete' => 'Eliminar',
    'edit' => 'Editar',
    'back' => 'Atrás',
    'next' => 'Siguiente',
    'close' => 'Cerrar',
    'confirm' => 'Confirmar',
    
    // Mensajes
    'success' => 'Éxito',
    'error' => 'Error',
    'warning' => 'Advertencia',
    'info' => 'Información',
    'required_field' => 'Campo obligatorio',
    'invalid_email' => 'Correo electrónico no válido',
    'password_too_short' => 'Contraseña demasiado corta',
    'listing_created' => 'Anuncio creado correctamente',
    'listing_updated' => 'Anuncio actualizado correctamente',
    'listing_deleted' => 'Anuncio eliminado correctamente',
    
    // Paquetes
    'packages' => 'Paquetes',
    'free_package' => 'Gratis',
    'bronze_package' => 'Bronce',
    'silver_package' => 'Plata',
    'gold_package' => 'Oro',
    'platinum_package' => 'Platino',
    'choose_package' => 'Elegir paquete',
    'upgrade' => 'Mejorar',
    
    // Pie de página
    'about_us' => 'Sobre nosotros',
    'contact' => 'Contacto',
    'help' => 'Ayuda',
    'terms' => 'Términos y condiciones',
    'privacy' => 'Política de privacidad',
    'imprint' => 'Aviso legal',
    'cookie_policy' => 'Política de cookies',
    
    // Días de la semana
    'monday' => 'Lunes',
    'tuesday' => 'Martes',
    'wednesday' => 'Miércoles',
    'thursday' => 'Jueves',
    'friday' => 'Viernes',
    'saturday' => 'Sábado',
    'sunday' => 'Domingo',
];
```

---

## 🇫🇷 /languages/fr/main.php (ФРАНЦУЗСКИЙ)

```php
<?php
return [
    // Général
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Bienvenue',
    'search' => 'Rechercher',
    'login' => 'Connexion',
    'register' => 'S\'inscrire',
    'logout' => 'Déconnexion',
    'my_account' => 'Mon compte',
    'settings' => 'Paramètres',
    'language' => 'Langue',
    
    // Menu
    'menu_home' => 'Accueil',
    'menu_search' => 'Recherche',
    'menu_sell' => 'Vendre',
    'menu_favorites' => 'Favoris',
    'menu_messages' => 'Messages',
    'menu_help' => 'Aide',
    
    // Recherche
    'search_placeholder' => 'Marque, modèle ou type',
    'advanced_search' => 'Recherche avancée',
    'radius' => 'Rayon',
    'price_from' => 'Prix minimum',
    'price_to' => 'Prix maximum',
    'year_from' => 'Année minimum',
    'year_to' => 'Année maximum',
    'mileage_from' => 'Kilométrage minimum',
    'mileage_to' => 'Kilométrage maximum',
    'power' => 'Puissance',
    'fuel_type' => 'Type de carburant',
    'transmission' => 'Transmission',
    'color' => 'Couleur',
    
    // Annonces
    'create_listing' => 'Créer une annonce',
    'edit_listing' => 'Modifier l\'annonce',
    'delete_listing' => 'Supprimer l\'annonce',
    'listing_details' => 'Détails du véhicule',
    'contact_seller' => 'Contacter le vendeur',
    'add_to_favorites' => 'Ajouter aux favoris',
    'share' => 'Partager',
    'print' => 'Imprimer',
    'report' => 'Signaler',
    
    // Catégories
    'vehicles' => 'Véhicules',
    'cars' => 'Voitures',
    'motorcycles' => 'Motos',
    'trucks' => 'Camions',
    'motorhomes' => 'Camping-cars',
    'trailers' => 'Remorques',
    
    // Boutons
    'submit' => 'Envoyer',
    'cancel' => 'Annuler',
    'save' => 'Enregistrer',
    'delete' => 'Supprimer',
    'edit' => 'Modifier',
    'back' => 'Retour',
    'next' => 'Suivant',
    'close' => 'Fermer',
    'confirm' => 'Confirmer',
    
    // Messages
    'success' => 'Succès',
    'error' => 'Erreur',
    'warning' => 'Avertissement',
    'info' => 'Information',
    'required_field' => 'Champ obligatoire',
    'invalid_email' => 'Adresse e-mail invalide',
    'password_too_short' => 'Mot de passe trop court',
    'listing_created' => 'Annonce créée avec succès',
    'listing_updated' => 'Annonce mise à jour avec succès',
    'listing_deleted' => 'Annonce supprimée avec succès',
    
    // Forfaits
    'packages' => 'Forfaits',
    'free_package' => 'Gratuit',
    'bronze_package' => 'Bronze',
    'silver_package' => 'Argent',
    'gold_package' => 'Or',
    'platinum_package' => 'Platine',
    'choose_package' => 'Choisir un forfait',
    'upgrade' => 'Mettre à niveau',
    
    // Pied de page
    'about_us' => 'À propos',
    'contact' => 'Contact',
    'help' => 'Aide',
    'terms' => 'Conditions générales',
    'privacy' => 'Politique de confidentialité',
    'imprint' => 'Mentions légales',
    'cookie_policy' => 'Politique des cookies',
    
    // Jours de la semaine
    'monday' => 'Lundi',
    'tuesday' => 'Mardi',
    'wednesday' => 'Mercredi',
    'thursday' => 'Jeudi',
    'friday' => 'Vendredi',
    'saturday' => 'Samedi',
    'sunday' => 'Dimanche',
];
```

---

## 🇳🇱 /languages/nl/main.php (НИДЕРЛАНДСКИЙ)

```php
<?php
return [
    // Algemeen
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Welkom',
    'search' => 'Zoeken',
    'login' => 'Inloggen',
    'register' => 'Registreren',
    'logout' => 'Uitloggen',
    'my_account' => 'Mijn account',
    'settings' => 'Instellingen',
    'language' => 'Taal',
    
    // Menu
    'menu_home' => 'Home',
    'menu_search' => 'Zoeken',
    'menu_sell' => 'Verkopen',
    'menu_favorites' => 'Favorieten',
    'menu_messages' => 'Berichten',
    'menu_help' => 'Hulp',
    
    // Zoeken
    'search_placeholder' => 'Merk, model of type',
    'advanced_search' => 'Geavanceerd zoeken',
    'radius' => 'Straal',
    'price_from' => 'Prijs vanaf',
    'price_to' => 'Prijs tot',
    'year_from' => 'Jaar vanaf',
    'year_to' => 'Jaar tot',
    'mileage_from' => 'Kilometerstand vanaf',
    'mileage_to' => 'Kilometerstand tot',
    'power' => 'Vermogen',
    'fuel_type' => 'Brandstoftype',
    'transmission' => 'Transmissie',
    'color' => 'Kleur',
    
    // Advertenties
    'create_listing' => 'Advertentie plaatsen',
    'edit_listing' => 'Advertentie bewerken',
    'delete_listing' => 'Advertentie verwijderen',
    'listing_details' => 'Voertuigdetails',
    'contact_seller' => 'Contact met verkoper',
    'add_to_favorites' => 'Toevoegen aan favorieten',
    'share' => 'Delen',
    'print' => 'Afdrukken',
    'report' => 'Melden',
    
    // Categorieën
    'vehicles' => 'Voertuigen',
    'cars' => 'Auto\'s',
    'motorcycles' => 'Motoren',
    'trucks' => 'Vrachtwagens',
    'motorhomes' => 'Campers',
    'trailers' => 'Aanhangers',
    
    // Knoppen
    'submit' => 'Verzenden',
    'cancel' => 'Annuleren',
    'save' => 'Opslaan',
    'delete' => 'Verwijderen',
    'edit' => 'Bewerken',
    'back' => 'Terug',
    'next' => 'Volgende',
    'close' => 'Sluiten',
    'confirm' => 'Bevestigen',
    
    // Berichten
    'success' => 'Succes',
    'error' => 'Fout',
    'warning' => 'Waarschuwing',
    'info' => 'Informatie',
    'required_field' => 'Verplicht veld',
    'invalid_email' => 'Ongeldig e-mailadres',
    'password_too_short' => 'Wachtwoord te kort',
    'listing_created' => 'Advertentie succesvol aangemaakt',
    'listing_updated' => 'Advertentie succesvol bijgewerkt',
    'listing_deleted' => 'Advertentie succesvol verwijderd',
    
    // Pakketten
    'packages' => 'Pakketten',
    'free_package' => 'Gratis',
    'bronze_package' => 'Brons',
    'silver_package' => 'Zilver',
    'gold_package' => 'Goud',
    'platinum_package' => 'Platina',
    'choose_package' => 'Pakket kiezen',
    'upgrade' => 'Upgraden',
    
    // Footer
    'about_us' => 'Over ons',
    'contact' => 'Contact',
    'help' => 'Hulp',
    'terms' => 'Voorwaarden',
    'privacy' => 'Privacybeleid',
    'imprint' => 'Colofon',
    'cookie_policy' => 'Cookiebeleid',
    
    // Dagen van de week
    'monday' => 'Maandag',
    'tuesday' => 'Dinsdag',
    'wednesday' => 'Woensdag',
    'thursday' => 'Donderdag',
    'friday' => 'Vrijdag',
    'saturday' => 'Zaterdag',
    'sunday' => 'Zondag',
];
```

---

## 🇵🇱 /languages/pl/main.php (ПОЛЬСКИЙ)

```php
<?php
return [
    // Ogólne
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Witamy',
    'search' => 'Szukaj',
    'login' => 'Zaloguj się',
    'register' => 'Zarejestruj się',
    'logout' => 'Wyloguj się',
    'my_account' => 'Moje konto',
    'settings' => 'Ustawienia',
    'language' => 'Język',
    
    // Menu
    'menu_home' => 'Strona główna',
    'menu_search' => 'Szukaj',
    'menu_sell' => 'Sprzedaj',
    'menu_favorites' => 'Ulubione',
    'menu_messages' => 'Wiadomości',
    'menu_help' => 'Pomoc',
    
    // Wyszukiwanie
    'search_placeholder' => 'Marka, model lub typ',
    'advanced_search' => 'Wyszukiwanie zaawansowane',
    'radius' => 'Promień',
    'price_from' => 'Cena od',
    'price_to' => 'Cena do',
    'year_from' => 'Rok od',
    'year_to' => 'Rok do',
    'mileage_from' => 'Przebieg od',
    'mileage_to' => 'Przebieg do',
    'power' => 'Moc',
    'fuel_type' => 'Rodzaj paliwa',
    'transmission' => 'Skrzynia biegów',
    'color' => 'Kolor',
    
    // Ogłoszenia
    'create_listing' => 'Dodaj ogłoszenie',
    'edit_listing' => 'Edytuj ogłoszenie',
    'delete_listing' => 'Usuń ogłoszenie',
    'listing_details' => 'Szczegóły pojazdu',
    'contact_seller' => 'Skontaktuj się ze sprzedającym',
    'add_to_favorites' => 'Dodaj do ulubionych',
    'share' => 'Udostępnij',
    'print' => 'Drukuj',
    'report' => 'Zgłoś',
    
    // Kategorie
    'vehicles' => 'Pojazdy',
    'cars' => 'Samochody',
    'motorcycles' => 'Motocykle',
    'trucks' => 'Ciężarówki',
    'motorhomes' => 'Kampery',
    'trailers' => 'Przyczepy',
    
    // Przyciski
    'submit' => 'Wyślij',
    'cancel' => 'Anuluj',
    'save' => 'Zapisz',
    'delete' => 'Usuń',
    'edit' => 'Edytuj',
    'back' => 'Wstecz',
    'next' => 'Dalej',
    'close' => 'Zamknij',
    'confirm' => 'Potwierdź',
    
    // Wiadomości
    'success' => 'Sukces',
    'error' => 'Błąd',
    'warning' => 'Ostrzeżenie',
    'info' => 'Informacja',
    'required_field' => 'Pole wymagane',
    'invalid_email' => 'Nieprawidłowy adres e-mail',
    'password_too_short' => 'Hasło za krótkie',
    'listing_created' => 'Ogłoszenie utworzone pomyślnie',
    'listing_updated' => 'Ogłoszenie zaktualizowane pomyślnie',
    'listing_deleted' => 'Ogłoszenie usunięte pomyślnie',
    
    // Pakiety
    'packages' => 'Pakiety',
    'free_package' => 'Darmowy',
    'bronze_package' => 'Brązowy',
    'silver_package' => 'Srebrny',
    'gold_package' => 'Złoty',
    'platinum_package' => 'Platynowy',
    'choose_package' => 'Wybierz pakiet',
    'upgrade' => 'Ulepsz',
    
    // Stopka
    'about_us' => 'O nas',
    'contact' => 'Kontakt',
    'help' => 'Pomoc',
    'terms' => 'Regulamin',
    'privacy' => 'Polityka prywatności',
    'imprint' => 'Informacje prawne',
    'cookie_policy' => 'Polityka cookies',
    
    // Dni tygodnia
    'monday' => 'Poniedziałek',
    'tuesday' => 'Wtorek',
    'wednesday' => 'Środa',
    'thursday' => 'Czwartek',
    'friday' => 'Piątek',
    'saturday' => 'Sobota',
    'sunday' => 'Niedziela',
];
```

---

## 🇷🇴 /languages/ro/main.php (РУМЫНСКИЙ)

```php
<?php
return [
    // General
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Bun venit',
    'search' => 'Căutare',
    'login' => 'Autentificare',
    'register' => 'Înregistrare',
    'logout' => 'Deconectare',
    'my_account' => 'Contul meu',
    'settings' => 'Setări',
    'language' => 'Limbă',
    
    // Meniu
    'menu_home' => 'Acasă',
    'menu_search' => 'Căutare',
    'menu_sell' => 'Vinde',
    'menu_favorites' => 'Favorite',
    'menu_messages' => 'Mesaje',
    'menu_help' => 'Ajutor',
    
    // Căutare
    'search_placeholder' => 'Marcă, model sau tip',
    'advanced_search' => 'Căutare avansată',
    'radius' => 'Rază',
    'price_from' => 'Preț de la',
    'price_to' => 'Preț până la',
    'year_from' => 'An de la',
    'year_to' => 'An până la',
    'mileage_from' => 'Kilometraj de la',
    'mileage_to' => 'Kilometraj până la',
    'power' => 'Putere',
    'fuel_type' => 'Tip combustibil',
    'transmission' => 'Transmisie',
    'color' => 'Culoare',
    
    // Anunțuri
    'create_listing' => 'Creează anunț',
    'edit_listing' => 'Editează anunț',
    'delete_listing' => 'Șterge anunț',
    'listing_details' => 'Detalii vehicul',
    'contact_seller' => 'Contactează vânzătorul',
    'add_to_favorites' => 'Adaugă la favorite',
    'share' => 'Distribuie',
    'print' => 'Tipărește',
    'report' => 'Raportează',
    
    // Categorii
    'vehicles' => 'Vehicule',
    'cars' => 'Mașini',
    'motorcycles' => 'Motociclete',
    'trucks' => 'Camioane',
    'motorhomes' => 'Rulote',
    'trailers' => 'Remorci',
    
    // Butoane
    'submit' => 'Trimite',
    'cancel' => 'Anulează',
    'save' => 'Salvează',
    'delete' => 'Șterge',
    'edit' => 'Editează',
    'back' => 'Înapoi',
    'next' => 'Următorul',
    'close' => 'Închide',
    'confirm' => 'Confirmă',
    
    // Mesaje
    'success' => 'Succes',
    'error' => 'Eroare',
    'warning' => 'Avertisment',
    'info' => 'Informație',
    'required_field' => 'Câmp obligatoriu',
    'invalid_email' => 'Adresă de email invalidă',
    'password_too_short' => 'Parolă prea scurtă',
    'listing_created' => 'Anunț creat cu succes',
    'listing_updated' => 'Anunț actualizat cu succes',
    'listing_deleted' => 'Anunț șters cu succes',
    
    // Pachete
    'packages' => 'Pachete',
    'free_package' => 'Gratuit',
    'bronze_package' => 'Bronz',
    'silver_package' => 'Argint',
    'gold_package' => 'Aur',
    'platinum_package' => 'Platină',
    'choose_package' => 'Alege pachet',
    'upgrade' => 'Upgrade',
    
    // Footer
    'about_us' => 'Despre noi',
    'contact' => 'Contact',
    'help' => 'Ajutor',
    'terms' => 'Termeni și condiții',
    'privacy' => 'Politica de confidențialitate',
    'imprint' => 'Informații legale',
    'cookie_policy' => 'Politica de cookie-uri',
    
    // Zilele săptămânii
    'monday' => 'Luni',
    'tuesday' => 'Marți',
    'wednesday' => 'Miercuri',
    'thursday' => 'Joi',
    'friday' => 'Vineri',
    'saturday' => 'Sâmbătă',
    'sunday' => 'Duminică',
];
```

---

## 🇷🇺 /languages/ru/main.php (РУССКИЙ)

```php
<?php
return [
    // Общее
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Добро пожаловать',
    'search' => 'Поиск',
    'login' => 'Войти',
    'register' => 'Регистрация',
    'logout' => 'Выйти',
    'my_account' => 'Мой аккаунт',
    'settings' => 'Настройки',
    'language' => 'Язык',
    
    // Меню
    'menu_home' => 'Главная',
    'menu_search' => 'Поиск',
    'menu_sell' => 'Продать',
    'menu_favorites' => 'Избранное',
    'menu_messages' => 'Сообщения',
    'menu_help' => 'Помощь',
    
    // Поиск
    'search_placeholder' => 'Марка, модель или тип',
    'advanced_search' => 'Расширенный поиск',
    'radius' => 'Радиус',
    'price_from' => 'Цена от',
    'price_to' => 'Цена до',
    'year_from' => 'Год от',
    'year_to' => 'Год до',
    'mileage_from' => 'Пробег от',
    'mileage_to' => 'Пробег до',
    'power' => 'Мощность',
    'fuel_type' => 'Тип топлива',
    'transmission' => 'Коробка передач',
    'color' => 'Цвет',
    
    // Объявления
    'create_listing' => 'Создать объявление',
    'edit_listing' => 'Редактировать объявление',
    'delete_listing' => 'Удалить объявление',
    'listing_details' => 'Детали автомобиля',
    'contact_seller' => 'Связаться с продавцом',
    'add_to_favorites' => 'Добавить в избранное',
    'share' => 'Поделиться',
    'print' => 'Распечатать',
    'report' => 'Пожаловаться',
    
    // Категории
    'vehicles' => 'Транспорт',
    'cars' => 'Автомобили',
    'motorcycles' => 'Мотоциклы',
    'trucks' => 'Грузовики',
    'motorhomes' => 'Дома на колёсах',
    'trailers' => 'Прицепы',
    
    // Кнопки
    'submit' => 'Отправить',
    'cancel' => 'Отмена',
    'save' => 'Сохранить',
    'delete' => 'Удалить',
    'edit' => 'Редактировать',
    'back' => 'Назад',
    'next' => 'Далее',
    'close' => 'Закрыть',
    'confirm' => 'Подтвердить',
    
    // Сообщения
    'success' => 'Успешно',
    'error' => 'Ошибка',
    'warning' => 'Предупреждение',
    'info' => 'Информация',
    'required_field' => 'Обязательное поле',
    'invalid_email' => 'Неверный email адрес',
    'password_too_short' => 'Пароль слишком короткий',
    'listing_created' => 'Объявление успешно создано',
    'listing_updated' => 'Объявление успешно обновлено',
    'listing_deleted' => 'Объявление успешно удалено',
    
    // Пакеты
    'packages' => 'Пакеты',
    'free_package' => 'Бесплатный',
    'bronze_package' => 'Бронзовый',
    'silver_package' => 'Серебряный',
    'gold_package' => 'Золотой',
    'platinum_package' => 'Платиновый',
    'choose_package' => 'Выбрать пакет',
    'upgrade' => 'Обновить',
    
    // Подвал
    'about_us' => 'О нас',
    'contact' => 'Контакты',
    'help' => 'Помощь',
    'terms' => 'Условия использования',
    'privacy' => 'Политика конфиденциальности',
    'imprint' => 'Правовая информация',
    'cookie_policy' => 'Политика cookie',
    
    // Дни недели
    'monday' => 'Понедельник',
    'tuesday' => 'Вторник',
    'wednesday' => 'Среда',
    'thursday' => 'Четверг',
    'friday' => 'Пятница',
    'saturday' => 'Суббота',
    'sunday' => 'Воскресенье',
];
```

---

## 🇨🇿 /languages/cs/main.php (ЧЕШСКИЙ)

```php
<?php
return [
    // Obecné
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Vítejte',
    'search' => 'Hledat',
    'login' => 'Přihlásit se',
    'register' => 'Registrovat',
    'logout' => 'Odhlásit se',
    'my_account' => 'Můj účet',
    'settings' => 'Nastavení',
    'language' => 'Jazyk',
    
    // Menu
    'menu_home' => 'Domů',
    'menu_search' => 'Hledat',
    'menu_sell' => 'Prodat',
    'menu_favorites' => 'Oblíbené',
    'menu_messages' => 'Zprávy',
    'menu_help' => 'Nápověda',
    
    // Vyhledávání
    'search_placeholder' => 'Značka, model nebo typ',
    'advanced_search' => 'Pokročilé vyhledávání',
    'radius' => 'Poloměr',
    'price_from' => 'Cena od',
    'price_to' => 'Cena do',
    'year_from' => 'Rok od',
    'year_to' => 'Rok do',
    'mileage_from' => 'Najeté km od',
    'mileage_to' => 'Najeté km do',
    'power' => 'Výkon',
    'fuel_type' => 'Typ paliva',
    'transmission' => 'Převodovka',
    'color' => 'Barva',
    
    // Inzeráty
    'create_listing' => 'Vytvořit inzerát',
    'edit_listing' => 'Upravit inzerát',
    'delete_listing' => 'Smazat inzerát',
    'listing_details' => 'Detaily vozidla',
    'contact_seller' => 'Kontaktovat prodejce',
    'add_to_favorites' => 'Přidat do oblíbených',
    'share' => 'Sdílet',
    'print' => 'Tisknout',
    'report' => 'Nahlásit',
    
    // Kategorie
    'vehicles' => 'Vozidla',
    'cars' => 'Auta',
    'motorcycles' => 'Motocykly',
    'trucks' => 'Nákladní vozy',
    'motorhomes' => 'Obytné vozy',
    'trailers' => 'Přívěsy',
    
    // Tlačítka
    'submit' => 'Odeslat',
    'cancel' => 'Zrušit',
    'save' => 'Uložit',
    'delete' => 'Smazat',
    'edit' => 'Upravit',
    'back' => 'Zpět',
    'next' => 'Další',
    'close' => 'Zavřít',
    'confirm' => 'Potvrdit',
    
    // Zprávy
    'success' => 'Úspěch',
    'error' => 'Chyba',
    'warning' => 'Varování',
    'info' => 'Informace',
    'required_field' => 'Povinné pole',
    'invalid_email' => 'Neplatná e-mailová adresa',
    'password_too_short' => 'Heslo je příliš krátké',
    'listing_created' => 'Inzerát úspěšně vytvořen',
    'listing_updated' => 'Inzerát úspěšně aktualizován',
    'listing_deleted' => 'Inzerát úspěšně smazán',
    
    // Balíčky
    'packages' => 'Balíčky',
    'free_package' => 'Zdarma',
    'bronze_package' => 'Bronzový',
    'silver_package' => 'Stříbrný',
    'gold_package' => 'Zlatý',
    'platinum_package' => 'Platinový',
    'choose_package' => 'Vybrat balíček',
    'upgrade' => 'Upgradovat',
    
    // Zápatí
    'about_us' => 'O nás',
    'contact' => 'Kontakt',
    'help' => 'Nápověda',
    'terms' => 'Obchodní podmínky',
    'privacy' => 'Zásady ochrany osobních údajů',
    'imprint' => 'Právní informace',
    'cookie_policy' => 'Zásady používání souborů cookie',
    
    // Dny v týdnu
    'monday' => 'Pondělí',
    'tuesday' => 'Úterý',
    'wednesday' => 'Středa',
    'thursday' => 'Čtvrtek',
    'friday' => 'Pátek',
    'saturday' => 'Sobota',
    'sunday' => 'Neděle',
];
```

---

## 🇹🇷 /languages/tr/main.php (ТУРЕЦКИЙ)

```php
<?php
return [
    // Genel
    'site_name' => 'Auto Marketplace',
    'welcome' => 'Hoş geldiniz',
    'search' => 'Ara',
    'login' => 'Giriş yap',
    'register' => 'Kayıt ol',
    'logout' => 'Çıkış yap',
    'my_account' => 'Hesabım',
    'settings' => 'Ayarlar',
    'language' => 'Dil',
    
    // Menü
    'menu_home' => 'Ana sayfa',
    'menu_search' => 'Ara',
    'menu_sell' => 'Sat',
    'menu_favorites' => 'Favoriler',
    'menu_messages' => 'Mesajlar',
    'menu_help' => 'Yardım',
    
    // Arama
    'search_placeholder' => 'Marka, model veya tip',
    'advanced_search' => 'Gelişmiş arama',
    'radius' => 'Yarıçap',
    'price_from' => 'Fiyat (başlangıç)',
    'price_to' => 'Fiyat (bitiş)',
    'year_from' => 'Yıl (başlangıç)',
    'year_to' => 'Yıl (bitiş)',
    'mileage_from' => 'Kilometre (başlangıç)',
    'mileage_to' => 'Kilometre (bitiş)',
    'power' => 'Güç',
    'fuel_type' => 'Yakıt türü',
    'transmission' => 'Şanzıman',
    'color' => 'Renk',
    
    // İlanlar
    'create_listing' => 'İlan oluştur',
    'edit_listing' => 'İlanı düzenle',
    'delete_listing' => 'İlanı sil',
    'listing_details' => 'Araç detayları',
    'contact_seller' => 'Satıcıyla iletişime geç',
    'add_to_favorites' => 'Favorilere ekle',
    'share' => 'Paylaş',
    'print' => 'Yazdır',
    'report' => 'Bildir',
    
    // Kategoriler
    'vehicles' => 'Araçlar',
    'cars' => 'Otomobiller',
    'motorcycles' => 'Motosikletler',
    'trucks' => 'Kamyonlar',
    'motorhomes' => 'Karavanlar',
    'trailers' => 'Römorklar',
    
    // Düğmeler
    'submit' => 'Gönder',
    'cancel' => 'İptal',
    'save' => 'Kaydet',
    'delete' => 'Sil',
    'edit' => 'Düzenle',
    'back' => 'Geri',
    'next' => 'İleri',
    'close' => 'Kapat',
    'confirm' => 'Onayla',
    
    // Mesajlar
    'success' => 'Başarılı',
    'error' => 'Hata',
    'warning' => 'Uyarı',
    'info' => 'Bilgi',
    'required_field' => 'Zorunlu alan',
    'invalid_email' => 'Geçersiz e-posta adresi',
    'password_too_short' => 'Şifre çok kısa',
    'listing_created' => 'İlan başarıyla oluşturuldu',
    'listing_updated' => 'İlan başarıyla güncellendi',
    'listing_deleted' => 'İlan başarıyla silindi',
    
    // Paketler
    'packages' => 'Paketler',
    'free_package' => 'Ücretsiz',
    'bronze_package' => 'Bronz',
    'silver_package' => 'Gümüş',
    'gold_package' => 'Altın',
    'platinum_package' => 'Platin',
    'choose_package' => 'Paket seç',
    'upgrade' => 'Yükselt',
    
    // Alt bilgi
    'about_us' => 'Hakkımızda',
    'contact' => 'İletişim',
    'help' => 'Yardım',
    'terms' => 'Kullanım koşulları',
    'privacy' => 'Gizlilik politikası',
    'imprint' => 'Yasal bilgiler',
    'cookie_policy' => 'Çerez politikası',
    
    // Haftanın günleri
    'monday' => 'Pazartesi',
    'tuesday' => 'Salı',
    'wednesday' => 'Çarşamba',
    'thursday' => 'Perşembe',
    'friday' => 'Cuma',
    'saturday' => 'Cumartesi',
    'sunday' => 'Pazar',
];
```

---

## ✅ ИТОГО

### Создано 10 файлов переводов:
- ✅ Немецкий (Deutsch) - по умолчанию
- ✅ Английский (English)
- ✅ Испанский (Español)
- ✅ Французский (Français)
- ✅ Нидерландский (Nederlands)
- ✅ Польский (Polski)
- ✅ Румынский (Română)
- ✅ Русский (Русский)
- ✅ Чешский (Čeština)
- ✅ Турецкий (Türk)

### Каждый файл содержит:
- 60+ базовых переводов
- Все пункты меню
- Все кнопки и формы
- Категории транспорта
- Сообщения об ошибках
- Названия пакетов
- Дни недели
- Футер

**Точно как на mobile.de!** ✅