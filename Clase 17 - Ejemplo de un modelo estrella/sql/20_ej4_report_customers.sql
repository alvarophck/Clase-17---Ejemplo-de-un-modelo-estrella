/*
===============================================================================
Ejercicio 4: vista gold.report_customers
===============================================================================
Una fila por cliente con edad, pedidos, ventas, primer y ultimo pedido,
antiguedad como comprador y segmento.
- Edad exacta a la fecha de consulta.
- Antiguedad como comprador: meses entre el primer y el ultimo pedido.
- VIP: mas de 5.000 y mas de 12 meses; Regular: solo una condicion; New: ninguna.
- Las ventas se agregan desde silver.crm_sales_details y se unen una sola vez con
  gold.dim_customers para no anidar vistas sobre vistas.
===============================================================================
*/
USE DataWarehouse;
GO

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH customer_sales AS (
    SELECT
        sls_cust_id                 AS customer_id,
        COUNT(DISTINCT sls_ord_num) AS total_orders,
        SUM(sls_sales)              AS total_sales,
        MIN(sls_order_dt)           AS first_order_date,
        MAX(sls_order_dt)           AS last_order_date
    FROM silver.crm_sales_details
    GROUP BY sls_cust_id
),
customer_base AS (
    SELECT
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name,
        c.country,
        CASE
            WHEN c.birthdate IS NULL THEN NULL
            ELSE DATEDIFF(YEAR, c.birthdate, GETDATE())
                 - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, c.birthdate, GETDATE()), c.birthdate) > GETDATE()
                        THEN 1 ELSE 0 END
        END                                                         AS age,
        ISNULL(s.total_orders, 0)                                   AS total_orders,
        ISNULL(s.total_sales, 0)                                    AS total_sales,
        s.first_order_date,
        s.last_order_date,
        ISNULL(DATEDIFF(MONTH, s.first_order_date, s.last_order_date), 0) AS lifespan_months
    FROM gold.dim_customers c
    LEFT JOIN customer_sales s ON s.customer_id = c.customer_id
)
SELECT
    customer_key,
    customer_number,
    first_name,
    last_name,
    country,
    age,
    total_orders,
    total_sales,
    first_order_date,
    last_order_date,
    lifespan_months,
    CASE
        WHEN total_sales > 5000 AND lifespan_months > 12 THEN 'VIP'
        WHEN total_sales > 5000 OR  lifespan_months > 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_base;
GO

-- Comprobaciones
SELECT TOP 10 * FROM gold.report_customers ORDER BY total_sales DESC;

SELECT customer_segment, COUNT(*) AS clientes, SUM(total_sales) AS ventas
FROM gold.report_customers
GROUP BY customer_segment
ORDER BY ventas DESC;

-- Una fila por cliente y mismas ventas que fact_sales (18484 y 29356250)
SELECT COUNT(*) AS filas, COUNT(DISTINCT customer_key) AS clientes, SUM(total_sales) AS ventas
FROM gold.report_customers;
