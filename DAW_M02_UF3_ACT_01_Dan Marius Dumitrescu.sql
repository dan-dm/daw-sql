-- Título de la actividad: SQL: DCL y extensión procedimental, casos prácticos I
-- Alumno: Dan Marius Dumitrescu 
-- Módulo: M02-Bases de datos 
-- UF3: Lenguaje SQL: DCL y extensión procedimental

/* 
La academia de idiomas World de nuestra localidad nos ha pedido una pequeña 
base de datos para controlar las inscripciones a los cursillos de idiomas 
del próximo verano. 
Para simplificar el problema supondremos que un alumno solo puede apuntarse a 
un solo curso de idiomas.

De los cursos queremos guardar la siguiente información:
•	Código del curso
•	Nombre
•	Horario
•	Fecha inicio
•	Fecha final
•	Precio
•	Profesor que lo imparte.

De los alumnos queremos guardar.

•	Nombre
•	Número de alumno (Clave primaria)
•	Curso al que se inscribe.
•	Fecha de inscripción

Para implementar la tarea debemos realizar las siguientes operaciones: */

--1.	Crear un tablespace de 400MB llamado academia donde se almacenaran 
--todos los datos.

--DROP TABLESPACE academia INCLUDING CONTENTS AND DATAFILES;
CREATE TABLESPACE academia DATAFILE 'C:\oracle-dbs\academia.dbf' SIZE 20M 
AUTOEXTEND ON; 

--2.	Crea un usuario llamado “world” que tenga todos los privilegios en el 
--sistema Oracle. Comprobar que realmente tiene asignados estos permisos.

--DROP USER world CASCADE;
CREATE USER world IDENTIFIED BY "Pa55w.rd" DEFAULT TABLESPACE academia QUOTA 
UNLIMITED ON academia; 

GRANT ALL PRIVILEGES TO world WITH ADMIN OPTION; 

--Opción 1: Ver listado de roles asignados.
SELECT * 
FROM   dba_sys_privs 
WHERE  grantee = 'WORLD'; 

--Opción 2: Ver número de roles asignados.
SELECT grantee, 
       Count(privilege) 
FROM   dba_sys_privs 
WHERE  grantee = 'WORLD' 
GROUP  BY grantee; 

--3.	Utilizando el usuario de nombre “world” crea la tabla cursos y la tabla 
--alumnos. Utilizar el tipo de campo y la longitud que creáis más adecuados para
--cada uno de los campos. Introduce datos en las tablas.

--En Oracle SQL Developer los conectamos a la base de datos con el nuevo usuario
--utilizando el botón "New Database Connection" (botón + verde de la 
--barra de conexiones) 

--CONNECT world
--Verificamos el usuario conectado:
select user from dual;
--Se nos muestra USER: WORLD.

--Crear tablas
CREATE TABLE cursos 
  ( 
     id_curso     NUMBER(5) PRIMARY KEY, 
     nombre       VARCHAR2(50) NOT NULL, 
     horario      VARCHAR2(25) NOT NULL, 
     fecha_inicio DATE NOT NULL, 
     fecha_final  DATE NOT NULL, 
     precio       NUMBER(8, 2) NOT NULL, 
     profesor     VARCHAR2(50) NOT NULL 
  ); 

CREATE TABLE alumnos 
  ( 
     id_alumno      NUMBER(5) PRIMARY KEY, 
     nombre         VARCHAR2(50) NOT NULL, 
     fecha_inscr    DATE NOT NULL, 
     curso_inscrito NUMBER(5), 
     CONSTRAINT fk_alumno FOREIGN KEY (curso_inscrito) REFERENCES cursos( 
     id_curso) 
  ); 

--Inserts
INSERT INTO cursos 
VALUES      (1, 
             'Inglés B2 - Intermediary', 
             'L-J de 20:00 a 21:30', 
             '28-NOV-2020', 
             '15-FEB-2021', 
             990.00, 
             'Alice Wonderland'); 

INSERT INTO cursos 
VALUES      (2, 
             'Inglés C1 - Advanced', 
             'L-V de 17:30 a 19:00', 
             '20-NOV-2020', 
             '15-JAN-2021', 
             1490.50, 
             'Peter Pan'); 

--SELECT * FROM   cursos; 

INSERT INTO alumnos 
VALUES      (1, 
             'Margaret Thatcher', 
             '29-OCT-2020', 
             2); 

INSERT INTO alumnos 
VALUES      (2, 
             'Winston Churchill', 
             '15-NOV-2020', 
             1); 

--SELECT * FROM   alumnos; 

--4.	Crear dos usuarios “secre1” y “secre2” con password “world1234”, que se 
--encarguen de la gestión de la academia (añadir, modificar, borrar, consultar) 
--en la tabla de cursos y en la tabla de alumnos.  Comprueba que los privilegios
--se han asignado de forma correcta y que puede hacer las operaciones asignadas.

--DROP USER secre1 CASCADE;
--DROP USER secre2 CASCADE;
CREATE USER secre1 IDENTIFIED BY "Pa55w.rd" DEFAULT TABLESPACE academia QUOTA 
UNLIMITED ON academia; 

CREATE USER secre2 IDENTIFIED BY "Pa55w.rd" DEFAULT TABLESPACE academia QUOTA 
UNLIMITED ON academia; 

--Asignamos privilegios.
GRANT CREATE SESSION TO secre1, secre2; 

GRANT SELECT, INSERT, UPDATE, DELETE ON cursos TO secre1, secre2; 

