/*
===============================================================================
Ejecucion y validacion de la capa Bronze (Seccion 7.4)
===============================================================================
*/
USE DataWarehouse;
GO

EXEC bronze.load_bronze;
GO

SELECT 'crm_cust_info'     AS tabla, COUNT(*) AS filas FROM bronze.crm_cust_info     UNION ALL
SELECT 'crm_prd_info',               COUNT(*)          FROM bronze.crm_prd_info      UNION ALL
SELECT 'crm_sales_details',          COUNT(*)          FROM bronze.crm_sales_details UNION ALL
SELECT 'erp_cust_az12',              COUNT(*)          FROM bronze.erp_cust_az12     UNION ALL
SELECT 'erp_loc_a101',               COUNT(*)          FROM bronze.erp_loc_a101      UNION ALL
SELECT 'erp_px_cat_g1v2',            COUNT(*)          FROM bronze.erp_px_cat_g1v2;
-- Enunciado: 18494 / 397 / 60398 / 18484 / 18484 / 37
-- Con los CSV entregados: 18493 / 397 / 60398 / 18483 / 18484 / 37
