/*
===============================================================================
Ejercicio 3: ticket medio por pedido y pais
===============================================================================
*/
USE DataWarehouse;

DROP TABLE IF EXISTS #fact, #cust;
SELECT * INTO #fact FROM gold.fact_sales;
SELECT * INTO #cust FROM gold.dim_customers;

SELECT
    c.country,
    COUNT(DISTINCT c.customer_key)                                   AS clientes,
    COUNT(DISTINCT f.order_number)                                   AS pedidos,
    SUM(f.sales_amount)                                              AS ventas,
    CAST(1.0 * SUM(f.sales_amount) / COUNT(DISTINCT f.order_number) AS DECIMAL(10,2)) AS ticket_medio,
    CAST(1.0 * COUNT(DISTINCT f.order_number) / COUNT(DISTINCT c.customer_key) AS DECIMAL(10,2)) AS pedidos_por_cliente
FROM #fact f
JOIN #cust c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY ticket_medio DESC;