GRANT SELECT, INSERT, UPDATE, DELETE ON alumnos TO secre1, secre2; 

--Comprobamos privilegios globales. Hemos de conectarnos con el usuario SYSTEM.
--CONNECT SYSTEM
SELECT * 
FROM   dba_sys_privs 
WHERE  grantee IN( 'SECRE1', 'SECRE2' ); 

SELECT Substr(grantee, 1, 10), 
       Substr(table_name, 1, 10), 
       Substr(privilege, 1, 10) 
FROM   dba_tab_privs 
WHERE  grantee IN( 'SECRE1', 'SECRE2' ); 

--5.	Se decide que el usuario “secre1” pueda crear nuevos usuarios, pero no 
--podrá eliminar a ningún usuario.  Comprobar que realmente tiene asignados 
--estos permisos. Quitamos el permiso de borrar registros al usuario “secre2” 
--sobre la tabla de cursos. Comprobación.

GRANT CREATE USER TO secre1; 

--Comprobación 
--CONNECT SYSTEM
SELECT * 
FROM   dba_sys_privs 
WHERE  grantee = 'SECRE1'; 

--Para comprobar nos conectamos a la base de datos con el usuario 'secre1'
--DROP USER usuario_prueba CASCADE;
--CONNECT secre1
CREATE USER usuario_prueba IDENTIFIED BY "Pa55w.rd" DEFAULT TABLESPACE academia 
QUOTA UNLIMITED ON academia;

--El siguiente comando nos da error ORA-01031: insufficient privileges
DROP USER usuario_prueba;
--El usuario secre1 sólo tiene permisos para crear usuarios, no para borrarlos.

--CONNECT WORLD
REVOKE DELETE ON cursos FROM secre2; 

--Comprobaión permisos sobre tablas
--CONNECT SYSTEM
SELECT * 
FROM   dba_tab_privs 
WHERE  grantee = 'SECRE2'; 
--Vemos que el usuario 'secre2' ya no tiene permisos de DELETE sobre 'cursos'

--6.	El usuario “world” concede al usuario “secre2”, la posibilidad de 
--asignar el permiso de lectura (SELECT) de datos a otros usuarios sobre la 
--tabla de alumnos. Comprobar que realmente tiene asignados estos permisos.

--CONNECT world
GRANT SELECT ON alumnos TO secre2 WITH GRANT OPTION; 

GRANT CREATE SESSION TO usuario_prueba; 

--CONNECT secre2
GRANT SELECT ON world.alumnos TO usuario_prueba;

SELECT nombre 
FROM   world.alumnos; 

--CONNECT SYSTEM
SELECT substr(grantee, 1, 10)    AS "user", 
       substr(table_name, 1, 10) AS "table",
       substr(privilege, 1, 10)  AS "priviledge"
FROM   dba_tab_privs 
WHERE  grantee = 'USUARIO_PRUEBA'; 

--7.	Crea un rol llamado rolprofe con las siguientes características: Puede 
--iniciar sesión, leer la tabla de cursos y leer y modificar la tabla de 
--alumnos (no puede ni borrar ni añadir).

--CONNECT world
CREATE ROLE rolprofe; 

GRANT CREATE SESSION TO rolprofe; 

GRANT SELECT ON cursos TO rolprofe; 

GRANT SELECT, UPDATE ON alumnos TO rolprofe; 

--8.	Crea dos usuarios “profe1” y “profe2” con password “profe1234” y le 
--asignas el rol anterior. Comprueba que tienen los permisos correspondientes.

--DROP USER profe1 CASCADE;
--DROP USER profe2 CASCADE;
CREATE USER profe1 IDENTIFIED BY "profe1234" DEFAULT TABLESPACE academia QUOTA 
UNLIMITED ON academia; 

CREATE USER profe2 IDENTIFIED BY "profe1234" DEFAULT TABLESPACE academia QUOTA 
UNLIMITED ON academia; 

GRANT rolprofe TO profe1; 

GRANT rolprofe TO profe2; 

--Comprobaciónes
--CONNECT SYSTEM
SELECT * 
FROM   dba_sys_privs 
WHERE  grantee = 'ROLPROFE'; 

SELECT table_name, 
       privilege, 
       grantee 
FROM   dba_tab_privs 
WHERE  grantee = 'ROLPROFE'; 

--CONNECT profe1
SELECT * 
FROM   world.cursos; 

SELECT * 
FROM   world.alumnos; 

UPDATE world.alumnos 
SET    curso_inscrito = 1 
WHERE  id_alumno = 1; 

--En la tabla cursos no tiene privilegios! 
UPDATE world.cursos 
SET    nombre = 'Castellano B2' 
WHERE  id_curso = 1; 

--9.	Crearemos un perfil para los profesores llamado perfilprofe que tenga un
--tiempo máximo de conexión de 1 hora, dos conexiones simultáneas y le obligue a
--cambiar la contraseña cada 30 días. Asigna este perfil al usuario profe1.

--CONNECT world
--DROP PROFILE perfilprofe;
CREATE PROFILE perfilprofe LIMIT
CONNECT_TIME 60
SESSIONS_PER_USER 2
PASSWORD_LIFE_TIME 30;

ALTER USER profe1 PROFILE perfilprofe;

--Comprobar los limites aplicados
--CONNECT SYSTEM
SELECT resource_name, 
       limit 
FROM   dba_profiles 
WHERE  PROFILE = 'PERFILPROFE'; 
