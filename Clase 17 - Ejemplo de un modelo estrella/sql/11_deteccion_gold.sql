/*
===============================================================================
Deteccion del conflicto de integracion del genero (Seccion 9.2)
===============================================================================
*/
USE DataWarehouse;
GO

SELECT DISTINCT
    ci.cst_gndr AS genero_crm,
    ca.gen      AS genero_erp
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
ORDER BY 1, 2;
