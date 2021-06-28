USE BluePrint

-- 1 Hacer un trigger que al ingresar una colaboración obtenga el precio de la misma a partir del precio hora base del tipo de tarea. Tener en cuenta que si el colaborador es externo el costo debe ser un 20% más caro.


		CREATE TRIGGER TR_PrecioColaboracion ON COLABORACIONES
		AFTER INSERT
		AS
		BEGIN
			DECLARE @IdTarea BIGINT
			SELECT @IdTarea = (SELECT IdTarea FROM inserted)

			DECLARE @Precio MONEY

			SELECT @Precio = (SELECT TT.PrecioHoraBase FROM Tareas T INNER JOIN TiposTarea TT ON T.IDTipo = TT.ID 
			WHERE @IdTarea = T.ID)

			IF (SELECT COL.Tipo FROM inserted I INNER JOIN Colaboradores COL ON I.IDColaborador = COL.ID) LIKE 'E' BEGIN
				SET @Precio = @Precio * 1.2
				END
		END


-- 2 Hacer un trigger que no permita que un colaborador registre más de 15 tareas en un mismo mes. De lo contrario generar un error con un mensaje aclaratorio.

	CREATE TRIGGER TR_CantTareas ON COLABORACIONES
	AFTER INSERT
	AS
	BEGIN
		DECLARE @IdCol BIGINT
		SELECT @IdCol = (SELECT IDColaborador FROM inserted)

		DECLARE @Fecha DATE
		SELECT @Fecha = (SELECT T.FechaInicio FROM inserted I INNER JOIN Tareas T ON I.IDTarea = T.ID)

		DECLARE @Cant INT
		SELECT @Cant = (SELECT COUNT(IDTarea) FROM inserted I WHERE IDColaborador = @IdCol AND YEAR(@Fecha) = YEAR(GETDATE()) AND MONTH(@Fecha) = MONTH(GETDATE()))

		IF @Cant > 15 BEGIN
			RAISERROR('MAS TAREAS DE LO DEBIDO', 16 , 1)
			END

	END


-- 3 Hacer un trigger que al ingresar una tarea cuyo tipo contenga el nombre 'Programación' se agreguen automáticamente dos tareas de tipo 'Testing unitario' y 'Testing de integración' de 4 horas cada una. 
-- La fecha de inicio y fin de las mismas debe ser NULL. Calcular el costo estimado de la tarea.


-- 4 Hacer un trigger que al borrar una tarea realice una baja lógica de la misma en lugar de una baja física.

	DISABLE TRIGGER TR_EliminarTarea ON TAREAS

	ALTER TRIGGER TR_EliminarTarea ON TAREAS
	INSTEAD OF DELETE
	AS
	BEGIN
		UPDATE Tareas SET Estado = 0 WHERE ID = (SELECT ID FROM deleted)
	END

	DELETE FROM TAREAS WHERE ID = 13

	SELECT * FROM TAREAS WHERE ID = 13

-- 5 Hacer un trigger que al borrar un módulo realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas las tareas asociadas al módulo.

-- 6 Hacer un trigger que al borrar un proyecto realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas los módulos asociados al proyecto.

	ALTER TRIGGER TR_EliminarProyecto ON Proyectos
	INSTEAD OF DELETE
	AS 
	BEGIN
		UPDATE Proyectos SET ESTADO = 0 WHERE ID = (SELECT ID FROM deleted)

		UPDATE Modulos SET Estado = 0 WHERE IDProyecto = (SELECT ID FROM deleted)
	END

	DELETE FROM Proyectos WHERE ID LIKE 'A100'
	SELECT * FROM Proyectos  WHERE ID LIKE 'A100'
	SELECT * FROM Modulos WHERE IDProyecto LIKE 'A100'

-- 7 Hacer un trigger que si se agrega una tarea cuya fecha de fin es mayor a la fecha estimada de fin del módulo asociado a la tarea entonces se modifique la fecha estimada de fin en el módulo.

	ALTER TRIGGER TR_CambiarFechaModulo ON TAREAS
	AFTER INSERT
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				 DECLARE @Fecha DATE
				 SELECT @Fecha = FechaFin FROM inserted

				 DECLARE @FechaFinModulo DATE
				 DECLARE @IdModulo BIGINT
				 SELECT @FechaFinModulo = M.FechaEstimadaFin, @IdModulo = M.ID FROM Modulos M INNER JOIN inserted I ON M.ID = I.IDModulo

				 IF @Fecha > @FechaFinModulo BEGIN
					UPDATE Modulos SET FechaEstimadaFin = @Fecha  WHERE ID LIKE @IdModulo
				 END

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK
			RAISERROR('ERROR',16,1)
		END CATCH

	END

	INSERT INTO TAREAS
	VALUES(7,1,GETDATE(),GETDATE(),1)

	SELECT * FROM Modulos
	SELECT * FROM Tareas
-- 8 Hacer un trigger que al borrar una tarea que previamente se ha dado de baja lógica realice la baja física de la misma.

	CREATE TRIGGER TR_EliminarLATarea ON TAREAS
	AFTER DELETE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @Id BIGINT
			SELECT @Id = ID FROM deleted

			DECLARE @Estado BIT
			SELECT @Estado = Estado FROM deleted


			IF @Estado = 0 BEGIN
				DELETE FROM TAREAS WHERE ID = @Id
			END
			
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK
			RAISERROR('ERROR',16,1)
		END CATCH


	END

	DELETE FROM Tareas WHERE ID = 1

-- 9 Hacer un trigger que al ingresar una colaboración no permita que el colaborador/a superponga las fechas con las de otras colaboraciones que se les hayan asignado anteriormente. 
-- En caso contrario, registrar la colaboración sino generar un error con un mensaje aclaratorio.

	

-- 10 Hacer un trigger que al modificar el precio hora base de un tipo de tarea registre en una tabla llamada HistorialPreciosTiposTarea el ID, el precio antes de modificarse y la fecha de modificación.
-- NOTA: La tabla debe estar creada previamente. NO crearla dentro del trigger.
