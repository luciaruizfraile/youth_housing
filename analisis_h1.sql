USE youth_housing; 

-- H1: ¿Qué comunidades tienen mayor dificultad para acceder a la vivienda? 
-- En base a cuántos metros 2 te puedes comprar al mes según el salario mensual de la media de cada ccaa

SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    s.total,
    ROUND(s.total / 12, 2) AS salario_mensual,
    ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
FROM precios p
JOIN salario_ccaa s
  ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas AND p.año = s.año
WHERE s.decil = '5'
  AND s.tipo_de_jornada = 'Total'
ORDER BY esfuerzo_m2_mensual DESC;

-- EJEMPLO: En Madrid, una persona del 5º decil puede pagar 1.66 m² al mes con su sueldo completo.
-- EJEMPLO: En Extremadura puede pagar más de 2 m², lo cual sugiere mejor accesibilidad a la vivienda.

-- 1. Comparativa regional: ¿Dónde es más asequible comprar?
SELECT 
    comunidades_y_ciudades_autónomas,
    ROUND(AVG(esfuerzo_m2_mensual), 2) AS esfuerzo_medio
FROM (
    SELECT 
        p.comunidades_y_ciudades_autónomas,
        p.año,
        p.precio_m2,
        s.total,
        ROUND(s.total / 12, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
    FROM precios p
    JOIN salario_ccaa s
      ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
     AND p.año = s.año
    WHERE s.decil = '5'
      AND s.tipo_de_jornada = 'Total'
) AS subconsulta
GROUP BY comunidades_y_ciudades_autónomas
ORDER BY esfuerzo_medio ASC;
-- Verás un ranking de comunidades donde es más (o menos) accesible comprar vivienda con un sueldo mensual medio.
-- Puedes representarlo en Power BI como gráfico de columnas o mapa de calor por comunidad.

-- 2. Evolución temporal: ¿Está mejorando o empeorando el acceso a vivienda?
SELECT 
    año,
    ROUND(AVG(esfuerzo_m2_mensual), 2) AS esfuerzo_promedio_nacional
FROM (
    SELECT 
        p.comunidades_y_ciudades_autónomas,
        p.año,
        p.precio_m2,
        s.total,
        ROUND(s.total / 12, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
    FROM precios p
    JOIN salario_ccaa s
      ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
     AND p.año = s.año
    WHERE s.decil = '5'
      AND s.tipo_de_jornada = 'Total'
) AS subconsulta
GROUP BY año
ORDER BY año;
-- Esto te muestra si el esfuerzo para comprar vivienda ha ido en aumento o no a lo largo de los años.
-- Lo ideal sería un gráfico de líneas en Power BI para visualizar la tendencia.


-- H2: 
-- hemos cogido dos grupos de edad de 16 a 24 y de 25 a 36 
-- ¿Cuántos m² puede permitirse al mes un joven medio en España, si quiere comprar vivienda en cada comunidad autónoma?
-- Comunidades donde un joven medio español puede permitirse menos m² al mes
-- “Mapa de dificultad de acceso” por región para jóvenes
-- Comparativa con esfuerzo general (de tu primera query) → esto sí está alineado geográficamente
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    s.total AS salario_mensual_joven_nacional,
    ROUND(p.precio_m2 / s.total, 2) AS esfuerzo_m2_joven

FROM precios p
JOIN salario_edad s
  ON p.año = s.año

WHERE s.grupo_de_edad = 'De 25 a 34 años'
  AND s.tipo_de_jornada = 'Total'
  AND s.decil = '5'

ORDER BY esfuerzo_m2_joven DESC;

-- comparativa esfuerzo jóvenes de 25 a 24 vs general
-- El salario joven es el mismo para todas las comunidades
-- El salario general sí varía por comunidad

SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    
    -- Precio de vivienda
    p.precio_m2,
    
    -- Salario mensual joven (nacional, se repetirá en todas las filas por año)
    sj.total AS salario_mensual_joven,
    ROUND(p.precio_m2 / sj.total, 2) AS esfuerzo_m2_joven,
    
    -- Salario mensual general (por comunidad)
    sg.total AS salario_mensual_general,
    ROUND(p.precio_m2 / sg.total, 2) AS esfuerzo_m2_general

FROM precios p

-- JOIN salario joven nacional (sin comunidad)
JOIN salario_edad sj
  ON p.año = sj.año

-- JOIN salario general por comunidad
JOIN salario_ccaa sg
  ON p.año = sg.año AND p.comunidades_y_ciudades_autónomas = sg.comunidades_y_ciudades_autónomas

WHERE sj.grupo_de_edad = 'De 25 a 34 años'
  AND sj.tipo_de_jornada = 'Total'
  AND sj.decil = '5'
  AND sg.tipo_de_jornada = 'Total'
  AND sg.decil = '5'

ORDER BY esfuerzo_m2_joven DESC;
-- ACLARACIÓN DE ESTO IMPORTANTE: 
-- "En este análisis, el salario joven se refiere al promedio nacional para la franja 25–34 años, aplicado a todas las comunidades. 
-- En cambio, el esfuerzo general sí considera el salario regional. Esta comparación busca ilustrar cómo se amplía o reduce la brecha de acceso entre generaciones según la comunidad."


-- esta hipotesis no sé si es redundante... no la veo muy coherente :):
-- H3: ¿Cuántos m² puede permitirse un joven con salario mediano en cada comunidad? ¿Es suficiente respecto a la superficie media real?
-- * a tener en cuenta: “Se ha considerado como superficie media de referencia para los años 2021–2025 el valor correspondiente al año 2020, 
-- dado que las variaciones anuales han sido mínimas y no se dispone de datos actualizados desglosados por comunidad.”
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    
    -- Precio por metro cuadrado
    p.precio_m2,
    
    -- Salario mensual joven (nacional)
    sj.total AS salario_mensual_joven,
    
    -- Superficie media real estimada
    s.superficie_util,
    
    -- Cuántos metros puede permitirse el joven
    ROUND(sj.total / p.precio_m2, 2) AS metros_posibles,
    
    -- Brecha respecto a la superficie real
    ROUND((sj.total / p.precio_m2) - s.superficie_util, 2) AS diferencia_m2

FROM precios p

JOIN superficie_ok s
  ON p.año = s.año AND p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas

JOIN salario_edad sj
  ON p.año = sj.año

WHERE sj.grupo_de_edad = 'De 25 a 34 años'
  AND sj.tipo_de_jornada = 'Total'
  AND sj.decil = '5'

ORDER BY diferencia_m2;

-- Insights que puedes extraer
-- Comunidades donde el joven medio no alcanza la superficie media real
-- Regiones donde sí podría vivir con cierta comodidad
-- Puedes incluso categorizar:
-- “Déficit severo”
-- “Déficit moderado”
-- “Suficiencia”
-- “Superávit”
-- Si los jóvenes podrían permitirse el tipo de vivienda promedio en cada comunidad.
-- Qué regiones tienen mayor déficit o superávit de espacio disponible.
-- Qué comunidades ofrecen mejores condiciones de acceso a vivienda adecuada.
-- “El joven necesitaría más de un mes entero de salario para comprar apenas 1 metro cuadrado.”

-- H4: ¿Qué impacto tienen los tipos de interés en el precio o acceso a la vivienda?
-- Crear una gráfica en Power BI que compare:
-- 📉 Evolución del tipo de interés
-- 💰 Evolución del precio medio
-- 🧮 Variación del esfuerzo económico
-- Identificar si cuando sube el tipo de interés, cae la capacidad de compra

SELECT 
    i.año,
    
    -- Promedio de tipo de interés anual
    ROUND(AVG(i.total), 2) AS interes_medio,

    -- Precio medio nacional (promedio de todas las CCAA)
    ROUND(AVG(p.precio_m2), 2) AS precio_m2_medio,

    -- Salario mensual medio nacional
    ROUND(AVG(s.total), 2) AS salario_mensual_medio,

    -- Esfuerzo mensual nacional medio
    ROUND(AVG(p.precio_m2) / AVG(s.total), 2) AS esfuerzo_m2_mensual

FROM interes_fijo i

JOIN precios p
  ON i.año = p.año

JOIN salario_ccaa s
  ON i.año = s.año

WHERE i.tipo_de_interés = 'Fijo'
  AND i.naturaleza_de_la_finca = 'Viviendas'
  AND s.tipo_de_jornada = 'Total'
  AND s.decil = '5'

GROUP BY i.año
ORDER BY i.año;

-- conclusión: A corto plazo (2020–2022), los cambios en el tipo de interés fijo no han generado una mejora significativa en la accesibilidad de la vivienda. 
-- Aunque los tipos bajan ligeramente en 2021, el esfuerzo económico sigue siendo prácticamente el mismo

-- H5 : ¿Qué comunidades autónomas han tenido la mayor variación de precios de vivienda en los últimos 5 años?
-- Detectar si la subida de precios es coherente con el esfuerzo económico y los salarios
-- minimo de 2020 y max de 2024

SELECT 
    comunidad.comunidades_y_ciudades_autónomas,
    
    -- Precio en 2020
    MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END) AS precio_2020,

    -- Precio más reciente disponible (2024 o 2025)
    MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) AS precio_2024,

    -- Variación absoluta
    ROUND(
        MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) -
        MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END), 2
    ) AS variacion_absoluta,

    -- Variación porcentual
    ROUND(
        100 * (
            MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) -
            MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END)
        ) / MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END), 2
    ) AS variacion_porcentual

