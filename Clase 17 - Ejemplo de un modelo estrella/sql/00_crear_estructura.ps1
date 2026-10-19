# ============================================================
# 00_crear_estructura.ps1
# Crea C:\sql\dwh_project\datasets y copia los CSV del CRM y del ERP.
# $origen es la carpeta donde se descargaron los CSV.
# ============================================================
$origen = "C:\Users\AlumnoM_AI\Downloads\OneDrive_1_19-10-2026"
$base   = "C:\sql\dwh_project\datasets"

New-Item -ItemType Directory -Force -Path "$base\source_crm", "$base\source_erp" | Out-Null
Copy-Item "$origen\source_crm\*.csv" "$base\source_crm\" -Force
Copy-Item "$origen\source_erp\*.csv" "$base\source_erp\" -Force

# Comprobacion: deben aparecer los 6 ficheros
Get-ChildItem $base -Recurse -File | Select-Object DirectoryName, Name, Length

# Permiso de lectura para la cuenta de SQL Server Agent (ejecutar como administrador)
# icacls "C:\sql\dwh_project\datasets" /grant "NT SERVICE\SQLSERVERAGENT:(OI)(CI)R"
