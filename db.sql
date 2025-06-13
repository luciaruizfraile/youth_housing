USE youth_housing;

-- crear primary keys 
ALTER TABLE precios
ADD COLUMN id_precios INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE interes_fijo
ADD COLUMN id_interes_fijo INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE ipv
ADD COLUMN id_ipv INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE salario_ccaa
ADD COLUMN id_salario_ccaa INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE salario_edad
ADD COLUMN id_salario_edad INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE superficie
ADD COLUMN id_superficie INT AUTO_INCREMENT PRIMARY KEY;

-- comprobación de nulos
SELECT COUNT(*) FROM superficie WHERE año IS NULL;


