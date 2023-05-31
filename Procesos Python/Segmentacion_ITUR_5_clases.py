#Sript de Python para integrar la segmentación del ITUR en cinco categorias, en el "Pield Calculator".
#Se deben emplear los siguientes parámetros:
#Parser: Python
#Expression: Reclass(!VALOR!)

#Cídigo Pytho para el Code Block:
def Reclass(VALOR):
  if (VALOR >= 0 and VALOR <= 0.170403):
    return 1
  elif (VALOR > 0.170403 and VALOR <= 0.353337):
    return 2
  elif (VALOR > 0.353337 and VALOR <= 0.585282):
    return 3
  elif (VALOR > 0.585282 and VALOR <= 0.801901):
    return 4
  elif (VALOR > 0.801901):
    return 5