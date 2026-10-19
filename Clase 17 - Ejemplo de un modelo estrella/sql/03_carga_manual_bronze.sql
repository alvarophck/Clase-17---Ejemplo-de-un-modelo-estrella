/*
===============================================================================
Carga manual de prueba (Seccion 7.2 y 7.3)
===============================================================================
*/
USE DataWarehouse;
GO

TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
WITH (
    FIRSTROW = 2,           -- Salta la cabecera
    FIELDTERMINATOR = ',',  -- Separador de columnas
    TABLOCK                 -- Bloquea la tabla completa: carga mas rapida
);
GO

-- Llegaron todas las filas? Enunciado: 18494. Con los CSV entregados: 18493
SELECT COUNT(*) AS filas FROM bronze.crm_cust_info;

-- Cada valor esta en su columna?
SELECT TOP 10 * FROM bronze.crm_cust_info;
