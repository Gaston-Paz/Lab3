USE BluePrint

-- 1- Listar los nombres de proyecto y costo estimado de aquellos proyectos cuyo costo estimado sea mayor al promedio de costos.
	SELECT Nombre, CostoEstimado from Proyectos
	WHERE CostoEstimado > (SELECT AVG(CostoEstimado) FROM Proyectos)

-- 2- Listar razón social, cuit y contacto (email, celular o teléfono) de aquellos clientes que no tengan proyectos que comiencen en el año 2020.
	SELECT C.RazonSocial, C.CUIT, COALESCE(C.EMail, C.Celular, C.Telefono) Contacto FROM Clientes C
	WHERE C.ID not in (SELECT P.IDCliente FROM Proyectos P WHERE YEAR(P.FechaInicio) = '2020')

-- 3- Listado de países que no tengan clientes relacionados.
	SELECT P.Nombre FROM Paises P
	WHERE(P.ID NOT IN (SELECT DISTINCT P.ID FROM Paises P
	INNER JOIN Ciudades C ON P.ID = C.IDPais
	INNER JOIN Clientes CL ON C.ID = CL.IDCiudad))

-- 4- Listado de proyectos que no tengan tareas registradas. 
	SELECT P.Nombre FROM Proyectos P
	WHERE P.ID NOT IN (
	SELECT DISTINCT P.ID FROM Proyectos P INNER JOIN Modulos M ON P.ID = M.IDProyecto
	INNER JOIN Tareas T ON M.ID = T.IDModulo
	)

-- 5- Listado de tipos de tareas que no registren tareas pendientes.
	SELECT TT.ID, TT.Nombre, TT.PrecioHoraBase
	FROM TiposTarea TT
	WHERE TT.ID NOT IN(
	SELECT T.IDTipo FROM Tareas T
	WHERE T.FechaInicio > GETDATE() OR T.FechaInicio IS NULL
	)

-- 6- Listado con ID, nombre y costo estimado de proyectos cuyo costo estimado sea menor al costo estimado de cualquier proyecto de clientes extranjeros (clientes que sean de Argentina o no tengan asociado un país).
	SELECT P.ID, P.Nombre, P.CostoEstimado
	FROM Proyectos P
	WHERE P.CostoEstimado < (
	SELECT DISTINCT MIN(P.CostoEstimado)
	FROM Proyectos P INNER JOIN Clientes CL ON P.IDCliente = CL.ID
	LEFT JOIN Ciudades C ON CL.IDCiudad = C.ID
	LEFT JOIN Paises PA ON C.IDPais = PA.ID
	WHERE PA.Nombre = 'Argentina' OR CL.IDCiudad IS NULL)

-- 7- Listado de apellido y nombres de colaboradores que hayan demorado más en una tarea que el colaborador de la ciudad de 'Buenos Aires' que más haya demorado.
	SELECT C.Apellido, C.Nombre
	FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
	WHERE COL.Tiempo > (
	SELECT MAX(COL.Tiempo)
	FROM Colaboraciones COL
	INNER JOIN Colaboradores C ON COL.IDColaborador = C.ID
	INNER JOIN Ciudades CI ON C.IDCiudad = CI.ID
	WHERE CI.Nombre LIKE 'Buenos Aires'
	)
	ORDER BY C.Nombre ASC

-- 8- Listado de clientes indicando razón social, nombre del país (si tiene) y cantidad de proyectos comenzados y cantidad de proyectos por comenzar.
	SELECT CL.RazonSocial, 
	ISNULL((SELECT PA.NOMBRE FROM Paises PA LEFT JOIN Ciudades CI ON PA.ID = CI.IDPais
	LEFT JOIN Clientes C ON CI.ID = C.IDCiudad
	WHERE C.ID = CL.ID),'NO REGISTRA PAIS'),
	(SELECT DISTINCT COUNT(P.ID) FROM Proyectos P
	LEFT JOIN CLIENTES C ON C.ID = P.IDCliente
	WHERE P.FechaInicio <= GETDATE() AND CL.ID = C.ID), (SELECT DISTINCT COUNT(P.ID) FROM Proyectos P
	LEFT JOIN Clientes C ON C.ID = P.IDCliente
	WHERE P.FechaInicio > GETDATE() AND CL.ID = C.ID)
	FROM Clientes CL

-- 9- Listado de tareas indicando nombre del módulo, nombre del tipo de tarea, cantidad de colaboradores externos que la realizaron y cantidad de colaboradores internos que la realizaron.
	SELECT M.Nombre, TT.Nombre,
	(
		SELECT DISTINCT COUNT(*)
		FROM Colaboradores COL INNER JOIN Colaboraciones C ON COL.ID = C.IDColaborador
		INNER JOIN Tareas TA ON C.IDTarea = TA.ID
		WHERE COL.Tipo LIKE 'I' AND T.ID = TA.ID
	) AS 'COLABORADORES INTERNOS',
	(
		SELECT DISTINCT COUNT(*)
		FROM Colaboradores COL INNER JOIN Colaboraciones C ON COL.ID = C.IDColaborador
		INNER JOIN Tareas TA ON C.IDTarea = TA.ID
		WHERE COL.Tipo LIKE 'E' AND T.ID = TA.ID
	) AS 'COLABORADORES EXTERNOS'
	FROM Modulos M INNER JOIN Tareas T ON M.ID = T.IDModulo
	INNER JOIN TiposTarea TT ON T.IDTipo = TT.ID

-- 10- Listado de proyectos indicando nombre del proyecto, costo estimado, cantidad de módulos cuya estimación de fin haya sido exacta, cantidad de módulos con estimación adelantada y cantidad de módulos con estimación demorada.
--	   Adelantada →  estimación de fin haya sido inferior a la real.
--	   Demorada   →  estimación de fin haya sido superior a la real.
	SELECT P.Nombre, P.CostoEstimado,
	(
		SELECT DISTINCT COUNT(*)
		FROM Modulos M
		WHERE M.FechaFin = M.FechaEstimadaFin AND M.IDProyecto = P.ID
	) AS 'MODULOS EXACTOS',
	(
		SELECT DISTINCT COUNT(*)
		FROM Modulos M
		WHERE M.FechaFin < M.FechaEstimadaFin AND M.IDProyecto = P.ID
	) AS 'MODULOS ADELANTADOS',
	(
		SELECT DISTINCT COUNT(*)
		FROM Modulos M
		WHERE M.FechaFin > M.FechaEstimadaFin AND M.IDProyecto = P.ID
	) AS 'MODULOS DEMORADOS'
	FROM Proyectos P

-- 11- Listado con nombre del tipo de tarea y total abonado en concepto de honorarios para colaboradores internos y total abonado en concepto de honorarios para colaboradores externos.
	SELECT TT.Nombre,
	(
		SELECT SUM(COL.Tiempo*COL.PrecioHora)
		FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
		INNER JOIN Tareas TA ON COL.IDTarea = TA.ID
		INNER JOIN TiposTarea T ON TA.IDTipo = T.ID
		WHERE C.Tipo LIKE 'I' AND TT.ID = T.ID
	) AS 'HONORARIOS INTERNOS',
	(
		SELECT SUM(COL.Tiempo*COL.PrecioHora)
		FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
		INNER JOIN Tareas TA ON COL.IDTarea = TA.ID
		INNER JOIN TiposTarea T ON TA.IDTipo = T.ID
		WHERE C.Tipo LIKE 'E' AND TT.ID = T.ID
	) AS 'HONORARIOS EXTERNOS'
	FROM TiposTarea TT