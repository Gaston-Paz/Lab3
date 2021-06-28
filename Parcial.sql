use parcial1

--Listado con Apellido y nombres de los t�cnicos que, en promedio, hayan demorado
--m�s de 225 minutos en la prestaci�n de servicios.	SELECT T1.Apellido, T1.Nombre	FROM(SELECT T.ID, T.Apellido, T.Nombre, AVG(S.Duracion) AS PROMEDIO		FROM Tecnicos T INNER JOIN Servicios S ON T.ID = S.IDTecnico		GROUP BY T.ID, T.Apellido, T.Nombre) T1	WHERE T1.PROMEDIO >225--ID, Apellido y nombres de los t�cnicos que hayan otorgado m�s d�as de garant�a en
--alg�n servicio que el m�ximo de d�as de garant�a otorgado a un servicio de tipo
--"Reparacion de heladeras"

	SELECT T.ID, T.Apellido, T.Nombre
	FROM Tecnicos T INNER JOIN Servicios S ON T.ID = S.IDTecnico
	WHERE S.DiasGarantia > (
	SELECT TOP (1)S.DiasGarantia 
	FROM Servicios S INNER JOIN TiposServicio TS ON S.IDTipo = TS.ID
	WHERE TS.Descripcion LIKE 'Reparacion de heladeras'
	ORDER BY S.DiasGarantia DESC)

	--Listado con Descripci�n del tipo de servicio y cantidad de clientes distintos de tipo
--	Particular y la cantidad de clientes distintos de tipo Empresa
	SELECT TS.Descripcion, 
	(
		SELECT COUNT(C.ID)
		FROM TiposServicio TIS LEFT JOIN Servicios S ON TIS.ID = S.IDTipo
		LEFT JOIN Clientes C ON S.IDCliente = C.ID
		WHERE C.Tipo LIKE 'P' AND TIS.ID = TS.ID
	) as 'Clientes Particulares',
	(
		SELECT COUNT(C.ID)
		FROM TiposServicio TIS LEFT JOIN Servicios S ON TIS.ID = S.IDTipo
		LEFT JOIN Clientes C ON S.IDCliente = C.ID
		WHERE C.Tipo LIKE 'E' AND TIS.ID = TS.ID
	) as 'Clientes Empresa'
	FROM TiposServicio TS


--Cantidad de clientes que hayan contratado la misma cantidad de servicios con
--garant�a que servicios sin garant�a.

	SELECT COUNT(*)
	FROM (	SELECT CL.ID, 
			(
				SELECT COUNT(S.ID)
				FROM Clientes C INNER JOIN Servicios S ON C.ID = S.IDCliente
				WHERE S.DiasGarantia = 0 AND C.ID = CL.ID
		
			) as 'Sin garantia', 
			(
				SELECT COUNT(S.ID)
				FROM Clientes C INNER JOIN Servicios S ON C.ID = S.IDCliente
				WHERE S.DiasGarantia > 0 AND C.ID = CL.ID
			) as 'Con garantia'
			FROM Clientes CL) AS T1
	WHERE T1.[Con garantia] = T1.[Sin garantia]


Agregar las tablas y/o restricciones que considere necesario para permitir a un
cliente que contrate a un t�cnico por un per�odo determinado. Dicha contrataci�n
debe poder registrar la fecha de inicio y fin del trabajo, el costo total, el domicilio al
que debe el t�cnico asistir y la periodicidad del trabajo (1 - Diario, 2 - Semanal, 3 -
Quincenal).CREATE TABLE Contrataciones(	ID BIGINT PRIMARY KEY NOT NULL,	IDCliente INT FOREIGN KEY REFERENCES Clientes(ID) NOT NULL,	IDTecnico INT FOREIGN KEY REFERENCES Tecnicos(ID) NOT NULL,	FechaInicio DATE CHECK(FechaInicio >= GETDATE()) NOT NULL,	FechaFin DATE NOT NULL,	Domicilio VARCHAR(100) NOT NULL,	Costo MONEY CHECK(Costo > 0),	IDPeriodicidad SMALLINT CHECK(IDPeriodicidad = 'Diario' OR IDPeriodicidad = 'Semanal' OR IDPeriodicidad = 'Quincenal') NOT NULL)ALTER TABLE Contrataciones add constraint CHK_Fechafin check(FechaFin>= FechaInicio)