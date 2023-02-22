# Código: Zonal_ITUR_Dist50k.py
# Descripción: Estadistica zonal de los valores de distancia a localidad 
#              con mas de 50k habitantes en la malla 9 de INEGI.
# Autor: Pablo Leautaud Valenzuela
# Fecha de creación: 2023-02-20

print("Inicio de script")

# Importar librerias necesarias
import arcpy
from arcpy.sa import *
print("Se importaron las librerias")

# Validar licencia de ArcGIS Spatial Analyst
arcpy.CheckOutExtension("Spatial")
print("Se valdó la licencia")

# Definir ambiente de trabajo
arcpy.env.workspace = "E:\SEDATU\ITUR\Py"
print("Se definió el ambiente de trabajo")

# Definir variables locales
inZoneData = "ITUR_Py.gdb\Vectores\Malla_Nacional_INEGI"
zoneField = "codigo"
inValueRaster = "ITUR_Py.gdb\SCINCE_2020_Loc_50k_Dist_Acum_Ajust"
outTable = "EZ_Dist_50k_Nal_GDB.dbf"
print("Se definieron las variables locales")

# Validación malla INEGI
cuenta_in = arcpy.GetCount_management(inZoneData)
print("Número de celdas en la malla:")
print(cuenta_in)

# Ejecución de estadistica zonal
print("Comenzó el proceso")
outZSaT = ZonalStatisticsAsTable(inZoneData, zoneField, inValueRaster, 
                                 outTable, "DATA", "MEAN")
print("Concluyó el proceso")

# Validación tabla salida
cuenta_out = arcpy.GetCount_management(outTable)
print("Número de celdas en la tabla:")
print(cuenta_out)