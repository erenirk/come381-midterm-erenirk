-- Bu sorgu yapay zekanın verdiği cevap değildir. Hatalı COUNT(*) yöntemini göstermek için kullanılan karşılaştırma sorgusudur.
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
GROUP BY g.guest_id, g.full_name
HAVING COUNT(*) = (SELECT COUNT(*) FROM room_type)
ORDER BY g.guest_id;
