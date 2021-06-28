	USE BluePrint

-- 1 Hacer un trigger que al ingresar una colaboración obtenga el precio de la misma a partir del precio hora base del tipo de tarea. Tener en cuenta que si el colaborador es externo el costo debe ser un 20% más caro.

	CREATE TRIGGER TR_PRECIO_COLABORACION ON COLABORACIONES
	AFTER INSERT
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @TIPO CHAR
				SELECT @TIPO = C.TIPO FROM inserted I INNER JOIN Colaboradores C ON I.IDColaborador = C.ID
				DECLARE @PRECIO MONEY
				SELECT @PRECIO = TT.PrecioHoraBase  FROM inserted I INNER JOIN Tareas T ON I.IDTarea = T.ID INNER JOIN TiposTarea TT ON T.ID = TT.ID
				DECLARE @IDTAREA BIGINT
				DECLARE @IDCOLABORADOR BIGINT
				SELECT @IDTAREA = IDTAREA, @IDCOLABORADOR = IDCOLABORADOR FROM inserted

				IF @TIPO LIKE 'I' BEGIN
					UPDATE Colaboraciones SET PrecioHora = @PRECIO WHERE IDTarea = @IDTAREA AND IDColaborador = @IDCOLABORADOR
				END

				IF @TIPO LIKE 'E' BEGIN
					UPDATE Colaboraciones SET PrecioHora = @PRECIO*1.2 WHERE IDTarea = @IDTAREA AND IDColaborador = @IDCOLABORADOR
				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			RAISERROR('ERROR',16,1)
		END CATCH
	END

	DROP TRIGGER TR_PRECIO_COLABORACION

-- 2 Hacer un trigger que no permita que un colaborador registre más de 15 tareas en un mismo mes. De lo contrario generar un error con un mensaje aclaratorio.

	CREATE TRIGGER TR_MENOS_15_TAREAS ON COLABORACIONES
	AFTER INSERT
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @IdCol BIGINT
				DECLARE @IDTAREA BIGINT
				SELECT @IdCol = IDColaborador, @IDTAREA = IDTarea FROM inserted

				DECLARE @Fecha DATE
				SELECT @Fecha = (SELECT T.FechaInicio FROM inserted I INNER JOIN Tareas T ON I.IDTarea = T.ID)

				DECLARE @Cant INT
				SELECT @Cant = (SELECT COUNT(DISTINCT IDTarea) FROM inserted I WHERE IDColaborador = @IdCol AND YEAR(@Fecha) = YEAR(GETDATE()) AND MONTH(@Fecha) = MONTH(GETDATE()))

				IF @Cant > 15 BEGIN
					DELETE Colaboraciones WHERE IDColaborador = @IdCol AND IDTarea = @IDTAREA
				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			RAISERROR('ERROR',16,1)
		END CATCH

	END

	DROP TR_MENOS_15_TAREAS
	

-- 3 Hacer un trigger que al ingresar una tarea cuyo tipo contenga el nombre 'Programación' se agreguen automáticamente dos tareas de tipo 'Testing unitario' y 'Testing de integración' de 4 horas cada una. 
-- La fecha de inicio y fin de las mismas debe ser NULL. Calcular el costo estimado de la tarea.

	

-- 4 Hacer un trigger que al borrar una tarea realice una baja lógica de la misma en lugar de una baja física.

	CREATE TRIGGER TR_ELIMINAR_TAREA ON TAREAS
	INSTEAD OF DELETE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @IDTAREA BIGINT
			SELECT @IDTAREA = ID FROM deleted

			UPDATE TAREAS SET Estado = 0 WHERE ID = @IDTAREA

		END TRY
		BEGIN CATCH
			RAISERROR('ERROR',16,1)
		END CATCH
	END

	SELECT * FROM TAREAS

	DELETE TAREAS WHERE ID = 1


-- 5 Hacer un trigger que al borrar un módulo realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas las tareas asociadas al módulo.

	CREATE TRIGGER TR_ELIMINAR_MODULO ON MODULOS
	INSTEAD OF DELETE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @IDMODULO BIGINT
			SELECT @IDMODULO = ID FROM deleted

			UPDATE Modulos SET Estado = 0 WHERE ID = @IDMODULO

			UPDATE TAREAS SET Estado = 0 WHERE IDModulo = @IDMODULO

		END TRY
		BEGIN CATCH
			RAISERROR('ERROR',16,1)
		END CATCH
	END

-- 6 Hacer un trigger que al borrar un proyecto realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas los módulos asociados al proyecto.

	CREATE TRIGGER TR_ELIMINAR_PROYECTO ON PROYECTOS
	INSTEAD OF DELETE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @IDPROYECTO VARCHAR(5)
			SELECT @IDPROYECTO = ID FROM deleted

			UPDATE Proyectos SET Estado = 0 WHERE ID LIKE @IDPROYECTO

			DELETE MODULOS WHERE IDProyecto = @IDPROYECTO

		END TRY
		BEGIN CATCH
			RAISERROR('ERROR',16,1)
		END CATCH
	END

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

-- 9 Hacer un trigger que al ingresar una colaboración no permita que el colaborador/a superponga las fechas con las de otras colaboraciones que se les hayan asignado anteriormente. 
-- En caso contrario, registrar la colaboración sino generar un error con un mensaje aclaratorio.

	CREATE TRIGGER TR_COLABORACION_SUPERPUESTA ON COLABORACIONES
	AFTER INSERT
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @FECHA DATE
				DECLARE @IDCOL BIGINT
				SELECT @IDCOL = I.IDColaborador, @FECHA = T.FechaInicio FROM inserted I INNER JOIN TAREAS T ON I.IDTarea = T.ID

				IF @FECHA BETWEEN (SELECT T.FechaInicio FROM Colaboraciones COL INNER JOIN TAREAS T ON COL.IDTarea = T.ID WHERE @IDCOL = COL.IDColaborador) AND (SELECT T.FechaFin FROM Colaboraciones COL INNER JOIN TAREAS T ON COL.IDTarea = T.ID WHERE @IDCOL = COL.IDColaborador) BEGIN
					RAISERROR('ERROR',16,1)
				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION

		END CATCH
	END

-- 10 Hacer un trigger que al modificar el precio hora base de un tipo de tarea registre en una tabla llamada HistorialPreciosTiposTarea el ID, el precio antes de modificarse y la fecha de modificación.
-- NOTA: La tabla debe estar creada previamente. NO crearla dentro del trigger.

	CREATE TABLE HistorialPreciosTiposTarea(
		IDTAREA INT FOREIGN KEY REFERENCES TAREAS (ID) NOT NULL,
		PRECIOPREVIO MONEY NOT NULL,
		FECHAMODIFICACIONES DATE NOT NULL
	)
	
	CREATE TRIGGER TR_PRECIO_TIPO_TAREA ON TIPOSTAREA
	AFTER UPDATE
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @IDTAREA INT
				DECLARE @PRECIO MONEY
				SELECT @IDTAREA = I.ID , @PRECIO = I.PrecioHoraBase FROM inserted I

				INSERT INTO HistorialPreciosTiposTarea(IDTAREA,PRECIOPREVIO,FECHAMODIFICACIONES)
				VALUES(@IDTAREA, @PRECIO, GETDATE())
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK
			RAISERROR('ERROR',16,1)
		END CATCH
	END

	SELECT * FROM TiposTarea
	SELECT * FROM HistorialPreciosTiposTarea
	UPDATE TiposTarea SET PrecioHoraBase = '5000' WHERE ID = 1

