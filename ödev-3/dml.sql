\set VERBOSITY verbose

BEGIN;

-- Önce: Sıcak içeceklerin mevcut fiyatları
SELECT name, price
FROM product
WHERE category = 'Sıcak İçecek'
ORDER BY product_id;

-- Komut 1: Sıcak içeceklerin fiyatını 5 TL artır
UPDATE product
SET price = price + 5
WHERE category = 'Sıcak İçecek';

-- Sonra: Fiyatların 5 TL arttığını göster
SELECT name, price
FROM product
WHERE category = 'Sıcak İçecek'
ORDER BY product_id;

-- Komut 2: Olmayan 999 numaralı ürünü siparişe eklemeyi dene
-- Beklenen hata kodu: 23503 (foreign key ihlali)
INSERT INTO order_item (order_id, product_id, quantity)
VALUES (1, 999, 1);

ROLLBACK;

-- ROLLBACK sonrası: Fiyatların eski hâline döndüğünü göster
SELECT name, price
FROM product
WHERE category = 'Sıcak İçecek'
ORDER BY product_id;