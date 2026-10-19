/*
===============================================================================
Ejecucion de la carga Silver y comprobaciones posteriores (Seccion 8.3 a 8.9)
===============================================================================
*/
USE DataWarehouse;
GO

EXEC silver.load_silver;
GO

-- Recuento de filas por tabla
SELECT 'crm_cust_info'     AS tabla, COUNT(*) AS filas FROM silver.crm_cust_info     UNION ALL
SELECT 'crm_prd_info',               COUNT(*)          FROM silver.crm_prd_info      UNION ALL
SELECT 'crm_sales_details',          COUNT(*)          FROM silver.crm_sales_details UNION ALL
SELECT 'erp_cust_az12',              COUNT(*)          FROM silver.erp_cust_az12     UNION ALL
SELECT 'erp_loc_a101',               COUNT(*)          FROM silver.erp_loc_a101      UNION ALL
SELECT 'erp_px_cat_g1v2',            COUNT(*)          FROM silver.erp_px_cat_g1v2;
-- Esperado: 18484 / 397 / 60398 / 18484 / 18484 / 37

-- Distribuciones de clientes
SELECT cst_marital_status, COUNT(*) AS clientes FROM silver.crm_cust_info GROUP BY cst_marital_status;
SELECT cst_gndr,           COUNT(*) AS clientes FROM silver.crm_cust_info GROUP BY cst_gndr;

-- Productos: historico corregido
SELECT prd_key, prd_start_dt, prd_end_dt
FROM silver.crm_prd_info
WHERE prd_key = 'HL-U509-R'
ORDER BY prd_start_dt;

SELECT prd_line, COUNT(*) AS productos FROM silver.crm_prd_info GROUP BY prd_line ORDER BY productos DESC;

-- Ventas sin fecha de pedido (esperado: 19)
SELECT COUNT(*) AS ventas_sin_fecha FROM silver.crm_sales_details WHERE sls_order_dt IS NULL;

-- Integracion ERP -> CRM (esperado: 0 filas)
SELECT cid FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Genero ERP
SELECT gen, COUNT(*) AS clientes FROM silver.erp_cust_az12 GROUP BY gen;

-- Paises estandarizados
SELECT cntry, COUNT(*) AS clientes FROM silver.erp_loc_a101 GROUP BY cntry ORDER BY clientes DESC;

-- Categoria sin correspondencia en el ERP (esperado: CO_PE)
SELECT DISTINCT cat_id
FROM silver.crm_prd_info
WHERE cat_id NOT IN (SELECT id FROM silver.erp_px_cat_g1v2);
