USE ModeloParcial2

-- 1 Hacer un trigger que al cargar un crédito verifique que el importe del mismo sumado a los importes de los créditos que actualmente solicitó esa persona no supere al triple de la declaración de ganancias. 
-- Sólo deben tenerse en cuenta en la sumatoria los créditos que no se encuentren cancelados. De no poder otorgar el crédito aclararlo con un mensaje.

	SELECT * FROM Creditos
	SELECT * FROM Personas

	DROP TRIGGER TR_CREDITO_MENOR_GANANCIAS

	CREATE TRIGGER TR_CREDITO_MENOR_GANANCIAS ON CREDITOS
	INSTEAD OF INSERT
	AS
	BEGIN
		BEGIN TRY
			DECLARE @DNI BIGINT
			DECLARE @IMPORTE MONEY
			DECLARE @ACUMULADO MONEY
			DECLARE @GANANCIAS MONEY

			SELECT @DNI = DNI, @IMPORTE = IMPORTE FROM inserted

			SELECT @ACUMULADO = SUM(IMPORTE) FROM CREDITOS WHERE DNI = @DNI AND Cancelado LIKE '0'

			SELECT @GANANCIAS = DECLARACIONGANANCIAS FROM Personas WHERE DNI = @DNI

			IF (@IMPORTE + @ACUMULADO) <= (@GANANCIAS * 3) BEGIN
				INSERT INTO Creditos(IDBanco, DNI, FECHA, Importe, Plazo)
				SELECT IDBanco, DNI, Fecha, Importe, Plazo FROM inserted
			END
			ELSE BEGIN 
				RAISERROR('NO DISPONE DEL MONTO DESEADO',16,1)
			END

		END TRY
		BEGIN CATCH
			RAISERROR('NO DISPONE DEL MONTO DESEADO',16,1)
		END CATCH
	END

	INSERT INTO Creditos(IDBanco, DNI, FECHA, Importe, Plazo)
	VALUES(1,1111,GETDATE(),30000,5)

-- 2 Hacer un trigger que al eliminar un crédito realice la cancelación del mismo.

	CREATE TRIGGER TR_ELIMINAR_CREDITO ON CREDITOS
	INSTEAD OF DELETE
	AS
	BEGIN
		BEGIN TRY

			DECLARE @ID BIGINT
			SELECT @ID = ID FROM deleted

			UPDATE CREDITOS SET Cancelado = 1 WHERE @ID = ID

		END TRY
		BEGIN CATCH
			RAISERROR('ERROR',16,1)
		END CATCH
	END

	DELETE CREDITOS WHERE ID = 6

-- 3 Hacer un trigger que no permita otorgar créditos con un plazo de 20 o más años a personas cuya declaración de ganancias sea menor al promedio de declaración de ganancias.

	CREATE TRIGGER TR_CREDITOS_MAS_20 ON CREDITOS
	INSTEAD OF INSERT
	AS
	BEGIN
		BEGIN TRY
			DECLARE @PROMEDIO MONEY
			DECLARE @DECLARACION MONEY
			DECLARE @DNI BIGINT
			SELECT @PROMEDIO = AVG(DeclaracionGanancias) FROM Personas
			DECLARE @PLAZO BIGINT 
			SELECT @PLAZO =  PLAZO, @DNI = DNI FROM inserted
			SELECT @DECLARACION =  DECLARACIONGANANCIAS FROM PERSONAS WHERE DNI = @DNI


			IF @PLAZO >= 20 AND @PROMEDIO > @DECLARACION BEGIN
				RAISERROR('NO PUEDE SOLICITAR EL CREDITO EN ESTE PLAZO',16,1)
			END
			ELSE BEGIN
				INSERT INTO Creditos(IDBanco, DNI, Fecha, Importe, Plazo)
				SELECT IDBanco, DNI, Fecha, Importe, Plazo FROM inserted
			END
		END TRY

		BEGIN CATCH
			RAISERROR('ERROR',16,1)
		END CATCH
	END

	SELECT * FROM Creditos
	SELECT * FROM Personas

	SELECT AVG(DECLARACIONGANANCIAS) FROM PERSONAS

	INSERT INTO Creditos(IDBanco, DNI, Fecha, Importe, Plazo)
	VALUES(1,4444,GETDATE(),2000,19)

-- 4 Hacer un procedimiento almacenado que reciba dos fechas y liste todos los créditos otorgados entre esas fechas. Debe listar el apellido y nombre del solicitante, el nombre del banco, el tipo de banco, 
-- la fecha del crédito y el importe solicitado.

	CREATE PROCEDURE SP_CREDITOS_OTORGADOS(
		@FECHAINICIO DATE,
		@FECHAFIN DATE
	)
	AS
	BEGIN
		SELECT P.Nombres, P.Apellidos, B.Nombre, B.Tipo, C.Fecha, C.Importe FROM Personas P INNER JOIN CREDITOS C ON P.DNI = C.DNI 
		INNER JOIN BANCOS B ON B.ID = C.IDBanco
		WHERE C.Fecha BETWEEN @FECHAINICIO AND @FECHAFIN
	END

	EXEC SP_CREDITOS_OTORGADOS '1/01/2021', '31/12/2021'