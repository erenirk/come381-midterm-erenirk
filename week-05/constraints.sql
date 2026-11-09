-- COM E381 | Ödev 2 | Bölüm A: Constraint'ler
-- sql/schema.sql'den sonra çalışır; tabloları yeniden yaratmaz.
-- Tekrar çalıştırılabilir: isimli constraint'ler eklenmeden önce kaldırılır.

-- =====================================================================
-- A1. NOT NULL
-- =====================================================================
-- Her müşterinin adı olmalıdır.
ALTER TABLE guest ALTER COLUMN full_name SET NOT NULL;
-- Müşteri e-postası boş olamaz.
ALTER TABLE guest ALTER COLUMN email SET NOT NULL;
-- Müşterinin şehri tutulmalıdır.
ALTER TABLE guest ALTER COLUMN city SET NOT NULL;
-- Müşteri hesabının durumu bilinmelidir.
ALTER TABLE guest ALTER COLUMN status SET NOT NULL;
-- Müşteri kaydının tarihi bilinmelidir.
ALTER TABLE guest ALTER COLUMN joined_date SET NOT NULL;

-- Oda tipinin adı olmalıdır.
ALTER TABLE room_type ALTER COLUMN name SET NOT NULL;

-- Otelin adı boş olamaz.
ALTER TABLE hotel ALTER COLUMN name SET NOT NULL;
-- Otelin şehri boş olamaz.
ALTER TABLE hotel ALTER COLUMN city SET NOT NULL;

-- Her oda bir otele ve oda tipine bağlı olmalı; numarası, fiyatı ve kapasitesi bulunmalıdır.
ALTER TABLE room ALTER COLUMN hotel_id SET NOT NULL;
ALTER TABLE room ALTER COLUMN room_type_id SET NOT NULL;
ALTER TABLE room ALTER COLUMN room_number SET NOT NULL;
ALTER TABLE room ALTER COLUMN nightly_rate SET NOT NULL;
ALTER TABLE room ALTER COLUMN max_occupancy SET NOT NULL;

-- Her rezervasyon müşteri, oda, tarih aralığı, misafir sayısı ve durum bilgisine sahip olmalıdır.
ALTER TABLE reservation ALTER COLUMN guest_id SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN room_id SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN booked_on SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN check_in SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN check_out SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN guest_count SET NOT NULL;
ALTER TABLE reservation ALTER COLUMN status SET NOT NULL;
-- rating bilerek NULL olabilir: konaklama değerlendirilmemiş olabilir.

-- =====================================================================
-- A2. UNIQUE
-- =====================================================================
-- Aynı e-posta iki müşteri kaydına atanamaz.
ALTER TABLE guest DROP CONSTRAINT IF EXISTS uq_guest_email;
ALTER TABLE guest ADD CONSTRAINT uq_guest_email UNIQUE (email);

-- Oda tipi adları benzersiz olmalıdır.
ALTER TABLE room_type DROP CONSTRAINT IF EXISTS uq_room_type_name;
ALTER TABLE room_type ADD CONSTRAINT uq_room_type_name UNIQUE (name);

-- Aynı şehirde aynı isimde iki otel kaydı oluşturulamaz.
ALTER TABLE hotel DROP CONSTRAINT IF EXISTS uq_hotel_name_city;
ALTER TABLE hotel ADD CONSTRAINT uq_hotel_name_city UNIQUE (name, city);

-- Bir otelin içinde oda numarası tekrar edemez (çok sütunlu UNIQUE).
ALTER TABLE room DROP CONSTRAINT IF EXISTS uq_room_hotel_number;
ALTER TABLE room ADD CONSTRAINT uq_room_hotel_number UNIQUE (hotel_id, room_number);

-- Aynı müşteri aynı oda için aynı giriş tarihine iki rezervasyon açamaz (çok sütunlu UNIQUE).
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS uq_reservation_guest_room_check_in;
ALTER TABLE reservation ADD CONSTRAINT uq_reservation_guest_room_check_in
    UNIQUE (guest_id, room_id, check_in);

