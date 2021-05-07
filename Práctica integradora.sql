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