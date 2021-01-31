-- Título de la actividad: Caso práctico III de lenguajes SQL: DML y DDL 
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



-- 1.	En nuestra base de datos concesionario queremos almacenar la información referente a las empresas a la que pertenecen cada tienda. 
-- Crea la siguiente tabla teniendo en cuenta que el nombre del campo debe coincidir con el título de la columna y el tipo de datos estará en función del contenido.
-- Tabla: grupo
--
-- |     idgrupo    	|     empresa           	|     ciudad       	|     presidente         	|     fundacion    	|
-- |----------------	|-----------------------	|------------------	|------------------------	|------------------	|
-- |     1          	|     Madrid Central    	|     Madrid       	|     Sebastián Amaya    	|     2000         	|
-- |     2          	|     Cars Holding      	|     Barcelona    	|     Carmen Álvarez     	|     2003         	|

CREATE TABLE grupo 
  ( 
     idgrupo    INT NOT NULL, 
     empresa    VARCHAR(100), 
     ciudad     VARCHAR(100), 
     presidente VARCHAR(100), 
     fundacion  INT, 
     PRIMARY KEY (idgrupo) 
  ); 
  
-- 2.	Añade a la tabla tienda un campo llamado idgrupo y crea una relación entre el grupo y las tiendas. Un grupo tiene muchas tiendas, y una tienda solo pertenece a un grupo.
ALTER TABLE tienda 
  ADD COLUMN grupo INT, 
  ADD FOREIGN KEY (grupo) REFERENCES grupo(idgrupo); 
  
-- 3.	Añade la información a la tabla grupo.
INSERT INTO grupo 
VALUES	(1,'Madrid Central','Madrid','Sebastián Amaya',2000),
		(2,'Cars Holding','Barcelona','Carmen Álvarez',2003);

-- 4.	Asigna a cada tienda su grupo: Auto2 y CarAuto pertenecen al grupo Madrid Central y las restantes tiendas a Cars Holding.
SET sql_safe_updates = 0; 

UPDATE tienda 
SET    grupo = CASE 
                 WHEN nombre = 'Auto 2' 
                       OR nombre = 'CarAuto' THEN 1 
                 ELSE 2 
               END; 

-- 5.	Muestra el nombre del grupo con el total de trabajadores y el total de superficie de exposición.
SELECT grupo.empresa                AS 'grupo', 
       Sum(tienda.num_trabajadores) AS 'total num. trabajadores', 
       Sum(tienda.superficie)       AS 'total superficie' 
FROM   grupo 
       INNER JOIN tienda 
               ON tienda.grupo = grupo.idgrupo 
GROUP  BY grupo.empresa; 

-- 6.	Muestra para cada vehículo con cilindrada superior a 1.4, su marca, modelo, precio, km, la tienda y el grupo al que pertenece.
SELECT vehiculos.marca  AS marca, 
       vehiculos.modelo AS modelo, 
       vehiculos.precio AS precio, 
       vehiculos.km     AS km, 
       tienda.nombre    AS tienda, 
       grupo.empresa    AS grupo 
FROM   vehiculos 
       LEFT JOIN tienda 
               ON tienda.idtienda = vehiculos.idtienda 
       LEFT JOIN grupo 
               ON grupo.idgrupo = tienda.grupo 
WHERE  cilindrada > 1.4; 

-- 7.	Turismos Díaz amplía su superficie a 2500 metros y ahora dispone de 12 trabajadores. Realiza este cambio en la tabla.
UPDATE tienda
SET superficie = 2500, num_trabajadores = 12
WHERE nombre = 'Turismos Díaz';

-- 8.	Añade a la tabla vehiculos un campo llamado financiado después del campo precio. Rellena este campo con el precio del vehículo más un 10%.
ALTER TABLE vehiculos 
  ADD COLUMN financiado INT AFTER precio; 

UPDATE vehiculos 
SET    financiado = ( vehiculos.precio + vehiculos.precio * 0.1 ); 

-- 9.	Añade a la tabla vehículos un campo llamado descuento. Rellena este campo con el 10% de su precio pero solo aquellos vehículos con una antigüedad inferior a 2015 y un precio inferior a 10000.
ALTER TABLE vehiculos 
  ADD COLUMN descuento INT AFTER km;
  
UPDATE vehiculos 
SET    descuento = (vehiculos.precio * 0.1)
WHERE antiguedad < 2015 AND precio < 10000; 

-- 10.	Crear una base de datos llamada “copiaseguridad” y copiar todos los datos actuales. Deben de utilizarse instrucciones SQL. 
DROP DATABASE IF EXISTS copiaseguridad; 
CREATE DATABASE copiaseguridad; 
USE copiaseguridad; 

CREATE TABLE grupo AS 
  SELECT * 
  FROM   concesionario.grupo; 

CREATE TABLE tienda AS 
  SELECT * 
  FROM   concesionario.tienda; 

CREATE TABLE vehiculos AS 
  SELECT * 
  FROM   concesionario.vehiculos; 

USE concesionario; 

-- 11.	Crea  una vista con todos los vehículos del grupo Madrid Central. La vista mostrará el nombre de la tienda y todos los datos del vehículo. La vista se llamará VistaMadridCentral
CREATE VIEW VistaMadridCentral 
AS 
  SELECT vehiculos.*, 
         tienda.nombre AS tienda 
  FROM   vehiculos 
         INNER JOIN tienda 
                 ON vehiculos.idtienda = tienda.idtienda 
         INNER JOIN grupo 
                 ON tienda.grupo = grupo.idgrupo 
  WHERE  grupo.empresa = 'Madrid Central'; 

