-- COM E381 | Ödev 2 | Bölüm D: Test verileri
-- violations.sql'den SONRA çalışır; tekrar çalıştırıldığında aynı seed verisini kurar.
-- Veri altı cebir sorusunu, özellikle D4 ve D6'yı sınayacak şekilde seçilmiştir.

TRUNCATE reservation, room, hotel, room_type, guest RESTART IDENTITY CASCADE;

-- 5 oda tipi (D6 division için küme).
INSERT INTO room_type (name) VALUES
  ('Standard'),  -- 1
  ('Deluxe'),    -- 2
  ('Suite'),     -- 3
  ('Family'),    -- 4
  ('Executive'); -- 5

-- 5 otel.
INSERT INTO hotel (name, city) VALUES
  ('Bosphorus Hotel', 'Istanbul'), -- 1
  ('City Center Hotel', 'Istanbul'), -- 2
  ('Ankara Grand', 'Ankara'), -- 3
  ('Aegean Resort', 'Izmir'), -- 4
  ('Bursa Boutique', 'Bursa'); -- 5

-- 10 müşteri; şehir dağılımı D5 self-join sorusunda tam 10 çift üretir.
INSERT INTO guest (full_name, email, city, status, joined_date) VALUES
  ('Ayse Yilmaz',   'ayse@example.com',   'Istanbul', 'active',    '2025-09-15'), -- 1
  ('Mehmet Kaya',   'mehmet@example.com', 'Istanbul', 'active',    '2025-09-20'), -- 2
  ('Elif Demir',    'elif@example.com',   'Ankara',   'active',    '2025-10-01'), -- 3, rezervasyonu yok
  ('Can Ozturk',    'can@example.com',    'Izmir',    'active',    '2025-10-05'), -- 4, rezervasyonu yok
  ('Zeynep Arslan', 'zeynep@example.com', 'Ankara',  'suspended', '2025-10-10'), -- 5, rezervasyonu yok
  ('Burak Sahin',   'burak@example.com',  'Istanbul', 'active',    '2025-11-02'), -- 6, rezervasyonu yok
  ('Selin Celik',   'selin@example.com',  'Izmir',    'active',    '2025-11-12'), -- 7, rezervasyonu yok
  ('Emre Aydin',    'emre@example.com',  'Istanbul', 'closed',    '2025-11-20'), -- 8, rezervasyonu yok
  ('Deniz Koc',     'deniz@example.com', 'Ankara',   'active',    '2025-12-01'), -- 9, rezervasyonu yok
  ('Ceren Polat',   'ceren@example.com', 'Bursa',    'active',    '2025-12-05'); -- 10

-- 8 oda, 5 oda tipinin her biri en az bir odada bulunur.
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES
  (1, 1, '101', 150.00, 2), -- 1 Standard
  (1, 2, '201', 250.00, 3), -- 2 Deluxe
  (1, 3, '301', 450.00, 4), -- 3 Suite
  (2, 1, '102', 130.00, 2), -- 4 Standard
  (2, 2, '202', 230.00, 3), -- 5 Deluxe
  (2, 3, '302', 420.00, 4), -- 6 Suite
  (3, 4, '401', 300.00, 5), -- 7 Family
  (4, 5, '501', 600.00, 2); -- 8 Executive

-- 15 rezervasyon. Tüm tarih aralıkları geçmişte, odaların tarih aralıkları çakışmaz.
-- Ayşe ve Mehmet beş oda tipinin tamamını rezerve etti -> D6 sonucu.
-- Ceren'in beş rezervasyonu var, fakat yalnızca Standard/Deluxe/Suite tiplerinde kalmış;
-- filtresiz COUNT(*) = oda tipi sayısı hatalı biçimde Ceren'i de seçer.
-- Müşteri 3-9'un rezervasyonu yok -> D4 sonucu.
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status, rating) VALUES
  (1, 1, '2026-06-01', '2026-08-01', '2026-08-03', 2, 'completed', 5),
  (1, 2, '2026-06-01', '2026-08-03', '2026-08-05', 2, 'completed', 4),
  (1, 3, '2026-06-01', '2026-08-05', '2026-08-07', 3, 'completed', 5),
  (1, 7, '2026-06-01', '2026-08-07', '2026-08-10', 4, 'completed', NULL),
  (1, 8, '2026-06-01', '2026-08-10', '2026-08-12', 2, 'completed', 5),
  (2, 4, '2026-06-01', '2026-08-01', '2026-08-03', 2, 'completed', 4),
  (2, 5, '2026-06-01', '2026-08-03', '2026-08-05', 3, 'completed', 5),
  (2, 6, '2026-06-01', '2026-08-05', '2026-08-07', 2, 'completed', 4),
  (2, 7, '2026-06-01', '2026-08-10', '2026-08-13', 4, 'completed', 5),
  (2, 8, '2026-06-01', '2026-08-13', '2026-08-15', 2, 'completed', 4),
  (10, 1, '2026-06-01', '2026-08-03', '2026-08-05', 2, 'completed', 3),
  (10, 2, '2026-06-01', '2026-08-05', '2026-08-07', 2, 'completed', 4),
  (10, 3, '2026-06-01', '2026-08-07', '2026-08-09', 3, 'completed', NULL),
  (10, 4, '2026-06-01', '2026-08-04', '2026-08-06', 1, 'completed', 4),
  (10, 5, '2026-06-01', '2026-08-07', '2026-08-09', 2, 'completed', 3);
