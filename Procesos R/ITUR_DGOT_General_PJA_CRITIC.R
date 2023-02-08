#Script para el cálculo del ITUR con los datos continuos DGOT.
#Pablo Leautaud Valenzuela
#5 de diciembre del 2022

#----------------------------------
#Librerias a usar:
library(data.table)
library(dplyr)
library(sf)

#----------------------------------
#Semilla datos aleatorios:
set.seed(42)

#----------------------------------
#Importación de los datos:
datos <- read.csv("11_Guanajuato_ITUR.csv", header = TRUE, encoding = "UTF-8") ##-ENTRADA-##
variables <-  as.data.frame(colnames(datos))
datos <- subset(datos, select = c(codigo, v_pob, v_den_pob, v_d_loc50, v_p_agrop,
                                  v_p_const, v_d_pavim, v_eq_e_s, v_ser_viv))
codigos_o <- distinct(datos, codigo)
datos <- filter_all(datos, all_vars(.>= 0))

redondo <- function(x) {
  return(round(x, digits = 5))
}
datos_red <- sapply(datos[,2:9], redondo)
datos_red <- as.data.frame(datos_red)
datos <- cbind(datos$codigo,datos_red)
datos <- rename(datos, codigo = `datos$codigo`)

unicos <- distinct(datos, codigo)
summary(datos)

#----------------------------------
#Normalización de datos:
datos_log <- datos
datos_log$v_pob <- log10(datos_log$v_pob + 1)
datos_log$v_den_pob <- log10(datos_log$v_den_pob + 1)

normal <- function(x) {
  return((x-min(x))/(max(x)-min(x)))
}

datos_n <- sapply(datos_log[,2:9], normal)
datos_n <- as.data.frame(datos_n)
datos_n <- cbind(datos$codigo,datos_n)

datos_n <- datos_n %>%
  rename(codigo = `datos$codigo`,
         n_pob = v_pob,
         n_den_pob = v_den_pob,
         n_d_loc50 = v_d_loc50,
         n_p_agrop = v_p_agrop,
         n_p_const = v_p_const,
         n_d_pavim = v_d_pavim,
         n_eq_e_s = v_eq_e_s,
         n_ser_viv = v_ser_viv)

summary(datos_n)

datos2 <- left_join(datos, datos_n)
datos2 <- left_join(unicos %>% group_by(codigo) %>% mutate(id = row_number()),
                    datos2 %>% group_by(codigo) %>% mutate(id = row_number()), 
                    by = c("codigo", "id"))
datos2 <- subset(datos2, select = -c(id))

#----------------------------------
#Ajuste escalas (1 = rural, 0 = urbano):
datos2$n_pob <- 1 - datos2$n_pob
datos2$n_den_pob <- 1- datos2$n_den_pob
datos2$n_p_const <- 1- datos2$n_p_const

#----------------------------------
#Integración de los pesos PJA:
datos2$p_pob <- (datos2$n_pob * 0.603) + 0.000001
datos2$p_den_pob <- (datos2$n_den_pob * 1.000) + 0.000001
datos2$p_d_loc50 <- (datos2$n_d_loc50 * 0.155) + 0.000001
datos2$p_p_agrop <- (datos2$n_p_agrop * 0.372) + 0.000001
datos2$p_p_const <- (datos2$n_p_const * 0.466) + 0.000001
datos2$p_d_pavim <- (datos2$n_d_pavim * 0.200) + 0.000001
datos2$p_eq_e_s <- (datos2$n_eq_e_s * 0.357) + 0.000001
datos2$p_ser_viv <- (datos2$n_ser_viv * 0.075) + 0.000001

#----------------------------------
#Integración de los pesos CRITIC:
datos2$c_pob <- (datos2$n_pob * 0.9985) + 0.000001
datos2$c_den_pob <- (datos2$n_den_pob * 1.0000) + 0.000001
datos2$c_d_loc50 <- (datos2$n_d_loc50 * 0.4103) + 0.000001
datos2$c_p_agrop <- (datos2$n_p_agrop * 0.3655) + 0.000001
datos2$c_p_const <- (datos2$n_p_const * 0.3819) + 0.000001
datos2$c_d_pavim <- (datos2$n_d_pavim * 0.8094) + 0.000001
datos2$c_eq_e_s <- (datos2$n_eq_e_s * 0.2735) + 0.000001
datos2$c_ser_viv <- (datos2$n_ser_viv * 0.5570) + 0.000001

#----------------------------------
#Calculo del ITUR por media geométrica:
datos2 <- data.table(datos2)
t_itur <- datos2[, v1 := Reduce(`+`, lapply(.SD, function(x) x!=0)), .SDcols = 18:25]
t_itur <- t_itur[, itur_p_geo := round((Reduce(`*`, lapply(.SD, function(x) 
  replace(x, x==0, 1))))^(1/v1), 2), .SDcols = 18:25][, v1 := NULL][]
t_itur$itur_p_geo <- normal(t_itur$itur_p_geo)

t_itur <- t_itur[, v1 := Reduce(`+`, lapply(.SD, function(x) x!=0)), .SDcols = 26:33]
t_itur <- t_itur[, itur_c_geo := round((Reduce(`*`, lapply(.SD, function(x) 
  replace(x, x==0, 1))))^(1/v1), 2), .SDcols = 26:33][, v1 := NULL][]
t_itur$itur_c_geo <- normal(t_itur$itur_c_geo)

#----------------------------------
#Calculo del ITUR por suma ponderada:
t_itur$itur_p_sum <- rowSums(t_itur[,c(18,19,20,21,22,23,24,25)])
escalar_p <- function(x) (x-0.000001)/(3.228 - 0.000001)
t_itur$itur_p_sum <- escalar_p(t_itur$itur_p_sum)

t_itur$itur_c_sum <- rowSums(t_itur[,c(26,27,28,29,30,31,32,33)])
escalar_c <- function(x) (x-0.000001)/(4.7962 - 0.000001)
t_itur$itur_c_sum <- escalar_c(t_itur$itur_c_sum)

summary(t_itur)

#----------------------------------
#Recuperar celdas sin dato (código = -99):
t_itur <- left_join(codigos_o %>% group_by(codigo) %>% mutate(id = row_number()),
                    t_itur %>% group_by(codigo) %>% mutate(id = row_number()), 
                    by = c("codigo", "id"))
t_itur <- subset(t_itur, select = -c(id))
t_itur[is.na(t_itur)] <- -99

checar <- function(x) {
  salida <- 2
  salida <- ifelse(x == -99, 1, 0)
  return(salida)
}

t_itur$omitir <- checar(t_itur$v_pob)

#----------------------------------
#Exportar resultados:
t_itur_corto <- subset(t_itur, select = c(codigo, itur_p_geo, itur_c_geo,
                                          itur_p_sum, itur_c_sum, omitir))

write.csv(t_itur,"./ITUR/Datos_ITUR_11_GTO_SEDATU.csv", row.names = TRUE) ##-SALIDA-##
write.csv(t_itur_corto,"./ITUR/Datos_ITUR_11_GTO_SEDATU_Resumen.csv", row.names = TRUE)##-SALIDA-##

#----------------------------------
#Integración de datos al SHP de la entidad:
geo_shp <- st_read("./SHP/11_ITUR_Sedatu_Guanajuato.shp")
geo_itur <- left_join(geo_shp, t_itur, by = c("codigo" = "codigo"))

st_write(geo_itur, "./SHP/11_ITUR_Sedatu_Guanajuato.shp", layer_options = c( "LAUNDER=false"),
         delete_dsn = TRUE) ##-SALIDA-##