FROM precios comunidad
WHERE año IN (2020, 2024)
GROUP BY comunidad.comunidades_y_ciudades_autónomas
ORDER BY variacion_porcentual DESC;

-- CAMBIO EN TODAS LAS QUERIES:
-- de:  WHERE decil = '5'
-- a:    WHERE decil = 'Total'
-- H1 Comunidades con mayor dificultad
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    s.total,
    ROUND(s.total / 12, 2) AS salario_mensual,
    ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
FROM precios p
JOIN salario_ccaa s
  ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas AND p.año = s.año
WHERE s.decil = 'Total decil'
  AND s.tipo_de_jornada = 'Total'
ORDER BY esfuerzo_m2_mensual DESC;

-- H1.1: Comparativa regional (ranking esfuerzo medio)
SELECT 
    comunidades_y_ciudades_autónomas,
    ROUND(AVG(esfuerzo_m2_mensual), 2) AS esfuerzo_medio
FROM (
    SELECT 
        p.comunidades_y_ciudades_autónomas,
        p.año,
        p.precio_m2,
        s.total,
        ROUND(s.total / 12, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
    FROM precios p
    JOIN salario_ccaa s
      ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
     AND p.año = s.año
    WHERE s.decil = 'Total decil'
      AND s.tipo_de_jornada = 'Total'
) AS subconsulta
GROUP BY comunidades_y_ciudades_autónomas
ORDER BY esfuerzo_medio ASC;

-- H2: Evolución nacional del esfuerzo
SELECT 
    año,
    ROUND(AVG(esfuerzo_m2_mensual), 2) AS esfuerzo_promedio_nacional
FROM (
    SELECT 
        p.comunidades_y_ciudades_autónomas,
        p.año,
        p.precio_m2,
        s.total,
        ROUND(s.total / 12, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total / 12), 2) AS esfuerzo_m2_mensual
    FROM precios p
    JOIN salario_ccaa s
      ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
     AND p.año = s.año
    WHERE s.decil = 'Total decil'
      AND s.tipo_de_jornada = 'Total'
) AS subconsulta
GROUP BY año
ORDER BY año;

