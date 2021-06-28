USE BluePrint

-- 1 Hacer un reporte que liste por cada tipo de tarea se liste el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones).

	CREATE VIEW VW_REPORTE_TAREAS_PRECIO AS
	SELECT TT.Nombre, TT.PrecioHoraBase, AVG(C.PrecioHora) AS 'PROMEDIO HORA/PRECIO'
	FROM TiposTarea TT INNER JOIN Tareas T ON TT.ID = T.ID
	INNER JOIN Colaboraciones C ON T.ID = C.IDTarea
	GROUP BY TT.Nombre, TT.PrecioHoraBase

	SELECT * FROM VW_REPORTE_TAREAS_PRECIO

-- 2 Modificar el reporte de (1) para que también liste una columna llamada Variación con las siguientes reglas:
--Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
--Mediana → Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
--Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.

	CREATE VIEW VW_REPORTE_TAREAS_PRECIO_VARIACION AS
	SELECT VW.Nombre, VW.PrecioHoraBase, VW.[PROMEDIO HORA/PRECIO],
	CASE
	WHEN VW.[PROMEDIO HORA/PRECIO] - VW.PrecioHoraBase < 500 THEN 'POCA'
	WHEN VW.[PROMEDIO HORA/PRECIO] - VW.PrecioHoraBase < 999 THEN 'MEDIANA'
	WHEN VW.[PROMEDIO HORA/PRECIO] - VW.PrecioHoraBase > 999 THEN 'ALTA'
	END AS 'VARIACION'
	FROM VW_REPORTE_TAREAS_PRECIO VW

	SELECT * FROM VW_REPORTE_TAREAS_PRECIO_VARIACION
	


-- 3 Crear un procedimiento almacenado que liste las colaboraciones de un colaborador cuyo ID se envía como parámetro.

	CREATE PROCEDURE SP_COLABORACIONESXCOLABORADOR(
		@IDCOLABORADOR BIGINT
	)
	AS
	BEGIN
		SELECT * FROM Colaboraciones WHERE IDColaborador = @IDCOLABORADOR
	END

	EXEC SP_COLABORACIONESXCOLABORADOR 2

	SELECT * FROM Colaboradores

-- 4 Hacer una vista que liste por cada colaborador el apellido y nombre, el nombre del tipo (Interno o Externo) y la cantidad de proyectos distintos en los que haya trabajado.

	CREATE VIEW VW_COLABORADOR_PROYECTOS AS
	SELECT CONCAT(C.APELLIDO, C.NOMBRE) AS 'NOMBRE + APELLIDO', 
	CASE 
	WHEN C.Tipo LIKE 'I' THEN 'INTERNO'
	WHEN C.Tipo LIKE 'E' THEN 'EXTERNO'
	END AS 'TIPO',
	COUNT(DISTINCT M.IDProyecto) AS 'PROYECTOS'
	FROM Colaboradores C INNER JOIN Colaboraciones COL ON C.ID = COL.IDColaborador
	INNER JOIN Tareas T ON T.ID = COL.IDTarea
	INNER JOIN Modulos M ON T.IDModulo = M.ID
	GROUP BY CONCAT(C.APELLIDO, C.NOMBRE), C.Tipo

	SELECT * FROM VW_COLABORADOR_PROYECTOS

--Opcional: Hacer una aplicación en C# (consola, escritorio o web) que consuma la vista y la muestre por pantalla.

-- 5 Hacer un procedimiento almacenado que reciba dos fechas como parámetro y liste todos los datos de los proyectos que se encuentren entre esas fechas.

	CREATE PROCEDURE SP_PROYECTOSXFECHAS(
		@FECHAINICIO DATE,
		@FECHAFIN DATE
	)
	AS
	BEGIN
		SELECT *
		FROM Proyectos
		WHERE FechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN
	END

	EXEC SP_PROYECTOSXFECHAS '1/01/2019', '31/12/2019'

-- 6 Hacer un procedimiento almacenado que reciba un ID de Cliente, un ID de Tipo de contacto y un valor y modifique los datos de contacto de dicho cliente. 
-- El ID de Tipo de contacto puede ser: 1 - Email, 2 - Teléfono y 3 - Celular.

	CREATE PROCEDURE SP_MODIFICAR_CLIENTE(
		@IDCLIENTE BIGINT,
		@IDTIPOCONTACTO SMALLINT,
		@CONTACTO VARCHAR(100)
	)
	AS
	BEGIN
		IF @IDTIPOCONTACTO = 1 BEGIN
			UPDATE Clientes SET EMail = @CONTACTO WHERE ID = @IDCLIENTE
		END
		IF @IDTIPOCONTACTO = 2 BEGIN
			UPDATE Clientes SET Telefono = @CONTACTO WHERE ID = @IDCLIENTE
		END
		IF @IDTIPOCONTACTO = 3 BEGIN
			UPDATE Clientes SET Celular = @CONTACTO WHERE ID = @IDCLIENTE
		END
	END

	SELECT * FROM Clientes

	EXEC SP_MODIFICAR_CLIENTE 1,1, 'BRILARA@GAMEJAM.COM'
	EXEC SP_MODIFICAR_CLIENTE 1,2, '47405478'
	EXEC SP_MODIFICAR_CLIENTE 1,3, '1122334455'


-- 7 Hacer un procedimiento almacenado que reciba un ID de Módulo y realice la baja lógica tanto del módulo como de todas sus tareas futuras. Utilizar una transacción para realizar el proceso de manera atómica.

	CREATE PROCEDURE SP_BAJA_MODULO(
		@IDMODULO BIGINT
	)
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

				UPDATE Modulos SET Estado = 0 WHERE ID = @IDMODULO

				UPDATE TAREAS SET Estado = 0 WHERE IDModulo = @IDMODULO AND FechaInicio > GETDATE()

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			RAISERROR('NO ANDUVO',16,1)
		END CATCH
	END

	SELECT * FROM Modulos

	EXEC SP_BAJA_MODULO 10
