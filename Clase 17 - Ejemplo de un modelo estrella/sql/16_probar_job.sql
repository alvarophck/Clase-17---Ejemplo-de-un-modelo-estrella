/* ============================================================
   Lanzar el trabajo y consultar su historial (Seccion 10.2)
   Ejecuta primero el bloque 1, espera unos 10 segundos y
   despues ejecuta el bloque 2.
   ============================================================ */

-- Bloque 1: lanzar el trabajo
EXEC msdb.dbo.sp_start_job @job_name = N'DWH - Carga diaria';
GO

-- Bloque 2: historial de ejecucion
SELECT
    h.step_id,
    h.step_name,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS inicio,
    CASE h.run_status
        WHEN 0 THEN 'Fallido'
        WHEN 1 THEN 'Correcto'
        WHEN 3 THEN 'Cancelado'
        WHEN 4 THEN 'En curso'
    END                                            AS estado,
    h.message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
WHERE j.name = N'DWH - Carga diaria'
ORDER BY h.instance_id DESC;
