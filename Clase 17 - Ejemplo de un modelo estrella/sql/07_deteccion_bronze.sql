/*
===============================================================================
Consultas de deteccion sobre Bronze (Seccion 8.3 a 8.8)
Ejecuta cada bloque por separado (seleccionalo y pulsa F5).
===============================================================================
*/
USE DataWarehouse;
GO

-- ============================================================
-- 8.3 crm_cust_info
-- ============================================================
-- Clave primaria duplicada o nula (esperado: 6 filas)
SELECT cst_id, COUNT(*) AS repeticiones
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Ejemplo de duplicado
SELECT * FROM bronze.crm_cust_info WHERE cst_id = 29466 ORDER BY cst_create_date;

-- Espacios sobrantes (solo detecta los iniciales: 15 y 17 filas)
SELECT cst_firstname FROM bronze.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname  FROM bronze.crm_cust_info WHERE cst_lastname  != TRIM(cst_lastname);

-- Espacios en ambos extremos (17 y 22 filas)
SELECT cst_firstname FROM bronze.crm_cust_info WHERE DATALENGTH(cst_firstname) != DATALENGTH(TRIM(cst_firstname));
SELECT cst_lastname  FROM bronze.crm_cust_info WHERE DATALENGTH(cst_lastname)  != DATALENGTH(TRIM(cst_lastname));

-- Valores de baja cardinalidad
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info;
SELECT DISTINCT cst_gndr           FROM bronze.crm_cust_info;

-- ============================================================
-- 8.4 crm_prd_info
-- ============================================================
SELECT prd_key,
       SUBSTRING(prd_key, 1, 5)            AS parte_categoria,
       SUBSTRING(prd_key, 7, LEN(prd_key)) AS parte_producto
FROM bronze.crm_prd_info;

-- Costes nulos o negativos (2 filas)
SELECT prd_id, prd_nm, prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Valores de linea de producto
SELECT DISTINCT '[' + prd_line + ']' AS prd_line FROM bronze.crm_prd_info;

-- Fechas de fin anteriores a la de inicio (200 filas)
SELECT prd_key, prd_nm, prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Historico de un producto
SELECT prd_key, prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key = 'AC-HE-HL-U509-R'
ORDER BY prd_start_dt;

-- ============================================================
-- 8.5 crm_sales_details
-- ============================================================
-- Fechas de pedido no validas (0, 5489, 32154)
SELECT sls_order_dt, COUNT(*) AS filas
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8
GROUP BY sls_order_dt;

SELECT sls_ship_dt, COUNT(*) AS filas
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8
GROUP BY sls_ship_dt;

SELECT sls_due_dt, COUNT(*) AS filas
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8
GROUP BY sls_due_dt;

-- Logica temporal (0 filas)
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Importes incoherentes
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0    OR sls_quantity <= 0    OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ============================================================
-- 8.6 erp_cust_az12
-- ============================================================
SELECT TOP 5 cid FROM bronze.erp_cust_az12;

SELECT bdate FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

SELECT DISTINCT '[' + gen + ']' AS gen FROM bronze.erp_cust_az12;

-- ============================================================
-- 8.7 erp_loc_a101
-- ============================================================
SELECT DISTINCT cntry FROM bronze.erp_loc_a101 ORDER BY cntry;

SELECT TOP 5 cid FROM bronze.erp_loc_a101;

-- ============================================================
-- 8.8 erp_px_cat_g1v2
-- ============================================================
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;
