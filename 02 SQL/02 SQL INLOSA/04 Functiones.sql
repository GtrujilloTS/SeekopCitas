SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 07/04/2021
-- Ejemplo: SELECT dbo.fnCA_BusquedaClaveParametroInterfaz(1,'SeekopCitas','Usuario')
-- Descripción: Busca en la tabla de Interfaces el valor para el parametro que se configuro 
-- Parámetros: Sucursal,Interfaz,Clave
-- Resultado: Valor que Posee el parametro con que se configuro en una interfaz para una sucursal especifica
   =============================================*/
CREATE FUNCTION [dbo].[fnCA_BusquedaClaveParametroInterfaz](@Sucursal INT,@Interfaz VARCHAR(100),@Clave VARCHAR(100))
RETURNS VARCHAR(255)
AS
BEGIN
DECLARE
@Valor VARCHAR(255);

	SELECT @Valor=ISNULL(Valor,'') FROM CA_Interfaces AS I
	INNER JOIN CA_InterfacesD AS ID ON I.ID=ID.ID
	WHERE I.Interfaz=@Interfaz AND I.Sucursal=@Sucursal AND ID.Clave =@Clave

	RETURN @Valor
END
GO
/*****************************************************************************************************************************************************/
CREATE FUNCTION [dbo].[fnCA_DivideNombreRev](@Cadena varchar(200), @Tipo varchar(15))
RETURNS varchar(100)
AS
BEGIN
  DECLARE 
    @SubCadena varchar(100),
    @Cadena1 varchar(100),
    @Cadena2 varchar(100),
    @Cadena3 varchar(100),
    @Cadena4 varchar(100),
    @Nombres varchar(100),
    @Paterno varchar(100),
    @Materno varchar(100),
    @Inicio int,
    @Fin int
    
SELECT @Inicio = 0  
  SELECT @Fin = CASE WHEN CHARINDEX(' ', REVERSE(@cadena)) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ', REVERSE(@cadena)) END  
  SELECT @Cadena1 = reverse(SUBSTRING(reverse(@Cadena),@Inicio,@Fin)) 
  SELECT @Cadena = reverse(SUBSTRING(reverse(@Cadena),@Fin+1,LEN(@Cadena)-@Fin+1)  )
   IF @Cadena <> ''  
  BEGIN  
    SELECT @Fin = CASE WHEN CHARINDEX(' ', REVERSE(@cadena)) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ', REVERSE(@cadena)) END  
    SELECT @Cadena2 = reverse (SUBSTRING(reverse(@Cadena),@Inicio,@Fin)  )
    SELECT @Cadena = reverse(SUBSTRING(reverse(@Cadena),@Fin+1,LEN(@Cadena)-@Fin+1)) 
  END  
    SELECT @Nombres = ISNULL(@Cadena,''),  
           @Paterno = ISNULL(@Cadena2,''),  
           @Materno = ISNULL(@Cadena1,'')  
  
  IF @Tipo = 'Nombre'
    SELECT @SubCadena = @Nombres
  ELSE IF @Tipo = 'Paterno'
    SELECT @SubCadena = @Paterno
  ELSE IF @Tipo = 'Materno'
    SELECT @SubCadena = @Materno

  RETURN @SubCadena
END
GO

