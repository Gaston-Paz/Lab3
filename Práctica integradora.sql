USE BluePrint

-- 1- Por cada colaborador listar el apellido y nombre y la cantidad de proyectos distintos en los que haya trabajado.
	SELECT COL.Nombre, COL.Apellido, COUNT(M.IDProyecto) AS 'PROYECTOS TRABAJADOS'
	FROM Colaboradores COL 	INNER JOIN Colaboraciones COLA ON COL.ID = COLA.IDColaborador
	INNER JOIN Tareas T ON COLA.IDTarea = T.ID
	INNER JOIN Modulos M ON T.IDModulo = M.ID
	GROUP BY COL.Nombre, COL.Apellido

-- 2- Por cada cliente, listar la razón social y el costo estimado del módulo más costoso que haya solicitado.
	SELECT CL.RazonSocial, 
	(
		SELECT MAX(M.CostoEstimado)
		FROM Clientes C INNER JOIN Proyectos P ON C.ID = P.IDCliente
		INNER JOIN Modulos M ON P.ID = M.IDProyecto
		WHERE C.ID = CL.ID
	) AS 'COSTO DE MODULO MAS COSTOSO'
	FROM Clientes CL

-- 3- Los nombres de los tipos de tareas que hayan registrado más de diez colaboradores distintos en el año 2020. 
	SELECT TT.Nombre
	FROM TiposTarea TT
	WHERE 10 < (SELECT COUNT(DISTINCT COL.ID) FROM Colaboradores COL INNER JOIN Colaboraciones COLA ON COL.ID = COLA.IDColaborador
				INNER JOIN Tareas T ON COLA.IDTarea = T.ID
				WHERE TT.ID = T.IDTipo AND YEAR(T.FechaInicio) = '2020')

-- 4- Por cada cliente listar la razón social y el promedio abonado en concepto de proyectos. Si no tiene proyectos asociados mostrar el cliente con promedio nulo.
	SELECT CL.RazonSocial, (
								SELECT SUM(COLA.PrecioHora*COLA.Tiempo)
								FROM Clientes C INNER JOIN Proyectos PR ON C.ID = PR.IDCliente
								INNER JOIN Modulos M ON PR.ID = M.IDProyecto
								INNER JOIN Tareas T ON M.ID = T.IDModulo
								INNER JOIN Colaboraciones COLA ON T.ID = COLA.IDTarea
								WHERE CL.ID = C.ID) / (SELECT ISNULL(COUNT(P.ID),0)
														FROM Clientes CLI LEFT JOIN Proyectos P ON CLI.ID = P.IDCliente
														WHERE CLI.ID = CL.ID) AS 'PROMEDIO ABONADO EN PROYECTOS'
	FROM Clientes CL INNER JOIN Proyectos P ON CL.ID = P.IDCliente

-- 5- Los nombres de los tipos de tareas que hayan promediado más horas de colaboradores externos que internos.
	SELECT T1.Nombre
	FROM(
	SELECT TT.Nombre, AVG(COLA.Tiempo) AS 'PROMEDIO DE HS INTERNOS',
	(
		SELECT AVG(COLA.TIEMPO)
		FROM TiposTarea TITA INNER JOIN Tareas T ON TITA.ID = T.IDTipo
		INNER JOIN Colaboraciones COLA ON T.ID = COLA.IDTarea
		INNER JOIN Colaboradores COL ON COLA.IDColaborador = COL.ID
		WHERE COL.Tipo LIKE 'E' AND TT.Nombre = TITA.Nombre
	) AS 'PROMEDIO DE HS EXTERNOS' 
	FROM TiposTarea TT INNER JOIN Tareas T ON TT.ID = T.IDTipo
	INNER JOIN Colaboraciones COLA ON T.ID = COLA.IDTarea
	INNER JOIN Colaboradores COL ON COLA.IDColaborador = COL.ID
	WHERE COL.Tipo LIKE 'I'
	GROUP BY TT.Nombre) T1
	WHERE T1.[PROMEDIO DE HS EXTERNOS] > T1.[PROMEDIO DE HS INTERNOS]

-- 6- El nombre de proyecto que más colaboradores distintos haya empleado.
	SELECT TOP 1 COUNT(DISTINCT COL.IDColaborador), P.Nombre
	FROM Proyectos P INNER JOIN Modulos M ON P.ID = M.IDProyecto
	INNER JOIN Tareas T ON M.ID = T.IDModulo
	INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
	GROUP BY P.Nombre
	ORDER BY (1) DESC
	
-- 7- Por cada colaborador, listar el apellido y nombres y la cantidad de horas trabajadas en el año 2018, la cantidad de horas trabajadas en 2019 y la cantidad de horas trabajadas en 2020
	SELECT COL.Nombre, 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaInicio) LIKE '2018'
	),0) AS 'HS 2018', 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaFin) LIKE '2019'
	),0) AS 'HS 2019', 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaFin) LIKE '2020'
	),0) AS 'HS 2020'
	FROM Colaboradores COL

-- 8- Los apellidos y nombres de los colaboradores que hayan trabajado más horas en 2018 que en 2019 y más horas en 2019 que en 2020.
	SELECT T1.Nombre, T1.Apellido
	FROM (SELECT COL.Nombre,COL.Apellido, 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaInicio) LIKE '2018'
	),0) AS 'HS 2018', 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaFin) LIKE '2019'
	),0) AS 'HS 2019', 
	ISNULL((
		SELECT SUM(COLA.Tiempo)
		FROM Colaboradores C INNER JOIN Colaboraciones COLA ON C.ID = COLA.IDColaborador
		INNER JOIN Tareas T ON COLA.IDTarea = T.ID
		WHERE COL.ID = C.ID AND YEAR(T.FechaFin) LIKE '2020'
	),0) AS 'HS 2020'
	FROM Colaboradores COL) T1
	WHERE T1.[HS 2018] > T1.[HS 2019] AND T1.[HS 2019] > T1.[HS 2020]