/*
===============================================================================
Explotacion de la capa Gold (Seccion 11)
Las vistas Gold se materializan primero en tablas temporales para que las
consultas con JOIN respondan en segundos. Ejecutar todo en la misma pestana
de SSMS: las tablas temporales solo existen en esa sesion.
===============================================================================
*/
USE DataWarehouse;
GO

-- Preparacion
DROP TABLE IF EXISTS #fact, #cust, #prod;
SELECT * INTO #fact FROM gold.fact_sales;
SELECT * INTO #cust FROM gold.dim_customers;
SELECT * INTO #prod FROM gold.dim_products;

-- 11.1 Indicadores principales
SELECT
    SUM(sales_amount)            AS ventas_totales,
    SUM(quantity)                AS unidades_vendidas,
    COUNT(DISTINCT order_number) AS pedidos,
    COUNT(DISTINCT customer_key) AS clientes_con_compras
FROM #fact;

-- 11.2 Ventas por categoria
SELECT
    p.category,
    SUM(f.sales_amount) AS ventas,
    CAST(100.0 * SUM(f.sales_amount) / SUM(SUM(f.sales_amount)) OVER () AS DECIMAL(5,2)) AS pct_total
FROM #fact f
JOIN #prod p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY ventas DESC;

-- 11.3 Ventas por pais
SELECT
    c.country,
    COUNT(DISTINCT c.customer_key) AS clientes,
    SUM(f.sales_amount)            AS ventas
FROM #fact f
JOIN #cust c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY ventas DESC;

-- 11.4 Ventas por anio
SELECT
    YEAR(order_date)             AS anio,
    SUM(sales_amount)            AS ventas,
    COUNT(DISTINCT customer_key) AS clientes
FROM #fact
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY anio;

-- 11.5 Top 5 productos
SELECT TOP 5
    p.product_name,
    p.subcategory,
    SUM(f.sales_amount) AS ventas
FROM #fact f
JOIN #prod p ON f.product_key = p.product_key
GROUP BY p.product_name, p.subcategory
ORDER BY ventas DESC;

-- 11.6 Perfil de clientes
SELECT gender, marital_status, COUNT(*) AS clientes
FROM #cust
GROUP BY gender, marital_status
ORDER BY gender, marital_status;

-- 11.7 Coherencia de importes (esperado: 0)
SELECT COUNT(*) AS lineas_incoherentes
FROM #fact
WHERE sales_amount IS NULL
   OR sales_amount <= 0
   OR sales_amount != quantity * price;
