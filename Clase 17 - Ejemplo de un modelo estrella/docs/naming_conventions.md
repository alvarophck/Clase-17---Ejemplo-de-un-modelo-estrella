# Convenciones de nombres

| Elemento | Regla | Ejemplo |
|---|---|---|
| General | snake_case, minúsculas, en inglés, sin palabras reservadas | customer_number |
| Tablas Bronze y Silver | <sistema_origen>_<entidad>, con el nombre original de la entidad | crm_cust_info |
| Objetos Gold | <categoría>_<entidad> con nombre de negocio | dim_customers, fact_sales |
| Prefijos Gold | dim_ dimensión · fact_ hechos · report_ informe | report_customers |
| Claves subrogadas | <entidad>_key | customer_key |
| Columnas técnicas | Prefijo dwh_ | dwh_create_date |
| Procedimientos de carga | load_<capa> | load_bronze, load_silver |
| Tablas de control | dwh_<función> en el esquema dbo | dbo.dwh_load_log |

Nota: en el catálogo original del proyecto la columna de mantenimiento de gold.dim_products figuraba como maintenance_required, pero la vista la expone como maintenance. Este catálogo usa el nombre real de la vista.
