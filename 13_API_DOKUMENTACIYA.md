# 📡 AUTOMARKET REST API ДОКУМЕНТАЦИЯ

## 📋 СОДЕРЖАНИЕ

1. Введение
2. Аутентификация
3. Endpoints - Пользователи
4. Endpoints - Объявления
5. Endpoints - Категории
6. Endpoints - Поиск
7. Endpoints - Платежи
8. Endpoints - Чат
9. Endpoints - Уведомления
10. Endpoints - Аналитика
11. Webhooks
12. Коды ошибок
13. Rate Limiting
14. Примеры использования

---

## 1️⃣ ВВЕДЕНИЕ

### Base URL

```
Production: https://api.automarket.com/v1
Staging: https://api-staging.automarket.com/v1
Development: http://localhost/api/v1
```

### Формат данных

- **Request**: JSON
- **Response**: JSON
- **Charset**: UTF-8

### Заголовки

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
Accept-Language: de
```

---

## 2️⃣ АУТЕНТИФИКАЦИЯ

### Регистрация

**POST** `/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "password_confirm": "SecurePass123!",
  "account_type": "individual",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+491234567890",
  "gdpr_consent": true,
  "marketing_consent": false,
  "recaptcha_token": "03AGdBq..."
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Registration successful. Please verify your email.",
  "data": {
    "user_id": 12345,
    "email": "user@example.com",
    "email_verified": false
  }
}
```

### Вход

**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "remember_me": true
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "def502003e8c7a...",
    "user": {
      "id": 12345,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "account_type": "individual",
      "avatar": "https://cdn.automarket.com/avatars/12345.jpg"
    }
  }
}
```

### Обновление токена

**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "def502003e8c7a..."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### Выход

**POST** `/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### Восстановление пароля

**POST** `/auth/forgot-password`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Password reset link sent to your email"
}
```

---

## 3️⃣ ENDPOINTS - ПОЛЬЗОВАТЕЛИ

### Получить профиль

**GET** `/users/me`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 12345,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+491234567890",
    "account_type": "individual",
    "email_verified": true,
    "avatar": "https://cdn.automarket.com/avatars/12345.jpg",
    "created_at": "2024-01-15T10:30:00Z",
    "stats": {
      "active_listings": 5,
      "sold_items": 12,
      "reviews_count": 8,
      "average_rating": 4.5
    }
  }
}
```

### Обновить профиль

**PUT** `/users/me`

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Smith",
  "phone": "+491234567890",
  "city": "Berlin",
  "zip_code": "10115"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 12345,
    "first_name": "John",
    "last_name": "Smith",
    "phone": "+491234567890",
    "city": "Berlin",
    "zip_code": "10115"
  }
}
```

### Загрузить аватар

**POST** `/users/me/avatar`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
```
avatar: [file]
```

**Response 200:**
```json
{
  "success": true,
  "message": "Avatar uploaded successfully",
  "data": {
    "avatar_url": "https://cdn.automarket.com/avatars/12345.jpg"
  }
}
```

### Получить объявления пользователя

**GET** `/users/me/listings`

