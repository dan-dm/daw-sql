-- Título de la actividad: Base de datos objeto-relacional, casos prácticos. 
-- Alumno: Dan Marius Dumitrescu 
-- Módulo: M02-Bases de datos 
-- UF4: Bases de datos objeto-relacionales

/*1. Instalaciones deportivas municipales. 

Se quiere diseñar una Base de Datos Objeto Relacional para controlar el acceso a las pistas deportivas de nuestra ciudad. Se tendrán en cuenta los siguientes supuestos:
• Todo aquel que quiera hacer uso de las instalaciones tendrá que registrarse y proporcionar su nombre, apellidos, email, teléfono, y fecha de nacimiento. A cada usuario se le asignará un código.
• Hay varios polideportivos en la ciudad, identificados por nombre, dirección, extensión (en m2) y un determinado código.
• En cada polideportivo hay varias pistas de diferentes deportes. De cada pista guardaremos un código que la identifica, el tipo de pista (tenis, fútbol, pádel, etc.), si está operativa o en mantenimiento y el precio.
• Cada vez que un usuario registrado quiera utilizar una pista tendrá que realizar una reserva previa a través de la web que el ayuntamiento ha creado. De cada reserva queremos registrar la fecha en la que se reserva la pista, la fecha en la que se usará. Hay que tener en cuenta que todos los jugadores que vayan a hacer uso de las pistas deberán estar registrados en el sistema y serán vinculados con la reserva
*/ 
--DROP TABLESPACE INSTALACIONES_DEPORTIVAS including contents and datafiles; 
CREATE TABLE instalaciones_deportivas DATAFILE 'c:\oracle-dbs\instalaciones.dbf' SIZE 20m; 

-- 1. Creación de todos los tipos y tablas asociadas. 
-- TIPO/TABLA USUARIo 
--DROP TYPE TIPOUSUARIO;
CREATE OR REPLACE TYPE TIPOUSUARIO AS OBJECT ( 
  id               NUMBER, 
  nombre           VARCHAR2(50), 
  apellidos        VARCHAR2(50), 
  email            VARCHAR2(50), 
  telefono         VARCHAR2(50), 
  fecha_nacimiento DATE 
);

--DROP TABLE TABLAUSUARIOS; 
CREATE TABLE TABLAUSUARIOS OF TIPOUSUARIO ( 
  id PRIMARY KEY 
); 

-- TIPO/TABLA POLIDEPORTIVO 
--DROP TYPE TIPOPOLIDEPORTIVO; 
CREATE OR REPLACE TYPE TIPOPOLIDEPORTIVO AS OBJECT ( 
  id        NUMBER, 
  nombre    VARCHAR2(50), 
  direccion VARCHAR2(50), 
  extension NUMBER 
); 

--DROP TABLE TABLAPOLIDEPORTIVOS; 
CREATE TABLE TABLAPOLIDEPORTIVOS OF TIPOPOLIDEPORTIVO ( 
    id PRIMARY KEY, 
    extension DEFAULT 0 
); 

-- TIPO/TABLA PISTA 
--DROP TYPE TIPOPISTA; 
CREATE OR REPLACE TYPE TIPOPISTA AS OBJECT ( 
  id     NUMBER, 
  codigo VARCHAR2(10), 
  tipo   VARCHAR2(20), 
  estado VARCHAR2(4), 
  precio DECIMAL(7, 2), 
  id_polideportivo ref TIPOPOLIDEPORTIVO 
);

--DROP TABLE TABLAPISTAS; 
CREATE TABLE TABLAPISTAS OF TIPOPISTA ( 
    id PRIMARY KEY, 
    tipo CHECK (tipo IN ('PADEL', 
                         'FUTBOL', 
                         'TENIS')), 
    estado CHECK (estado IN ('oper', 
                             'mant')), 
    id_polideportivo REFERENCES TABLAPOLIDEPORTIVOS 
); 

-- TIPO/TABLA RESERVAS 
--DROP TYPE TIPORESERVA; 
CREATE OR REPLACE TYPE TIPORESERVA AS OBJECT ( 
  id NUMBER, 
  fecha_reserva timestamp, 
  fecha_uso timestamp, 
  id_pista ref tipopista, 
  id_usuario ref tipousuario
);