-- H3 ¿Cuántos m² puede permitirse un joven medio?
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    s.total AS salario_mensual_joven_nacional,
    ROUND(p.precio_m2 / s.total, 2) AS esfuerzo_m2_joven
FROM precios p
JOIN salario_edad s
  ON p.año = s.año
WHERE s.grupo_de_edad = 'De 25 a 34 años'
  AND s.tipo_de_jornada = 'Total'
  AND s.decil = 'Total decil'
ORDER BY esfuerzo_m2_joven DESC;

-- H3.1: Comparativa esfuerzo jóvenes vs general
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    sj.total AS salario_mensual_joven,
    ROUND(p.precio_m2 / sj.total, 2) AS esfuerzo_m2_joven,
    sg.total AS salario_mensual_general,
    ROUND(p.precio_m2 / sg.total, 2) AS esfuerzo_m2_general
FROM precios p
JOIN salario_edad sj
  ON p.año = sj.año
JOIN salario_ccaa sg
  ON p.año = sg.año AND p.comunidades_y_ciudades_autónomas = sg.comunidades_y_ciudades_autónomas
WHERE sj.grupo_de_edad = 'De 25 a 34 años'
  AND sj.tipo_de_jornada = 'Total'
  AND sj.decil = 'Total'
  AND sg.tipo_de_jornada = 'Total'
  AND sg.decil = 'Total'
ORDER BY esfuerzo_m2_joven DESC;

--  H3.2: ¿El joven alcanza la superficie media?
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    sj.total AS salario_mensual_joven,
    s.superficie_util,
    ROUND(sj.total / p.precio_m2, 2) AS metros_posibles,
    ROUND((sj.total / p.precio_m2) - s.superficie_util, 2) AS diferencia_m2
FROM precios p
JOIN superficie_ok s
  ON p.año = s.año AND p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas
JOIN salario_edad sj
  ON p.año = sj.año
WHERE sj.grupo_de_edad = 'De 25 a 34 años'
  AND sj.tipo_de_jornada = 'Total'
  AND sj.decil = 'Total'
ORDER BY diferencia_m2;

-- H4: Interés vs esfuerzo
SELECT 
    i.año,
    ROUND(AVG(i.total), 2) AS interes_medio,
    ROUND(AVG(p.precio_m2), 2) AS precio_m2_medio,
    ROUND(AVG(s.total), 2) AS salario_mensual_medio,
    ROUND(AVG(p.precio_m2) / AVG(s.total), 2) AS esfuerzo_m2_mensual
FROM interes_fijo i
JOIN precios p
  ON i.año = p.año
JOIN salario_ccaa s
  ON i.año = s.año
WHERE i.tipo_de_interés = 'Fijo'
  AND i.naturaleza_de_la_finca = 'Viviendas'
  AND s.tipo_de_jornada = 'Total'
  AND s.decil = 'Total'
GROUP BY i.año
ORDER BY i.año;

-- Variación de precios por comunidad
SELECT 
    comunidad.comunidades_y_ciudades_autónomas,
    MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END) AS precio_2020,
    MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) AS precio_2024,
    ROUND(
        MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) -
        MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END), 2
    ) AS variacion_absoluta,
    ROUND(
        100 * (
            MAX(CASE WHEN comunidad.año = 2024 THEN comunidad.precio_m2 END) -
            MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END)
        ) / MIN(CASE WHEN comunidad.año = 2020 THEN comunidad.precio_m2 END), 2
    ) AS variacion_porcentual
FROM precios comunidad
WHERE año IN (2020, 2024)
GROUP BY comunidad.comunidades_y_ciudades_autónomas
ORDER BY variacion_porcentual DESC;

