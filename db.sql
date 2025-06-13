USE youth_housing;

CREATE TABLE fact_ipv (
    comunidad_autonoma VARCHAR(100),
    periodo VARCHAR(10),
    valor_indexado DECIMAL(10,2),
    PRIMARY KEY (comunidad_autonoma, periodo)
);

-- Crea la tabla final
CREATE TABLE fact_salary_community (
    comunidad_autonoma VARCHAR(100),
    tipo_jornada VARCHAR(100),
    decil VARCHAR(50),
    periodo INT,
    salario DECIMAL(10, 2)
);

CREATE TABLE fact_interes (
    tipo_interes VARCHAR(50),              -- e.g., 'Fijo'
    naturaleza_finca VARCHAR(50),          -- e.g., 'Vivienda'
    periodo VARCHAR(10),                   -- e.g., '2022T3'
    valor_interes DECIMAL(5, 2),
    PRIMARY KEY (tipo_interes, naturaleza_finca, periodo)
);

CREATE TABLE fact_precio (
    comunidad_autonoma VARCHAR(100),
    año INT,
    precio_m2 DECIMAL(10, 2),
    PRIMARY KEY (comunidad_autonoma, año)
);

CREATE TABLE fact_salary_edad (
    tipo_jornada VARCHAR(50),
    grupo_edad VARCHAR(50),
    decil VARCHAR(50),
    periodo VARCHAR(10),
    salario DECIMAL(10, 2),
    PRIMARY KEY (tipo_jornada, grupo_edad, decil, periodo)
);
