\set VERBOSITY verbose
\set ECHO all
\pset footer off
-- COM E381 | Ödev 2 | Bölüm B: Constraint ihlal ve sınır testleri
-- Her ihlal testi yalnızca hedeflediği kuralı bozar; başarılı sınır testleri sonraki veriyi etkiler.
-- Beklenen PostgreSQL SQLSTATE yorum satırında belirtilir.
-- Hazırlık bloğu: tablo içeriğini ve identity değerlerini sabitler.
TRUNCATE reservation, room, guest, hotel, room_type RESTART IDENTITY CASCADE;
INSERT INTO room_type (name) VALUES ('Standard'), ('Suite');
INSERT INTO hotel (name, city) VALUES ('Test Hotel', 'Istanbul');
INSERT INTO guest (full_name, email, city, status, joined_date) VALUES
  ('Test Guest One', 'one@example.com', 'Istanbul', 'active', '2025-01-01'),
  ('Test Guest Two', 'two@example.com', 'Ankara', 'active', '2025-02-01');
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES
  (1, 1, '101', 100.00, 2),
  (1, 1, '102', 120.00, 2),
  (1, 2, '201', 250.00, 4);
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status, rating)
VALUES (1, 1, '2026-10-01', '2026-12-01', '2026-12-03', 2, 'confirmed', 4);

-- ---------------------------------------------------------------------
-- NOT NULL: 20 test; hedef sütun dışındaki girdiler geçerli tutulur.
-- ---------------------------------------------------------------------
-- T01 | guest.full_name NOT NULL | Beklenen: 23502
INSERT INTO guest (full_name, email, city) VALUES (NULL, 't01@example.com', 'Istanbul');
-- T02 | guest.email NOT NULL | Beklenen: 23502
INSERT INTO guest (full_name, email, city) VALUES ('No Email', NULL, 'Istanbul');
-- T03 | guest.city NOT NULL | Beklenen: 23502
INSERT INTO guest (full_name, email, city) VALUES ('No City', 't03@example.com', NULL);
-- T04 | guest.status NOT NULL | Beklenen: 23502
INSERT INTO guest (full_name, email, city, status) VALUES ('No Status', 't04@example.com', 'Istanbul', NULL);
-- T05 | guest.joined_date NOT NULL | Beklenen: 23502
INSERT INTO guest (full_name, email, city, joined_date) VALUES ('No Date', 't05@example.com', 'Istanbul', NULL);
-- T06 | room_type.name NOT NULL | Beklenen: 23502
INSERT INTO room_type (name) VALUES (NULL);
-- T07 | hotel.name NOT NULL | Beklenen: 23502
INSERT INTO hotel (name, city) VALUES (NULL, 'Istanbul');
-- T08 | hotel.city NOT NULL | Beklenen: 23502
INSERT INTO hotel (name, city) VALUES ('City Missing Hotel', NULL);
-- T09 | room.hotel_id NOT NULL | Beklenen: 23502
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (NULL, 1, 'x09', 100, 2);
-- T10 | room.room_type_id NOT NULL | Beklenen: 23502
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, NULL, 'x10', 100, 2);
-- T11 | room.room_number NOT NULL | Beklenen: 23502
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, NULL, 100, 2);
-- T12 | room.nightly_rate NOT NULL | Beklenen: 23502
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x12', NULL, 2);
-- T13 | room.max_occupancy NOT NULL | Beklenen: 23502
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x13', 100, NULL);
-- T14 | reservation.guest_id NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (NULL, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T15 | reservation.room_id NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, NULL, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T16 | reservation.booked_on NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, NULL, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T17 | reservation.check_in NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, NULL, '2026-12-11', 1, 'confirmed');
-- T18 | reservation.check_out NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', NULL, 1, 'confirmed');
-- T19 | reservation.guest_count NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', NULL, 'confirmed');
-- T20 | reservation.status NOT NULL | Beklenen: 23502
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, NULL);

