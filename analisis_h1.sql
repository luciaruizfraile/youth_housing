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



-- H2: ¿Los jóvenes menores de 30 ganan lo suficiente para comprar vivienda en su comunidad?