--DROP TABLE TABLARESERVAS; 
CREATE TABLE TABLARESERVAS OF TIPORESERVA ( 
    id PRIMARY KEY, 
    fecha_reserva DEFAULT current_timestamp, 
    id_pista REFERENCES TABLAPISTAS, 
    id_usuario REFERENCES TABLAUSUARIOS 
); 

--2. Inserción de datos en todas las tablas. 
INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(1, 'Miles', 'Olyonov', 'molyonov0@chron.com', '1562768101', '21-Sep-1973') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(2, 'Andris', 'Jaggard', 'ajaggard1@irs.gov', '8903945799', '17-Apr-1989') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(3, 'Gabbie', 'Cracknall', 'gcracknall2@stumbleupon.com', '5592339350', '12-Jan-1976') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(4, 'Arabel', 'Kmicicki', 'akmicicki3@is.gd', '9391931080', '09-Dec-1971') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(5, 'Dorena', 'Pardie', 'dpardie4@ed.gov', '4228108412', '19-May-1981') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(6, 'Tilly', 'Herion', 'therion5@goo.gl', '4227208578', '30-Jan-1980') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(7, 'Anneliese', 'Sporton', 'asporton6@berkeley.edu', '3082600005', '20-Oct-1982') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(8, 'Sephira', 'Litster', 'slitster7@wp.com', '5633740751', '23-Oct-1994') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(9, 'Kaylee', 'Bubbins', 'kbubbins8@com.com', '9686646725', '04-Mar-1989') 
            ); 

INSERT INTO TABLAUSUARIOS VALUES 
            ( 
                        TIPOUSUARIO(10, 'Monika', 'Chiverton', 'mchiverton9@cbslocal.com', '5717659724', '24-Feb-1975') 
            ); 

SELECT * 
FROM   TABLAUSUARIOS; 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(1, 'Dibbert, Brekke and Auer', '6570 Oakridge Place', 676)
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(2, 'Kemmer, Durgan and Hoeger', '3 Messerschmidt Drive', 637)
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(3, 'Nitzsche LLC', '357 Dunning Place', 467) 
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(4, 'Johns, Hayes and Schiller', '665 Merrick Pass', 546)
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(5, 'Purdy LLC', '044 Pennsylvania Lane', 838) 
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(6, 'Fay Inc', '8680 Fremont Circle', 384) 
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(7, 'Williamson Group', '2595 Glacier Hill Junction', 391)
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(8, 'Ernser-Robel', '10 Randy Lane', 900) 
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(9, 'Altenwerth-Stroman', '65235 Dottie Way', 307) 
            ); 

INSERT INTO TABLAPOLIDEPORTIVOS VALUES 
            ( 
                        TIPOPOLIDEPORTIVO(10, 'Kutch-Kozey', '60 Hoffman Lane', 296) 
            ); 

SELECT * 
FROM   TABLAPOLIDEPORTIVOS; 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(1, 'PADEL50612', 'PADEL', 'oper', '136', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=6)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(2, 'PADEL88716', 'PADEL', 'oper', '157.53', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=7)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(3, 'PADEL85616', 'PADEL', 'mant', '157.50', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=5)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(4, 'FUTBO93436', 'FUTBOL', 'mant', '108.21', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=3)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(5, 'PADEL79976', 'PADEL', 'oper', '71.31', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=1)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(6, 'PADEL94469', 'PADEL', 'mant', '121.01', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=1)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(7, 'PADEL14232', 'PADEL', 'mant', '109.20', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=2)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(8, 'TENIS46742', 'TENIS', 'mant', '145.50', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=2)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(9, 'FUTBO45352', 'FUTBOL', 'oper', '159.91', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=7)) 
            ); 

INSERT INTO TABLAPISTAS VALUES 
            ( 
                        tipopista(10, 'PADEL50164', 'PADEL', 'oper', '47.86', 
                        ( 
                               SELECT ref(t) 
                               FROM   tablapolideportivos t 
                               WHERE  t.id=7)) 
            ); 