-- ---------------------------------------------------------------------
-- UNIQUE
-- ---------------------------------------------------------------------
-- T21 | uq_guest_email | Beklenen: 23505
INSERT INTO guest (full_name, email, city) VALUES ('Duplicate Email', 'one@example.com', 'Izmir');
-- T22 | uq_room_type_name | Beklenen: 23505
INSERT INTO room_type (name) VALUES ('Standard');
-- T23 | uq_hotel_name_city | Beklenen: 23505
INSERT INTO hotel (name, city) VALUES ('Test Hotel', 'Istanbul');
-- T24 | uq_room_hotel_number | Beklenen: 23505
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, '102', 140, 2);
-- T25 | uq_reservation_guest_room_check_in | Beklenen: 23505
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (1, 1, '2026-10-02', '2026-12-01', '2026-12-04', 2, 'confirmed');

-- ---------------------------------------------------------------------
-- CHECK ihlalleri
-- ---------------------------------------------------------------------
-- T26 | chk_room_nightly_rate_positive | Beklenen: 23514
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x26', 0, 2);
-- T27 | chk_room_max_occupancy_positive | Beklenen: 23514
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x27', 100, 0);
-- T28 | chk_reservation_date_order | Beklenen: 23514
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-11', '2026-12-10', 1, 'confirmed');
-- T29 | chk_reservation_guest_count_positive | Beklenen: 23514
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 0, 'confirmed');
-- T30 | chk_guest_status_values | Beklenen: 23514
INSERT INTO guest (full_name, email, city, status) VALUES ('Invalid Status', 't30@example.com', 'Izmir', 'banned');
-- T31 | chk_reservation_status_values | Beklenen: 23514
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'booked-ish');
-- T32 | chk_reservation_rating_range | Beklenen: 23514
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status, rating) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed', 6);

-- ---------------------------------------------------------------------
-- Sınır ve NULL testleri
-- ---------------------------------------------------------------------
-- T33 | chk_room_nightly_rate_positive | Beklenen: OK (en düşük pozitif fiyat)
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x33', 0.01, 1);
-- T34 | chk_room_max_occupancy_positive | Beklenen: OK (en düşük geçerli kapasite)
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 1, 'x34', 1, 1);
-- T35 | chk_reservation_date_order | Beklenen: OK (en kısa konaklama: bir gece)
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (2, 2, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T36 | chk_reservation_rating_range | Beklenen: OK (üst sınır 5)
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status, rating) VALUES (1, 3, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed', 5);
-- T37 | chk_reservation_rating_range | Beklenen: OK (NULL -> UNKNOWN; CHECK bunu reddetmez)
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status, rating) VALUES (2, 3, CURRENT_DATE, '2026-12-12', '2026-12-13', 1, 'completed', NULL);

-- ---------------------------------------------------------------------
-- FOREIGN KEY (olmayan ebeveyn ve ebeveyn güncelleme/silme yönleri)
-- ---------------------------------------------------------------------
-- T38 | fk_reservation_guest | Beklenen: 23503
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (999, 1, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T39 | fk_reservation_room | Beklenen: 23503
INSERT INTO reservation (guest_id, room_id, booked_on, check_in, check_out, guest_count, status) VALUES (1, 999, CURRENT_DATE, '2026-12-10', '2026-12-11', 1, 'confirmed');
-- T40 | fk_room_hotel | Beklenen: 23503
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (999, 1, 'x40', 100, 2);
-- T41 | fk_room_room_type | Beklenen: 23503
INSERT INTO room (hotel_id, room_type_id, room_number, nightly_rate, max_occupancy) VALUES (1, 999, 'x41', 100, 2);
-- T42 | fk_reservation_guest | Beklenen: 23503 (rezervasyonu olan müşterinin id'sini değiştirme)
UPDATE guest SET guest_id = 500 WHERE guest_id = 1;
-- T43 | fk_room_hotel | Beklenen: 23001 (odası olan oteli silme; RESTRICT)
DELETE FROM hotel WHERE hotel_id = 1;
-- T44 | fk_reservation_room | Beklenen: 23001 (rezervasyonu bulunan odayı silme; RESTRICT)
DELETE FROM room WHERE room_id = 1;

-- T45 | fk_room_room_type | Beklenen: 23001 (odaları olan oda tipini silme; RESTRICT)
DELETE FROM room_type WHERE room_type_id = 1;
