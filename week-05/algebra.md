# Bölüm D: İlişkisel cebir, hesap ve sonuçlar

Senaryo: otel rezervasyon sistemi (`guest`, `hotel`, `room_type`, `room`, `reservation`). Seed verisi 10 müşteri, 5 otel, 5 oda tipi, 8 oda ve 15 rezervasyondan oluşur. **Aşağıdaki sonuçlar `week-05/algebra.sql` dosyasının PostgreSQL 18.6 üzerinde çalıştırılmasıyla elde edilen `algebra_output.txt` çıktısıyla karşılaştırılarak doğrulanmıştır.** Sonuç tabloları okunabilirlik için Markdown biçiminde düzenlenmiştir; ham terminal çıktısı ayrıca `algebra_output.txt` dosyasında saklanır.

Gösterim: σ seçim, π izdüşüm, ⋈ birleştirme, ∪ birleşim, − fark, ρ yeniden adlandırma, ÷ bölme.

---

## D1: σ selection ve π projection

**Soru:** Gecelik fiyatı 200'den yüksek odaların oda kimliği, numarası ve gecelik fiyatı nedir?

**Cebir:** `π room_id, room_number, nightly_rate ( σ nightly_rate>200 (room) )`

**SQL:** `algebra.sql` → D1

```text
 room_id | room_number | nightly_rate
---------+-------------+-------------
       2 | 201         |      250.00
       3 | 301         |      450.00
       5 | 202         |      230.00
       6 | 302         |      420.00
       7 | 401         |      300.00
       8 | 501         |      600.00
(6 rows)
```

**DISTINCT notu:** Gerekmez; `room_id` birincil anahtar olduğundan projeksiyonda her oda bir kez bulunur.

**İlişkisel hesap (tuple relational calculus):**

```text
{ t.room_id, t.room_number, t.nightly_rate | room(t) ∧ t.nightly_rate > 200 }
```

---

## D2: ⋈ join

**Soru:** Her rezervasyon için rezervasyon numarası, müşteri adı, otel adı ve oda numarası nedir? İlk 10 rezervasyon gösterilir.

**Cebir:** `π reservation_id, guest.full_name, hotel.name, room.room_number (((reservation ⋈ reservation.guest_id=guest.guest_id guest) ⋈ reservation.room_id=room.room_id room) ⋈ room.hotel_id=hotel.hotel_id hotel)`

**SQL:** `algebra.sql` → D2

```text
 reservation_id |  full_name  |     hotel_name      | room_number
----------------+-------------+---------------------+------------
              1 | Ayse Yilmaz | Bosphorus Hotel      | 101
              2 | Ayse Yilmaz | Bosphorus Hotel      | 201
              3 | Ayse Yilmaz | Bosphorus Hotel      | 301
              4 | Ayse Yilmaz | Ankara Grand        | 401
              5 | Ayse Yilmaz | Aegean Resort        | 501
              6 | Mehmet Kaya | City Center Hotel   | 102
              7 | Mehmet Kaya | City Center Hotel   | 202
              8 | Mehmet Kaya | City Center Hotel   | 302
              9 | Mehmet Kaya | Ankara Grand        | 401
             10 | Mehmet Kaya | Aegean Resort        | 501
(10 rows)
```

**DISTINCT notu:** Gerekmez; çıktı `reservation_id` birincil anahtarını içerir ve her rezervasyon tek müşteri, tek oda ve o odanın tek oteliyle eşleşir.

---

## D3: ∪ union

**Soru:** Suite veya Family oda tipinde en az bir rezervasyon yapmış müşteriler kimlerdir?

**Cebir:**

```text
π guest_id, full_name ( σ room_type.name='Suite' ( guest ⋈ reservation ⋈ room ⋈ room_type ) )
∪
π guest_id, full_name ( σ room_type.name='Family' ( guest ⋈ reservation ⋈ room ⋈ room_type ) )
```

**SQL:** `algebra.sql` → D3 (`UNION`)

```text
 guest_id |  full_name
----------+-------------
        1 | Ayse Yilmaz
        2 | Mehmet Kaya
       10 | Ceren Polat
(3 rows)
```

**DISTINCT notu:** Ayrıca gerekmez; `UNION` tekrarları otomatik kaldırır. Ayşe ve Mehmet her iki oda tipinde de rezervasyon yaptığı için iki alt sorguda da yer alırlar, sonuçta ise birer kez görünürler.

---

## D4: − difference

**Soru:** Hiç rezervasyon yapmamış müşteriler kimlerdir?

**Cebir:** `π guest_id, full_name (guest) − π guest_id, full_name (guest ⋈ reservation)`

**SQL:** `algebra.sql` → D4a (`EXCEPT`) ve D4b (`NOT EXISTS`)

D4a ve D4b çalıştırıldığında aynı sonuç elde edildi:

