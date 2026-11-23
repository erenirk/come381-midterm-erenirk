# Ödev 2 - Çalıştırma ve test notları

Ödev 1'de hazırladığım otel rezervasyon veritabanına bu ödevde constraint'ler ekledim ve test ettim.

## Çalıştırma sırası

Proje klasöründe, boş bir `come381` veritabanında sırasıyla:

```bash
psql -d come381 -f sql/schema.sql
psql -d come381 -f week-05/constraints.sql
psql -d come381 -f week-05/violations.sql
psql -d come381 -f week-05/seed.sql
psql -d come381 -f week-05/algebra.sql
```

Windows'ta `-U postgres` eklenebilir. Ben `psql` için `C:\Program Files\PostgreSQL\18\bin\psql.exe` yolunu kullandım. `violations.sql` tabloları boşalttığı için `seed.sql` dosyasını sonrasında çalıştırdım. Hata çıktılarını `violations_output.txt` dosyasına kaydettim; dosyayı elle değiştirmedim.

## NULL testi

T37'de `reservation.rating` alanına `NULL` verdim ve kayıt kabul edildi. Çünkü bu sütun `NOT NULL` değil. `CHECK` ifadesi `NULL` için `UNKNOWN` sonucu veriyor; PostgreSQL bunu ihlal saymıyor.

## Beklemediğim sonuç

T43–T45 testlerinde `RESTRICT` nedeniyle silme işlemleri engellendi. `23503` beklerken PostgreSQL `23001` kodunu verdi. Test dosyasındaki beklenen kodları buna göre düzelttim.
