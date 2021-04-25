Use BluePrint

-- 1- Por cada cliente listar razón social, cuit y nombre del tipo de cliente.
	SELECT C.RazonSocial, C.CUIT, T.Nombre AS 'Tipo Cliente'
	FROM Clientes C INNER JOIN TiposCliente T
	ON c.IDTipo = T.ID

-- 2- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Sólo de aquellos clientes que posean ciudad y país.
	SELECT Cl.RazonSocial, Cl.CUIT, C.Nombre AS 'Ciudad', P.Nombre AS 'Pais'
	FROM Clientes Cl INNER JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	INNER JOIN Paises P
	ON C.IDPais = P.ID
	
-- 3- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellos clientes que no tengan ciudad relacionada.
	SELECT Cl.RazonSocial, Cl.CUIT, C.Nombre AS 'Ciudad', P.Nombre AS 'Pais'
	FROM Clientes Cl LEFT JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	LEFT JOIN Paises P
	ON C.IDPais = P.ID

-- 4-Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellas ciudades y países que no tengan clientes relacionados.
	SELECT Cl.RazonSocial, Cl.CUIT, C.Nombre AS 'Ciudad', P.Nombre 'Pais'
	FROM Clientes Cl RIGHT JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	RIGHT JOIN Paises P
	ON C.IDPais = P.ID
	ORDER BY Cl.RazonSocial DESC

-- 5- Listar los nombres de las ciudades que no tengan clientes asociados. Listar también el nombre del país al que pertenece la ciudad
	SELECT C.nombre AS 'Ciudad', P.nombre AS 'Pais'
	FROM Clientes Cl RIGHT JOIN Ciudades AS C ON C.ID = Cl.IDCiudad
	RIGHT JOIN Paises AS P ON P.ID = C.IDPais
	WHERE CL.ID IS NULL

-- 6- Listar para cada proyecto el nombre del proyecto, el costo, la razón social del cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene registrada) 
--    de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o 'Unicornio'.
	SELECT P.Nombre AS 'Nombre del proyecto', P.CostoEstimado, Cl.RazonSocial, T.Nombre AS 'Tipo Cliente', C.Nombre AS 'Ciudad'
	FROM Proyectos P INNER JOIN Clientes Cl
	ON P.IDCliente = Cl.ID
	INNER JOIN TiposCliente T
	ON T.ID = Cl.IDTipo
	LEFT JOIN Ciudades C
	ON C.ID = Cl.IDCiudad
	WHERE T.Nombre IN ('Extranjero','Unicornio')

-- 7- Listar los nombre de los proyectos de aquellos clientes que sean de los países 'Argentina' o 'Italia'.
	SELECT Pr.Nombre AS 'Proyecto'
	FROM Proyectos Pr INNER JOIN Clientes Cl
	ON Pr.IDCliente = Cl.ID
	INNER JOIN Ciudades C
	ON Cl.IDCiudad = C.ID
	INNER JOIN Paises P
	ON C.IDPais = P.ID
	WHERE P.Nombre IN ('Argentina','Italia')

-- 8-Listar para cada módulo el nombre del módulo, el costo estimado del módulo, el nombre del proyecto, la descripción del proyecto y el costo estimado del proyecto de todos aquellos proyectos que hayan finalizado.
	SELECT M.Nombre AS 'Nombre Modulo', M.CostoEstimado, P.Nombre AS 'Nombre Proyecto', P.Descripcion, P.CostoEstimado
	FROM Modulos M INNER JOIN Proyectos P
	ON M.IDProyecto = P.ID
	WHERE P.FechaFin IS NOT NULL AND P.FechaFin < GETDATE()

-- 9- Listar los nombres de los módulos y el nombre del proyecto de aquellos módulos cuyo tiempo estimado de realización sea de más de 100 horas.
	SELECT M.Nombre AS 'Nombre Modulo', P.Nombre AS 'Nombre Proyecto'
	FROM Modulos M INNER JOIN Proyectos P
	ON M.IDProyecto = P.ID
	WHERE M.TiempoEstimado > 100

-- 10- Listar nombres de módulos, nombre del proyecto, descripción y tiempo estimado de aquellos módulos cuya fecha estimada de fin sea mayor a la fecha real de fin y el costo estimado del proyecto sea mayor a cien mil.
	SELECT M.Nombre AS 'Nombre Modulo', P.Nombre AS 'Nombre Proyecto', M.Descripcion, M.TiempoEstimado
	FROM Modulos M INNER JOIN Proyectos P
	ON M.IDProyecto = P.ID
	WHERE M.FechaEstimadaFin > M.FechaFin AND P.CostoEstimado > 100000

-- 11- Listar nombre de proyectos, sin repetir, que registren módulos que hayan finalizado antes que el tiempo estimado.
	SELECT DISTINCT P.Nombre AS 'Nombre de proyecto'
	FROM Proyectos P INNER JOIN Modulos M
	ON P.ID = M.IDProyecto
	WHERE M.FechaFin < M.FechaEstimadaFin

-- 12- Listar nombre de ciudades, sin repetir, que no registren clientes pero sí colaboradores.
	SELECT DISTINCT C.Nombre AS 'Ciudad'
	FROM Clientes Cl RIGHT JOIN Ciudades C
	ON C.ID = Cl.IDCiudad
	RIGHT JOIN Colaboradores Col
	ON Col.IDCiudad = C.ID
	WHERE Cl.IDCiudad IS NULL

