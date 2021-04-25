USE BluePrint

-- 1- La cantidad de colaboradores
	SELECT COUNT(*) AS 'Cantidad de Colaboradores' FROM Colaboradores

-- 2- La cantidad de colaboradores nacidos entre 1990 y 2000.
	SELECT COUNT(*) AS 'Cantidad de Colaboradores' FROM Colaboradores
	WHERE YEAR(FechaNacimiento) BETWEEN '1990' AND '2000'

-- 3- El promedio de precio hora base de los tipos de tareas
	SELECT AVG(PrecioHoraBase) AS 'Promedio de precio hora/base de los tipos de tarea' FROM TiposTarea

-- 4- El promedio de costo de los proyectos iniciados en el año 2019.
	SELECT AVG(CostoEstimado) AS 'Promedio de costo de proyectos de 2019' FROM Proyectos
	WHERE YEAR(FechaInicio) = '2019'

-- 5- El costo más alto entre los proyectos de clientes de tipo 'Unicornio'
	SELECT MAX(P.CostoEstimado)
	FROM TiposCliente TC INNER JOIN Clientes C
	ON TC.ID = C.IDTipo AND TC.Nombre LIKE 'Unicornio'
	INNER JOIN Proyectos P
	ON C.ID = P.IDCliente

-- 6- El costo más bajo entre los proyectos de clientes del país 'Argentina'
	SELECT MIN(P.CostoEstimado)
	FROM Paises Pa INNER JOIN Ciudades Ci
	ON Pa.ID = Ci.IDPais AND Pa.Nombre LIKE 'Argentina' 
	INNER JOIN Clientes C
	ON Ci.ID = C.IDCiudad
	INNER JOIN Proyectos P
	ON C.ID = P.IDCliente

-- 7- La suma total de los costos estimados entre todos los proyectos.
	SELECT SUM(CostoEstimado) FROM Proyectos

-- 8- Por cada ciudad, listar el nombre de la ciudad y la cantidad de clientes.
	SELECT C.Nombre, COUNT(*)
	FROM Clientes Cl LEFT JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	GROUP BY C.Nombre

-- 9- Por cada país, listar el nombre del país y la cantidad de clientes.
	SELECT P.Nombre, COUNT(*)
	FROM Clientes Cl LEFT JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	LEFT JOIN Paises P
	ON C.IDPais = P.ID
	GROUP BY P.Nombre
	ORDER BY COUNT(*) DESC

-- 10- Por cada tipo de tarea, la cantidad de colaboraciones registradas. Indicar el tipo de tarea y la cantidad calculada.
	SELECT TT.Nombre, COUNT(*)
	FROM Colaboraciones C LEFT JOIN Tareas T
	ON C.IDTarea = T.ID
	LEFT JOIN TiposTarea TT
	ON T.IDTipo = TT.ID
	GROUP BY TT.Nombre
	ORDER BY COUNT(*) DESC

-- 11- Por cada tipo de tarea, la cantidad de colaboradores distintos que la hayan realizado. Indicar el tipo de tarea y la cantidad calculada
	SELECT TT.Nombre, COUNT(*)
	FROM Colaboradores COL LEFT JOIN Colaboraciones C 
	ON COL.ID = C.IDColaborador
	LEFT JOIN Tareas T
	ON C.IDTarea = T.ID
	LEFT JOIN TiposTarea TT
	ON T.IDTipo = TT.ID
	GROUP BY TT.Nombre
	ORDER BY COUNT(*) DESC

-- 12- Por cada módulo, la cantidad total de horas trabajadas. Indicar el ID, nombre del módulo y la cantidad totalizada. Mostrar los módulos sin horas registradas con 0.
	SELECT M.ID, M.Nombre,
	CASE
	WHEN SUM(C.Tiempo) IS NULL THEN '0'
	WHEN SUM(C.Tiempo) IS NOT NULL THEN SUM(C.Tiempo)
	END
	FROM Modulos M LEFT JOIN Tareas T ON M.ID = T.IDModulo
	LEFT JOIN Colaboraciones C ON T.ID = C.IDTarea
	GROUP BY M.ID, M.Nombre
	ORDER BY SUM(C.Tiempo) DESC

-- 13- Por cada módulo y tipo de tarea, el promedio de horas trabajadas. Indicar el ID y nombre del módulo, el nombre del tipo de tarea y el total calculado.
	SELECT M.ID, M.Nombre, TT.Nombre, 
	CASE
	WHEN AVG(Col.Tiempo) IS NULL THEN '0' 
	WHEN AVG(Col.Tiempo) IS NOT NULL THEN AVG(Col.Tiempo)
	END
	FROM Modulos M LEFT JOIN Tareas T ON M.ID = T.IDModulo
	LEFT JOIN TiposTarea TT ON T.IDTipo = TT.ID
	LEFT JOIN Colaboraciones Col ON T.ID = Col.IDTarea
	GROUP BY M.ID, M.Nombre, TT.Nombre

-- 14- Por cada módulo, indicar su ID, apellido y nombre del colaborador y total que se le debe abonar en concepto de colaboraciones realizadas en dicho módulo.
	SELECT M.ID, C.Apellido, C.Nombre, SUM(COL.PrecioHora * COL.Tiempo) AS 'Pago'
	FROM Modulos M INNER JOIN Tareas T ON M.ID = T.IDModulo
	INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
	INNER JOIN Colaboradores C ON COL.IDColaborador = C.ID
	GROUP BY M.ID, C.Apellido, C.Nombre

-- 15- Por cada proyecto indicar el nombre del proyecto y la cantidad de horas registradas en concepto de colaboraciones y el total que debe abonar en concepto de colaboraciones.
	SELECT P.Nombre, SUM(COL.Tiempo), SUM(COL.PrecioHora * COL.Tiempo)
	FROM Proyectos P INNER JOIN Modulos M ON P.ID = M.IDProyecto
	INNER JOIN Tareas T ON M.ID = T.IDModulo
	INNER JOIN Colaboraciones COL ON T.ID = COL.IDTarea
	GROUP BY P.Nombre

-- 16- Listar los nombres de los proyectos que hayan registrado menos de cinco colaboradores distintos y más de 100 horas total de trabajo.
	SELECT P.Nombre
	FROM Proyectos P INNER JOIN Modulos M ON P.ID = M.IDProyecto
	LEFT JOIN Tareas T ON M.ID = T.IDModulo
	LEFT JOIN Colaboraciones COL ON T.ID = COL.IDTarea
	LEFT JOIN Colaboradores C ON COL.IDColaborador = C.ID
	GROUP BY P.Nombre
	HAVING COUNT(C.ID) < 5 AND SUM(COL.Tiempo) > 100

-- 17- 