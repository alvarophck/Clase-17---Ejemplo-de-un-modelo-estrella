/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Comprueba:
    - Unicidad de las claves subrogadas de las dimensiones.
    - Integridad referencial entre fact_sales y las dimensiones.

Nota: la version original une gold.fact_sales con las vistas de dimension
directamente. Como fact_sales ya se construye a partir de esas vistas y
ninguna tiene indices, SQL Server recalcula el ROW_NUMBER() de las
dimensiones repetidamente y la consulta no terminaba (mas de 3 minutos).
Se materializan antes las vistas en tablas temporales; la comprobacion es
la misma.
===============================================================================
*/
USE DataWarehouse;
GO

-- Clave de cliente duplicada
-- Expectation: No results
SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Clave de producto duplicada
-- Expectation: No results
SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Ventas huerfanas (conectividad del modelo)
-- Expectation: No results
SELECT customer_key INTO #cust FROM gold.dim_customers;
SELECT product_key  INTO #prod FROM gold.dim_products;
SELECT * INTO #fact FROM gold.fact_sales;

SELECT f.*
FROM #fact f
LEFT JOIN #cust c ON c.customer_key = f.customer_key
LEFT JOIN #prod p ON p.product_key  = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

DROP TABLE #cust, #prod, #fact;

-- ====================================================================
-- Ejercicio 1: control anadido
-- ====================================================================
-- Productos sin categoria
-- Expectation: 7 filas (los pedales, category_id CO_PE)
SELECT product_key, product_number, product_name, category_id, category, subcategory
FROM gold.dim_products
WHERE category IS NULL;
