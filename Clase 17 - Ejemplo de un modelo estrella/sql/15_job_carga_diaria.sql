/* ============================================================
   job_carga_diaria.sql
   Crea el trabajo de SQL Server Agent que recarga el DWH cada dia.
   Requisitos: SQL Server Agent arrancado y permisos de lectura
   sobre C:\sql\dwh_project\datasets para la cuenta del servicio de Agent.
   Los procedimientos ya incluyen THROW; en el CATCH.
   Cambio respecto al original: se usa @@SERVERNAME en lugar de '(local)'
   para que funcione tambien en instancias con nombre.
   ============================================================ */
USE msdb;
GO

-- Si el trabajo ya existe, lo eliminamos para poder recrearlo
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'DWH - Carga diaria')
    EXEC dbo.sp_delete_job @job_name = N'DWH - Carga diaria';
GO

-- Si la programacion ya existe (de una ejecucion anterior), tambien
IF EXISTS (SELECT 1 FROM dbo.sysschedules WHERE name = N'Diario 06:00')
    EXEC dbo.sp_delete_schedule @schedule_name = N'Diario 06:00', @force_delete = 1;
GO

-- 1. El trabajo
EXEC dbo.sp_add_job
    @job_name    = N'DWH - Carga diaria',
    @description = N'Recarga completa de las capas Bronze y Silver del DataWarehouse',
    @enabled     = 1;

-- 2. Paso 1: Bronze
EXEC dbo.sp_add_jobstep
    @job_name          = N'DWH - Carga diaria',
    @step_name         = N'1 - Cargar Bronze',
    @subsystem         = N'TSQL',
    @database_name     = N'DataWarehouse',
    @command           = N'EXEC bronze.load_bronze;',
    @on_success_action = 3,    -- 3 = ir al siguiente paso
    @on_fail_action    = 2;    -- 2 = terminar el trabajo con error

-- 3. Paso 2: Silver
EXEC dbo.sp_add_jobstep
    @job_name          = N'DWH - Carga diaria',
    @step_name         = N'2 - Cargar Silver',
    @subsystem         = N'TSQL',
    @database_name     = N'DataWarehouse',
    @command           = N'EXEC silver.load_silver;',
    @on_success_action = 1,    -- 1 = terminar el trabajo con exito
    @on_fail_action    = 2;

-- 4. Programacion: todos los dias a las 06:00
EXEC dbo.sp_add_schedule
    @schedule_name     = N'Diario 06:00',
    @freq_type         = 4,       -- 4 = diario
    @freq_interval     = 1,       -- cada 1 dia
    @active_start_time = 060000;  -- formato HHMMSS

EXEC dbo.sp_attach_schedule
    @job_name      = N'DWH - Carga diaria',
    @schedule_name = N'Diario 06:00';

-- 5. Asignar el trabajo a este servidor
DECLARE @srv SYSNAME = @@SERVERNAME;
EXEC dbo.sp_add_jobserver
    @job_name    = N'DWH - Carga diaria',
    @server_name = @srv;
GO
