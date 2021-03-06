USE UNIVERSIDAD
CREATE TABLE CARRERAS(
ID CHAR(4) PRIMARY KEY,
Nombre VARCHAR(50) NOT NULL,
FechaCreacion DATETIME NOT NULL CHECK(FechaCreacion < GETDATE()),
Mail VARCHAR(80) NOT NULL,
Nivel VARCHAR (12) NOT NULL CHECK(Nivel = 'Diplomatura' OR Nivel = 'Pregrado' OR Nivel = 'Grado' OR Nivel = 'Posgrado')
)
GO
CREATE TABLE ALUMNOS(
Legajo BIGINT PRIMARY KEY IDENTITY(1000,1),
IDCarrera CHAR(4) NOT NULL FOREIGN KEY REFERENCES CARRERAS(ID),
Nombre VARCHAR(50) NOT NULL,
Apellido VARCHAR (50) NOT NULL,
FechaNacimiento DATETIME NOT NULL CHECK (FechaNacimiento < GETDATE()),
Mail VARCHAR(80) NOT NULL UNIQUE,
Telefono VARCHAR(20) NULL
)
GO

CREATE TABLE MATERIAS(
ID INT PRIMARY KEY IDENTITY(1,1),
IDCarrera CHAR(4) NOT NULL FOREIGN KEY REFERENCES CARRERAS(ID),
Nombre VARCHAR(50) NOT NULL,
CargaHoraria SMALLINT NOT NULL CHECK(CargaHoraria > 0)
)
