use BluePrint
-- 1 Hacer un reporte que liste por cada tipo de tarea se liste el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones).
	CREATE VIEW VW_ReporteTipoTarea AS
	SELECT TT.Nombre, TT.PrecioHoraBase, AVG(C.PrecioHora) AS 'Promedio $/H real' FROM TiposTarea TT
	INNER JOIN Tareas T ON TT.ID = T.IDTipo
	INNER JOIN Colaboraciones C ON T.ID = C.IDTarea
	GROUP BY TT.Nombre, TT.PrecioHoraBase

	SELECT *  FROM VW_ReporteTipoTarea


-- 2 Modificar el reporte de (1) para que también liste una columna llamada Variación con las siguientes reglas:
-- Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
-- Mediana → Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
-- Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.

	ALTER VIEW VW_ReporteTipoTarea2 AS
	SELECT TABLA.Nombre, TABLA.PrecioHoraBase, TABLA.[Promedio $/H real],
	CASE 
	WHEN TABLA.[Promedio $/H real] - TABLA.PrecioHoraBase < 500 THEN 'Poca'
	WHEN TABLA.[Promedio $/H real] - TABLA.PrecioHoraBase > 500 AND TABLA.[Promedio $/H real] - TABLA.PrecioHoraBase < 999 THEN 'Mediana'
	WHEN TABLA.[Promedio $/H real] - TABLA.PrecioHoraBase >= 1000 THEN 'Alta'
	END AS 'Variación'
	FROM(SELECT TT.Nombre, TT.PrecioHoraBase, AVG(C.PrecioHora) AS 'Promedio $/H real'	
	FROM TiposTarea TT
	INNER JOIN Tareas T ON TT.ID = T.IDTipo
	INNER JOIN Colaboraciones C ON T.ID = C.IDTarea
	GROUP BY TT.Nombre, TT.PrecioHoraBase) AS TABLA

	SELECT * FROM VW_ReporteTipoTarea2


-- 3 Crear un procedimiento almacenado que liste las colaboraciones de un colaborador cuyo ID se envía como parámetro.

	CREATE PROCEDURE SP_ColaboracionesxColaborador(
		@IdColaborador BIGINT
	)
	AS
	BEGIN
		SELECT *
		FROM Colaboraciones COL
		WHERE COL.IDColaborador = @IdColaborador
	END

	EXEC SP_ColaboracionesxColaborador 2


-- 4 Hacer una vista que liste por cada colaborador el apellido y nombre, el nombre del tipo (Interno o Externo) y la cantidad de proyectos distintos en los que haya trabajado
	CREATE VIEW VW_ReporteColaboradores AS
	SELECT C.Nombre, C.Apellido,
	CASE
	WHEN C.Tipo LIKE 'I' THEN 'Interno'
	WHEN C.Tipo LIKE 'E' THEN 'Externo'
	END AS 'TIPO',
	ISNULL((
		 SELECT COUNT(DISTINCT M.IDProyecto)
		 FROM Colaboradores COL LEFT JOIN Colaboraciones COLA ON COL.ID = COLA.IDColaborador
		 LEFT JOIN Tareas T ON COLA.IDTarea = T.ID
		 LEFT JOIN Modulos M ON T.IDModulo = M.ID
		 WHERE COL.ID = C.ID
	),0) AS 'Cant proyectos'
	FROM Colaboradores C

	SELECT * FROM VW_ReporteColaboradores


-- 5 Hacer un procedimiento almacenado que reciba dos fechas como parámetro y liste todos los datos de los proyectos que se encuentren entre esas fechas.

	CREATE PROCEDURE SP_ProyectoxFecha(
		@Fecha1 DATE,
		@Fecha2 DATE
	)
	AS
	BEGIN
		SELECT * FROM PROYECTOS P
		WHERE FechaFin BETWEEN @Fecha1 AND @Fecha2

	END

	EXEC SP_ProyectoxFecha '2020-01-01', '2020-12-31'

	SELECT * FROM Proyectos

-- 6 Hacer un procedimiento almacenado que reciba un ID de Cliente, un ID de Tipo de contacto y un valor y modifique los datos de contacto de dicho cliente.
-- El ID de Tipo de contacto puede ser: 1 - Email, 2 - Teléfono y 3 - Celular.

	ALTER PROCEDURE SP_ModificarClienteContacto(
		@IdCliente BIGINT,
		@IdContacto INT,
		@Valor VARCHAR(80)
	)
	AS
	BEGIN
		IF @IdContacto = 1
			UPDATE Clientes SET EMail = @Valor WHERE ID = @IdCliente
		ELSE
		IF @IdContacto = 2
			UPDATE Clientes SET Telefono = @Valor WHERE ID = @IdCliente
		ELSE
		IF @IdContacto = 3
			UPDATE Clientes SET Celular = @Valor WHERE ID = @IdCliente
	END

	SELECT * FROM Clientes
	EXEC SP_ModificarClienteContacto '1','3','HOLA'
	
-- 7 Hacer un procedimiento almacenado que reciba un ID de Módulo y realice la baja lógica tanto del módulo como de todas sus tareas futuras. Utilizar una transacción para realizar el proceso de manera atómica

	CREATE PROCEDURE SP_BajaModulo(
		@IdModulo BIGINT
	)
	AS
	BEGIN
		BEGIN TRY
		-- BAJA LOGICA DE MODULO
			BEGIN TRANSACTION
			UPDATE Modulos SET Estado = 0 WHERE ID = @IdModulo
			EXEC SP_BajaTareas @IdModulo
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0 BEGIN
				ROLLBACK TRANSACTION
				END
			RAISERROR('NO SE PUDO DAR DE BAJA', 16, 1)
		END CATCH

	END

	EXEC SP_BajaModulo 1
	SELECT * FROM Modulos
	SELECT * FROM Tareas WHERE IDModulo = 2


	CREATE PROCEDURE SP_BajaTareas(
		@IdMod BIGINT
	)
	AS
	BEGIN
		BEGIN TRY
		BEGIN TRANSACTION
		UPDATE Tareas SET estado = 0 WHERE IdModulo = @IdMod
		
		COMMIT TRANSACTION
		
		END TRY

		BEGIN CATCH
		ROLLBACK
		RAISERROR('NO DIO DE BAJA LAS TAREAS', 16 , 1)
		END CATCH
	END
