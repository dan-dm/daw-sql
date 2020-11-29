-- Título de la actividad: Caso práctico I de lenguajes SQL: DML y DDL.
-- Alumno: Dan Marius Dumitrescu 
-- Módulo: M02-Bases de datos 
-- UF2: Lenguajes SQL: DML y DLLPaquete SCORM

/*
	1.	Realiza el Modelo Relacional del modelo E-R de los alojamientos rurales.
    
ALOJAMIENTO(CodAlojamiento, Nombre, Direccion, Telefono, Categoria);
PERSONAL(CodPersonal, Nombre, Apellido1, Apellido2, Nif, Direccion);
TIPO_HABITACION(CodTipo, Tipo);
HABITACION(NumHabitación, Precio, Bano, CodTipo, CodAlojamiento);
ACTIVIDAD(CodActividad, Nombre, Nivel, Descripcion);
ALO_ACT(CodAlojamiento, CodActividad, Dia);
*/

/*
	2.	Implementa en MySQL el modelo relacional. La base de datos se llamará ARURAL.
*/
/* Creación de la base de datos */
CREATE DATABASE IF NOT EXISTS ARURAL;
USE ARURAL;

/* Creación de las tablas */
CREATE TABLE alojamiento 
  ( 
    codalojamiento MEDIUMINT PRIMARY KEY auto_increment NOT NULL, 
    nombre    CHAR(50) NOT NULL, 
    direccion CHAR(100), 
    telefono  NUMERIC(9), 
    categoria VARCHAR(5) check (categoria IN ('*', 
                                              '**', 
                                              '***', 
                                              '****', 
                                              '*****')) 
  );

CREATE TABLE personal 
  ( 
     codpersonal    MEDIUMINT PRIMARY KEY auto_increment NOT NULL, 
     nombre         CHAR(25) NOT NULL, 
     apellido1      CHAR(50) NOT NULL, 
     apellido2      CHAR(50), 
     nif            VARCHAR(9) NOT NULL, 
     direccion      CHAR(100), 
     codalojamiento MEDIUMINT NOT NULL, 
     CONSTRAINT fk_pers_aloj FOREIGN KEY (codalojamiento) REFERENCES alojamiento 
     (codalojamiento) 
  ); 

CREATE TABLE tipo_habitacion 
  ( 
     codtipo SMALLINT PRIMARY KEY auto_increment NOT NULL, 
     tipo    CHAR(25) NOT NULL 
  ); 
																												
CREATE TABLE habitacion 
  ( 
     numhabitacion  SMALLINT NOT NULL, 
     precio         DECIMAL(10, 2) NOT NULL, 
     bano           TINYINT, 
     codtipo        SMALLINT NOT NULL, 
     codalojamiento MEDIUMINT NOT NULL, 
     CONSTRAINT pk_habitacion PRIMARY KEY (numhabitacion, codalojamiento), 
     CONSTRAINT fk_habi_tipo FOREIGN KEY (codtipo) REFERENCES tipo_habitacion( 
     codtipo), 
     CONSTRAINT fk_habi_aloj FOREIGN KEY (codalojamiento) REFERENCES alojamiento 
     (codalojamiento) 
  ); 																																	

CREATE TABLE actividad 
  ( 
     codactividad MEDIUMINT PRIMARY KEY auto_increment NOT NULL, 
     nombre CHAR(50) NOT NULL, 
     nivel  SMALLINT check (nivel BETWEEN 1 AND 10) DEFAULT 5, 
     descripcion text 
  );

CREATE TABLE alo_act 
  ( 
     codalojamiento MEDIUMINT NOT NULL, 
     codactividad   MEDIUMINT NOT NULL, 
     dia            DATE NOT NULL, 
     CONSTRAINT pk_alo_act PRIMARY KEY (codalojamiento, codactividad, dia), 
     CONSTRAINT fk_codalojamiento FOREIGN KEY (codalojamiento) REFERENCES 
     alojamiento(codalojamiento), 
     CONSTRAINT fk_codactividad FOREIGN KEY (codactividad) REFERENCES actividad( 
     codactividad) 
  ); 

/*
	3.	Se realizaran muchas búsquedas por el nombre del alojamiento rural, crea un índice para acelerar estas consultas. 
		También se realizan muchas consultas por el nif del personal. Crea un índice para éste campo.
*/
/* Creación de índices */
CREATE FULLTEXT INDEX index_nombrealojamiento ON alojamiento(nombre); 

CREATE UNIQUE INDEX index_nifpersonal ON personal(nif ASC, codpersonal); 
