
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 05/06/2020
-- Ejemplo:  EXEC xpCA_HorarioAgente 3,2020,09,2,'SePa'
-- Parámetros SucursalTaller, Año, Mes, Dia, Interfaz
-- Descripción:Genera los horarios disponibles para los agentes por un dia espeficifico
*/
CREATE PROCEDURE [dbo].[xpCA_HorarioAgente](@Sucursal int,@Anio VARCHAR(4),@Mes VARCHAR(2),@Dia VARCHAR(2), @Interfaz VARCHAR(20))
AS
BEGIN
/*GTS|Inicio|Funcion para obtener un horario de dia dependiendo de la la hora de la jornada y los minutos de recepcion*/
SET NOCOUNT ON
DECLARE
@Recepcion		INT ,
@Inicio			VARCHAR(5),
@IFin			VARCHAR(5),
@FinI			VARCHAR(5),
@Fin			VARCHAR(5),
@Hora			VARCHAR(5),
@Jornada		VARCHAR(50),
@FechaIni		datetime,
@FechaFin		datetime,
@Agente			VARCHAR(10),
@HoraMargen		INT,			/*PERMITE DAR UN MARGEN DE TIEMPO PARA AGENDAR O MOSTRAR HORARIOS*/
@FechaConMargen DATETIME,
@HoraComienzo	VARCHAR(5)


	SELECT @Recepcion = CCTRecepcion
		FROM Sucursal 
	   WHERE Sucursal = @Sucursal 
	
	IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CA_sepa_conf_correo') and type = 'U')/*Revisamos si existe la tabla para poder sacar la Margenes de tiempo*/
	BEGIN
		IF EXISTS (SELECT * FROM CA_sepa_conf_correo WHERE Sucursal=@Sucursal)
		BEGIN 
			SELECT @HoraMargen = ISNULL(HoraMargenCita,0) FROM CA_sepa_conf_correo WHERE Sucursal=@Sucursal
		END	
		ELSE 
			SET @HoraMargen=0
	END
	ELSE
		SET @HoraMargen=0

	DECLARE @HorariosJornadas TABLE
	(
	Hora	VARCHAR(5),
	Jornada	VARCHAR(50)
	)

	IF ISNULL(@Recepcion,'') =''
	BEGIN
		SELECT 'No hay Horario Disponible'
		RETURN
	END

	SELECT @FechaConMargen=CONVERT(VARCHAR(23),DATEADD(HOUR, @HoraMargen ,GETDATE()),126)

	IF @FechaConMargen >(CONVERT(datetime, @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')+'T'+'19:00'+':00.000',126))/*El horario con margen es mayoy a la fecha de consulta*/
	BEGIN	
		SELECT 'No hay Horario Disponible1'
		RETURN
	END
	ELSE
	BEGIN
		--IF --(SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))>('19:00')/*Horario de consulta mayor a 7 de la tarde*/
		--BEGIN
		--	SELECT 'No hay Horario Disponible2'
		--	RETURN
		--END
		--ELSE 
		--BEGIN 
			IF (SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))>('19:00')
			BEGIN
				SELECT @HoraComienzo='07:00'
			END
			ELSE IF (SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))<('07:00')
			BEGIN
				SELECT @HoraComienzo='07:00'
			END
			ELSE
			BEGIN
				SELECT @HoraComienzo=SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5)
			END
		--END
	END



	CREATE TABLE #HorariosDisponibles
	(
	Agente VARCHAR(100),
	Jornada VARCHAR(100) NULL,
	FechaEmision DATETIME NULL, 
	HoraRecepcion VARCHAR(5), 
	FechaRequerida DATETIME NULL,  
	HoraRequerida VARCHAR(5),
	dtRequeridaIni DATETIME NULL,
	dtRequeridaFin DATETIME NULL
	)


	INSERT INTO #HorariosDisponibles
	SELECT Agente,Jornada,FechaEmision,HoraRecepcion, FechaRequerida, HoraRequerida,dtRequeridaIni,dtRequeridaFin
	FROM vwCA_CCVistaAgentes WHERE 
	YEAR(FechaRequerida) =@Anio  AND MONTH(FechaRequerida) = @Mes AND DAY(FechaRequerida)=@Dia

	
	IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CA_Asesores') and type = 'U')/*Revisamos si existe la tabla para poder sacar la prospoeccion*/
	BEGIN
		INSERT INTO #HorariosDisponibles
		SELECT	Agente1,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente1=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION 
		SELECT	Agente2,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente2=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente3,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente3=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente4,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente4=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente5,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente5=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente6,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente6=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente7,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente7=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente8,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente8=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente9,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente9=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
		UNION
		SELECT	Agente10,A.Jornada,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CA.Fecha,CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END,CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126),CONVERT(datetime,CONVERT(VARCHAR(10),CA.Fecha,126)+'T'+CASE WHEN CA.Horario='' THEN '00:00' ELSE CA.Horario END+':00.000',126) FROM CA_Asesores AS CA 
		INNER JOIN Agente AS A ON CA.Agente10=A.Agente
		WHERE SUCURSAL=@Sucursal
		AND	YEAR(CA.Fecha) =@Anio  AND MONTH(CA.Fecha) = @Mes AND DAY(CA.Fecha)=@Dia
	END

	---------------BUSCAMOS LOS ASESORES O TECNICOS CON UNA JORNADA ASIGNADA ------------------------------
	IF @Interfaz='SePa'
	BEGIN 
		DECLARE HorarioJornada CURSOR FOR   
		SELECT  DISTINCT Jornada FROM Agente  
		WHERE Tipo IN ('Asesor')  AND Estatus = 'Alta'  AND ISNULL(Jornada,'') !=''
		AND NULLIF(Jornada,'') IS NOT NULL AND SucursalEmpresa =@Sucursal
	END ELSE
	BEGIN 
		DECLARE HorarioJornada CURSOR FOR   
		SELECT DISTINCT Jornada FROM Agente 
		WHERE Tipo IN ('Asesor','Mecanico')  AND Estatus = 'Alta' 
		AND NULLIF(Jornada,'') IS NOT NULL AND SucursalEmpresa =@Sucursal
	END
	------------------------------------------------------------------

	OPEN HorarioJornada  
	FETCH NEXT FROM HorarioJornada INTO @Jornada  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		-------------------------SE SACA EL INICIO, FIN Y DESCANSOS DE LAS HORAS DE CADA JORNADA ------------------------------------
		SELECT @Hora=null
		SELECT @Inicio=MIN(CONVERT(varchar(5), Entrada, 108)),@IFin=MIN(CONVERT(varchar(5), Salida, 108)),
		@FinI=MAX(CONVERT(varchar(5), Entrada, 108)),@Fin=MAX(CONVERT(varchar(5), Salida, 108)) 
		FROM JornadaTiempo WHERE Jornada in(@Jornada) 
		AND YEAR(Fecha) = @Anio AND MONTH(Fecha) = @Mes AND DAY(Fecha)=@Dia AND Fecha NOT IN (SELECT Fecha FROM JornadaDiaFestivo)
		-------------------------------------------------------------------------------------------------------------------------
	
		---SE BUSCA QUE LA HORA DE INICO ESTE ENEL RANGO DE INICIO Y HORA DE COMIDA
		WHILE ISNULL(@Hora,@Inicio) BETWEEN @Inicio AND @IFin--< @IFin  
		BEGIN 
			--SI LA HORA ES NULL QUIERE DECIR QUE ES EL PRIMER HORARIO Y SE LE ASIGNA EL INICIO DE CASO CONTRARIO SE LE INCREMENTA LOS MINITOS DE TIEMPO EN RECEPCION 
			IF @Hora IS NULL
				SELECT @Hora=@Inicio
			ELSE
				SELECT @Hora = CONVERT(varchar(5),DATEADD( MI ,@Recepcion,ISNULL(@Hora,@Inicio)), 108)
		
			---SI LA HORA ES MENOR A LA HORA DE COMIDA LO ASIGNA A LA VARIABLE TABLA 
			IF @Hora < @IFin --OR @Hora > @FinI
				INSERT INTO @HorariosJornadas VALUES(@Hora,@Jornada)
		END


		----SI LA HORA ES MENOR A LA HORA DE REGRESO DE COMIDA, LE ASIGNA LA HORA DE INICIO DE COMIDA
		IF @Hora<@FinI
			SET @Hora=@FinI
	

		WHILE @Hora BETWEEN @FinI AND @Fin  
		BEGIN 
		
			---INCREMENTA LOS MITUTOS DE RECEPCION A CADA HORA HASTA LLEGAR AL HORARIO DE SALIDA 
			SELECT @Hora = CONVERT(varchar(5),DATEADD( MI ,@Recepcion,ISNULL(@Hora,@FinI)), 108)
			IF @Hora < @Fin
				INSERT INTO @HorariosJornadas VALUES(@Hora,@Jornada)
		END
   
	FETCH NEXT FROM HorarioJornada INTO @Jornada  
	END  
  
	CLOSE HorarioJornada  
	DEALLOCATE HorarioJornada  


	DECLARE @HorarioAgentes TABLE
	(
	Agente  VARCHAR(10),
	Fecha	DATETIME,
	Hora	VARCHAR(5)
	)

	--- EXTRAE LOS ASESORES JUNTO CON SUS JORNADAS Y HORARIOS DISPONIBLES 
		IF @Interfaz='SePa'
		BEGIN
			DECLARE HorarioAgentes CURSOR FOR   
			SELECT  A.Jornada,A.Agente,HJ.Hora FROM Agente  AS A
			INNER JOIN @HorariosJornadas AS HJ ON A.Jornada=HJ.Jornada
			WHERE A.Tipo IN ('Asesor') AND A.Estatus = 'Alta' 
			--AND Familia = 'Recepcion'
			AND NULLIF(A.Jornada,'') IS NOT NULL AND A.SucursalEmpresa =@Sucursal;
		END
		ELSE
		BEGIN
			DECLARE HorarioAgentes CURSOR FOR   
			SELECT  A.Jornada,A.Agente,HJ.Hora FROM Agente  AS A
			INNER JOIN @HorariosJornadas AS HJ ON A.Jornada=HJ.Jornada
			WHERE A.Tipo IN ('Asesor','Mecanico') AND A.Estatus = 'Alta' 
			--AND Familia = 'Recepcion'
			AND NULLIF(A.Jornada,'') IS NOT NULL AND A.SucursalEmpresa =@Sucursal;
		END

	OPEN HorarioAgentes  
	FETCH NEXT FROM HorarioAgentes INTO @Jornada,@Agente,@Hora
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		----ASIGNA EL HORARIO POR DIA Y HORA
		SELECT	@FechaIni =CONVERT(datetime, @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')+'T'+@Hora+':00.000',126)
			,@FechaFin = DATEADD(MI,ISNULL(@Recepcion,0),@FechaIni);
		---SE BUSCA QUE NO HEXISTA UNA CITA U SERVICIO EN ESE HORARIO, DE EXISTIR SIMPLEMENTE NO CONTAMOS A ESE ASESOR PAR ESA HORA PROPUESTA Y SALTA AL SIGUIENTE
		IF NOT EXISTS(	SELECT * FROM #HorariosDisponibles WHERE Agente = @Agente AND (dtRequeridaIni BETWEEN @FechaIni AND @FechaFin 	OR dtRequeridaFin BETWEEN @FechaIni AND @FechaFin ) AND Jornada=@Jornada)
		BEGIN
			INSERT INTO @HorarioAgentes Values(@Agente,@FechaIni,@Hora)
		END
		
		FETCH NEXT FROM HorarioAgentes INTO @Jornada,@Agente,@Hora  
	END   
	CLOSE HorarioAgentes  
	DEALLOCATE HorarioAgentes  

	IF @Interfaz='SePa'
	BEGIN
		SELECT * FROM @HorarioAgentes WHERE Hora>@HoraComienzo ORDER BY Hora
	END
	ELSE
	BEGIN
		IF (SELECT TOP 1 CONVERT(VARCHAR(10),Fecha,103) FROM @HorarioAgentes)=CONVERT(VARCHAR(10),GETDATE(),103)
		BEGIN 
			INSERT INTO CA_apitoyhorarios
			SELECT  H.*, A.PersonalNombres, A.PersonalApellidoPaterno, A.tipo, @Anio, @Mes, @Dia 
			FROM @HorarioAgentes AS H 
			INNER JOIN Agente AS A ON H.agente = A.agente  WHERE H.Hora>SUBSTRING(CONVERT(VARCHAR(23),DATEADD(HOUR, @HoraMargen ,GETDATE()),126),12,5)
			ORDER BY H.Agente asc, H.Hora asc 
		END
		ELSE
		BEGIN
			INSERT INTO CA_apitoyhorarios
			SELECT  H.*, A.PersonalNombres, A.PersonalApellidoPaterno, A.tipo, @Anio, @Mes, @Dia 
			FROM @HorarioAgentes AS H 
			INNER JOIN Agente AS A ON H.agente = A.agente 
			ORDER BY H.Agente asc, H.Hora asc
		END
	END
--/*GTS|Fin|Funcion para obtener un horario de dia dependiendo de la la hora de la jornada y los minutos de recepcion*/
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
 Autor:Giovanni Trujillo Silvas
 Creación: 24/01/2021
 Descripción: Registro de un Nuevo Cliente en Intelisis
 Ejemplo: EXEC xpCA_GeneraClienteSC 'Nombres','Apellido Paterno','Apellido Materno','','',''
 Parámetros: Nombre, Apaterno,Amaterno,CP,Email,Telefono
 Resultado: ID de Cliente en Intelisis
 =============================================*/
CREATE PROCEDURE [dbo].[xpCA_GeneraClienteSC] (@Nomre VARCHAR(50),@APaterno VARCHAR(50),@AMaterno VARCHAR(50),@CP VARCHAR(10)=NULL,@Email VARCHAR(100)=NULL,@Tel VARCHAR(15)=NULL)
AS
BEGIN
SET NOCOUNT ON
DECLARE 
@Consecutivo VARCHAR(10),	
@Delegacion VARCHAR(100), 
@Colonia VARCHAR(100),
@Poblacion VARCHAR(100),
@Estado VARCHAR(100),
@Pais VARCHAR(100),
@Contacto VARCHAR(15),
@OkRef VARCHAR(255),
@Empresa VARCHAR(10)
	
	SELECT TOP 1 @Empresa = Empresa FROM Empresa

	SELECT @Delegacion=SATMunicipioDescripcion,@Colonia=SATColoniaDescripcion,@Poblacion=SATLocalidadDescripcion,@Estado=SATEstadoDescripcion,@Pais=SATPaisDescripcion FROM SATDireccionFiscal WHERE ClaveCP=@CP
	
	IF ISNULL(@Email,'') != '' 
	BEGIN 
		SET @Contacto = 'Correo Electrónico'
	END
	IF ISNULL(@Tel,'') != ''
	BEGIN 
		SET @Contacto = 'Teléfono Móvil'
	END
	IF ISNULL(@Email,'') = '' AND ISNULL(@Tel,'') = ''
	BEGIN 
		SET @Contacto = 'No Contactar'
	END
	IF ISNULL(@Email,'') = ''
	BEGIN 
		SET @Email = 'notienecorreo@hotmail.com'
	END
	IF ISNULL(@Tel,'') = ''
	BEGIN 
		SET @Tel = '5555555555'
	END
	IF ISNULL(@CP,'') = ''
	BEGIN 
		SET @CP = '00000'
	END
	IF ISNULL(@Delegacion,'') = ''
	BEGIN 
		SET @Delegacion = 'DESCONOCIDO'
	END
	IF ISNULL(@Colonia,'') = ''
	BEGIN 
		SET @Colonia = 'DESCONOCIDO'
	END
	IF ISNULL(@Poblacion,'') = ''
	BEGIN 
		SET @Poblacion=@Delegacion
	END
	IF ISNULL(@Estado,'') = ''
	BEGIN 
		SET @Estado = 'DESCONOCIDO'
	END
	IF ISNULL(@Pais,'') = ''
	BEGIN 
		SET @Pais = 'DESCONOCIDO'
	END

	EXEC spConsecutivo 'CitasSK', 0, @Consecutivo OUTPUT 

	BEGIN TRY  
		BEGIN TRANSACTION

			INSERT INTO CA_SKClientes (Cliente,Estatus,Nombre,PersonalNombres,PersonalApellidoPaterno,PersonalApellidoMaterno,Delegacion,Colonia,Poblacion,CodigoPostal,Estado,Pais,Direccion,DireccionNumero,RFC,FiscalRegimen,TelefonosLada,Telefonos,PersonalTelefonoMovil,eMail1,Contactar,ContactarDe,ContactarA,Sexo) 
			VALUES(@Consecutivo,'ALTA',UPPER(@Nomre+' '+@APaterno+' '+@AMaterno),UPPER(@Nomre),UPPER(@APaterno),UPPER(@AMaterno),@Delegacion,@Colonia,@Poblacion,@CP,@Estado,@Pais,'Conocido','#','XAXX010101000','Persona Fisica',SUBSTRING(@Tel,1,3),SUBSTRING(@Tel,4,10),SUBSTRING(@Tel,1,10),@Email,@Contacto,'09:00','19:00','Masculino')

		COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH  
		SELECT @OkRef=ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH;
	

	IF @OkRef IS NULL
	BEGIN
		SELECT @OkRef=@Consecutivo
	END

	SELECT @OkRef AS Cliente

END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
 Autor:Giovanni Trujillo Silvas
 Creación: 27/01/2021
 Descripción: Busqueda de clientes existentes en Intelisis
 Ejemplo: EXEC xpCA_BuquedaClinteSK 'Nombre','Apellido1','Apellido2' ó EXEC xpCA_BuquedaClinteSK 'Nombre Apellido1 Apellido2'
 Parámetros: Nombre, Apaterno,Amaterno
 Resultado: ID de Cliente en Intelisis y Nombre del Cliente
 =============================================*/
CREATE PROCEDURE [dbo].[xpCA_BuquedaClinteSK] (
@Nombre VARCHAR(100),
@APaterno VARCHAR(50)=NULL,
@AMaterno VARCHAR(50)= NULl )
AS
BEGIN
SET NOCOUNT ON
DECLARE
@Contador INT,
@Nombres VARCHAR(100),
@Apellido1 VARCHAR(100),
@Apellido2 VARCHAR(100)

	IF (@Nombre IS NOT NULL AND @APaterno IS NOT NULL )
		SELECT @Nombres=@Nombre, @Apellido1=@APaterno, @Apellido2=ISNULL(@AMaterno,'')
	
	IF (@Nombre IS NOT NULL AND @APaterno IS NULL )
	BEGIN
		SELECT @Contador= LEN(@Nombre) - LEN(REPLACE(@Nombre, ' ', ''))

		IF (@Contador <=3 )
		BEGIN 
			SELECT @Nombres = dbo.fnCA_DivideNombre(@Nombre,'Nombre')
			SELECT @Apellido1 = dbo.fnCA_DivideNombre(@Nombre,'Paterno')
			SELECT @Apellido2 = ISNULL(dbo.fnCA_DivideNombre(@Nombre,'Materno'),'')
		END
		IF (@Contador >3 )
		BEGIN 
			SELECT @Nombres = dbo.fnCA_DivideNombreRev(@Nombre,'Nombre')
			SELECT @Apellido1 = dbo.fnCA_DivideNombreRev(@Nombre,'Paterno')
			SELECT @Apellido2 = ISNULL(dbo.fnCA_DivideNombreRev(@Nombre,'Materno'),'')
		END
	END

	;WITH PosiblesCTE 
	AS
	(
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE PersonalNombres=@Nombres AND PersonalApellidoPaterno=@Apellido1 AND  PersonalApellidoMaterno LIKE @Apellido2+'%'
	UNION
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE Nombre = @Nombres+' '+@Apellido1+' '+@Apellido2
	UNION
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE Nombre LIKE @Nombres+' '+@Apellido1+' '+@Apellido2+'%'
	UNION
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE Nombre LIKE @Nombres+' '+@Apellido1+'% '+@Apellido2+'%'
	UNION
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE Nombre = @Apellido1+' '+@Apellido2+' '+@Nombres
	UNION
	SELECT Cliente,Nombre FROM CA_SKClientes WHERE Nombre LIKE @Apellido1+'% '+@Apellido2+'% '+@Nombres
	)
	SELECT TOP 10 * FROM PosiblesCTE

END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo 
-- Creación: 17/06/2020
-- Descripción: Creacionde Cita Servicio provemiente de Sepa
-- Parámetros: Id del registro en el log de citas a generar
-- Resultado: El folio del movimiento o una respuesta del por que no se genero
-- =============================================*/
CREATE PROCEDURE [dbo].[xpCA_GenerarCitaSePa] (@ID int)
AS
BEGIN
SET NOCOUNT ON
DECLARE
@Usuario		VARCHAR(25),
@AgenteServicio VARCHAR(25),
@Fecha			DATE,
@dtFecha		DATETIME,
@Hora			VARCHAR(5),
@HoraRecepcion	VARCHAR(5),
@Sucursal		INT, 
@Agente			VARCHAR(10),
@GenerarID		INT, 	
@OK				INT,
@OkRef			VARCHAR(255),
@Info			VARCHAR(255),
@Cliente		VARCHAR(20),
@ClienteSK		VARCHAR(20),
@SArt			VARCHAR(20),
@SModelo		VARCHAR(20),
@SPlacas		VARCHAR(20),
@SVin			VARCHAR(20),
@SDesArt		VARCHAR(100),
@ArticuloPaquete VARCHAR(100),
@Concepto		VARCHAR(20),
@IDLog			INT


	IF EXISTS (SELECT * FROM CA_log_sepa_citas WHERE ID=@ID AND Estatus='SINAFECTAR')
		SELECT @Fecha =FechaEmision, @Hora=HoraRequerida, @Sucursal=Sucursal,@Agente=Agente, @Cliente=Cliente FROM CA_log_sepa_citas WHERE ID=@ID 
	ELSE
	BEGIN
		SELECT '' AS 'Folio', 'Ya fue creada su cita anteriormente, favor de hablar a la Agencia' AS 'OkRef'
		RETURN 
	END
	BEGIN TRANSACTION
	
	
	IF EXISTS (SELECT * FROM AgendaHora WHERE Hora >=   SUBSTRING(CONVERT(VARCHAR(23),GETDATE(),126),12,5))
		SELECT TOP 1 @HoraRecepcion=Hora FROM AgendaHora WHERE Hora >=   SUBSTRING(CONVERT(VARCHAR(23),GETDATE(),126),12,5)
	ELSE
	SELECT  @HoraRecepcion= SUBSTRING(CONVERT(VARCHAR(23),GETDATE(),126),12,5)	
	
	SELECT @Usuario=UsuarioSePaCS,@AgenteServicio=AgenteServicio FROM CA_sepa_conf_correo WHERE Sucursal=@Sucursal


	IF @Cliente LIKE 'SKS%'---- CLIENTE QUE ES EXCLUSIVO PARA SEEKOP
	BEGIN
		
			--SET @ClienteSK='ITCTESK'
		/*Se buscan los parametros configurados en la ventana de Interfaces por sucursal y extrae el valor configurado*/

		SELECT @Usuario=dbo.fnCA_BusquedaClaveParametroInterfaz(@Sucursal,'SeekopCitas','Usuario')
		SELECT @AgenteServicio=dbo.fnCA_BusquedaClaveParametroInterfaz(@Sucursal,'SeekopCitas','AgenteServicio')
		SELECT @ClienteSK=dbo.fnCA_BusquedaClaveParametroInterfaz(@Sucursal,'SeekopCitas','ClienteSeekop')

		SELECT TOP 1 @SArt=ServicioArticulo,@SModelo=ServicioModelo,@SPlacas=ServicioPlacas,@SVin=ServicioSerie,@ArticuloPaquete=ISNULL(ArticuloPaquete,''),@Concepto=Concepto FROM CA_log_sepa_citas WHERE Cliente =@Cliente ORDER BY ID DESC
		
		
		SELECT TOP 1 @SDesArt=Descripcion FROM CA_SKModeloVehiculos WHERE Clave=@SArt


		/*CLIENTE EXCLUSIVO DE SEEKOP EN LA AGENCIA*/
		
		INSERT INTO Venta
		(Empresa,Mov,FechaEmision,Concepto,UEN,Moneda,TipoCambio,Usuario,Estatus,Cliente,Almacen,Agente/*,FechaRequerida,HoraRequerida*/,HoraRecepcion
		,Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,Sucursal,Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,AgenteServicio)
		--SELECT Empresa,Mov,CONVERT(VARCHAR(10),GETDATE(),126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,@HoraRecepcion,
		SELECT Empresa,Mov,CONVERT(VARCHAR(10),FechaEmision,126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,@ClienteSK,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,HoraRequerida,
		Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),'Creada desde Interfaz Seekop '+CHAR(10)+Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,@SDesArt,@AgenteServicio
		FROM CA_log_sepa_citas
		WHERE ID=@ID			
		
		SELECT @GenerarID=IDENT_CURRENT('Venta')	


		/*Buscar informacion de Cliente SK para insertar en CA_Venta*/
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CA_Venta' AND TABLE_SCHEMA = 'dbo')/*Revisa si trae la nomenclatura CA_ en la tabla para buscar tablas de la V6000 */
		BEGIN
			INSERT INTO CA_Venta(ID,SKCte,SKNombreCompleto,SKNombres,SKAPaterno,SKAMaterno,SKArtVehiculo,SKModelo,SKPlacas,SKVin)
			--INSERT INTO CA_Venta(,SKCte,SKNombreCompleto,SKNombres,SKAPaterno,SKAMaterno)
			SELECT @GenerarID,Cliente,Nombre,PersonalNombres,PersonalApellidoPaterno,PersonalApellidoMaterno,@SArt,@SModelo,@SPlacas,@SVin FROM CA_SKClientes WHERE Cliente=@Cliente
		END
		 
		

	END
	ELSE
	BEGIN
		INSERT INTO Venta
		(Empresa,Mov,FechaEmision,Concepto,UEN,Moneda,TipoCambio,Usuario,Estatus,Cliente,Almacen,Agente/*,FechaRequerida,HoraRequerida*/,HoraRecepcion
		,Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,Sucursal,Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,AgenteServicio)
		--SELECT Empresa,Mov,CONVERT(VARCHAR(10),GETDATE(),126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,@HoraRecepcion,
		SELECT Empresa,Mov,CONVERT(VARCHAR(10),FechaEmision,126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,HoraRequerida,
		Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),'Creada desde APP SePa '+CHAR(10)+Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,@AgenteServicio
		FROM CA_log_sepa_citas
		WHERE ID=@ID			
		
		SELECT @GenerarID=IDENT_CURRENT('Venta')	
	END


	/*Afectamos la CS*/
	EXEC spAfectar 'VTAS', @GenerarID, 'AFECTAR', 'Todo', NULL, @Usuario, @Estacion=1000,@EnSilencio=1,@Ok=@OK OUTPUT,@OkRef=@OkRef OUTPUT
	UPDATE Venta SET FechaEmision=@Fecha,HoraRecepcion=@Hora WHERE ID=@GenerarID
	/*Buscamos que la cita Servicio que creamos este por confirmar*/
		
	IF EXISTS(SELECT * FROM Venta WHERE ID=@GenerarID AND Estatus IN ('CONFIRMAR'))
	BEGIN
		SELECT MovID AS Folio, '' AS OkRef FROM Venta WHERE ID=@GenerarID
		UPDATE CA_log_sepa_citas SET Estatus='CONFIRMAR',Id_CitaIntelisis=@GenerarID WHERE Id=@ID

		IF @Cliente LIKE 'SKS%'
		BEGIN
			
			/*INICIO:Insertamos Informacion en el Monitor General de Interfaces*/
			/*Cabecero*/
			INSERT INTO CA_LogMovimientosInterfaz
			SELECT V.Sucursal,'SeekopCitas',V.ID,'VTAS',V.MOV,V.MOVID,GETDATE(),GETDATE(),NULL,NULL,V.Estatus,NULL, 'SeekopCitas',(SELECT TOP 1 VERSION FROM Sucursal)
			FROM Venta AS V WHERE V.ID=@GenerarID
			SELECT @IDLog=IDENT_CURRENT('CA_LogMovimientosInterfaz')
			/*Detalle*/
			INSERT INTO CA_LogMovimientosInterfazD
			SELECT @IDLog,CONVERT(VARCHAR(6),@OK),CASE WHEN @OK IS NULL THEN '1' ELSE '1' END, NULL,@OkRef
			/*INICIO:Insertamos Informacion en el Monitor General de Interfaces*/
			

			IF @ArticuloPaquete!=''
			BEGIN
				INSERT INTO VENTAD (ID,Renglon,RenglonSub,RenglonID,RenglonTipo,Almacen,UEN,Sucursal,SucursalOrigen,Cantidad,Articulo,Impuesto1,DescripcionExtra,UT,CCTiempoTab)
				SELECT @GenerarID,2048,0,1,'N',dbo.fnCA_GeneraAlmacenlValido('VTAS','Cita Servicio',dbo.fnCA_GeneraSucursalValida('VTAS','Cita Servicio',@Sucursal)),
				dbo.fnCA_GeneraUENValida('VTAS','Cita Servicio',dbo.fnCA_GeneraSucursalValida('VTAS','Cita Servicio',@Sucursal),@Concepto),
				dbo.fnCA_GeneraSucursalValida('VTAS','Cita Servicio',@Sucursal),dbo.fnCA_GeneraSucursalValida('VTAS','Cita Servicio',@Sucursal),
				ISNULL(Horas,1),Articulo,Impuesto1,Descripcion1,ISNULL(Horas,1),ISNULL(Horas,1) 
				FROM ART WHERE ARTICULO=@ArticuloPaquete
			END
		END
	END
		
	IF @OkRef='OK'
		SET @OkRef= NULL

	IF @Ok IS NOT NULL
		SELECT '' AS 'Folio', @OkRef AS 'OkRef' 


	IF @OkRef IS NULL AND @Ok IS NULL
		COMMIT TRANSACTION
	ELSE 
		ROLLBACK TRANSACTION
		
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo 
-- Creación: 12/02/2021
-- Ejemplo: EXC xpCA_CancelarCitaSePa 1 C2012
-- Descripción: Cancelacion de Citas 
-- Parámetros: Id del registro en el log de citas y folio de la Cita
-- Resultado: Estatus de cancelacion Exitosa.
-- =============================================*/
CREATE PROCEDURE [dbo].[xpCA_CancelarCitaSePa] (@ID INT,@Folio VARCHAR(20) )
AS
BEGIN
SET NOCOUNT ON
DECLARE
@IDIntelisis INT,
@Fecha			DATE,
@Hora			VARCHAR(5),
@Usuario		VARCHAR(25),
@OK				INT,
@OkRef			VARCHAR(255)

	IF EXISTS (SELECT * FROM CA_log_sepa_citas WHERE Id_sepa_Citas=@ID AND Estatus = 'CONFIRMAR')
	BEGIN
		SELECT @Fecha =FechaEmision, @Hora=HoraRequerida,@IDIntelisis=Id_CitaIntelisis FROM CA_log_sepa_citas WHERE Id_sepa_Citas=@ID 
		SELECT TOP 1 @Usuario=ISNULL(Usuario,'SOPDESA') FROM Venta WHERE ID=@IDIntelisis
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM CA_log_sepa_citas WHERE Id_sepa_Citas=@ID AND Estatus = 'CANCELADO')
		BEGIN
			SELECT 'CANCELADO' AS 'Estatus', 'Este folio ya fue Cancelado Previamente.' AS 'Respuesta', '404' AS 'Tipo'
		END
		ELSE
			SELECT '' AS 'Estatus', 'No existe ese Folio de Cita en la Agencia' AS 'Respuesta', '404' AS 'Tipo'
		RETURN 
	END
	BEGIN TRANSACTION
	
	
	/*Afectamos la CS*/
	EXEC spAfectar 'VTAS', @IDIntelisis, 'CANCELAR', 'Todo', NULL, @Usuario, @Estacion=1000,@EnSilencio=1,@Ok=@OK OUTPUT,@OkRef=@OkRef OUTPUT
	UPDATE Venta SET FechaEmision=@Fecha,HoraRecepcion=@Hora WHERE ID=@IDIntelisis
	/*Buscamos que la cita Servicio*/
		
	IF EXISTS(SELECT * FROM Venta WHERE ID=@IDIntelisis AND Estatus IN ('CANCELADO'))
	BEGIN
		UPDATE CA_log_sepa_citas SET Estatus='CANCELADO' WHERE Id_CitaIntelisis=@IDIntelisis
	END
		
	IF @OkRef='OK'
		SET @OkRef= NULL

	IF @Ok IS NOT NULL
		SELECT '' AS 'Estatus', @OkRef AS 'Respuesta' , '404' AS 'Tipo'


	IF @OkRef IS NULL AND @Ok IS NULL
	BEGIN
		COMMIT TRANSACTION
		SELECT 'CANCELADO' AS 'Estatus','Cancelacion Exitosa' AS 'Respuesta', '200' AS 'Tipo'
	END
	ELSE 
		ROLLBACK TRANSACTION

END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 12/02/2021
-- Ejemplo: EXC xpCA_ActualizacionEstatusMonitor 682293
-- Descripción: Actualizacion de CA_LogMovimientosInterfaz Actualiza los estatus en el monitor
-- Parámetros: Id del registro en el log de citas y folio de la Cita
-- Resultado: Estatus de cancelacion Exitosa.
-- =============================================*/
CREATE PROCEDURE [dbo].[xpCA_ActualizacionEstatusMonitor]( @ID INT)
AS
BEGIN
DECLARE
@Estatus VARCHAR(20),
@Mov  VARCHAR(50)

	SELECT @Mov=ISNULL(V.Mov,''),@Estatus=ISNULL(V.Estatus,'') FROM Venta AS V
	INNER JOIN CA_Venta AS CV ON V.ID=CV.ID
	WHERE SKCte LIKE 'SKS%' AND V.ID=@ID

	IF @Mov='Cita Servicio' AND @Estatus IN('CONCLUIDO','CANCELADO')
	BEGIN
		IF EXISTS(SELECT * FROM CA_LogMovimientosInterfaz WHERE IDDocumento=@ID AND Mov=@Mov AND Interfaz='SeekopCitas')
		BEGIN
			UPDATE CA_LogMovimientosInterfaz SET Estatus=@Estatus, FechaEnvio=GETDATE() WHERE IDDocumento=@ID AND Mov=@Mov AND Interfaz='SeekopCitas'
		END
	END

END
GO


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
 Autor:Giovanni Trujillo Silvas
 Creación: 25/05/2020
 Descripción:Cambio de estatus para citas en la API SePa
*/
CREATE PROCEDURE [dbo].[xpCA_ConcluirCitaSePa](@ID	INT)
AS
BEGIN
DECLARE 
@Comando	VARCHAR(MAX),
@Path		VARCHAR(MAX),
@Url		VARCHAR(800),
@Accion		VARCHAR(2),
@Json			VARCHAR(MAX),
@SQL NVARCHAR(500),
@Tabla NVARCHAR(25),
@Interfaz VARCHAR(100)= 'SePa',
@Sucursal INT


	IF	NOT EXISTS (SELECT * FROM VENTA WHERE ID=@ID  AND Mov='Cita Servicio' AND   Estatus='CONCLUIDO')
	BEGIN
		RETURN
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CA_InterfazRutaArchivo' AND TABLE_SCHEMA = 'dbo')/*Revisa si trae la nomenclatura CA_ en la tabla para buscar tablas de la V6000 */
	BEGIN
		SET @Tabla = 'CA_InterfazRutaArchivo'
	END
	ELSE
		SET @Tabla = 'InterfazRutaArchivo'

	SET @SQL = 'SELECT @Path=Ruta+Archivo FROM ' + @Tabla + ' WHERE Interfaz = '''+@Interfaz+''''

	EXEC SP_EXECUTESQL @SQL, N'@Path VARCHAR(MAX) OUT ', @Path = @Path OUT


	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CA_SepaConfigGral' AND TABLE_SCHEMA = 'dbo')/*Revisa si existen las tablas de Interfaz SEPA*/
	BEGIN 
		IF EXISTS (SELECT * FROM CA_log_sepa_citas WHERE Id_CitaIntelisis=@ID AND Cliente NOT LIKE 'SKS%'  )
			SELECT @Url=EndPointConcludeAppointments FROM CA_SepaConfigGral 
	END

	IF EXISTS (SELECT * FROM CA_log_sepa_citas WHERE Id_CitaIntelisis=@ID AND Cliente LIKE 'SKS%'  )
	BEGIN
		SELECT @Sucursal=Sucursal FROM VENTA WHERE ID=@ID  AND Mov='Cita Servicio' 
		SELECT @Url=dbo.fnCA_BusquedaClaveParametroInterfaz(@Sucursal,'SeekopCitas','EndPointConcludeAppointments')
	END

	IF EXISTS (SELECT * FROM CA_log_sepa_citas  WHERE Id_CitaIntelisis=@ID AND  Estatus='CONFIRMAR')
	BEGIN 	
		SELECT @Json = '"{' +char(34)+char(34)+ 'cliente' +char(34)+char(34)+ ': ' +char(34)+char(34)+ Cliente +char(34)+char(34)+ ','
		+char(34)+char(34)+ 'folio' +char(34)+char(34)+ ': ' +char(34)+char(34)+ CONVERT(VARCHAR(50),Id_sepa_Citas) +char(34)+char(34)+ ','
		+char(34)+char(34)+ 'empresa' +char(34)+char(34)+ ': ' +char(34)+char(34)+ Empresa +char(34)+char(34) +  '}"',
		@Accion='2' 
		FROM CA_log_sepa_citas  WHERE Id_CitaIntelisis=@ID 

		SELECT @Comando =  'master..xp_cmdshell ' + '''' 
		+@Path+' '+ @Url + ' ' +@Accion+ ' ' + @Json +''''+',no_output'
		
		EXEC (@Comando)

		UPDATE CA_log_sepa_citas SET Estatus='CONCLUIDA' WHERE Id_CitaIntelisis=@ID 
	END

END
GO