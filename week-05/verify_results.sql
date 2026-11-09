-- Seed verisinin sorgu tasarımındaki temel beklenen durumları sağlaması.
\set ON_ERROR_STOP on
SELECT CASE WHEN (SELECT count(*) FROM guest)=10 AND
                 (SELECT count(*) FROM hotel)=5 AND
                 (SELECT count(*) FROM room_type)=5 AND
                 (SELECT count(*) FROM room)=8 AND
                 (SELECT count(*) FROM reservation)=15
            THEN 'PASS' ELSE 'FAIL' END AS seed_counts;
WITH correct AS (
  SELECT g.guest_id FROM guest g WHERE NOT EXISTS (
    SELECT 1 FROM room_type rt WHERE NOT EXISTS (
      SELECT 1 FROM reservation r JOIN room rm ON rm.room_id=r.room_id
      WHERE r.guest_id=g.guest_id AND rm.room_type_id=rt.room_type_id))
), wrong AS (
  SELECT r.guest_id FROM reservation r GROUP BY r.guest_id
  HAVING count(*)=(SELECT count(*) FROM room_type)
)
SELECT CASE WHEN (SELECT array_agg(guest_id ORDER BY guest_id) FROM correct)=ARRAY[1,2]
            AND (SELECT array_agg(guest_id ORDER BY guest_id) FROM wrong)=ARRAY[1,2,10]
            THEN 'PASS' ELSE 'FAIL' END AS division_counterexample;
