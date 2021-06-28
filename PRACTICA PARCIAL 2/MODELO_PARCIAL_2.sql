

-- A) - Realizar un trigger que se encargue de verificar que un socio no pueda extraer más de un libro a la vez. 
-- Se sabrá que un socio tiene un libro sin devolver si contiene un registro en la tabla de Préstamos que no tiene fecha de devolución. 
--Si el socio tiene un libro sin devolver el trigger no deberá permitir el préstamo y deberá indicarlo con un mensaje aclaratorio. Caso contrario, registrar el préstamo.  (25 puntos)

	CREATE TRIGGER TR_UN_PRESTAMO ON PRESTAMOS
	INSTEAD OF INSERT
	AS
	BEGIN
		BEGIN TRY
			DECLARE @IDSOCIO BIGINT
			SELECT @IDSOCIO = IDSOCIO FROM inserted
			DECLARE @CANTIDAD BIGINT
			SELECT @CANTIDAD = COUNT(FDEVOLUCION) FROM PRESTAMOS WHERE IDSOCIO = @IDSOCIO AND FDEVOLUCION IS NULL

			IF @CANTIDAD = 0 BEGIN
				INSERT INTO PRESTAMOS(IDSOCIO, IDLIBRO,FPRESTAMO,COSTO)
				SELECT IDSOCIO, IDLIBRO, FPRESTAMO, COSTO FROM inserted
			END
			ELSE BEGIN
				RAISERROR('NO PUEDE PEDIR',16,1)
			END

		END TRY
		BEGIN CATCH
			RAISERROR('NO PUEDE PEDIR',16,1)
		END CATCH
	END

-- B) Realizar un procedimiento almacenado que a partir de un número de socio se pueda ver, ordenado por fecha decreciente, todos los libros retirados por el socio y que hayan sido devueltos. (20 puntos)

	CREATE PROCEDURE SP_PRESTAMOS_SOCIOS(
		@IDSOCIO BIGINT
	)
	AS
	BEGIN
		SELECT L.NOMBRE, P.FDEVOLUCION FROM PRESTAMOS P INNER JOIN LIBROS L ON P.IDLIBRO = L.ID
		WHERE P.IDSOCIO = @IDSOCIO AND P.FDEVOLUCION IS NOT NULL
	END

-- C) Hacer un procedimiento almacenado denominado 'Devolver_Libro' que a partir de un IDLibro y una Fecha de devolución, realice la devolución de dicho libro en esa fecha y asigne el costo del 
--préstamo que equivale al 10% del valor del libro. Si el libro es devuelto después de siete días o más de la fecha de préstamo, el costo del préstamo será del 20% del valor del libro.
--NOTA: Si el libro no se encuentra prestado indicarlo con un mensaje. (30 puntos)

	CREATE PROCEDURE SP_DEVOLVER_LIBRO(
		@IDLIBRO BIGINT,
		@FECHA DATE
	)
	AS
	BEGIN
		DECLARE @PRESTADO BIGINT
		DECLARE @IDPRESTAMOS BIGINT
		SELECT @PRESTADO = COUNT(DISTINCT FDEVOLUCION), @IDPRESTAMOS = ID FROM PRESTAMOS WHERE IDLIBRO = @IDLIBRO AND FDEVOLUCION IS NULL
		DECLARE @DIAS BIGINT
		DECLARE @PRESTAMO DATE
		DECLARE @PRECIO MONEY
		SELECT @PRECIO = PRECIO FROM LIBROS WHERE @IDLIBRO = ID

		IF @PRESTADO > 1 BEGIN
			RAISERROR('PRESTADO'16,1)
		END
		ELSE BEGIN
			SELECT @PRESTAMO = FPRESTAMO FROM PRESTAMOS WHERE IDLIBRO = @IDLIBRO AND FDEVOLUCION IS NULL
			SELECT @DIAS = DATEDIFF(DAY, @PRESTAMO,GETDATE())

			IF @DIAS > 6 BEGIN
				UPDATE PRESTAMOS SET FDEVOLUCION = GETDATE(), COSTO = @PRECIO*0.2 WHERE ID = @IDPRESTAMOS
			END
			ELSE BEGIN
				UPDATE PRESTAMOS SET FDEVOLUCION = GETDATE(), COSTO = @PRECIO*0.1 WHERE ID = @IDPRESTAMOS
			END


		END

		
		
	END


--D) Listar todos los socios que hayan retirado al menos un bestseller. Los datos del socio deben aparecer una sola vez en el listado. (25 puntos)


	CREATE VW_SOCIOS_BESTSELLER AS
	SELECT DISTINCT S.NOMBRE, S.APELLIDO, S.FNAC FROM SOCIOS S INNER JOIN PRESTAMOS P ON S.ID = P.IDSOCIO
	INNER JOIN LIBROS L ON P.IDLIBRO = L.ID
	WHERE L.BESTSELLER LIKE '1'