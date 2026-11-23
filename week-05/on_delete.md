# Bölüm C: Silme politikaları

Otel rezervasyon sistemindeki dört foreign key için aşağıdaki silme kurallarını kullandım.

| Foreign key | Ebeveyn → çocuk | ON DELETE | Neden? | Neden diğer seçenek değil? |
|---|---|---|---|---|
| `fk_room_hotel` | `hotel` → `room` | `RESTRICT` | Odası bulunan otelin yanlışlıkla silinmesini istemiyorum. | `CASCADE` otelle birlikte odaları da siler. |
| `fk_room_room_type` | `room_type` → `room` | `RESTRICT` | Odaların kullandığı oda tipi silinmemeli. | `SET NULL`, zorunlu `room_type_id` alanına uymaz. |
| `fk_reservation_guest` | `guest` → `reservation` | `CASCADE` | Bu ödev modelinde müşteri silinince ona bağlı rezervasyonlar da silinsin istedim. | `RESTRICT` müşteriyi silmeyi engeller. Gerçek bir otelde geçmiş kayıtları korumak için farklı bir karar gerekebilir. |
| `fk_reservation_room` | `room` → `reservation` | `RESTRICT` | Rezervasyonu bulunan oda silinmesin istedim. | `CASCADE` rezervasyon geçmişini de siler. |

Böylece iki farklı politika kullandım: **CASCADE** ve **RESTRICT**.

## CASCADE testi

`seed.sql` verilerini yükledikten sonra `guest_id = 1` olan müşteriyi sildim. Kullandığım SQL:

```sql
BEGIN;
SELECT (SELECT COUNT(*) FROM guest) AS guest_count,
       (SELECT COUNT(*) FROM reservation) AS reservation_count,
       (SELECT COUNT(*) FROM reservation WHERE guest_id = 1) AS target_reservations;
DELETE FROM guest WHERE guest_id = 1;
SELECT (SELECT COUNT(*) FROM guest) AS guest_count,
       (SELECT COUNT(*) FROM reservation) AS reservation_count,
       (SELECT COUNT(*) FROM reservation WHERE guest_id = 1) AS target_reservations;
ROLLBACK;
```

PostgreSQL'de aldığım gerçek sonuçlar:

| | Müşteri sayısı | Rezervasyon sayısı | Silinen müşteriye ait rezervasyon |
|---|---:|---:|---:|
| Silmeden önce | 10 | 15 | 5 |
| Silmeden sonra | 9 | 10 | 0 |

`DELETE 1` mesajını aldım. Yani bir müşteri silinince ona bağlı **5 rezervasyon da otomatik silindi**. Sonunda `ROLLBACK` çalıştırdığım için bu silme kalıcı olmadı. Gerçek terminal çıktısını `week-05/cascade_output.txt` dosyasına kaydettim.

## RESTRICT testi

Rezervasyonu veya bağlı odası olan kayıtları silmeyi denedim:

```sql
DELETE FROM hotel WHERE hotel_id = 1;
DELETE FROM room WHERE room_id = 1;
DELETE FROM room_type WHERE room_type_id = 1;
```

Bu işlemler sırasıyla `fk_room_hotel`, `fk_reservation_room` ve `fk_room_room_type` nedeniyle reddedildi. PostgreSQL'in verdiği SQLSTATE kodu **`23001`** oldu. Bunlar `violations.sql` içindeki T43–T45 testleridir.

## RESTRICT ile NO ACTION arasındaki fark

İkisi de bağlı kayıt varken silmeyi engelleyebilir. Ancak `NO ACTION` kuralı `DEFERRABLE` olarak tanımlanmışsa kontrol işlem sonuna ertelenebilir. `RESTRICT` ise bu şekilde ertelenemez.
