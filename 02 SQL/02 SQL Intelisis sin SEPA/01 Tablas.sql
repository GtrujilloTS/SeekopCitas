
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 10/02/2021
-- Descripción: Tabla para almacenamiento de datos Seekop en Venta 
-- =============================================*/

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CA_Venta') AND TYPE = 'U')
BEGIN

	CREATE TABLE [dbo].[CA_Venta](
		[IdVenta] [int] NOT NULL   ------------Este sera el ID que se usara para hacer referencia al ID de la tabla Venta
		) ON [PRIMARY]
END
GO



EXEC spALTER_TABLE 'CA_Venta', 'Id_OportunidadLX', 'varchar(100) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'IdProspecto', 'varchar(200) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'IDValuacion', 'int NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKCte', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKNombreCompleto', 'varchar(100) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKNombres', 'varchar(50) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKAPaterno', 'varchar(50) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKAMaterno', 'varchar(50) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKArtVehiculo', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKArtPaquete', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKModelo', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKPlacas', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'SKVin', 'varchar(20) NULL'
EXEC spALTER_TABLE 'CA_Venta', 'AcordeManual', 'bit NULL DEFAULT ((0))'
EXEC spALTER_TABLE 'CA_Venta', 'NoAcordeManual', 'bit NULL DEFAULT ((0))'
EXEC spALTER_TABLE 'CA_Venta', 'NoAplica', 'bit NULL DEFAULT ((0))'
EXEC spALTER_TABLE 'CA_Venta', 'FechaAcordeManual', 'datetime  NULL DEFAULT (NULL)'
EXEC spALTER_TABLE 'CA_Venta', 'Reasignado', 'bit NULL DEFAULT ((0))'
EXEC spALTER_TABLE 'CA_Venta', 'FechaReasignado', 'datetime NULL DEFAULT (NULL)'
EXEC spALTER_TABLE 'CA_Venta', 'IdVentaPilot', 'varchar(200) NULL'



/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 10/02/2021
-- Descripción: Tabla para almacenamiento de clientes temporales para Seekop 
-- =============================================*/
CREATE TABLE CA_SKClientes(
ID INT IDENTITY,
Cliente VARCHAR(20)NULL,
Estatus VARCHAR(20)NULL DEFAULT 'ALTA',
Nombre VARCHAR(100)NULL,
PersonalNombres VARCHAR(50)NULL,
PersonalApellidoPaterno VARCHAR(50),
PersonalApellidoMaterno VARCHAR(50),
Delegacion VARCHAR(50)NULL,
Colonia VARCHAR(50)NULL,
Poblacion VARCHAR(50)NULL,
CodigoPostal VARCHAR(10)NULL,
Estado VARCHAR(50)NULL,
Pais VARCHAR(50)NULL,
Direccion VARCHAR(50)NULL DEFAULT 'Conocido',  
DireccionNumero VARCHAR(50)NULL DEFAULT '#',
RFC VARCHAR(15)NULL DEFAULT 'XAXX010101000',
FiscalRegimen VARCHAR(50)NULL DEFAULT 'Persona Fisica',
TelefonosLada VARCHAR(50)NULL,
Telefonos VARCHAR(50)NULL,
PersonalTelefonoMovil VARCHAR(50)NULL,
eMail1 VARCHAR(100)NULL,
Contactar VARCHAR(50)NULL,
ContactarDe VARCHAR(10)NULL DEFAULT '09:00',
ContactarA VARCHAR(10) NULL DEFAULT '19:00',
Sexo VARCHAR(15)NULL DEFAULT 'Masculino') 

/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 04/02/2021
-- Descripción: Tabla para almacenamiento de Modelos de Vehiculos para Seekop 
-- =============================================*/
CREATE TABLE CA_SKModeloVehiculos(
ID INT IDENTITY,
Clave VARCHAR(20),
Descripcion VARCHAR(100),
);

/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 04/02/2021
-- Descripción: Tabla para almacenamiento de Paquetes para Seekop 
-- =============================================*/
CREATE TABLE CA_SKPaquetes(
ID INT IDENTITY,
Clave VARCHAR(20),
Descripcion VARCHAR(100),
Grupo VARCHAR(20)
);

GO

/* =============================================
-- Autor:Giovanni Trujillo 
-- Creación: 17/06/2020
-- Descripción: Tabla para log de citas
-- =============================================*/
CREATE TABLE [dbo].[CA_log_sepa_citas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Empresa] [nvarchar](5) NULL,
	[Mov] [nvarchar](20) NULL,
	[FechaEmision] [datetime] NULL,
	[Concepto] [nvarchar](50) NULL,
	[Moneda] [nvarchar](10) NULL,
	[TipoCambio] [float] NULL,
	[Usuario] [nvarchar](10) NULL,
	[Estatus] [nvarchar](15) NULL,
	[Cliente] [nvarchar](10) NULL,
	[Agente] [nvarchar](10) NULL,
	[HoraRequerida] [nvarchar](5) NULL,
	[Condicion] [nvarchar](50) NULL,
	[ServicioArticulo] [nvarchar](20) NULL,
	[ServicioDescripcion] [nvarchar](100) NULL,
	[ServicioSerie] [nvarchar](50) NULL,
	[ServicioPlacas] [nvarchar](20) NULL,
	[ServicioKms] [int] NULL,
	[ServicioNumeroEconomico] [nvarchar](20) NULL,
	[ServicioTipoOrden] [nvarchar](20) NULL,
	[ServicioTipoOperacion] [nvarchar](50) NULL,
	[ServicioModelo] [nvarchar](4) NULL,
	[Ejercicio] [int] NULL,
	[Periodo] [int] NULL,
	[ListaPreciosEsp] [nvarchar](20) NULL,
	[Sucursal] [int] NULL,
	[Comentarios] [nvarchar](500) NULL,
	[SucursalOrigen] [int] NULL,
	[Id_sepa_Citas] [int] NULL,
	[Id_CitaIntelisis] [int] NULL,
	[ArticuloPaquete] [nvarchar](20)NULL
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/* =============================================
-- Autor:Giovanni Trujillo 
-- Creación: 27/06/2021
-- Descripción: Tabla para Slot de Horarios a presentar
-- =============================================*/
CREATE TABLE [dbo].[CA_SlotHorarios](
	[Fecha] [date] NOT NULL,
	[DiaHabil] [bit] NOT NULL,
	[Inicio] [varchar](5) NOT NULL,
	[Fin] [varchar](5) NOT NULL,
	[Disponible] [bit] NOT NULL,
	[Sucursal] [int] NOT NULL
) ON [PRIMARY]

GO