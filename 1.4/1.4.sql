CREATE DATABASE BluePrint
GO
USE BluePrint
GO
CREATE TABLE TiposClientes(
	ID smallint primary key identity (1,1) not null,
	Nombre varchar(40) not null
)
GO
CREATE TABLE Clientes(
	ID smallint primary key identity (1,1) not null,
	RazonSocial varchar(50) not null unique,
	CUIT varchar(13) not null unique,
	Email varchar(100) null,
	Telefono varchar(15) null,
	Celular varchar(15) null,
	IDTipo smallint not null foreign key references TiposClientes(ID),
)
GO
CREATE TABLE Proyectos(
	ID varchar(5) primary key  not null,
	IDCliente smallint not null foreign key references Clientes(ID),
	Nombre varchar(100) not null,
	Descripcion varchar (512) null,
	CostoEstimado money not null check (CostoEstimado > 0),
	FechaInicio Date not null,
	FechaFin Date null,
	Estado bit not null default (1),
)
GO 
CREATE TABLE Paises(
	ID smallint primary key identity(1,1) not null,
	Nombre varchar(50) not null
)
GO
CREATE TABLE Ciudades(
	ID int primary key identity(1,1) not null,
	Nombre varchar(100) not null,
	IDPais smallint not null foreign key references Paises(ID)
)
GO
CREATE TABLE Colaboradores(
	ID smallint primary key identity(1,1) not null,
	Nombre varchar(30) not null,
	Apellido varchar(30) not null,
	Email varchar(100) null,
	Telefono varchar(15) null,
	FechaDeNacimiento date not null check(FechaDeNacimiento < GETDATE()),
	TipoColaborador char(1) check(TipoColaborador = 'I' OR TipoColaborador = 'E'),
	Domicilio varchar(250) null,
	IDCiudad int foreign key references Ciudades(ID) null
)
GO
CREATE TABLE Modulos(
	IDProyecto varchar(5) not null foreign key references Proyectos(ID),
	ID int identity(1,1) not null primary key,
	Nombre varchar(50) not null,
	Descripcion varchar(512) null,
	HorasEstimadas smallint not null check(HorasEstimadas > 0),
	CostoEstimado money not null check (CostoEstimado > 0),
	FechaFinEstimada date null,
	FechaInicio date null,
	FechaFin date null 
)
ALTER TABLE Modulos add constraint CHK_Fechafin check(FechaFin  >= FechaInicio)
ALTER TABLE Modulos add constraint CHK_FechafinEstimada check(FechaFinEstimada  >= FechaInicio)
ALTER TABLE Colaboradores add constraint CHK_mailYcelular check(Email is not null OR Telefono is not null)
ALTER TABLE Clientes
	ADD IDCiudad int null foreign key references Ciudades(ID)