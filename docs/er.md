# ER Diyagramı: Otel Rezervasyon Sistemi

Sistem müşterileri, otelleri, oda tiplerini, otel odalarını ve belirli tarihler için yapılan rezervasyonları takip eder. Bir müşteri zaman içinde birden çok rezervasyon yapabilir; aynı oda da farklı tarihlerde birden fazla rezervasyonda yer alabilir.

```mermaid
erDiagram
    HOTEL     ||--o{ ROOM : "barindirir"
    ROOM_TYPE ||--o{ ROOM : "siniflandirir"
    GUEST     ||--o{ RESERVATION : "yapar"
    ROOM      ||--o{ RESERVATION : "rezervasyona konu olur"

    GUEST {
        int guest_id PK
        string full_name
        string email
        string city
        string status
        date joined_date
    }
    HOTEL {
        int hotel_id PK
        string name
        string city
    }
    ROOM_TYPE {
        int room_type_id PK
        string name
    }
    ROOM {
        int room_id PK
        int hotel_id FK
        int room_type_id FK
        string room_number
        decimal nightly_rate
        int max_occupancy
    }
    RESERVATION {
        int reservation_id PK
        int guest_id FK
        int room_id FK
        date booked_on
        date check_in
        date check_out
        int guest_count
        string status
        int rating
    }
```

## İlişkiler ve kardinaliteler

| İlişki | Kardinalite | Açıklama |
|---|---|---|
| HOTEL — ROOM | 1:N | Her oda bir otele aittir; bir otelde çok oda bulunabilir. |
| ROOM_TYPE — ROOM | 1:N | Her oda tek bir oda tipine bağlıdır; aynı tipte çok oda bulunabilir. |
| GUEST — RESERVATION | 1:N | Bir müşteri zaman içinde birçok rezervasyon yapabilir; rezervasyon tek müşteriye aittir. |
| ROOM — RESERVATION | 1:N (zaman içinde) | Bir oda farklı tarihlerde birçok rezervasyonda kullanılabilir; her rezervasyon tek odayı gösterir. |
| GUEST — ROOM | M:N (RESERVATION üzerinden) | Müşteri birden çok oda için rezervasyon yapabilir; oda farklı tarihlerde farklı müşterilerce rezerve edilebilir. |

`reservation` zayıf varlık değildir; kendi `reservation_id` anahtarı vardır. `uq_reservation_guest_room_check_in`, aynı müşteri–oda–giriş tarihi birleşiminin tekrar oluşturulmasını engeller. Tarih aralıklarının birbiriyle çakışmaması ayrı, satırlar arası bir iş kuralıdır.
