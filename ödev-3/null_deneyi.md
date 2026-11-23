# NULL Deneyleri

## Deney 1

Sorgu:
SELECT COUNT(*), COUNT(phone) FROM customer;

Tahminim: Sorguyu çalıştırmadan önce tahminimi yazmadım.

Sonuç: COUNT(*) = 8, COUNT(phone) = 5.

Yorum: Toplam 8 müşteri var ama sadece 5 müşterinin telefon numarası kayıtlı. COUNT(*) bütün müşterileri sayıyor. COUNT(phone) ise telefon numarası boş olan 3 müşteriyi saymıyor. Bu yüzden sonuçlar farklı çıktı.

## Deney 2

Sorgu:
SELECT AVG(age), SUM(age) / COUNT(*) FROM customer;

Tahminim: İki işlem farklı sonuç verecek.
Sonuç: AVG(age) = 20,83 ve SUM(age) / COUNT(*) = 15.

Yorum: Tahminim doğru çıktı, iki işlem farklı sonuç verdi. AVG(age) yaşı boş olan müşterileri saymıyor. Diğer işlem ise bütün müşterilerin sayısına bölüyor ve tam sayı bölmesinde küsuratı atıyor.