/*
===============================================================================
Comprobaciones de las vistas Gold (Seccion 9.2 a 9.5)
===============================================================================
*/
USE DataWarehouse;
GO

-- Clientes y genero integrado (esperado: 18484)
SELECT COUNT(*) AS clientes FROM gold.dim_customers;
SELECT gender, COUNT(*) AS clientes FROM gold.dim_customers GROUP BY gender;

-- Productos vigentes (esperado: 295)
SELECT COUNT(*) AS productos FROM gold.dim_products;

-- Pedales sin categoria (esperado: 7 filas)
SELECT product_key, product_number, product_name, category_id, category, subcategory
FROM gold.dim_products
WHERE category IS NULL;

-- Filas de hechos frente a Silver (esperado: 60398 / 60398)
SELECT
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS filas_silver,
    (SELECT COUNT(*) FROM gold.fact_sales)          AS filas_gold;
