/* =============================================
-- Autor: Nestor Gabriel Marquez Lopez
-- Creación: 22/02/2021
-- Descripción: Tabla para almacenamiento de Registros con errores
-- =============================================*/
CREATE TABLE CA_LogMovimientosInterfazD
(
	ID					INT	identity,
	logID				INT NULL,    
	CodigoError			VARCHAR(6)	NULL,
	TipoError			VARCHAR(3)	NULL,
	Response			VARCHAR(max) NULL,-----Response LLevara la respuesta que debuelven los servicios 
	Descripcion	VARCHAR(5100)	NULL		--- llevara una respuesta procesada del response (Respuesta corta)
	CONSTRAINT pkCA_LogMovimientosInterfazD PRIMARY KEY CLUSTERED (ID)
)

	--CREATE INDEX IdLogErroresInterfaz ON LogErroresInterfaz(Sucursal, Tipo, ID)

/* =============================================
-- Autor: Nestor Gabriel Marquez LopezS
-- Creación: 22/02/2021
-- Descripción: Tabla para almacenamiento de Registros a enviar con interfaces
-- =============================================*/

CREATE TABLE CA_LogMovimientosInterfaz
(
	ID					INT			identity,
	Sucursal			INT			NOT NULL,
	Tipo				VARCHAR(100)  NULL, --- ORDENES DE REPARACION, VENTA REFACCIONES, VENTA AUTOS
	IDDocumento			INT			NULL,
	Modulo				VARCHAR(5)  NOT NULL,
	Mov					VARCHAR(20)	NULL,
	MovID				VARCHAR(35)	NULL,
	FechaCreacion		DATETIME	DEFAULT GETDATE(),
	FechaEnvio			DATETIME	NULL,
	TipoError			VARCHAR(3)	NULL, --DEFAULT = 'ERR', /* ERR, WAR, E/W */  GT
	OrigenError			VARCHAR(3)	NULL, /* SYS, USR */
	Estatus				VARCHAR(20)	NULL,  /* ENVIADO CORRECTO, ENVIADO CON ERROR, ENVIADO CON WARNING, PENDIENTE */
	Request				VARCHAR(max) NULL,
	Interfaz			VARCHAR(100),     --- BLUESERVICES
	Marca				VARCHAR(50)
	CONSTRAINT pkCA_LogMovimientosInterfaz PRIMARY KEY CLUSTERED (Sucursal, Modulo, ID)

);
GO

/****************************************************************************************************************************************************************/
/* =============================================
-- Autor: Giovanni Trujillo Silvas
-- Creación: 24/03/2021
-- Descripción: Tabla para almacenamiento de Catalogo de Interfaces en las agencias
-- =============================================*/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CA_Interfaces](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RenglonID] [int] NULL,
	[Empresa] [varchar](10) NOT NULL,
	[Interfaz] [varchar](100) NOT NULL,
	[Marca] [varchar](50) NOT NULL,
	[Sucursal] [int] NOT NULL,
	[Estatus] [bit] NOT NULL,
 CONSTRAINT [pkCA_Interfaces] PRIMARY KEY CLUSTERED 
(
	[Empresa] ASC,
	[Sucursal] ASC,
	[Interfaz] ASC,
	[Marca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

/****************************************************************************************************************************************************************/
/* =============================================
-- Autor: Giovanni Trujillo Silvas
-- Creación: 24/03/2021
-- Descripción: Tabla para almacenamiento del Detalle para Catalogo de Interfaces en las agencias
-- =============================================*/

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CA_InterfacesD](
	[ID] [int] NOT NULL,
	[Renglon] [float] NOT NULL,
	[RenglonID] [int] NULL,
	[Clave] [varchar](50) NOT NULL,
	[Valor] [varchar](255) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO



/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 10/02/2021
-- Descripción: Tabla para almacenamiento de datos Seekop en Venta 
-- =============================================*/

CREATE TABLE CA_Venta
(
ID INT NULL,
SKCte VARCHAR(20)NULL,
SKNombreCompleto VARCHAR(100)NULL,
SKNombres VARCHAR(50)NULL,
SKAPaterno VARCHAR(50)NULL,
SKAMaterno VARCHAR(50)NULL,
SKArtVehiculo VARCHAR(20)NULL,
SKArtPaquete VARCHAR(20)NULL,
SKModelo VARCHAR(20)NULL,
SKPlacas VARCHAR(20)NULL,
SKVin VARCHAR(20)NULL
);
GO
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
CREATE TABLE SlotHorarios(
Fecha DATE,
DiaHabil BIT, 
Inicio VARCHAR(5),
Fin VARCHAR(5),
Disponible BIT 
);
GO