-- =====================================================================
-- A3. CHECK
-- =====================================================================
-- Gecelik fiyat pozitif olmalıdır.
ALTER TABLE room DROP CONSTRAINT IF EXISTS chk_room_nightly_rate_positive;
ALTER TABLE room ADD CONSTRAINT chk_room_nightly_rate_positive CHECK (nightly_rate > 0);

-- Oda en az bir kişiyi ağırlayabilmelidir.
ALTER TABLE room DROP CONSTRAINT IF EXISTS chk_room_max_occupancy_positive;
ALTER TABLE room ADD CONSTRAINT chk_room_max_occupancy_positive CHECK (max_occupancy > 0);

-- Çıkış tarihi giriş tarihinden sonra olmalıdır (iki sütun karşılaştırılır).
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS chk_reservation_date_order;
ALTER TABLE reservation ADD CONSTRAINT chk_reservation_date_order CHECK (check_out > check_in);

-- Bir rezervasyondaki misafir sayısı en az 1 olmalıdır.
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS chk_reservation_guest_count_positive;
ALTER TABLE reservation ADD CONSTRAINT chk_reservation_guest_count_positive CHECK (guest_count > 0);

-- Müşteri hesabı yalnızca tanımlı durumlardan birinde olabilir.
ALTER TABLE guest DROP CONSTRAINT IF EXISTS chk_guest_status_values;
ALTER TABLE guest ADD CONSTRAINT chk_guest_status_values
    CHECK (status IN ('active', 'suspended', 'closed'));

-- Rezervasyon durumu yalnızca tanımlı değerlerden biri olabilir.
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS chk_reservation_status_values;
ALTER TABLE reservation ADD CONSTRAINT chk_reservation_status_values
    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed'));

-- Değerlendirme 1-5 aralığında olmalıdır; değerlendirme verilmediyse NULL olabilir.
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS chk_reservation_rating_range;
ALTER TABLE reservation ADD CONSTRAINT chk_reservation_rating_range CHECK (rating BETWEEN 1 AND 5);

-- =====================================================================
-- A4. FOREIGN KEY (Ödev 1'deki isimsiz FK'ler isimli politikalı FK'lerle değiştirilir)
-- =====================================================================
-- Her oda var olan bir otele bağlıdır; odası bulunan otel silinemez.
ALTER TABLE room DROP CONSTRAINT IF EXISTS room_hotel_id_fkey;
ALTER TABLE room DROP CONSTRAINT IF EXISTS fk_room_hotel;
ALTER TABLE room ADD CONSTRAINT fk_room_hotel
    FOREIGN KEY (hotel_id) REFERENCES hotel (hotel_id) ON DELETE RESTRICT;

-- Her oda var olan bir oda tipine bağlıdır; kullanılan oda tipi silinemez.
ALTER TABLE room DROP CONSTRAINT IF EXISTS room_room_type_id_fkey;
ALTER TABLE room DROP CONSTRAINT IF EXISTS fk_room_room_type;
ALTER TABLE room ADD CONSTRAINT fk_room_room_type
    FOREIGN KEY (room_type_id) REFERENCES room_type (room_type_id) ON DELETE RESTRICT;

-- Her rezervasyon var olan bir müşteriye bağlıdır; müşteri silinince rezervasyonları da silinir.
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS reservation_guest_id_fkey;
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS fk_reservation_guest;
ALTER TABLE reservation ADD CONSTRAINT fk_reservation_guest
    FOREIGN KEY (guest_id) REFERENCES guest (guest_id) ON DELETE CASCADE;

-- Her rezervasyon var olan bir odaya bağlıdır; geçmişi olan oda silinemez.
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS reservation_room_id_fkey;
ALTER TABLE reservation DROP CONSTRAINT IF EXISTS fk_reservation_room;
ALTER TABLE reservation ADD CONSTRAINT fk_reservation_room
    FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT;