SELECT * 
FROM   TABLAPISTAS; 

INSERT INTO TABLARESERVAS VALUES 
            ( 
                        tiporeserva(1, current_timestamp, to_date('30-01-21 09:30:00','DD-MM-YY HH24:MI:SS'), 
                        ( 
                               SELECT ref(ta) 
                               FROM   tablapistas ta 
                               WHERE  ta.id=1), 
                        ( 
                               SELECT ref(tb) 
                               FROM   tablausuarios tb 
                               WHERE  tb.id=1)) 
            ); 

INSERT INTO TABLARESERVAS VALUES 
            ( 
                        tiporeserva(2, current_timestamp, to_date('20-01-21 13:00:00','DD-MM-YY HH24:MI:SS'), 
                        ( 
                               SELECT ref(ta) 
                               FROM   tablapistas ta 
                               WHERE  ta.id=7), 
                        ( 
                               SELECT ref(tb) 
                               FROM   tablausuarios tb 
                               WHERE  tb.id=3)) 
            ); 

INSERT INTO TABLARESERVAS VALUES 
            ( 
                        tiporeserva(3, current_timestamp, to_date('04-02-21 10:30:00','DD-MM-YY HH24:MI:SS'), 
                        ( 
                               SELECT ref(ta) 
                               FROM   tablapistas ta 
                               WHERE  ta.id=6), 
                        ( 
                               SELECT ref(tb) 
                               FROM   tablausuarios tb 
                               WHERE  tb.id=5)) 
            ); 

INSERT INTO TABLARESERVAS VALUES 
            ( 
                        tiporeserva(4, current_timestamp, to_date('18-02-21 11:00:00','DD-MM-YY HH24:MI:SS'), 
                        ( 
                               SELECT ref(ta) 
                               FROM   tablapistas ta 
                               WHERE  ta.id=4), 
                        ( 
                               SELECT ref(tb) 
                               FROM   tablausuarios tb 
                               WHERE  tb.id=8)) 
            ); 

INSERT INTO TABLARESERVAS VALUES 
            ( 
                        tiporeserva(5, current_timestamp, to_date('21-02-21 12:30:00','DD-MM-YY HH24:MI:SS'), 
                        ( 
                               SELECT ref(ta) 
                               FROM   tablapistas ta 
                               WHERE  ta.id=2), 
                        ( 
                               SELECT ref(tb) 
                               FROM   tablausuarios tb 
                               WHERE  tb.id=3)) 
            ); 

--3. Consulta de todas las reservas. 
SELECT * 
FROM   TABLARESERVAS; 

--4. Consulta de las reservas de un determinado usuario. 
SELECT t.id, 
       t.fecha_reserva, 
       t.fecha_uso, 
       deref(id_pista).codigo, 
       deref(id_usuario).id 
FROM   tablareservas t 
WHERE  t.id_usuario= 
       ( 
              SELECT ref(tb) 
              FROM   tablausuarios tb 
              WHERE  tb.id=3); 

--5. Consulta de las reservas de un determinado mes. 
SELECT t.id, 
       t.fecha_reserva, 
       t.fecha_uso, 
       deref(id_pista).codigo, 
       deref(id_usuario).id 
FROM   tablareservas t 
WHERE  extract(month FROM t.fecha_uso) = 2; 

--para febrero hay 3 reservas 

--6.	Consulta de las pistas de un determinado polideportivo.

SELECT t.id AS "ID PISTA", 
       t.codigo, 
       t.tipo,
       t.estado,
       t.precio,
       deref(id_polideportivo).id AS "ID POLIDEPORTIVO",
       deref(id_polideportivo).nombre AS "POLIDEPORTIVO"
FROM   tablapistas t 
WHERE  t.id_polideportivo= 
       ( 
              SELECT ref(tb) 
              FROM   tablapolideportivos tb 
              WHERE  tb.id=2); 

--7. Comprobación de la integridad referencial. 
--Error report - 
--ORA-02292: integrity constraint (SYSTEM.SYS_C007623) violated - child record found 
DELETE 
FROM   tablausuarios 
WHERE  id=3;