-- 12.	Crea una vista actualizable con todos los vehículos de la marca Seat. Comprueba que puedes añadir un registro a esta vista. La vista se llamará VistaSeat. Solo podemos añadir vehículos de la marca Seat.
CREATE VIEW VistaSeat 
AS 
  SELECT * 
  FROM   vehiculos 
  WHERE  marca = 'Seat' 
WITH CHECK OPTION; 

SELECT * 
FROM   VistaSeat; 

INSERT INTO VistaSeat 
VALUES      ('7890-ZXC', 
             'Seat', 
             'Toledo', 
             'Azul', 
             2.4, 
             2020, 
             5800, 
             3000, 
             30000, 
             33000, 
             1); 

SELECT * 
FROM   VistaSeat; 

INSERT INTO VistaSeat 
VALUES      ('1245-ABC', 
             'Ferrari', 
             'Italia', 
             'Rojo', 
             5.4, 
             2010, 
             50000, 
             30000, 
             300000, 
             330000, 
             2); -- no funciona! 

SELECT * 
FROM   VistaSeat; 

-- 13.	Empieza una transacción con la instrucción BEGIN. Incrementa 500 € el precio de todos los vehículos de la marca Seat. Ejecuta un ROLLBACK. ¿Qué ha sucedido?
-- Consulta precios iniciales
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat'; 

BEGIN; 
UPDATE vehiculos 
SET    precio = ( precio + 500 )
WHERE  marca = 'Seat'; 

-- Aquí podemos ver que los precios HAN INCREMENTADO con 500
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat'; 

-- Aquí al hacer un ROLLBACK en vez de un COMMIT, TODOS los cambios se deshacen.
ROLLBACK; 

-- Aquí podemos ver que los precios han vuelto a los valores iniciales.
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat'; 

-- 14.	Empieza una transacción con la instrucción BEGIN. Incrementa 500€ el precio de todos los vehículos de la marca Nissan. Ejecuta un COMMIT. ¿Qué ha sucedido?
-- Consulta precios iniciales
SELECT * 
FROM   vehiculos
WHERE  marca = 'Nissan'; 

BEGIN; 
UPDATE vehiculos 
SET    precio = ( precio + 500 )
WHERE  marca = 'Nissan'; 

-- Aquí podemos ver que los precios HAN INCREMENTADO con 500
SELECT * 
FROM   vehiculos
WHERE  marca = 'Nissan'; 

-- Aquí al hacer un COMMIT, TODOS los cambios se GUARDAN.
COMMIT; 

-- Aquí podemos ver que los incrementos se han guardado.
SELECT * 
FROM   vehiculos
WHERE  marca = 'Nissan'; 

-- 15.	Empieza una transacción con la instrucción BEGIN. Incrementa 500 € el precio de todos los vehículos de la marca Seat. Define un punto de control llamado PASO1. 
-- Borra todos los vehículos de la marca Nissan. Haz un ROLLBACK al PASO1, y luego realiza un COMMIT. Comprueba y comenta que ha sucedido.
-- Consulta precios iniciales
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat' 
OR     marca = 'Nissan';

BEGIN; 
UPDATE vehiculos 
SET    precio = ( precio + 500 )
WHERE  marca = 'Seat'; 

-- Aquí podemos ver que los precios de los coches Seat HAN INCREMENTADO con 500
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat' 
OR     marca = 'Nissan';

-- Creamos el punto de control.
SAVEPOINT PASO1;

-- Borra todos los vehículos de la marca Nissan.
DELETE FROM vehiculos
WHERE  marca = 'Nissan'; 

-- Aquí podemos ver que los coches Nissan se han borrado de la tabla vehiculos.
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat' 
OR     marca = 'Nissan';

-- Aquí al hacer un ROLLBACK a un punto de control se deshace el borrado de los coches Nissan pero manteniendo el incremento de precio de los coches Seat.
ROLLBACK TO PASO1; 

-- Con el commit se guardan todos los cambios. En este caso todo hasta el punto de control.
COMMIT;

-- Aquí podemos comprobar los precios modificados en los coches Seat, y que los coches de marca Nissan siguen en la tabla vehiculos.
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat' 
OR     marca = 'Nissan';

-- 16.	Bloquear la tabla vehiculos por escritura e intentar modificar alguna fila de datos. Comprobara y explicar, con comentarios en el código, qué sucede.
-- Al usar un bloqueo de tipo WRITE, este nos deja a nosotros leer y modificar la tabla pero a nadie más nisiquiera acceder a la tabla, por lo tanto los cambios que hagamos nosotros se guardarán. 
-- Si quisieramos bloquear la tabla para que NADIE pueda hacer cambios en la tabla hemos de usar el bloqueo de tipo READ.
LOCK TABLE vehiculos WRITE;
UPDATE vehiculos 
SET    descuento = ( descuento * 2 )
WHERE  matricula = '1213-CRX'; 

-- El descuento efectivamente se ha doblado (de 200 a 400).
SELECT * 
FROM   vehiculos
WHERE  marca = 'Seat';

-- Con el comando UNLOCK desbloqueamos las tablas.
UNLOCK TABLES;
