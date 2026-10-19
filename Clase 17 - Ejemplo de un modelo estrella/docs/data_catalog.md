# Catálogo de datos de la capa Gold

## gold.dim_customers
Una fila por cliente del CRM, enriquecida con los datos demográficos y de ubicación del ERP.

| Columna | Tipo | Descripción | Origen (Silver) |
|---|---|---|---|
| customer_key | BIGINT | Clave subrogada del cliente en el DWH | Calculada (ROW_NUMBER por cst_id) |
| customer_id | INT | Identificador numérico del cliente en el CRM | crm_cust_info.cst_id |
| customer_number | NVARCHAR(50) | Código alfanumérico del cliente | crm_cust_info.cst_key |
| first_name | NVARCHAR(50) | Nombre, sin espacios sobrantes | crm_cust_info.cst_firstname |
| last_name | NVARCHAR(50) | Apellido, sin espacios sobrantes | crm_cust_info.cst_lastname |
| country | NVARCHAR(50) | País de residencia estandarizado, o n/a | erp_loc_a101.cntry |
| marital_status | NVARCHAR(50) | Estado civil: Married, Single o n/a | crm_cust_info.cst_marital_status |
| gender | NVARCHAR(50) | Género: Male, Female o n/a. Prioridad CRM; si es n/a, ERP | crm_cust_info.cst_gndr / erp_cust_az12.gen |
| birthdate | DATE | Fecha de nacimiento; NULL si en origen era futura | erp_cust_az12.bdate |
| create_date | DATE | Fecha de alta del cliente en el CRM | crm_cust_info.cst_create_date |

## gold.dim_products
Una fila por producto en su versión vigente (sin historificación).

| Columna | Tipo | Descripción | Origen (Silver) |
|---|---|---|---|
| product_key | BIGINT | Clave subrogada del producto | Calculada (ROW_NUMBER por fecha de inicio y clave) |
| product_id | INT | Identificador del producto en el CRM | crm_prd_info.prd_id |
| product_number | NVARCHAR(50) | Código del producto, sin el prefijo de categoría | crm_prd_info.prd_key |
| product_name | NVARCHAR(50) | Nombre comercial del producto | crm_prd_info.prd_nm |
| category_id | NVARCHAR(50) | Código de categoría para enlazar con el ERP | crm_prd_info.cat_id |
| category | NVARCHAR(50) | Categoría; NULL para CO_PE (no existe en el ERP) | erp_px_cat_g1v2.cat |
| subcategory | NVARCHAR(50) | Subcategoría | erp_px_cat_g1v2.subcat |
| maintenance | NVARCHAR(50) | Si el producto requiere mantenimiento: Yes o No | erp_px_cat_g1v2.maintenance |
| cost | INT | Coste del producto; 0 si en origen era nulo | crm_prd_info.prd_cost |
| product_line | NVARCHAR(50) | Línea: Mountain, Road, Touring, Other Sales o n/a | crm_prd_info.prd_line |
| start_date | DATE | Fecha de inicio de la versión vigente | crm_prd_info.prd_start_dt |

## gold.fact_sales
Una fila por línea de pedido.

| Columna | Tipo | Descripción | Origen (Silver) |
|---|---|---|---|
| order_number | NVARCHAR(50) | Número de pedido | crm_sales_details.sls_ord_num |
| product_key | BIGINT | Clave subrogada del producto | gold.dim_products |
| customer_key | BIGINT | Clave subrogada del cliente | gold.dim_customers |
| order_date | DATE | Fecha de pedido; NULL en 19 líneas con fecha no válida en origen | crm_sales_details.sls_order_dt |
| shipping_date | DATE | Fecha de envío | crm_sales_details.sls_ship_dt |
| due_date | DATE | Fecha de vencimiento | crm_sales_details.sls_due_dt |
| sales_amount | INT | Importe de la línea; cumple siempre cantidad × precio | crm_sales_details.sls_sales |
| quantity | INT | Unidades vendidas | crm_sales_details.sls_quantity |
| price | INT | Precio unitario | crm_sales_details.sls_price |

## gold.report_customers
Una fila por cliente con métricas de compra y segmento (ejercicio 4).

| Columna | Tipo | Descripción |
|---|---|---|
| customer_key, customer_number, first_name, last_name, country | | Igual que en gold.dim_customers |
| age | INT | Edad exacta a la fecha de consulta |
| total_orders | INT | Número de pedidos distintos |
| total_sales | INT | Suma de sales_amount del cliente |
| first_order_date, last_order_date | DATE | Primer y último pedido |
| lifespan_months | INT | Meses entre el primer y el último pedido |
| customer_segment | VARCHAR | VIP (más de 5.000 y más de 12 meses), Regular (solo una condición), New (ninguna) |
