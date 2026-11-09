-- seed.sql yüklendikten sonra çalıştır. Transaction sonunda geri alır.
\set ON_ERROR_STOP on
\echo 'CASCADE BEFORE'
BEGIN;
SELECT (SELECT count(*) FROM guest) AS guest_count,
       (SELECT count(*) FROM reservation) AS reservation_count,
       (SELECT count(*) FROM reservation WHERE guest_id=1) AS target_reservations;
DELETE FROM guest WHERE guest_id=1;
\echo 'CASCADE AFTER'
SELECT (SELECT count(*) FROM guest) AS guest_count,
       (SELECT count(*) FROM reservation) AS reservation_count,
       (SELECT count(*) FROM reservation WHERE guest_id=1) AS target_reservations;
ROLLBACK;
