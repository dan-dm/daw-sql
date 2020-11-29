-- Título de la actividad: Caso práctico II de lenguajes SQL: DML y DDL 
-- Alumno: Dan Marius Dumitrescu 
-- Módulo: M02-Bases de datos 
-- UF2: Lenguajes SQL: DML y DDL 
DROP DATABASE IF EXISTS concesionario; 

-- crear la base de datos 
CREATE DATABASE concesionario; 
USE concesionario; 

-- tabla tienda 
CREATE TABLE tienda 
  ( 
     idtienda         INT NOT NULL, 
     nombre           VARCHAR(100), 
     ciudad           VARCHAR(100), 
     num_trabajadores INT, 
     superficie       INT, 
     PRIMARY KEY (idtienda) 
  ); 

-- tabla vehiculos 
CREATE TABLE vehiculos 
  ( 
     matricula  VARCHAR(8) NOT NULL, 
     marca      VARCHAR(100), 
     modelo     VARCHAR(100), 
     color      VARCHAR(100), 
     cilindrada DECIMAL(2, 1), 
     antiguedad INT, 
     km         INT, 
     precio     INT, 
     idtienda   INT, 
     PRIMARY KEY (matricula), 
     FOREIGN KEY (idtienda) REFERENCES tienda(idtienda) 
  ); 

-- Rellenar la base de datos //inserts
INSERT INTO tienda 
VALUES	(1,'Auto 2','Madrid',5,1250),
		(2,'MultiMarca Total','Madrid',8,1750),
		(3,'CarAuto','Barcelona',10,2000),
		(4,'Turismos Díaz','Barcelona',5,1000),
		(5,'BarnaCar','Barcelona',15,3000);

INSERT INTO vehiculos 
VALUES	('1213-CRX','Seat','León','Negro',1.8,2004,180000,2000,1),
		('3243-HTN','Seat','Altea','Rojo',1.2,2013,85000,7900,2),
		('6643-KBM','Seat','Ibiza','Blanco',1,2017,25000,10900,2),
		('8265-HZL','Nissan','Juke','Blanco',1.6,2014,110000,13900,3),
		('8919-HHH','Nissan','Qashqai','Gris',2,2011,200000,8500,4),
		('7623-GRS','Volkswagen','Tiguan','Gris',2,2010,130000,12000,1),
		('4901-KPS','Volkswagen','Polo','Azul',1,2018,10000,11500,2),
		('6841-LBN','Volkswagen','Golf','Rojo',1.6,2019,15000,22500,NULL);

-- CONSULTAS --
-- 1.	Consulta que muestre todas las tiendas de más de 1500 metros, ordenadas por el nombre de la tienda.
SELECT nombre 
FROM   tienda 
WHERE  superficie > 1500 
ORDER  BY nombre; 

-- 2.	Consulta que muestre la marca y el modelo de los vehículos que sean blancos o su antigüedad sea inferior a 2012.
SELECT marca, 
       modelo 
FROM   vehiculos 
WHERE  color = 'blanco' 
        OR antiguedad < 2012; 

-- 3.	Consulta que muestre el nombre de la tienda, la marca, el modelo y el precio del vehículo.
SELECT tienda.nombre AS 'nombre tienda', 
       vehiculos.marca, 
       vehiculos.modelo, 
       vehiculos.precio 
FROM   vehiculos 
       JOIN tienda 
         ON tienda.idtienda = vehiculos.idtienda; 

-- 4.	¿Cuántos vehículos tenemos de cada marca?
SELECT marca, 
       Count(*) AS 'Número de vehículos'
FROM   vehiculos 
GROUP  BY marca 
ORDER  BY marca;

-- 5.	¿Cuál es el importe total de los vehículos de cada tienda?
SELECT nombre                AS tienda, 
       Sum(vehiculos.precio) AS importe 
FROM   tienda 
       JOIN vehiculos 
         ON tienda.idtienda = vehiculos.idtienda 
GROUP  BY tienda.idtienda;

-- 6.	Mostrar la marca, modelo, km y la tienda de cada vehículo. Si un vehículo no está en ninguna tienda también debe salir.
SELECT marca, 
       modelo, 
       km, 
       tienda.nombre AS tienda
FROM   vehiculos 
       LEFT JOIN tienda 
              ON tienda.idtienda = vehiculos.idtienda;

-- 7.	Mostrar la media de km de los vehículos de la marca Seat.
SELECT Avg(v.km) AS 'media km' 
FROM   vehiculos v 
       INNER JOIN tienda t 
               ON t.idtienda = v.idtienda 
WHERE  marca LIKE 'Seat'; 

-- 8.	¿Cuál es la media de km y de precio de los vehículos con una antigüedad inferior a 2015?
SELECT Avg(v.km)     AS 'media km', 
       Avg(v.precio) AS 'media precio' 
FROM   vehiculos v 
       INNER JOIN tienda t 
               ON t.idtienda = v.idtienda 
WHERE  antiguedad < 2015; 

-- 9.	Mostrar la tienda y la suma de km de sus vehículos, solo de aquellas tiendas que la suma de km de sus vehículos es superior a 150000.
SELECT nombre  AS tienda, 
       Sum(km) AS 'suma km vehiculos' 
FROM   vehiculos 
       INNER JOIN tienda using(idtienda) 
GROUP  BY nombre 
HAVING Sum(km) > 150000; 

-- 10.	Mostrar la marca y el modelo de los vehículos que no están en ninguna tienda.
SELECT marca, 
       modelo 
FROM   vehiculos 
WHERE  idtienda IS NULL; 

-- 11.	Mostrar la marca, el modelo, el precio y una nueva columna con un 10% sobre el precio a la que llamaremos descuento de los vehículos con más de 100000 km y un precio menor 10000€.
SELECT marca, 
       modelo, 
       ( 10 * precio ) / 100 AS descuento 
FROM   vehiculos 
WHERE  km > 100000 
       AND precio < 10000; 

-- 12.	Marca y modelo del vehículo de mayor antigüedad.
SELECT marca, 
       modelo 
FROM   vehiculos 
WHERE  antiguedad = (SELECT Min(antiguedad) 
                     FROM   vehiculos); 

-- 13.	Marca y modelo de los vehículos que tienen un importe superior al vehículo de la marca Seat más caro.
SELECT marca, 
       modelo 
FROM   vehiculos 
WHERE  precio > (SELECT Max(precio) 
                 FROM   vehiculos 
                 WHERE  marca = 'Seat');
                 
-- 14.	Qué antigüedad tiene el vehículo con  más km que no es de color blanco ni de la marca Wolkswagen.
SELECT antiguedad 
FROM   vehiculos 
WHERE  km IN (SELECT Max(km) 
              FROM   vehiculos 
              WHERE  color != 'blanco' 
                     AND marca != 'Volkswagen'); 

-- 15.	Mostrar los vehículos de las tiendas que no son de Madrid.
SELECT marca, 
       modelo, 
       nombre AS 'tienda' 
FROM   vehiculos 
       INNER JOIN tienda 
               ON tienda.idtienda = vehiculos.idtienda 
WHERE  ciudad != 'Madrid'; 
