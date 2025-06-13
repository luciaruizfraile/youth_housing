USE youth_housing;

CREATE TABLE fact_ipv (
    comunidad_autonoma VARCHAR(100),
    periodo VARCHAR(10),
    valor_indexado DECIMAL(10,2),
    PRIMARY KEY (comunidad_autonoma, periodo)
);
-- Crea tabla temporal sin restricciones
CREATE TEMPORARY TABLE tmp_ipv (
    comunidad_autonoma VARCHAR(100),
    tipo_vivienda VARCHAR(100),
    periodo VARCHAR(10),
    valor_indexado DECIMAL(10,2)
);

-- Carga CSV en la tabla temporal
LOAD DATA LOCAL INFILE '/Users/luciaruizfraile/git-practice/youth_housing/data/clean/ipv_clean.csv'
INTO TABLE tmp_ipv
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(comunidad_autonoma, tipo_vivienda, periodo, valor_indexado);

-- Inserta solo viviendas tipo 'General' en la tabla final
INSERT INTO fact_ipv (comunidad_autonoma, periodo, valor_indexado)
SELECT comunidad_autonoma, periodo, valor_indexado
FROM tmp_ipv
WHERE tipo_vivienda = 'General';

-- 1. Crea la tabla final
CREATE TABLE fact_salary_community (
    comunidad_autonoma VARCHAR(100),
    decil VARCHAR(50),
    periodo INT,
    salario DECIMAL(10, 2)
);

-- 2. Tabla temporal
CREATE TEMPORARY TABLE tmp_salario_ccaa (
    tipo_jornada VARCHAR(50),
    comunidad_autonoma VARCHAR(100),
    decil VARCHAR(50),
    periodo INT,
    salario DECIMAL(10, 2)
);

-- 3. Carga del CSV
LOAD DATA LOCAL INFILE '/Users/luciaruizfraile/git-practice/youth_housing/data/clean/salario_ccaa_clean.csv'
INTO TABLE tmp_salario_ccaa
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tipo_jornada, comunidad_autonoma, decil, periodo, salario);

-- 4. Inserta solo registros con jornada 'Total'
INSERT INTO fact_salary_community (comunidad_autonoma, decil, periodo, salario)
SELECT comunidad_autonoma, decil, periodo, salario
FROM tmp_salario_ccaa
WHERE tipo_jornada = 'Total';