-- 13- Listar el nombre del proyecto y nombre de módulos de aquellos módulos que contengan la palabra 'login' en su nombre o descripción.
	SELECT P.Nombre AS 'Nombre proyecto', M.Nombre AS 'Nombre modulo'
	FROM Proyectos P INNER JOIN Modulos M
	ON P.ID = M.IDProyecto
	WHERE M.Nombre LIKE '%login%' OR M.Descripcion LIKE '%login%'

-- 14- Listar el nombre del proyecto y el nombre y apellido de todos los colaboradores que hayan realizado algún tipo de tarea cuyo nombre 
--	   contenga 'Programación' o 'Testing'. Ordenarlo por nombre de proyecto de manera ascendente.
	SELECT P.Nombre, C.Nombre + ' ' + C.Apellido AS 'Nombre y apellido'
	FROM Proyectos P INNER JOIN Modulos M
	ON P.ID = M.IDProyecto
	INNER JOIN Tareas T
	ON M.ID = T.IDModulo
	INNER JOIN TiposTarea TT
	ON TT.ID = T.IDTipo
	INNER JOIN Colaboraciones Col
	ON Col.IDTarea = T.ID
	INNER JOIN Colaboradores C
	ON C.ID = Col.IDColaborador
	WHERE TT.Nombre LIKE '%Programación%' OR TT.Nombre LIKE '%Testing%'
	ORDER BY P.Nombre ASC

-- 15- Listar nombre y apellido del colaborador, nombre del módulo, nombre del tipo de tarea, precio hora de la colaboración y precio 
--     hora base de aquellos colaboradores que hayan cobrado su valor hora de colaboración más del 50% del valor hora base
	SELECT Col.Nombre + ' ' + Col.Apellido AS 'Nombre y apellido', M.Nombre AS 'Modulo', TT.Nombre AS 'Tipo de tarea', C.PrecioHora, TT.PrecioHoraBase
	FROM Colaboradores Col INNER JOIN Colaboraciones C
	ON Col.ID = C.IDColaborador
	INNER JOIN TAREAS T
	ON C.IDTarea = T.ID
	INNER JOIN TiposTarea TT
	ON TT.ID = T.IDTipo
	INNER JOIN Modulos M
	ON T.IDModulo = M.ID
	WHERE C.PrecioHora > TT.PrecioHoraBase + TT.PrecioHoraBase * 0.5

-- 16- Listar nombres y apellidos de las tres colaboraciones de colaboradores externos que más hayan demorado en realizar alguna tarea cuyo nombre de tipo de tarea contenga 'Testing'.
	SELECT TOP 3 Col.Nombre + ' ' + Col.Apellido AS 'Nombre y apellido', TT.Nombre, TT.ID ,C.Tiempo
	FROM Colaboradores Col INNER JOIN Colaboraciones C
	ON Col.ID = C.IDColaborador 
	INNER JOIN Tareas T
	ON C.IDTarea = T.ID
	INNER JOIN TiposTarea TT
	ON T.IDTipo = TT.ID
	WHERE Col.Tipo = 'E' AND TT.Nombre LIKE '%Testing%' 
	ORDER BY C.Tiempo DESC

-- 17- Listar apellido, nombre y mail de los colaboradores argentinos que sean internos y cuyo mail no contenga '.com'.
	SELECT Col.Apellido, Col.Nombre, Col.EMail 
	FROM Colaboradores Col
	INNER JOIN Ciudades C
	ON Col.IDCiudad = C.ID
	INNER JOIN Paises P
	ON C.IDPais = P.ID
	WHERE Col.Tipo = 'I' AND Col.EMail NOT LIKE '%.COM%' AND P.Nombre LIKE 'Argentina'

-- 18- Listar nombre del proyecto, nombre del módulo y tipo de tarea de aquellas tareas realizadas por colaboradores externos.
	SELECT DISTINCT P.Nombre, M.Nombre, TT.Nombre
	FROM Proyectos P INNER JOIN Modulos M
	ON P.ID = M.IDProyecto
	INNER JOIN Tareas T
	ON M.ID = T.IDModulo
	INNER JOIN Colaboraciones C
	ON T.ID = C.IDTarea
	INNER JOIN Colaboradores Col
	ON C.IDColaborador = Col.ID
	INNER JOIN TiposTarea TT
	ON T.IDTipo = TT.ID
	WHERE Col.Tipo = 'E'

-- 19- Listar nombre de proyectos que no hayan registrado tareas.
	SELECT P.Nombre
	FROM Proyectos P FULL JOIN Modulos M
	ON P.ID = M.IDProyecto
	FULL JOIN Tareas T
	ON M.ID = T.IDModulo
	FULL JOIN TiposTarea TT
	ON T.IDTipo = TT.ID
	WHERE TT.Nombre IS NULL


-- 20- Listar apellidos y nombres, sin repeticiones, de aquellos colaboradores que hayan trabajado en algún proyecto que aún no haya finalizado.
	SELECT DISTINCT Col.Apellido, Col.Nombre
	FROM Colaboradores Col INNER JOIN Colaboraciones C
	ON Col.ID = C.IDColaborador
	INNER JOIN Tareas T
	ON C.IDTarea = T.ID
	INNER JOIN Modulos M
	ON T.IDModulo = M.ID
	INNER JOIN Proyectos P
	ON M.IDProyecto = P.ID
	WHERE P.FechaFin IS NULL OR P.FechaFin < GETDATE()



	

	




