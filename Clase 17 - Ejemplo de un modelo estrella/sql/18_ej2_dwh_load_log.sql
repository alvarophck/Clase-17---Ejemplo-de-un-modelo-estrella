/*
===============================================================================
Ejercicio 2: registro de cargas
===============================================================================
1. Crea la tabla dbo.dwh_load_log.
2. Redefine bronze.load_bronze para registrar una fila por tabla cargada.

Version final: el TRUNCATE y el BULK INSERT se ejecutan con sp_executesql.
Con BULK INSERT directo, el error de fichero inexistente (Msg 4860) se produce
al compilar la instruccion, en el mismo nivel que el TRY, y el CATCH no lo
captura: no se registraba la fila de Error. Con SQL dinamico la instruccion se
compila en un nivel inferior y el CATCH si lo recoge.
@@ROWCOUNT se lee dentro del propio lote dinamico, justo despues del BULK INSERT.
===============================================================================
*/
USE DataWarehouse;
GO

IF OBJECT_ID('dbo.dwh_load_log', 'U') IS NOT NULL
    DROP TABLE dbo.dwh_load_log;
GO

CREATE TABLE dbo.dwh_load_log (
    log_id        INT IDENTITY(1,1) PRIMARY KEY,
    layer_name    NVARCHAR(20),
    table_name    NVARCHAR(100),
    rows_loaded   INT,
    start_time    DATETIME2,
    end_time      DATETIME2,
    load_status   NVARCHAR(20),
    error_message NVARCHAR(4000)
);
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME2, @end_time DATETIME2,
            @batch_start_time DATETIME2, @batch_end_time DATETIME2,
            @rows INT, @table NVARCHAR(100), @path NVARCHAR(400),
            @sql NVARCHAR(MAX), @i INT = 1;

    DECLARE @sources TABLE (ord INT, table_name NVARCHAR(100), file_path NVARCHAR(400));
    INSERT INTO @sources VALUES
        (1, 'bronze.crm_cust_info',     'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'),
        (2, 'bronze.crm_prd_info',      'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'),
        (3, 'bronze.crm_sales_details', 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'),
        (4, 'bronze.erp_loc_a101',      'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'),
        (5, 'bronze.erp_cust_az12',     'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'),
        (6, 'bronze.erp_px_cat_g1v2',   'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv');

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        WHILE @i <= 6
        BEGIN
            SELECT @table = table_name, @path = file_path FROM @sources WHERE ord = @i;

            IF @i = 1 BEGIN
                PRINT '------------------------------------------------';
                PRINT 'Loading CRM Tables';
                PRINT '------------------------------------------------';
            END
            IF @i = 4 BEGIN
                PRINT '------------------------------------------------';
                PRINT 'Loading ERP Tables';
                PRINT '------------------------------------------------';
            END

            SET @start_time = SYSDATETIME();
            PRINT '>> Truncating Table: ' + @table;
            PRINT '>> Inserting Data Into: ' + @table;

            SET @sql = N'TRUNCATE TABLE ' + @table + N';
                         BULK INSERT ' + @table + N'
                         FROM ''' + @path + N'''
                         WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);
                         SET @r = @@ROWCOUNT;';
            EXEC sp_executesql @sql, N'@r INT OUTPUT', @r = @rows OUTPUT;

            SET @end_time = SYSDATETIME();
            INSERT INTO dbo.dwh_load_log (layer_name, table_name, rows_loaded, start_time, end_time, load_status)
            VALUES ('bronze', @table, @rows, @start_time, @end_time, 'OK');
            PRINT '>> Rows Loaded: ' + CAST(@rows AS NVARCHAR);
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
            PRINT '>> -------------';

            SET @i += 1;
        END

        SET @batch_end_time = SYSDATETIME();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.dwh_load_log (layer_name, table_name, rows_loaded, start_time, end_time, load_status, error_message)
        VALUES ('bronze', @table, NULL, @start_time, SYSDATETIME(), 'Error', ERROR_MESSAGE());

        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
        THROW;
    END CATCH
END
GO

-- Prueba
EXEC bronze.load_bronze;
SELECT * FROM dbo.dwh_load_log ORDER BY log_id DESC;
