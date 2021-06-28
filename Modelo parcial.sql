USE MODELOPARCIAL1

-- 1 Apellido y nombres de los pacientes cuya cantidad de turnos de 'Proctologia' sea mayor a 2.
SELECT P.APELLIDO, P.NOMBRE
FROM PACIENTES P
WHERE 2 < (
			SELECT COUNT(PA.IDPACIENTE)
			FROM PACIENTES PA INNER JOIN TURNOS T ON PA.IDPACIENTE = T.IDPACIENTE
			INNER JOIN MEDICOS M ON T.IDMEDICO = M.IDMEDICO
			INNER JOIN ESPECIALIDADES E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
			WHERE PA.IDPACIENTE = P.IDPACIENTE AND E.NOMBRE LIKE 'PROCTOLOGIA')

--2 Los apellidos y nombres de los m�dicos (sin repetir) que hayan demorado en alguno de sus turnos menos de la duraci�n promedio de turnos.
	SELECT DISTINCT ME.APELLIDO, ME.NOMBRE
	FROM MEDICOS ME INNER JOIN TURNOS TU ON  ME.IDMEDICO = TU.IDMEDICO
	WHERE TU.DURACION < (SELECT AVG(T.DURACION) 
	FROM TURNOS T)

--3 Por cada paciente, el apellido y nombre y la cantidad de turnos realizados en el primer semestre y la cantidad de turnos realizados
--  en el segundo semestre. Indistintamente del a�o.
	SELECT P.APELLIDO, P.NOMBRE, 
	(
		SELECT COUNT(TU.IDPACIENTE) AS 'PRIMER SEMESTRE'
		FROM PACIENTES PA INNER JOIN TURNOS TU ON PA.IDPACIENTE = TU.IDPACIENTE
		WHERE MONTH(TU.FECHAHORA) <= 6 AND P.IDPACIENTE = PA.IDPACIENTE
		
	) AS 'PRIMER SEMESTRE', 
	(
		SELECT COUNT(TU.IDPACIENTE) AS 'SEGUNDO SEMESTRE'
		FROM PACIENTES PA INNER JOIN TURNOS TU ON PA.IDPACIENTE = TU.IDPACIENTE
		WHERE MONTH(TU.FECHAHORA) > 6 AND P.IDPACIENTE = PA.IDPACIENTE
	) AS 'SEGUNDO SEMESTRE'
	FROM PACIENTES P
	ORDER BY P.APELLIDO DESC
	

--4 Los pacientes que se hayan atendido m�s veces en el a�o 2000 que en el a�o 2001 y a su vez m�s veces en el a�o 2001 que en a�o 2002.
	SELECT T1.APELLIDO, T1.NOMBRE
	FROM(
	SELECT DISTINCT PA.IDPACIENTE, PA.APELLIDO, PA.NOMBRE, 
	(
		SELECT COUNT(TU.IDPACIENTE)
		FROM PACIENTES P INNER JOIN TURNOS TU ON P.IDPACIENTE = TU.IDPACIENTE
		WHERE YEAR(TU.FECHAHORA) = '2000' AND P.IDPACIENTE = PA.IDPACIENTE
	) AS 'TURNOS 2000',
	(
		SELECT COUNT(TU.IDPACIENTE)
		FROM PACIENTES P INNER JOIN TURNOS TU ON P.IDPACIENTE = TU.IDPACIENTE
		WHERE YEAR(TU.FECHAHORA) = '2001' AND P.IDPACIENTE = PA.IDPACIENTE
	) AS 'TURNOS 2001',
	(
		SELECT COUNT(TU.IDPACIENTE)
		FROM PACIENTES P INNER JOIN TURNOS TU ON P.IDPACIENTE = TU.IDPACIENTE
		WHERE YEAR(TU.FECHAHORA) = '2002' AND P.IDPACIENTE = PA.IDPACIENTE
	) AS 'TURNOS 2002'
	FROM PACIENTES PA INNER JOIN TURNOS TU ON PA.IDPACIENTE = TU.IDPACIENTE
	) T1
	WHERE T1.[TURNOS 2000] > T1.[TURNOS 2001] AND T1.[TURNOS 2001] > T1.[TURNOS 2002]