USE youth_housing;

CREATE TABLE ipv (
    comunidad_autonoma VARCHAR(100) DEFAULT NULL,
    periodo VARCHAR(10) DEFAULT NULL,
    valor_indexado DECIMAL(10,2) DEFAULT NULL
);

-- Crea la tabla final
CREATE TABLE salary_community (
    comunidad_autonoma VARCHAR(100) DEFAULT NULL,
    tipo_jornada VARCHAR(100) DEFAULT NULL,
    decil VARCHAR(50) DEFAULT NULL,
    anio INT DEFAULT NULL,
    salario DECIMAL(10, 2) DEFAULT NULL
);

CREATE TABLE interes (
    tipo_interes VARCHAR(50)DEFAULT NULL ,              -- e.g., 'Fijo'
    naturaleza_finca VARCHAR(50) DEFAULT NULL ,          -- e.g., 'Vivienda'
    periodo VARCHAR(10) DEFAULT NULL,                   -- e.g., '2022T3'
    valor_interes DECIMAL(5, 2) DEFAULT NULL
);

CREATE TABLE precio (
    comunidad_autonoma VARCHAR(100) DEFAULT NULL,
    anio INT DEFAULT NULL,
    precio_m2 DECIMAL(10, 2) DEFAULT NULL
);

CREATE TABLE salary_edad (
    tipo_jornada VARCHAR(50) DEFAULT NULL ,
    grupo_edad VARCHAR(50) DEFAULT NULL,
    decil VARCHAR(50) DEFAULT NULL,
    anio VARCHAR(10) DEFAULT NULL,
    salario DECIMAL(10, 2) DEFAULT NULL
);
