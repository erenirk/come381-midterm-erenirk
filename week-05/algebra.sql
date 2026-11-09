-- COM E381 | Ödev 2 | Bölüm D: İlişkisel cebir sorularının SQL karşılıkları
-- seed.sql'den SONRA çalışır.

-- ---------------------------------------------------------------------
-- D1 | σ selection + π projection
-- Soru: Gecelik fiyatı 200'den yüksek odaların kimlikleri, numaraları ve fiyatları.
-- ---------------------------------------------------------------------
\echo '=== D1 ==='
SELECT room_id, room_number, nightly_rate
FROM room
WHERE nightly_rate > 200
ORDER BY room_id;

-- ---------------------------------------------------------------------
-- D2 | ⋈ join
-- Soru: Her rezervasyon için rezervasyon no, müşteri, otel ve oda numarası (ilk 10).
-- ---------------------------------------------------------------------
\echo '=== D2 ==='
SELECT r.reservation_id, g.full_name, h.name AS hotel_name, rm.room_number
FROM reservation r
JOIN guest g ON g.guest_id = r.guest_id
JOIN room rm ON rm.room_id = r.room_id
JOIN hotel h ON h.hotel_id = rm.hotel_id
ORDER BY r.reservation_id
LIMIT 10;

-- ---------------------------------------------------------------------
-- D3 | ∪ union
-- Soru: Suite veya Family oda tipinde en az bir rezervasyon yapmış müşteriler.
-- UNION iki kümenin tekrarlarını kaldırır.
-- ---------------------------------------------------------------------
\echo '=== D3 ==='
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
JOIN room rm ON rm.room_id = r.room_id
JOIN room_type rt ON rt.room_type_id = rm.room_type_id
WHERE rt.name = 'Suite'
UNION
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
JOIN room rm ON rm.room_id = r.room_id
JOIN room_type rt ON rt.room_type_id = rm.room_type_id
WHERE rt.name = 'Family'
ORDER BY 1;

-- ---------------------------------------------------------------------
-- D4 | − difference (iki yöntem)
-- Soru: Hiç rezervasyon yapmamış müşteriler.
-- ---------------------------------------------------------------------
\echo '=== D4a (EXCEPT) ==='
SELECT guest_id, full_name FROM guest
EXCEPT
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
ORDER BY guest_id;

\echo '=== D4b (NOT EXISTS) ==='
SELECT g.guest_id, g.full_name
FROM guest g
WHERE NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.guest_id = g.guest_id
)
ORDER BY g.guest_id;

-- D4 doğrulaması: iki yöntemin farkı iki yönde de 0 satır olmalı.
\echo '=== D4 doğrulama (0 beklenir) ==='
WITH yontem_except AS (
    SELECT guest_id, full_name FROM guest
    EXCEPT
    SELECT g.guest_id, g.full_name
    FROM guest g JOIN reservation r ON r.guest_id = g.guest_id
),
yontem_not_exists AS (
    SELECT g.guest_id, g.full_name
    FROM guest g
    WHERE NOT EXISTS (SELECT 1 FROM reservation r WHERE r.guest_id = g.guest_id)
)
SELECT (SELECT count(*) FROM (SELECT * FROM yontem_except EXCEPT SELECT * FROM yontem_not_exists) a)
     + (SELECT count(*) FROM (SELECT * FROM yontem_not_exists EXCEPT SELECT * FROM yontem_except) b)
     AS fark_satir_sayisi;

-- ---------------------------------------------------------------------
-- D5 | ρ rename + self-join
-- Soru: Aynı şehirde yaşayan farklı müşteri çiftleri. a.guest_id < b.guest_id her çifti tek kez verir.
-- ---------------------------------------------------------------------
\echo '=== D5 ==='
SELECT a.guest_id AS guest_a_id, a.full_name AS guest_a,
       b.guest_id AS guest_b_id, b.full_name AS guest_b, a.city
FROM guest a
JOIN guest b ON a.city = b.city AND a.guest_id < b.guest_id
ORDER BY a.city, a.guest_id, b.guest_id;

-- ---------------------------------------------------------------------
-- D6 | ÷ division (iç içe NOT EXISTS)
-- Soru: Beş oda tipinin tümünde en az bir rezervasyon yapmış müşteriler.
-- ---------------------------------------------------------------------
\echo '=== D6 ==='
SELECT g.guest_id, g.full_name
FROM guest g
WHERE NOT EXISTS (
    SELECT 1
    FROM room_type rt
    WHERE NOT EXISTS (
        SELECT 1
        FROM reservation r
        JOIN room rm ON rm.room_id = r.room_id
        WHERE r.guest_id = g.guest_id
          AND rm.room_type_id = rt.room_type_id
    )
)
ORDER BY g.guest_id;

-- D6 çapraz kontrol: COUNT(DISTINCT) aynı sonucu vermeli.
\echo '=== D6 çapraz kontrol (HAVING COUNT DISTINCT) ==='
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
JOIN room rm ON rm.room_id = r.room_id
GROUP BY g.guest_id, g.full_name
HAVING COUNT(DISTINCT rm.room_type_id) = (SELECT COUNT(*) FROM room_type)
ORDER BY g.guest_id;

-- Bilerek hatalı karşı örnek: tüm oda tiplerini filtrelemeden rezervasyon adedini sayar.
-- Seed verisinde Ceren'in 5 rezervasyonu ve 5 oda tipi vardır; fakat Ceren yalnızca 3 tipi rezerve etmiştir.
\echo '=== D6 hatalı COUNT(*) örneği (Ceren yanlışlıkla gelir) ==='
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
GROUP BY g.guest_id, g.full_name
HAVING COUNT(*) = (SELECT COUNT(*) FROM room_type)
ORDER BY g.guest_id;
