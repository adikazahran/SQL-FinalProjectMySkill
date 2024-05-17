SELECT * FROM sku_detail;
SELECT * FROM order_detail;
SELECT * FROM payment_detail;
SELECT * FROM customer_detail;


-- Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi. Source table: order_detail
SELECT 
  strftime('%Y', order_date) AS Year, 
  strftime('%m', order_date) AS Month, 
  SUM(after_discount) AS Total_transaction	
FROM order_detail WHERE strftime('%Y', order_date) = '2021' AND is_valid = 1
GROUP BY Year, Month ORDER BY Total_transaction DESC LIMIT 1;


-- Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi. Source table: order_detail, sku_detail
SELECT
  s.category AS Category,
  SUM(o.after_discount) AS Total_transaction
FROM order_detail o JOIN sku_detail s ON o.sku_id = s.id
WHERE strftime('%Y', o.order_date) = '2022' AND o.is_valid = 1
GROUP BY s.category ORDER BY Total_transaction DESC LIMIT 1;


-- Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data transaksi. Source table: order_detail, sku_detail
SELECT category AS Category,
  SUM(CASE WHEN strftime('%Y', od.order_date) = '2021' THEN od.after_discount ELSE 0 END) AS Transaction_2021,
  SUM(CASE WHEN strftime('%Y', od.order_date) = '2022' THEN od.after_discount ELSE 0 END) AS Transaction_2022,
  SUM(CASE WHEN strftime('%Y', od.order_date) = '2022' THEN od.after_discount ELSE 0 END) -
      SUM(CASE WHEN strftime('%Y', od.order_date) = '2021' THEN od.after_discount ELSE 0 END) AS Transaction_Difference
FROM order_detail od JOIN sku_detail sd ON od.sku_id = sd.id
WHERE od.is_valid = 1 GROUP BY category
HAVING Transaction_Difference <> 0;

-- Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi. Source table: order_detail, payment_method
SELECT
    pd.payment_method,
    COUNT(DISTINCT od.id) AS total_unique_order
FROM order_detail od
JOIN payment_detail pd ON od.payment_id = pd.id
WHERE od.is_valid = 1 AND strftime('%Y', od.order_date) = '2022'
GROUP BY pd.payment_method
ORDER BY total_unique_order DESC
LIMIT 5;

-- Q: Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya. 1. Samsung, 2. Apple, 3. Sony, 4. Huawei, 5. Lenovo. Gunakan is_valid = 1 untuk memfilter data transaksi. Source table: order_detail, sku_detail
SELECT
    CASE
        WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
        WHEN LOWER(sd.sku_name) LIKE '%apple%' THEN 'Apple'
        WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
        WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
        WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
    END AS product_name,
    SUM(od.after_discount * od.qty_ordered) AS total_sales
FROM
    order_detail od
JOIN
    sku_detail sd ON od.sku_id = sd.id
WHERE
    od.is_valid = 1
    AND (
        LOWER(sd.sku_name) LIKE '%samsung%'
        OR LOWER(sd.sku_name) LIKE '%apple%'
        OR LOWER(sd.sku_name) LIKE '%sony%'
        OR LOWER(sd.sku_name) LIKE '%huawei%'
        OR LOWER(sd.sku_name) LIKE '%lenovo%'
    )
GROUP BY
    product_name
ORDER BY
    total_sales DESC;

   