#Script para el proceso de la tabla intersectado malla - USV
#Pablo Leautaud Valenzuela (https://www.pablo-leautaud.com/)
#Creación: 24 de noviembre del 2022

#----------------------------------
#Librerias a usar:
library(data.table)
library(tidyverse)

#----------------------------------
#Semilla datos aleatorios:
set.seed(42)

#----------------------------------
#Importación de los datos:
datos <- read.csv("tabla_malla_usv_jalisco.csv", header = TRUE, encoding = "UTF-8") ##-ENTRADA-##
head(datos)

#----------------------------------
#Proceso de los datos:
datos <- subset(datos, USV_GRAL2 != "")

pivot <- pivot_wider(
  datos, 
  id_cols = codigo, 
  names_from = USV_GRAL2, 
  values_from = Sup_ha,
  values_fn=sum
)

pivot[is.na(pivot)] <- 0
pivot$`Cobertura natural` <- round(pivot$`Cobertura natural`, digits = 4)
pivot$`Uso productivo` <- round(pivot$`Uso productivo`, digits = 4)
pivot$`Asentamientos humanos` <- round(pivot$`Asentamientos humanos`, digits = 4)
pivot$suma_ha <- rowSums(pivot[,c(2,3,4)])

pivot$v_p_natur <-round(pivot$`Cobertura natural`/pivot$suma_ha, digits = 4)
pivot$v_p_agrop <- round(pivot$`Uso productivo`/pivot$suma_ha, digits = 4)
pivot$v_p_const <- round(pivot$`Asentamientos humanos`/pivot$suma_ha, digits = 4)

summary(pivot)

#----------------------------------
#Exportar tabla final:
pivot <- subset(pivot, select = -c(suma_ha))
write.csv(pivot,"Dator_USV_14_JAL.csv", row.names = TRUE) ##-SALIDA-##