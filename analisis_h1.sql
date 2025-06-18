USE youth_housing; 

-- CAMBIO EN TODAS LAS QUERIES:
-- de:  WHERE decil = '5'
-- a:    WHERE decil = 'Total'
-- H1 Comunidades con mayor dificultad
SELECT 
    p.comunidades_y_ciudades_autónomas,
    p.año,
    p.precio_m2,
    s.total,
    ROUND(s.total, 2) AS salario_mensual,
    ROUND(p.precio_m2 / (s.total), 2) AS esfuerzo_m2_mensual
FROM precios p
JOIN salario_ccaa s
  ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas AND p.año = s.año
WHERE s.decil = 'Total decil'
  AND s.tipo_de_jornada = 'Total'
ORDER BY esfuerzo_m2_mensual DESC;

-- H1.1: Comparativa regional (ranking esfuerzo medio historico)
SELECT 
    comunidades_y_ciudades_autónomas,
    ROUND(AVG(esfuerzo_m2_mensual), 2) AS esfuerzo_medio
FROM (
    SELECT 
        p.comunidades_y_ciudades_autónomas,
        p.año,
        p.precio_m2,
        s.total,
        ROUND(s.total, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total), 2) AS esfuerzo_m2_mensual
    FROM precios p
    JOIN salario_ccaa s
      ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
     AND p.año = s.año
    WHERE s.decil = 'Total decil'
      AND s.tipo_de_jornada = 'Total'
) AS subconsulta
GROUP BY comunidades_y_ciudades_autónomas
ORDER BY esfuerzo_medio ASC;
-- ranking por ccaa actual 2023
SELECT 
    p.comunidades_y_ciudades_autónomas,
    ROUND(p.precio_m2 / (s.total),2) AS esfuerzo_m2_mensual
FROM precios p
JOIN salario_ccaa s
  ON p.comunidades_y_ciudades_autónomas = s.comunidades_y_ciudades_autónomas 
 AND p.año = s.año
WHERE s.decil = 'Total decil'
  AND s.tipo_de_jornada = 'Total'
  AND p.año = 2023 
ORDER BY esfuerzo_m2_mensual ASC;

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
        ROUND(s.total, 2) AS salario_mensual,
        ROUND(p.precio_m2 / (s.total), 2) AS esfuerzo_m2_mensual
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
  AND sj.decil = 'Total decil'
  AND sg.tipo_de_jornada = 'Total'
  AND sg.decil = 'Total decil'
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
  AND sj.decil = 'Total decil'
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
  AND s.decil = 'Total decil'
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