```text
 guest_id |   full_name
----------+---------------
        3 | Elif Demir
        4 | Can Ozturk
        5 | Zeynep Arslan
        6 | Burak Sahin
        7 | Selin Celik
        8 | Emre Aydin
        9 | Deniz Koc
(7 rows)
```

D4 doğrulama sorgusu çalıştırıldı; iki yöntem arasındaki `fark_satir_sayisi = 0` çıktı.

**DISTINCT notu:** `EXCEPT` küme farkı olarak tekrarları kaldırır. `NOT EXISTS` ise `guest` tablosunu dolaşır ve `guest_id` birincil anahtar olduğundan her müşteri en fazla bir kez döner.

**İlişkisel hesap (tuple relational calculus):**

```text
{ t.guest_id, t.full_name | guest(t) ∧ ¬∃r ( reservation(r) ∧ r.guest_id = t.guest_id ) }
```

---

## D5: ρ rename ve self-join

**Soru:** Aynı şehirde yaşayan farklı müşteri çiftleri kimlerdir?

**Cebir:** `π a.guest_id, a.full_name, b.guest_id, b.full_name, a.city ( ρ a (guest) ⋈ a.city=b.city ∧ a.guest_id<b.guest_id ρ b (guest) )`

`a.guest_id < b.guest_id` müşterinin kendisiyle eşleşmesini engeller ve her çifti yalnızca bir kez üretir.

**SQL:** `algebra.sql` → D5

| guest_a_id | guest_a | guest_b_id | guest_b | city |
|---:|---|---:|---|---|
| 3 | Elif Demir | 5 | Zeynep Arslan | Ankara |
| 3 | Elif Demir | 9 | Deniz Koc | Ankara |
| 5 | Zeynep Arslan | 9 | Deniz Koc | Ankara |
| 1 | Ayse Yilmaz | 2 | Mehmet Kaya | Istanbul |
| 1 | Ayse Yilmaz | 6 | Burak Sahin | Istanbul |
| 1 | Ayse Yilmaz | 8 | Emre Aydin | Istanbul |
| 2 | Mehmet Kaya | 6 | Burak Sahin | Istanbul |
| 2 | Mehmet Kaya | 8 | Emre Aydin | Istanbul |
| 6 | Burak Sahin | 8 | Emre Aydin | Istanbul |
| 4 | Can Ozturk | 7 | Selin Celik | Izmir |

**Sonuç:** 10 satır. Kimlik sütunları da gerçek SQL çıktısıyla uyumludur.

**DISTINCT notu:** Gerekmez; `<` koşulu her sırasız çifti tek yönde döndürür ve çıktı her iki müşterinin benzersiz kimliğini içerir. Sadece adlar seçilseydi aynı isimli müşteriler altında yinelenen satırlar oluşabilirdi.

---

## D6: ÷ division

**Soru:** `room_type` tablosunda tanımlı **tüm oda tiplerinde** en az bir rezervasyon yapmış müşteriler kimlerdir?

**Cebir:**

```text
R(guest_id, room_type_id) = π guest_id, room_type_id ( reservation ⋈ room )
S(room_type_id)           = π room_type_id ( room_type )
sonuç = π guest_id, full_name ( guest ⋈ (R ÷ S) )
```

**SQL:** `algebra.sql` → D6 (iç içe `NOT EXISTS`)

**Yöntem seçimi:** İç içe `NOT EXISTS`, “müşterinin rezervasyon yapmadığı hiçbir oda tipi yok” tanımını doğrudan uygular. Rezervasyon sayısını oda tipi sayısıyla karşılaştıran filtresiz `COUNT(*)` aynı şey değildir.

PostgreSQL üzerinde doğrulanan D6 sonucu:

```text
 guest_id |  full_name
----------+-------------
        1 | Ayse Yilmaz
        2 | Mehmet Kaya
(2 rows)
```

Doğru yazılmış `COUNT(DISTINCT rm.room_type_id)` çapraz kontrolü çalıştırıldığında da aynı iki müşteri döndü.

**Yanlış sorgu karşı örneği:** `HAVING COUNT(*) = (SELECT COUNT(*) FROM room_type)` kullanılırsa Ceren Polat da yanlışlıkla seçilir. Ceren'in beş rezervasyonu vardır ve beş oda tipi vardır; ancak Ceren yalnızca Standard, Deluxe ve Suite tiplerinde kalmıştır. `COUNT(*)` rezervasyon satırlarını sayar, farklı oda tiplerini değil.

**DISTINCT notu:** İç içe `NOT EXISTS` her `guest` satırını en fazla bir kez döndürür. Sayım tabanlı sorguda mutlaka `COUNT(DISTINCT rm.room_type_id)` kullanılmalıdır; aksi halde aynı oda tipindeki birden fazla rezervasyon sonucu bozabilir.