**Query Parameters:**
- `status` (string): active, pending, sold, expired
- `page` (int): номер страницы (default: 1)
- `per_page` (int): количество на странице (default: 20)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "listings": [
      {
        "id": 789,
        "title": "BMW 3 Series 320d",
        "price": 25000,
        "currency": "EUR",
        "status": "active",
        "views": 523,
        "favorites": 12,
        "created_at": "2024-01-20T15:00:00Z",
        "expires_at": "2024-04-20T15:00:00Z",
        "main_photo": "https://cdn.automarket.com/listings/789/main.jpg"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "per_page": 20,
      "total_items": 56
    }
  }
}
```

---

## 4️⃣ ENDPOINTS - ОБЪЯВЛЕНИЯ

### Получить список объявлений

**GET** `/listings`

**Query Parameters:**
- `category_id` (int): ID категории
- `brand` (string): марка автомобиля
- `model` (string): модель
- `year_from` (int): год от
- `year_to` (int): год до
- `price_from` (int): цена от
- `price_to` (int): цена до
- `mileage_from` (int): пробег от
- `mileage_to` (int): пробег до
- `fuel_type` (string): тип топлива
- `transmission` (string): коробка передач
- `city` (string): город
- `zip_code` (string): почтовый индекс
- `radius` (int): радиус поиска (км)
- `sort` (string): сортировка (newest, price_asc, price_desc, mileage_asc)
- `page` (int): страница
- `per_page` (int): количество

**Response 200:**
```json
{
  "success": true,
  "data": {
    "listings": [
      {
        "id": 789,
        "title": "BMW 3 Series 320d",
        "slug": "bmw-3-series-320d-2020-789",
        "price": 25000,
        "currency": "EUR",
        "negotiable": true,
        "brand": "BMW",
        "model": "3 Series",
        "year": 2020,
        "mileage": 45000,
        "fuel_type": "diesel",
        "transmission": "automatic",
        "power": 190,
        "color": "black",
        "body_type": "sedan",
        "location": {
          "city": "Berlin",
          "zip_code": "10115",
          "country": "Germany"
        },
        "seller": {
          "id": 12345,
          "name": "John Doe",
          "type": "individual",
          "rating": 4.5,
          "reviews_count": 8
        },
        "photos": [
          {
            "id": 1,
            "url": "https://cdn.automarket.com/listings/789/photo1.jpg",
            "thumbnail": "https://cdn.automarket.com/listings/789/photo1_thumb.jpg",
            "is_main": true
          }
        ],
        "features": {
          "is_highlighted": true,
          "is_top": false,
          "is_urgent": false
        },
        "stats": {
          "views": 523,
          "favorites": 12,
          "inquiries": 5
        },
        "created_at": "2024-01-20T15:00:00Z",
        "updated_at": "2024-01-25T10:30:00Z"
      }
    ],
    "filters": {
      "applied": {
        "brand": "BMW",
        "price_from": 20000,
        "price_to": 30000
      },
      "available": {
        "brands": ["Audi", "BMW", "Mercedes-Benz"],
        "models": ["3 Series", "5 Series", "X5"],
        "fuel_types": ["diesel", "benzin", "hybrid"],
        "price_range": {
          "min": 5000,
          "max": 100000
        }
      }
    },
    "pagination": {
      "current_page": 1,
      "total_pages": 142,
      "per_page": 20,
      "total_items": 2835
    }
  }
}
```

### Получить одно объявление

**GET** `/listings/{id}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 789,
    "title": "BMW 3 Series 320d",
    "description": "Excellent condition, full service history...",
    "slug": "bmw-3-series-320d-2020-789",
    "price": 25000,
    "currency": "EUR",
    "negotiable": true,
    "vat_included": false,
    "category_id": 5,
    "brand": "BMW",
    "model": "3 Series",
    "year": 2020,
    "mileage": 45000,
    "fuel_type": "diesel",
    "transmission": "automatic",
    "power": 190,
    "color": "black",
    "body_type": "sedan",
    "doors": 4,
    "seats": 5,
    "vin": "WBADT43452G123456",
    "first_registration": "2020-03-15",
    "condition": "used",
    "features": [
      "Navigation system",
      "Leather seats",
      "Parking sensors",
      "Cruise control",
      "Climate control"
    ],
    "equipment": {
      "safety": ["ABS", "ESP", "Airbags"],
      "comfort": ["Air conditioning", "Heated seats"],
      "technology": ["Navigation", "Bluetooth"]
    },
    "location": {
      "city": "Berlin",
      "zip_code": "10115",
      "country": "Germany",
      "coordinates": {
        "lat": 52.5200,
        "lng": 13.4050
      }
    },
    "seller": {
      "id": 12345,
      "name": "John Doe",
      "type": "individual",
      "phone": "+491234567890",
      "email": "john@example.com",
      "rating": 4.5,
      "reviews_count": 8,
      "member_since": "2020-05-10"
    },
    "photos": [
      {
        "id": 1,
        "url": "https://cdn.automarket.com/listings/789/photo1.jpg",
        "thumbnail": "https://cdn.automarket.com/listings/789/photo1_thumb.jpg",
        "is_main": true,
        "order": 1
      },
      {
        "id": 2,
        "url": "https://cdn.automarket.com/listings/789/photo2.jpg",
        "thumbnail": "https://cdn.automarket.com/listings/789/photo2_thumb.jpg",
        "is_main": false,
        "order": 2
      }
    ],
    "premium_features": {
      "is_highlighted": true,
      "is_top": false,
      "is_urgent": false,
      "expires_at": "2024-02-20T15:00:00Z"
    },
    "stats": {
      "views": 523,
      "views_today": 12,
      "favorites": 12,
      "inquiries": 5
    },
    "seo": {
      "title": "BMW 3 Series 320d (2020) ab 25.000 € in Berlin",
      "description": "Kaufen Sie BMW 3 Series 320d (2020) mit 45.000 km...",
      "keywords": "BMW, 3 Series, 320d, 2020, gebrauchtwagen"
    },
    "created_at": "2024-01-20T15:00:00Z",
    "updated_at": "2024-01-25T10:30:00Z",
    "expires_at": "2024-04-20T15:00:00Z"
  }
}
```

### Создать объявление

**POST** `/listings`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
```
category_id: 5
brand: BMW
model: 3 Series
year: 2020
mileage: 45000
fuel_type: diesel
transmission: automatic
power: 190
price: 25000
negotiable: true
title: BMW 3 Series 320d
description: Excellent condition...
color: black
body_type: sedan
doors: 4
seats: 5
vin: WBADT43452G123456
city: Berlin
zip_code: 10115
contact_name: John Doe
contact_phone: +491234567890
contact_email: john@example.com
show_phone: true
show_email: true
features[]: Navigation system
features[]: Leather seats
photos[]: [file1]
photos[]: [file2]
photos[]: [file3]
feature_highlighted: 1
feature_top: 0
terms_accepted: true
```

**Response 201:**
```json
{
  "success": true,
  "message": "Listing created successfully",
  "data": {
    "id": 789,
    "slug": "bmw-3-series-320d-2020-789",
    "status": "pending_review",
    "moderation": {
      "status": "pending",
      "estimated_review_time": "2-4 hours"
    },
    "payment_required": {
      "amount": 29.99,
      "currency": "EUR",
      "description": "Premium features",
      "payment_url": "https://automarket.com/payment/abc123"
    }
  }
}
```

### Обновить объявление

**PUT** `/listings/{id}`

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "BMW 3 Series 320d - Updated",
  "price": 24500,
  "description": "Updated description...",
  "mileage": 46000
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Listing updated successfully",
  "data": {
    "id": 789,
    "title": "BMW 3 Series 320d - Updated",
    "price": 24500,
    "updated_at": "2024-01-26T14:20:00Z"
  }
}
```

