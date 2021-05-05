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

-- 12- Listado con nombre del proyecto, razón social del cliente y saldo final del proyecto. El saldo final surge de la siguiente fórmula: 
--	   Costo estimado - Σ(HCE) - Σ(HCI) * 0.1
--	   Siendo HCE → Honorarios de colaboradores externos y HCI → Honorarios de colaboradores internos
		SELECT T1.Nombre, CL.RazonSocial, T1.CostoEstimado - T1.[HONORARIOS EXTERNOS] - (T1.[HONORARIOS INTERNOS]*0.1) AS 'SALDO FINAL'
		FROM(	
			SELECT P.Nombre, P.IDCliente, P.CostoEstimado ,
			(
				SELECT ISNULL(SUM(COL.Tiempo*COL.PrecioHora),0)
				FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
				INNER JOIN Tareas TA ON COL.IDTarea = TA.ID
				INNER JOIN Modulos M ON TA.IDModulo = M.ID
				INNER JOIN Proyectos PR ON M.IDProyecto = PR.ID
				WHERE C.Tipo LIKE 'I' AND P.ID = PR.ID
			) AS 'HONORARIOS INTERNOS',
			(
				SELECT ISNULL(SUM(COL.Tiempo*COL.PrecioHora),0)
				FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
				INNER JOIN Tareas TA ON COL.IDTarea = TA.ID
				INNER JOIN Modulos M ON TA.IDModulo = M.ID
				INNER JOIN Proyectos PR ON M.IDProyecto = PR.ID
				WHERE C.Tipo LIKE 'E' AND P.ID = PR.ID
			) AS 'HONORARIOS EXTERNOS'
			FROM Proyectos P
	) AS T1
	INNER JOIN Clientes CL ON T1.IDCliente = CL.ID

-- 13- Para cada módulo listar el nombre del proyecto, el nombre del módulo, el total en tiempo que demoraron las tareas de ese módulo y 
--	   qué porcentaje de tiempo representaron las tareas de ese módulo en relación al tiempo total de tareas del proyecto.
	SELECT P.Nombre, MO.Nombre,
	(	SELECT ISNULL(SUM(COL.Tiempo),0)
		FROM Modulos M INNER JOIN Tareas T ON M.ID = T.IDModulo
		INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
		WHERE M.ID = MO.ID)  AS 'HORAS POR TAREA',
	ISNULL((
		(SELECT ISNULL(SUM(COL.Tiempo),'0')
		FROM Modulos M INNER JOIN Tareas T ON M.ID = T.IDModulo
		INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
		WHERE M.ID = MO.ID) * 100 /
		(SELECT SUM(COL.Tiempo)
		FROM Proyectos P INNER JOIN Modulos M ON P.ID = M.IDProyecto
		INNER JOIN Tareas T ON M.ID = T.IDModulo
		INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
		WHERE P.ID = MO.IDProyecto)
	),0)
	FROM Modulos MO INNER JOIN Proyectos P ON MO.IDProyecto = P.ID

	
-- 14- Por cada colaborador indicar el apellido, el nombre, 'Interno' o 'Externo' según su tipo y la cantidad de tareas de tipo 'Testing' que haya realizado y la cantidad de tareas de tipo 'Programación' que haya realizado.
--     NOTA: Se consideran tareas de tipo 'Testing' a las tareas que contengan la palabra 'Testing' en su nombre. Ídem para Programación.
	SELECT C.Nombre, C.Apellido, C.Tipo,
	(
		SELECT COUNT(*)
		FROM Colaboradores CO INNER JOIN Colaboraciones COL ON CO.ID = COL.IDColaborador
		INNER JOIN Tareas T ON COL.IDTarea = T.ID
		INNER JOIN TiposTarea TT ON T.IDTipo = TT.ID
		WHERE TT.Nombre LIKE '%Testing%' AND C.ID = CO.ID
	) AS'TAREAS DE TESTING',
	(
		SELECT COUNT(*)
		FROM Colaboradores CO INNER JOIN Colaboraciones COL ON CO.ID = COL.IDColaborador
		INNER JOIN Tareas T ON COL.IDTarea = T.ID
		INNER JOIN TiposTarea TT ON T.IDTipo = TT.ID
		WHERE TT.Nombre LIKE '%Programación%' AND C.ID = CO.ID
	) AS'TAREAS DE PROGRAMACION'
	FROM Colaboradores C

-- 15- Listado apellido y nombres de los colaboradores que no hayan realizado tareas de 'Diseño de base de datos'.
	SELECT CO.Nombre, CO.Apellido
	FROM Colaboradores CO
	WHERE CO.ID NOT IN (SELECT COL.IDColaborador  FROM Colaboraciones COL INNER JOIN Tareas T ON COL.IDTarea = T.ID
						INNER JOIN TiposTarea TT ON T.IDTipo = TT.ID	
						WHERE TT.Nombre LIKE 'Diseño de base de datos')

-- 16- 