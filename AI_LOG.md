# Yapay zekâ kullanım kaydı

## Ödev 1

**Kullandığım araç:** ChatGPT.

**Nerede kullandım?** Otel rezervasyon senaryosunu düzenlemek, `docs/er.md` içindeki Mermaid ER diyagramını oluşturmak, `sql/schema.sql` dosyasını hazırlamak ve ana `README.md` metnini yazmak için yardım aldım.

**Yapay zekâdan istediğim işler:** Otel, oda, oda tipi, müşteri ve rezervasyon tablolarını ilişkilendirme; müşteri–oda arasındaki çoktan çoğa ilişkiyi `reservation` tablosuyla gösterme; bu yapının ER diyagramını ve PostgreSQL `CREATE TABLE` kodlarını hazırlama. Bu bölümdeki önceki mesajların tam metinleri elimde ayrı bir kayıt olarak olmadığı için bunları *birebir prompt* olarak değil, kullanım özeti olarak yazıyorum.

**Benim kontrolüm:** `schema.sql` dosyasını pgAdmin'de `come381` veritabanında ve sonrasında ayrı oluşturduğum boş `come381_test` veritabanında çalıştırdım; tablo oluşturma işlemi hata vermedi. `er.md` dosyasını VS Code önizlemesinde diyagram olarak gördüm.

## Ödev 2

**Kullandığım araç:** ChatGPT.

**D6 dışındaki kullanımlarım:**

| Konu / dosya | Yapay zekâdan istediğim yardım | Kendi kontrolüm |
|---|---|---|
| `constraints.sql` | `NOT NULL`, `UNIQUE`, `CHECK` ve isimli foreign key kurallarının hazırlanması ve açıklanması | PostgreSQL'de çalıştırdım; ihlal testleriyle davranışlarını denedim. |
| `violations.sql` | Kurallar için bilerek hatalı veri ekleyen testler ve SQLSTATE beklentileri | `violations_output.txt` çıktısını `psql` ile aldım. `RESTRICT` testlerinde beklenen `23503` yerine `23001` çıktığı için beklentileri düzelttim. |
| `seed.sql` | D1–D6 sorularını gösterecek örnek rezervasyon verisi | Örnek veriyi PostgreSQL'e yükledim; `verify_results.sql` iki `PASS` verdi. |
| `algebra.sql`, `algebra.md` | Altı ilişkisel cebir sorusunun SQL ve açıklamaları | Sorguları çalıştırdım, gerçek sonuçları karşılaştırdım; D4'ün iki yolu aynı sonucu verdi. |
| `on_delete.md` | Foreign key silme politikalarını açıklama ve CASCADE testini belgeleme | CASCADE testini çalıştırdım: silmeden önce 10 müşteri/15 rezervasyon, sonra 9 müşteri/10 rezervasyon; `ROLLBACK` ile geri aldım. |
| `README.md`, `week-05/README.md` | Çalıştırma sırası ve test notlarını daha kısa ve anlaşılır yazma | Gerçek test sonuçlarıyla uyumlu olacak biçimde düzenledim. |

Bu konularda yazdığım eski mesajların tamamının birebir metni ayrı bir kayıt hâlinde elimde olmadığı için yukarıdaki satırlar **promptların aynen aktarımı değil, yapay zekâ kullanımının açıklamasıdır**. D6 için gerçek promptu ve gelen cevabı aşağıda değiştirmeden kaydettim.

### D6 — Yapay zekâ sorgusu deneyi

**Gönderdiğim prompt (aynen):**

```text
PostgreSQL'de şu tablolarım var:
guest(guest_id, full_name)
room_type(room_type_id, name)
room(room_id, room_type_id)
reservation(reservation_id, guest_id, room_id)

Tüm oda tiplerinde en az bir rezervasyon yapmış müşterileri bulan SQL sorgusunu yaz. İlişkisel bölme (division) mantığını kullan. Yalnızca SQL kodunu ver.
```

**ChatGPT'nin verdiği SQL (aynen):**

```sql
SELECT g.guest_id, g.full_name
FROM guest AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM room_type AS rt
    WHERE NOT EXISTS (
        SELECT 1
        FROM reservation AS r
        JOIN room AS rm ON rm.room_id = r.room_id
        WHERE r.guest_id = g.guest_id
          AND rm.room_type_id = rt.room_type_id
    )
);
```

**Test (9 Kasım 2026):** Bu sorguyu pgAdmin'de PostgreSQL 18.6 üzerindeki `come381` veritabanında çalıştırdım. Gelen sonuç:

| guest_id | full_name |
|---|---|
| 1 | Ayse Yilmaz |
| 2 | Mehmet Kaya |

`week-05/algebra.sql` içindeki D6 sorgumun sonucu da aynıydı. Dolayısıyla yapay zekânın verdiği bu sorguda bir hata bulamadım.

**Yanıltıcı veri denemesi:** `seed.sql` içinde Ceren Polat (`guest_id = 10`) beş rezervasyon yapmış, ancak bunlar yalnızca üç farklı oda tipini kapsıyor. Bu veri, toplam rezervasyon sayısını oda tipi sayısıyla karşılaştıran şu **alternatif, hatalı** sorguyu yanıltıyor:

```sql
SELECT g.guest_id, g.full_name
FROM guest g
JOIN reservation r ON r.guest_id = g.guest_id
GROUP BY g.guest_id, g.full_name
HAVING COUNT(*) = (SELECT COUNT(*) FROM room_type)
ORDER BY g.guest_id;
```

Bu hatalı sorguda Ayse Yilmaz ve Mehmet Kaya'ya ek olarak Ceren Polat da çıktı. Doğru `NOT EXISTS` sorgusunda Ceren Polat çıkmadı. `verify_results.sql` çıktısında `seed_counts: PASS` ve `division_counterexample: PASS` gördüm.

**Ne öğrendim?** `COUNT(*)` rezervasyonları sayıyor; farklı oda tiplerini saymıyor. Bu yüzden beş rezervasyon yapmak, beş oda tipinin tamamında rezervasyon yapmak demek değil. **Ceren Polat örneği, ChatGPT'nin verdiği doğru `NOT EXISTS` sorgusunu değil, alternatif yanlış `COUNT(*)` sorgusunu yanıltıyor.** Bu ayrımı özellikle belirtiyorum.
