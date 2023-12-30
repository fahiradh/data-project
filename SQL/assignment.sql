-- Tampilkan email, nama depan, dan nama organisasi untuk member yang memiliki email
-- dengan akhiran @gmail.com dan merupakan anggota dari sebuah organisasi. Urutkan 
-- hasil berdasarkan nama depan sesuai abjad.

SELECT m.email_member, m.nama_depan, a.nama_org
FROM member m, anggota a
WHERE m.email_member = a.email_member AND m.email_member LIKE '%@gmail.com'
ORDER BY m.nama_depan ASC;

-- Tampilkan nama organisasi serta prefix dan nama depan dari member yang memiliki
-- peran sebagai 'Owner' dari organisasi tersebut.

SELECT a.nama_org, m.prefix, m.nama_depan
FROM anggota a, member m
WHERE a.email_member = m.email_member AND a.nama_depan = 'Owner';

-- Tampilkan nama depan, no HP (apabila lebih dari satu, dipisahkan dengan koma),
-- dan kota/kabupaten dari alamat tempat tinggal untuk member yang memiliki prefix 'Dr.'

SELECT m.nama_depan, STRING_AGG(n.no_hp, ', ') AS no_hp, a.kota_kabupaten
FROM member m
JOIN no_hp_member n ON m.email_member = n.email_member
INNER JOIN alamat a ON a.email_member = m.email_member
WHERE m.prefix = 'Dr.' AND a.jenis LIKE '%tempat tinggal'
GROUP BY m.email_member, a.kota_kabupaten;

-- Tampilkan email dan nama depan member yang belum pernah melakukan pembelian pada
-- rentang waktu 10 Maret 2023 hingga 10 April 2023 (inclusive). Urutkan berdasarkan
-- email sesuai abjad.

SELECT DISTINCT m.email_member, m.nama_depan
FROM member m
LEFT OUTER JOIN pembelian p ON m.email_member = p.email_member
WHERE m.email_member NOT IN (
    SELECT p.email_member
    FROM pembelian p
    WHERE p.tanggal_bayar BETWEEN '2023-03-10' AND '2023-04-10'
    ORDER BY m.email_member ASC
);

-- Tampilkan nomor akun, nama organisasi, nama bank, pemegang akun, serta nama yang
-- disimpan pada pemegang akun tersebut. Untuk pemegang akun individu, nama depan dan
-- nama belakang digabung, contoh: 'John Doe'.

SELECT i.nomor_akun, i.nama_organisasi, i.nama_bank, i.pemegang_akun,
    CASE WHEN i.pemegang_akun LIKE 'Perusahaan' THEN i.nama_organisasi
    ELSE (SELECT CONCAT(id.nama_depan, ' ', id.nama_belakang) AS nama_pemegang_akun
            FROM individu id
            WHERE i.nomor_akun = id.nomor_akun
    )
    END
FROM informasi_keuangan i;

-- Tampilkan email member dan blog untuk member yang pernah melakukan pembelian dengan
-- metode selain 'Kartu Kredit'.

SELECT DISTINCT m.email_member, m.blog, p.metode
FROM pembelian p
LEFT OUTER JOIN member m ON p.email_member = m.email_member
WHERE p.metode != 'Kartu Kredit';

-- Untuk setiap member, tampilkan email member dan banyaknya (berapa kali) pembelian
-- yang pernah dilakukan oleh member tersebut. Urutkan berdasarkan banyaknya pembelian.
-- (tetap tampilkan member yang belum pernah melakukan pembelian)

SELECT m.email_member, COUNT(p.email_member) AS banyaknya_pembelian
FROM member m
LEFT OUTER JOIN pembelian p ON m.email_member = p.email_member
GROUP BY m.email_member
ORDER BY COUNT(p.email_member) DESC;

-- Tampilkan nama event, nama organisasi, dan harga zona untuk event yang memiliki harga
-- zona paling mahal.

SELECT e.nama, z.nama_organisasi, z.harga
FROM zona z, event e 
WHERE z.no_event = e.no_event AND z.nama_organisasi = e.org_nama AND z.harga IN (
    SELECT MAX(z.harga)
    FROM zona z
);

-- Dari setiap metode pembayaran, tampilkan nama metode, banyaknya (berapa kali) pembelian
-- yang dilakukan menggunakan metode tersebut, dan rata-rata harga zona dari setiap pembelian

SELECT p.metode, COUNT(p.metode) AS banyaknya_pembelian, AVG(z.harga) AS avg_harga_zona
FROM ticket_seat ts, zona z, pembelian p
WHERE ts.email = p.email_member AND ts.nama_zona = z.nama AND ts.no_event = z.no_event
AND ts.nama_organisasi = z.nama_organisasi AND ts.tanggal_bayar_pembelian = p.tanggal_bayar
GROUP BY p.metode;

-- Tampilkan email member, pekerjaan, dan paypal id untuk member yang pernah melakukan pembelian
-- dengan metode pembayaran 'Paypal' dan melakukan akumulasi/total harga pembelian lebih dari 7000000

SELECT p.email_member, m.pekerjaan, py.paypal_id
FROM pembelian p, member m, zona z, ticket_seat ts, paypal py
WHERE p.email_member IN (
    SELECT p.email_member
    FROM pembelian p, paypal py
    WHERE p.metode 'Paypal' AND p.email_member = py.email_member
)
AND p.tanggal_bayar = ts.tanggal_bayar_pembelian
AND ts.no_event = z.no_event
AND ts.nama_zona = z.nama
AND ts.nama_organisasi = z.nama_organisasi
AND p.email_member = m.email_member
GROUP BY p.email_member, m.pekerjaan, py.paypal_id
HAVING SUM(z.harga) > 7000000
