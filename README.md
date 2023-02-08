## Procesos R
Carpeta que contiene scripts de lenguaje R asociados a diversos procesos de cuantificación del ITUR o alguno de sus componentes.

### Contenido de la carpeta
#### Diccionario datos SHP ITUR SEDATU.xlsx
Hoja de cálculo de Excel donde se describen los campos (columnas) del SHP de salida del código ITUR_DGOT_General_PJA_CRITIC.R

#### ITUR_DGOT_General_PJA_CRITIC.R
Contiene la propuesta de cuantificación del ITUR propuesta por SEDATU, requiere un archivo tabular delimitado por comas (CSV) que incorpore las variables base ITUR empleando la nomenclatura especificada en el Diccionario de Datos.

También requiere dos subcarpetas localizadas al interior del proyecto de R Studio con los nombres: “ITUR” y “SHP” para guardar los archivos de salida del código.

El proceso de cuantificación considera aplicar los pesos determinados por las aproximaciones del Proceso Jerárquico Analítico (PJA) como por el método CRITIC. Y Para el calculo del ITUR se realiza bajo dos aproximaciones: suma ponderada y media geométrica (raíz de los productos).


#### ITUR_Proceso_tabla_USV.R
Código para realizar el proceso de cuantificación de proporción de superficies de vegetación y usos de suelo, empleando una aproximación de tabla dinámica. Con base en la recategorización en tres clases de la Serie VII de vegetación y uso de suelo de INEGI.
