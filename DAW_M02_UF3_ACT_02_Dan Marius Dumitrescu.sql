-- Título de la actividad: SQL:DCL y extensión procedimental, casos prácticos II
-- Alumno: Dan Marius Dumitrescu 
-- Módulo: M02-Bases de datos 
-- UF3: Lenguaje SQL: DCL y extensión procedimental

-- Crear tablas
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

-- Inserts
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


-----------

SET SERVEROUTPUT ON;

-----------

-- 1.	Realizar un procedimiento almacenado “entrar_alumno” que me permita 
-- introducir los datos de un alumno por el teclado. Es necesario controlar 
-- como mínimo que el código del alumno no exista previamente (clave duplicada).

CREATE OR REPLACE PROCEDURE entrar_alumno(
                                        p_id     IN alumnos.id_alumno%TYPE, 
                                        p_nombre IN alumnos.nombre%TYPE, 
                                        p_fecha  IN alumnos.fecha_inscr%TYPE, 
                                        p_curso  IN alumnos.curso_inscrito%TYPE) 
IS 
  CURSOR cursoralumnos IS 
    SELECT * 
    FROM   alumnos; 
  fila alumnos%ROWTYPE; 
  alumnoyaexiste EXCEPTION; 
  
BEGIN 
    OPEN cursoralumnos;
    FOR fila IN cursoralumnos LOOP 
        IF p_id = fila.id_alumno THEN 
          RAISE alumnoyaexiste; 
        END IF; 
    END LOOP; 
    CLOSE cursoralumnos;

    INSERT INTO alumnos 
    VALUES      (p_id, 
                 p_nombre, 
                 p_fecha, 
                 p_curso); 

    dbms_output.put_line('Alumno introducido correctamente: ' || p_nombre); 
    
EXCEPTION 
  WHEN alumnoyaexiste THEN 
             raise_application_error(-20100, '**El alumno ya existe**'); 
END; 

--Llamada al procedimiento entrar_alumno
ACCEPT alumno prompt 'ID Usuario:'; 
ACCEPT nombre prompt 'Nombre:'; 
ACCEPT fecha prompt 'Fecha inscripción:'; 
ACCEPT curso prompt 'Curso:'; 
DECLARE 
    alumno alumnos.id_alumno%TYPE := &alumno; 
    nombre alumnos.nombre%TYPE := '&nombre'; 
    fecha  alumnos.fecha_inscr%TYPE := '&fecha'; 
    curso  alumnos.curso_inscrito%TYPE := &curso; 
BEGIN 
    entrar_alumno(alumno, nombre, fecha, curso); 
END; 


-- 2.	Implementar un disparador “mostrarcursos” para mostrar por consola, 
-- cuántos alumnos tenemos en total de cada curso. El disparador se ejecutará 
-- después de que se inserte o modifique un alumno de la tabla alumnos.

CREATE OR replace TRIGGER mostrarcursos 
  AFTER INSERT OR UPDATE ON alumnos 
DECLARE 
    CURSOR c_alumnos IS 
      SELECT cursos.nombre AS Curso, 
             Count(*)      AS Total 
      FROM   cursos 
             inner join alumnos 
                     ON cursos.id_curso = alumnos.curso_inscrito 
      GROUP  BY cursos.nombre; 
    fila cursos%ROWTYPE; 
    
BEGIN 
    OPEN c_alumnos;
    FOR fila IN c_alumnos LOOP 
        dbms_output.Put_line('Hay ' 
                             || fila.total 
                             || ' alumno(s) inscrito(s) en el curso de ' 
                             || fila.curso); 
    END LOOP;
    CLOSE c_alumnos;
END; 

-- Con el mismo procedimiento entrar_alumno podemos ver perfectamente como el 
-- disparador entra en funcionamiento automaticamente despúes de cada 
-- alumno que añadimos
ACCEPT alumno prompt 'ID Usuario:'; 
ACCEPT nombre prompt 'Nombre:'; 
ACCEPT fecha prompt 'Fecha inscripción:'; 
ACCEPT curso prompt 'Curso:'; 
DECLARE 
    alumno alumnos.id_alumno%TYPE := &alumno; 
    nombre alumnos.nombre%TYPE := '&nombre'; 
    fecha  alumnos.fecha_inscr%TYPE := '&fecha'; 
    curso  alumnos.curso_inscrito%TYPE := &curso; 
BEGIN 
    entrar_alumno(alumno, nombre, fecha, curso); 
END; 