### Удалить объявление

**DELETE** `/listings/{id}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Listing deleted successfully"
}
```

### Загрузить фото к объявлению

**POST** `/listings/{id}/photos`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
```
photos[]: [file1]
photos[]: [file2]
```

**Response 200:**
```json
{
  "success": true,
  "message": "Photos uploaded successfully",
  "data": {
    "photos": [
      {
        "id": 10,
        "url": "https://cdn.automarket.com/listings/789/photo10.jpg",
        "thumbnail": "https://cdn.automarket.com/listings/789/photo10_thumb.jpg",
        "order": 4
      }
    ]
  }
}
```

### Добавить в избранное

**POST** `/listings/{id}/favorite`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Added to favorites",
  "data": {
    "favorited": true,
    "favorites_count": 13
  }
}
```

### Удалить из избранного

**DELETE** `/listings/{id}/favorite`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Removed from favorites",
  "data": {
    "favorited": false,
    "favorites_count": 12
  }
}
```

---

## 5️⃣ ENDPOINTS - КАТЕГОРИИ

### Получить все категории

**GET** `/categories`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Cars",
        "name_de": "PKW",
        "slug": "cars",
        "icon": "🚗",
        "parent_id": null,
        "level": 1,
        "listings_count": 15420,
        "children": [
          {
            "id": 2,
            "name": "Sedan",
            "name_de": "Limousine",
            "slug": "sedan",
            "parent_id": 1,
            "level": 2,
            "listings_count": 5240
          }
        ]
      }
    ]
  }
}
```

### Получить марки автомобилей

**GET** `/categories/brands`

**Query Parameters:**
- `category_id` (int): ID категории

**Response 200:**
```json
{
  "success": true,
  "data": {
    "brands": [
      {
        "id": 1,
        "name": "Audi",
        "logo": "https://cdn.automarket.com/brands/audi.svg",
        "listings_count": 1245
      },
      {
        "id": 2,
        "name": "BMW",
        "logo": "https://cdn.automarket.com/brands/bmw.svg",
        "listings_count": 1830
      }
    ]
  }
}
```

### Получить модели по марке

**GET** `/categories/brands/{brand}/models`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "models": [
      {
        "id": 1,
        "name": "3 Series",
        "brand_id": 2,
        "listings_count": 456
      },
      {
        "id": 2,
        "name": "5 Series",
        "brand_id": 2,
        "listings_count": 328
      }
    ]
  }
}
```

---

## 6️⃣ ENDPOINTS - ПОИСК

### Поиск объявлений

**GET** `/search`

**Query Parameters:**
- `q` (string): поисковый запрос
- `category_id` (int)
- `brand` (string)
- `model` (string)
- `price_from` (int)
- `price_to` (int)
- `year_from` (int)
- `year_to` (int)
- `location` (string): город или почтовый индекс
- `radius` (int): радиус в км
- `sort` (string): newest, price_asc, price_desc