CREATE FUNCTION [dbo].[fnCA_DivideNombre](@Cadena varchar(200), @Tipo varchar(15))  
RETURNS varchar(100)  
AS  
BEGIN  
  DECLARE   
    @SubCadena varchar(100),  
    @Cadena1 varchar(100),  
    @Cadena2 varchar(100),  
    @Cadena3 varchar(100),  
    @Cadena4 varchar(100),  
    @Nombres varchar(100),  
    @Paterno varchar(100),  
    @Materno varchar(100),  
    @Inicio int,  
    @Fin int  
      
  SELECT @Inicio = 0  
  SELECT @Fin = CASE WHEN CHARINDEX(' ',@Cadena) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ',@Cadena) END  
  SELECT @Cadena1 = SUBSTRING(@Cadena,@Inicio,@Fin)  
  SELECT @Cadena = SUBSTRING(@Cadena,@Fin+1,LEN(@Cadena)-@Fin+1)  
  IF @Cadena <> ''  
  BEGIN  
    SELECT @Fin = CASE WHEN CHARINDEX(' ',@Cadena) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ',@Cadena) END  
    SELECT @Cadena2 = SUBSTRING(@Cadena,@Inicio,@Fin)  
    SELECT @Cadena = SUBSTRING(@Cadena,@Fin+1,LEN(@Cadena)-@Fin+1)  
  END  
  IF @Cadena <> ''  
  BEGIN  
    SELECT @Fin = CASE WHEN CHARINDEX(' ',@Cadena) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ',@Cadena) END  
    SELECT @Cadena3 = SUBSTRING(@Cadena,@Inicio,@Fin)  
    SELECT @Cadena = SUBSTRING(@Cadena,@Fin+1,LEN(@Cadena)-@Fin+1)  
  END  
  IF @Cadena <> ''  
  BEGIN  
    SELECT @Fin = CASE WHEN CHARINDEX(' ',@Cadena) = 0 THEN LEN(@Cadena)+1 ELSE CHARINDEX(' ',@Cadena) END  
    SELECT @Cadena4 = SUBSTRING(@Cadena,@Inicio,@Fin)  
    SELECT @Cadena = SUBSTRING(@Cadena,@Fin+1,LEN(@Cadena)-@Fin+1)  
  END  
    
  IF NOT(@Cadena4 IS NULL)  
    SELECT @Nombres = ISNULL(@Cadena1,'') + ' ' + ISNULL(@Cadena2,''),  
           @Paterno = @Cadena3,  
           @Materno = @Cadena4  
  ELSE  
    SELECT @Nombres = ISNULL(@Cadena1,''),  
           @Paterno = ISNULL(@Cadena2,''),  
           @Materno = ISNULL(@Cadena3,'')  
    
  IF @Tipo = 'Nombre'  
    SELECT @SubCadena = @Nombres  
  ELSE IF @Tipo = 'Paterno'  
    SELECT @SubCadena = @Paterno  
  ELSE IF @Tipo = 'Materno'  
    SELECT @SubCadena = @Materno  
      
  
  RETURN @SubCadena
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Autor:Giovanni Trujillo 
-- Parámetros: Modulo, Movimiento, Sucursal,Concepto del Movimiento
-- Resultado: Retorna una UEN que sea valida con o sin validacion de concepto
-- =============================================
CREATE FUNCTION [dbo].[fnCA_GeneraUENValida](@Modulo Varchar(5),@Mov  Varchar(20),@Sucursal int,@Concepto varchar(50))
RETURNS INT
AS
BEGIN
DECLARE 
@UEN INT

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CA_MovTipoValidarUEN' AND TABLE_SCHEMA = 'dbo')/*Revisa si trae la nomenclatura CA_ en la tabla para buscar tablas de la V6000 */
	BEGIN
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CA_ConceptoValidarUEN' AND TABLE_SCHEMA = 'dbo') AND @Concepto IS NOT NULL
			SELECT DISTINCT @UEN=CVU.UENValida FROM  CA_MovTipoValidarUEN AS MTVU 
			INNER JOIN CA_ConceptoValidarUEN AS CVU ON MTVU.Sucursal=CVU.Sucursal AND MTVU.Modulo=CVU.Modulo AND MTVU.UENValida=CVU.UENValida
			WHERE  MTVU.Sucursal=@Sucursal AND MTVU.Modulo=@Modulo AND MTVU.Mov=@Mov AND CVU.Concepto=@Concepto
		ELSE
			SELECT @UEN=UENValida FROM CA_MovTipoValidarUEN WHERE MOV=@Mov AND Sucursal=@Sucursal AND Modulo=@Modulo
	END
	ELSE
	BEGIN 
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ConceptoValidarUEN' AND TABLE_SCHEMA = 'dbo') AND @Concepto IS NOT NULL
			SELECT DISTINCT @UEN=CVU.UENValida FROM  MovTipoValidarUEN AS MTVU 
			INNER JOIN ConceptoValidarUEN AS CVU ON MTVU.Sucursal=CVU.Sucursal AND MTVU.Modulo=CVU.Modulo AND MTVU.UENValida=CVU.UENValida
			WHERE  MTVU.Sucursal=@Sucursal AND MTVU.Modulo=@Modulo AND MTVU.Mov=@Mov AND CVU.Concepto=@Concepto
		ELSE
			SELECT @UEN=UENValida FROM MovTipoValidarUEN WHERE MOV=@Mov AND Sucursal=@Sucursal AND Modulo=@Modulo
	END

	RETURN @UEN
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Autor:Giovanni Trujillo 
-- Parámetros: Modulo, Movimiento,Sucursal
-- Resultado: Retorna la sucursal valida para afectacion de movimeintos
-- =============================================
CREATE FUNCTION [dbo].[fnCA_GeneraSucursalValida](@Modulo Varchar(5),@Mov  Varchar(20),@Sucursal int)
RETURNS INT
AS
BEGIN

	IF @Mov IN ('Venta Perdida','Dias','Reservar')
	BEGIN	
		IF @Sucursal%2 =1
			SELECT @Sucursal=@Sucursal-1
	END
	IF @Mov IN ('Cita Servicio')
	BEGIN	
		IF @Sucursal%2 =0
			SELECT @Sucursal=@Sucursal+1
	END

	RETURN @Sucursal
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Autor:Giovanni Trujillo 
-- Parámetros: Modulo, Movimiento,Sucursal
-- Resultado: Retorna el Almacen valido para afectaciones
-- =============================================
CREATE FUNCTION [dbo].[fnCA_GeneraAlmacenlValido](@Modulo Varchar(5),@Mov  Varchar(20),@Sucursal int)
RETURNS Varchar(4)
AS
BEGIN
DECLARE
@Almacen Varchar(4)

	IF @Mov IN('Venta Perdida','Hist Refacc','Reservar')
	BEGIN
		IF @Sucursal%2 =1
			SELECT @Sucursal=@Sucursal-1
		SELECT @Almacen=Almacen FROM ALM WHERE Sucursal=@Sucursal AND Almacen like 'R%'
	END
	ELSE
		SELECT @Almacen=Almacen FROM ALM WHERE Sucursal=@Sucursal AND Almacen like 'S%'
	
	RETURN @Almacen

END
GO