**Response 200:**
```json
{
  "success": true,
  "data": {
    "query": "BMW 320d Berlin",
    "total_results": 142,
    "search_time": 0.023,
    "listings": [...],
    "suggestions": [
      "BMW 320d Touring",
      "BMW 318d",
      "BMW 520d"
    ],
    "filters": {...},
    "pagination": {...}
  }
}
```

### Автодополнение поиска

**GET** `/search/autocomplete`

**Query Parameters:**
- `q` (string): частичный запрос (минимум 2 символа)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "suggestions": [
      {
        "type": "brand",
        "value": "BMW",
        "count": 1830
      },
      {
        "type": "model",
        "value": "BMW 3 Series",
        "count": 456
      },
      {
        "type": "location",
        "value": "Berlin",
        "count": 3240
      }
    ]
  }
}
```

---

## 7️⃣ ENDPOINTS - ПЛАТЕЖИ

### Создать платёж

**POST** `/payments`

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "listing_id": 789,
  "payment_method": "stripe",
  "items": [
    {
      "type": "feature_highlighted",
      "price": 19.99
    },
    {
      "type": "feature_top",
      "price": 29.99
    }
  ],
  "return_url": "https://automarket.com/payment/success",
  "cancel_url": "https://automarket.com/payment/cancel"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "payment_id": "pay_abc123",
    "amount": 49.98,
    "currency": "EUR",
    "status": "pending",
    "payment_url": "https://checkout.stripe.com/pay/cs_test_..."
  }
}
```

### Получить статус платежа

**GET** `/payments/{payment_id}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "payment_id": "pay_abc123",
    "status": "completed",
    "amount": 49.98,
    "currency": "EUR",
    "payment_method": "stripe",
    "created_at": "2024-01-26T15:00:00Z",
    "completed_at": "2024-01-26T15:02:30Z"
  }
}
```

---

## 8️⃣ ENDPOINTS - ЧАТ

### Отправить сообщение

**POST** `/messages`

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "recipient_id": 67890,
  "listing_id": 789,
  "message": "Hello, is the car still available?"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "message_id": 12345,
    "conversation_id": 456,
    "sent_at": "2024-01-26T16:00:00Z"
  }
}
```

### Получить беседы

**GET** `/conversations`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "conversations": [
      {
        "id": 456,
        "listing": {
          "id": 789,
          "title": "BMW 3 Series 320d",
          "photo": "https://cdn.automarket.com/listings/789/main.jpg"
        },
        "participant": {
          "id": 67890,
          "name": "Jane Smith",
          "avatar": "https://cdn.automarket.com/avatars/67890.jpg",
          "online": true
        },
        "last_message": {
          "text": "Yes, it is still available",
          "sent_at": "2024-01-26T16:05:00Z",
          "read": false
        },
        "unread_count": 2
      }
    ]
  }
}
```

### Получить сообщения беседы

**GET** `/conversations/{conversation_id}/messages`

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (int)
- `per_page` (int): default 50

**Response 200:**
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": 12345,
        "sender_id": 12345,
        "text": "Hello, is the car still available?",
        "sent_at": "2024-01-26T16:00:00Z",
        "read": true,
        "read_at": "2024-01-26T16:01:00Z"
      },
      {
        "id": 12346,
        "sender_id": 67890,
        "text": "Yes, it is still available",
        "sent_at": "2024-01-26T16:05:00Z",
        "read": false
      }
    ],
    "pagination": {...}
  }
}
```

---

## 9️⃣ ENDPOINTS - УВЕДОМЛЕНИЯ

### Получить уведомления

**GET** `/notifications`

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `unread_only` (bool): только непрочитанные
- `type` (string): тип уведомления
- `page` (int)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 123,
        "type": "new_message",
        "title": "New message from Jane Smith",
        "body": "Is the car still available?",
        "data": {
          "conversation_id": 456,
          "sender_id": 67890
        },
        "read": false,
        "created_at": "2024-01-26T16:00:00Z"
      }
    ],
    "unread_count": 5
  }
}
```

### Отметить как прочитанное

**PUT** `/notifications/{id}/read`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

## 🔟 ENDPOINTS - АНАЛИТИКА

### Получить статистику объявления

**GET** `/listings/{id}/analytics`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": "last_30_days",
    "views": {
      "total": 523,
      "unique": 387,
      "by_day": [
        {"date": "2024-01-01", "views": 12},
        {"date": "2024-01-02", "views": 18}
      ]
    },
    "favorites": 12,
    "inquiries": 5,
    "phone_reveals": 8,
    "sources": {
      "organic": 245,
      "social": 102,
      "direct": 176
    },
    "devices": {
      "mobile": 312,
      "desktop": 178,
      "tablet": 33
    },
    "locations": [
      {"city": "Berlin", "count": 156},
      {"city": "Munich", "count": 89}
    ]
  }
}
```

---

## 1️⃣1️⃣ WEBHOOKS

### Доступные события

- `payment.completed` - платёж завершён
- `payment.failed` - платёж не прошёл
- `listing.approved` - объявление одобрено
- `listing.rejected` - объявление отклонено
- `message.received` - получено сообщение

### Формат webhook

**POST** `{your_webhook_url}`

**Headers:**
```
X-Automarket-Signature: sha256=abc123...
Content-Type: application/json
```

**Body:**
```json
{
  "event": "payment.completed",
  "timestamp": "2024-01-26T17:00:00Z",
  "data": {
    "payment_id": "pay_abc123",
    "listing_id": 789,
    "amount": 49.98,
    "currency": "EUR"
  }
}
```

---

## 1️⃣2️⃣ КОДЫ ОШИБОК

| Код | Описание |
|-----|----------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Unprocessable Entity |
| 429 | Too Many Requests |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

### Формат ошибки

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": ["Email is required"],
      "password": ["Password must be at least 8 characters"]
    }
  }
}
```

---

## 1️⃣3️⃣ RATE LIMITING

- **Аутентифицированные пользователи**: 1000 запросов/час
- **Неаутентифицированные**: 100 запросов/час

### Заголовки

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 985
X-RateLimit-Reset: 1706284800
```

---

## 1️⃣4️⃣ ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### JavaScript (Axios)

```javascript
const axios = require('axios');

const api = axios.create({
  baseURL: 'https://api.automarket.com/v1',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'de'
  }
});

// Вход
const login = async () => {
  const response = await api.post('/auth/login', {
    email: 'user@example.com',
    password: 'SecurePass123!'
  });
  
  const token = response.data.data.access_token;
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  
  return token;
};

// Поиск объявлений
const searchListings = async (query) => {
  const response = await api.get('/search', {
    params: {
      q: query,
      price_to: 30000,
      sort: 'price_asc'
    }
  });
  
  return response.data.data.listings;
};

// Использование
(async () => {
  await login();
  const listings = await searchListings('BMW 320d');
  console.log(listings);
})();
```

### PHP (cURL)

```php
<?php

class AutoMarketAPI {
    private $baseUrl = 'https://api.automarket.com/v1';
    private $token;
    
    public function login($email, $password) {
        $response = $this->request('POST', '/auth/login', [
            'email' => $email,
            'password' => $password
        ]);
        
        $this->token = $response['data']['access_token'];
        return $this->token;
    }
    
    public function searchListings($query, $filters = []) {
        $params = array_merge(['q' => $query], $filters);
        return $this->request('GET', '/search?' . http_build_query($params));
    }
    
    private function request($method, $endpoint, $data = null) {
        $ch = curl_init($this->baseUrl . $endpoint);
        
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json'
        ];
        
        if ($this->token) {
            $headers[] = 'Authorization: Bearer ' . $this->token;
        }
        
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        return json_decode($response, true);
    }
}

// Использование
$api = new AutoMarketAPI();
$api->login('user@example.com', 'SecurePass123!');
$listings = $api->searchListings('BMW 320d', ['price_to' => 30000]);
print_r($listings);
```

### Python (Requests)

```python
import requests

class AutoMarketAPI:
    def __init__(self):
        self.base_url = 'https://api.automarket.com/v1'
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def login(self, email, password):
        response = self.session.post(f'{self.base_url}/auth/login', json={
            'email': email,
            'password': password
        })
        
        data = response.json()
        token = data['data']['access_token']
        self.session.headers.update({'Authorization': f'Bearer {token}'})
        return token
    
    def search_listings(self, query, **filters):
        params = {'q': query, **filters}
        response = self.session.get(f'{self.base_url}/search', params=params)
        return response.json()['data']['listings']

# Использование
api = AutoMarketAPI()
api.login('user@example.com', 'SecurePass123!')
listings = api.search_listings('BMW 320d', price_to=30000)
print(listings)
```

---

## ✅ ИТОГО

API документация включает:
- ✅ Полная аутентификация (JWT)
- ✅ CRUD для пользователей
- ✅ CRUD для объявлений
- ✅ Расширенный поиск
- ✅ Категории и фильтры
- ✅ Платежи
- ✅ Чат и сообщения
- ✅ Уведомления
- ✅ Аналитика
- ✅ Webhooks
- ✅ Rate limiting
- ✅ Примеры на 3 языках

🚀 **API готов к интеграции!**
