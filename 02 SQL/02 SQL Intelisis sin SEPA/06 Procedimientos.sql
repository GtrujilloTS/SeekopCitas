
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
 Autor:Giovanni Trujillo Silvas
 Creaci�n: 05/06/2020
 Descripci�n:Genera los horarios disponibles para los agentes por un dia espeficifico
*/
CREATE PROCEDURE [dbo].[xpCA_HorarioAgenteNombres](@Sucursal int,@Anio VARCHAR(4),@Mes VARCHAR(2),@Dia VARCHAR(2), @Interfaz VARCHAR(20))
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
				SELECT 'No hay Horario Disponible2'
				RETURN
			END
			ELSE IF (SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))<('07:00')
			BEGIN
				SELECT @HoraComienzo='07:00'
			END
			ELSE IF @FechaConMargen < (CONVERT(datetime, @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')+'T'+'07:00'+':00.000',126))--(CONVERT(VARCHAR(10),@FechaConMargen,103))=(CONVERT(VARCHAR(10),GETDATE(),103))
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
	SELECT DISTINCT Jornada FROM Agente 
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
		SELECT H.Agente,A.Nombre,H.Fecha,H.Hora FROM @HorarioAgentes AS H
		INNER JOIN Agente as A ON H.Agente=A.Agente  WHERE Hora>@HoraComienzo ORDER BY Hora
END
--/*GTS|Fin|Funcion para obtener un horario de dia dependiendo de la la hora de la jornada y los minutos de recepcion*/
END

GO
/*GTS|Ejemplo..*/
 --EXEC xpCA_HorarioAgenteNombres 1,2021,5,28,'SePa'

 /************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creaci�n: 05/06/2020
-- Ejemplo:  EXEC xpCA_HorarioAgente 3,2020,09,2,'SePa'
-- Par�metros SucursalTaller, A�o, Mes, Dia, Interfaz
-- Descripci�n:Genera los horarios disponibles para los agentes por un dia espeficifico
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
		IF @Interfaz='SePaSlot'
		BEGIN
			SELECT '','',''
			RETURN
		END
		ELSE
		BEGIN
			SELECT 'Sin Horario', '', ''
			RETURN
		END
	END

	SELECT @FechaConMargen=CONVERT(VARCHAR(23),DATEADD(HOUR, @HoraMargen ,GETDATE()),126)


	IF @FechaConMargen >(CONVERT(datetime, @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')+'T'+'19:00'+':00.000',126))/*El horario con margen es mayoy a la fecha de consulta*/
	BEGIN	
		IF @Interfaz='SePaSlot'
		BEGIN
			SELECT '','',''
			RETURN
		END
		ELSE
		BEGIN
			SELECT 'Sin Horario', '', ''
			RETURN
		END
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
			IF (SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))>('19:00') AND CONVERT(VARCHAR(10),@FechaConMargen,103)= @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')
			BEGIN
				IF @Interfaz='SePaSlot'
				BEGIN
					SELECT '','',''
					RETURN
				END
				ELSE
				BEGIN
					SELECT 'Sin Horario', '', ''
					RETURN
				END
			END
			ELSE IF (SUBSTRING(CONVERT(VARCHAR(23),@FechaConMargen,126),12,5))<('07:00')
			BEGIN
				SELECT @HoraComienzo='07:00'
			END
			ELSE IF @FechaConMargen < (CONVERT(datetime, @Anio+'-'+REPLACE(STR(@Mes,2),' ','0')+'-'+REPLACE(STR(@Dia,2),' ','0')+'T'+'07:00'+':00.000',126))--(CONVERT(VARCHAR(10),@FechaConMargen,103))=(CONVERT(VARCHAR(10),GETDATE(),103))
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
	SELECT Agente,Jornada,FechaEmision,ISNULL(HoraRecepcion,HoraRequerida) as HoraRecepcion, FechaRequerida, HoraRequerida,dtRequeridaIni,dtRequeridaFin
	FROM vwCA_CCVistaAgentes WHERE 
	YEAR(FechaRequerida) =@Anio  AND MONTH(FechaRequerida) = @Mes AND DAY(FechaRequerida)=@Dia
       AND Jornada IS NOT NULL --AND HoraRecepcion  IS NOT NULL AND LEN(ISNULL(HoraRequerida,''))>4

        INSERT INTO #HorariosDisponibles
	SELECT L.Agente,A.Jornada,L.FechaEmision,L.HoraRequerida,L.FechaEmision,L.HoraRequerida,
	CONVERT(datetime, CONVERT(varchar(10), L.FechaEmision,126) + 'T' + CASE WHEN ISDATE(L.HoraRequerida) = 1 AND CHARINDEX(':',L.HoraRequerida) > 0 THEN L.HoraRequerida ELSE '00:00' END +':00.000',126),
	DATEADD(MI,15,CONVERT(datetime, CONVERT(varchar(10), L.FechaEmision,126) + 'T' + CASE WHEN ISDATE(L.HoraRequerida) = 1 AND CHARINDEX(':',L.HoraRequerida) > 0 THEN L.HoraRequerida ELSE '00:00' END +':00.000',126))
	FROM CA_log_sepa_citas L
	INNER JOIN AGENTE A ON A.Agente = L.Agente
	WHERE YEAR(L.FechaEmision) =@Anio  AND MONTH(L.FechaEmision) = @Mes AND DAY(L.FechaEmision)=@Dia

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
	IF @Interfaz IN ('SePa','SePaSlot')
	BEGIN 
		IF EXISTS(SELECT * FROM CA_HorarioAgenteRecepcion AS H INNER JOIN AGENTE A ON H.Agente = A.Agente WHERE A.SucursalEmpresa =@Sucursal)
		BEGIN
		DECLARE HorarioJornada CURSOR FOR
			SELECT DISTINCT A.Jornada FROM Agente AS A
			INNER JOIN CA_HorarioAgenteRecepcion AS H ON A.Agente = H.Agente+''
			WHERE A.Tipo IN ('Asesor')  AND A.Estatus = 'Alta'  AND ISNULL(A.Jornada,'') !=''
			AND NULLIF(A.Jornada,'') IS NOT NULL AND A.SucursalEmpresa =@Sucursal
			AND (SELECT SucursalEmpresa FROM AGENTE WHERE AGENTE = H.Agente)=@Sucursal
		END
	ELSE
		BEGIN
			DECLARE HorarioJornada CURSOR FOR
			SELECT DISTINCT A.Jornada FROM Agente AS A
			WHERE A.Tipo IN ('Asesor')  AND A.Estatus = 'Alta'  AND ISNULL(A.Jornada,'') !=''
			AND NULLIF(A.Jornada,'') IS NOT NULL
			AND A.SucursalEmpresa =@Sucursal
		END
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
		IF @Interfaz IN ('SePa','SePaSlot')
		BEGIN
			IF EXISTS(SELECT * FROM CA_HorarioAgenteRecepcion AS H INNER JOIN AGENTE A ON H.Agente = A.Agente WHERE A.SucursalEmpresa =@Sucursal)
			BEGIN
				DECLARE HorarioAgentes CURSOR FOR
				SELECT  A.Jornada,A.Agente,HJ.Hora FROM Agente  AS A
				INNER JOIN @HorariosJornadas AS HJ ON A.Jornada=HJ.Jornada
				INNER JOIN CA_HorarioAgenteRecepcion AS H ON A.Agente = H.Agente
				WHERE A.Tipo IN ('Asesor') AND A.Estatus = 'Alta'
				--AND Familia = 'Recepcion'
				AND NULLIF(A.Jornada,'') IS NOT NULL AND A.SucursalEmpresa =@Sucursal
				AND (SELECT SucursalEmpresa FROM AGENTE WHERE AGENTE = H.Agente)=@Sucursal
			END
		ELSE
			BEGIN
			DECLARE HorarioAgentes CURSOR FOR
			SELECT  A.Jornada,A.Agente,HJ.Hora FROM Agente  AS A
			INNER JOIN @HorariosJornadas AS HJ ON A.Jornada=HJ.Jornada
			WHERE A.Tipo IN ('Asesor') AND A.Estatus = 'Alta' 
			--AND Familia = 'Recepcion'
			AND NULLIF(A.Jornada,'') IS NOT NULL AND A.SucursalEmpresa =@Sucursal;
		END
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

	IF @Interfaz IN ('SePa','SePaSlot')
	BEGIN
	IF EXISTS(SELECT * FROM CA_HorarioAgenteRecepcion AS H INNER JOIN AGENTE A ON H.Agente = A.Agente WHERE A.SucursalEmpresa =@Sucursal)
		BEGIN
			IF EXISTS(SELECT * FROM @HorarioAgentes)
			BEGIN
				SELECT H.Agente,H.Fecha,H.Hora FROM @HorarioAgentes AS H
				INNER JOIN CA_HorarioAgenteRecepcion AS HO ON H.Agente = HO.Agente
				WHERE Hora>@HoraComienzo AND HO.HoraFin > Hora
				ORDER BY Hora
			END
			ELSE
			BEGIN
				SELECT 'Sin Horario', '', ''
				RETURN
			END
		END
	ELSE
	BEGIN
		IF EXISTS(SELECT * FROM @HorarioAgentes)
		BEGIN
		SELECT * FROM @HorarioAgentes WHERE Hora>@HoraComienzo ORDER BY Hora
	END
		ELSE
		BEGIN
			SELECT 'Sin Horario', '', ''
			RETURN
		END
	END
END

--/*GTS|Fin|Funcion para obtener un horario de dia dependiendo de la la hora de la jornada y los minutos de recepcion*/
END
GO
/***************************************************************/
/********************xpCA_GeneraClienteSC***********************/
/***************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_GeneraClienteSC') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_GeneraClienteSC;
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
@Empresa VARCHAR(10),
@Contador INT,
@Nombres VARCHAR(100),
@Apellido1 VARCHAR(100),
@Apellido2 VARCHAR(100)
 
 SELECT TOP 1 @Empresa = Empresa FROM Empresa
 
 --Implementar busqueda
 IF (@Nomre IS NOT NULL AND @APaterno IS NOT NULL )
 BEGIN
  SELECT @Nombres=@Nomre, @Apellido1=@APaterno, @Apellido2=ISNULL(@AMaterno,'')
 
  CREATE table #Target(
	  Cliente VARCHAR(100)Null,
	  Nombre VARCHAR(1000) null
    );
 
 INSERT INTO #Target 
 
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
 
 SELECT @Contador=count(*) from #Target WHERE Cliente is not null
 END 


 if ISNULL(@Contador,0) >0
	begin
	SELECT TOP 10 * FROM #Target WHERE Cliente is not null
	end
 else
	begin
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
END
GO

/***************************************************************/
/********************xpCA_BuquedaClinteSK***********************/
/***************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_BuquedaClinteSK') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_BuquedaClinteSK;
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
/***************************************************************/
/********************xpCA_GenerarCitaSePa***********************/
/***************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_GenerarCitaSePa') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_GenerarCitaSePa;
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
@Concepto		VARCHAR(50),
@IDLog			INT

BEGIN TRY
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
	
	IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CA_sepa_conf_correo') and type = 'U')/*Revisamos si existe la tabla para poder sacar la Margenes de tiempo*/
	BEGIN
		SELECT @Usuario=UsuarioSePaCS,@AgenteServicio=AgenteServicio FROM CA_sepa_conf_correo WHERE Sucursal=@Sucursal
	END
	
	IF @Cliente LIKE 'SKS%'---- CLIENTE QUE ES EXCLUSIVO PARA SEEKOP
	BEGIN
		
			--SET @ClienteSK='ITCTESK'
		/*Se buscan los parametros configurados en la ventana de Interfaces por sucursal y extrae el valor configurado*/
		IF @Agente IN ('AgenteDef','')
		BEGIN
			--SELECT @Agente=dbo.fnCA_CatParametrosSucursalValor(@Sucursal,'SKAgenteDefaultSeekop')---Agregar funcion de recoleccion de parametro por interfaz
			SELECT top 1 @Agente=Agente.Agente FROM Agente 
			INNER JOIN JornadaTiempo AS JT ON JT.Jornada=Agente.Jornada
			WHERE Agente.Jornada is not null and Tipo='Asesor' AND Estatus='ALTA' and sucursalempresa=@Sucursal
			AND YEAR(Fecha) = YEAR(GETDATE()) AND MONTH(Fecha) = MONTH(GETDATE())
			ORDER BY NEWID()
		END
		
		SELECT @Usuario=dbo.fnCA_CatParametrosSucursalValor(@Sucursal,'SKUsuario')
		SELECT @AgenteServicio=dbo.fnCA_CatParametrosSucursalValor(@Sucursal,'SKAgenteCitas')
		SELECT @ClienteSK=dbo.fnCA_CatParametrosSucursalValor(@Sucursal,'SKClienteSeekop')

		SELECT TOP 1 @SArt=ServicioArticulo,@SModelo=ServicioModelo,@SPlacas=ServicioPlacas,@SVin=ServicioSerie,@ArticuloPaquete=ISNULL(ArticuloPaquete,''),@Concepto=Concepto FROM CA_log_sepa_citas WHERE Cliente =@Cliente AND ID=@ID ORDER BY ID DESC
		
		
		SELECT TOP 1 @SDesArt=Descripcion FROM CA_SKModeloVehiculos WHERE Clave=@SArt
		
		IF @Concepto != (SELECT TOP 1 Concepto FROM Venta where Mov='cita Servicio' AND Concepto LIKE 'Publico%' order by ID  desc)
		BEGIN 
			SELECT TOP 1 @Concepto=Concepto FROM Venta where Mov='cita Servicio' AND Concepto LIKE 'Publico%' order by ID  desc	
		END
		/*CLIENTE EXCLUSIVO DE SEEKOP EN LA AGENCIA*/
		--SELECT @HoraRecepcion,@Fecha,@Hora,@Sucursal,@Agente,@Cliente,@Usuario,@AgenteServicio,@ClienteSK,@SArt,@SModelo,@SPlacas,@SVin,@ArticuloPaquete,@Concepto,@SDesArt
		INSERT INTO Venta
		(Empresa,Mov,FechaEmision,Concepto,UEN,Moneda,TipoCambio,Usuario,Estatus,Cliente,Almacen,Agente,FechaRequerida,HoraRequerida,HoraRecepcion
		,Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,Sucursal,Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,AgenteServicio)
		--SELECT Empresa,Mov,CONVERT(VARCHAR(10),GETDATE(),126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,@HoraRecepcion,
		SELECT Empresa,Mov,CONVERT(VARCHAR(10),FechaEmision,126),@Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),@Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,@ClienteSK,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),@Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,HoraRequerida,
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
		(Empresa,Mov,FechaEmision,Concepto,UEN,Moneda,TipoCambio,Usuario,Estatus,Cliente,Almacen,Agente,FechaRequerida,HoraRequerida,HoraRecepcion
		,Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,Sucursal,Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,AgenteServicio)
		--SELECT Empresa,Mov,CONVERT(VARCHAR(10),GETDATE(),126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,@HoraRecepcion,
		SELECT Empresa,Mov,CONVERT(VARCHAR(10),FechaEmision,126),Concepto,dbo.fnCA_GeneraUENValida('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),Concepto),Moneda,TipoCambio,ISNULL(@Usuario,'SOPDESA'),Estatus,Cliente,dbo.fnCA_GeneraAlmacenlValido('VTAS',Mov,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal)),Agente,CONVERT(VARCHAR(10),FechaEmision,126),HoraRequerida,HoraRequerida,
		Condicion,ServicioArticulo,ServicioSerie,ServicioPlacas,ServicioKms,Ejercicio,Periodo,ListaPreciosEsp,dbo.fnCA_GeneraSucursalValida('VTAS',Mov,Sucursal),'Creada desde APP SePa '+CHAR(10)+Comentarios,SucursalOrigen,ServicioTipoOrden,ServicioTipoOperacion,ServicioModelo,ServicioNumeroEconomico,ServicioDescripcion,@AgenteServicio
		FROM CA_log_sepa_citas
		WHERE ID=@ID			
		
		SELECT @GenerarID=IDENT_CURRENT('Venta')	
	END


	/*Afectamos la CS*/
	--EXEC spAfectar 'VTAS', @GenerarID, 'AFECTAR', 'Todo', NULL, @Usuario, @Estacion=1000,@EnSilencio=1,@Ok=@OK OUTPUT,@OkRef=@OkRef OUTPUT--comentado para test de envio de borrador

	-- Se insertan los IDS en la tabla para posteriormente se recorran dentro del JOB xpCA_ConfirmarCitaSeekop y se actaulicen los datos de las tablas CA_LogMovimientosInterfaz y CA_LogMovimientosInterfazD
	INSERT INTO CA_IDSPendientesConfirmarCita (IDVenta,Estatus,FechaProcesamiento) VALUES(@GenerarID,'SINPROCESAR', GETDATE())

	UPDATE Venta SET FechaEmision=@Fecha,HoraRecepcion=@Hora WHERE ID=@GenerarID
	/*Buscamos que la cita Servicio que creamos este por confirmar*/
		
	IF EXISTS(SELECT * FROM Venta WHERE ID=@GenerarID )--AND Estatus IN ('CONFIRMAR'))
	BEGIN
		SELECT /*MovID*/ CONVERT(VARCHAR(10),@GenerarID) AS Folio, '' AS OkRef FROM Venta WHERE ID=@GenerarID
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

	--SET @OkRef=  CONVERT(VARCHAR(10),@GenerarID)--GTS CAMBIO PARA MANDAR EL ID DE LA INSERCION DE VENTA Y NO EL FOLIO GENERADO


END TRY
BEGIN CATCH
	SELECT @OK=1065, @OkRef = ERROR_MESSAGE()+' '+ CONVERT(VARCHAR(100),ERROR_LINE()) 
END CATCH 

		
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
/****************************************************************/
/********************xpCA_CancelarCitaSePa***********************/
/****************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_CancelarCitaSePa') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_CancelarCitaSePa;
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
/***************************************************************************/
/********************xpCA_ActualizacionEstatusMonitor***********************/
/***************************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_ActualizacionEstatusMonitor') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_ActualizacionEstatusMonitor;
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
/****************************************************************/
/********************xpCA_ConcluirCitaSePa***********************/
/****************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_ConcluirCitaSePa') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_ConcluirCitaSePa;
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
		SELECT @Url=dbo.fnCA_BusquedaClaveParametroInterfazEmpresa('SeekopCitas','SKEndPointConcludeAppointments')
		---dbo.fnCA_BusquedaClaveParametroInterfaz(@Sucursal,'SeekopCitas','EndPointConcludeAppointments')
		
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
/*************************************************************/
/********************xpCA_SlotsHorarios***********************/
/*************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_SlotsHorarios') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_SlotsHorarios;
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo Silvas
-- Creación: 27/06/2021
-- Ejemplo:  EXEC xpCA_SlotsHorarios
-- Parámetros 
-- Descripción:Genera los horarios disponibles para los agentes en un rango de 60 dias
*/
CREATE PROCEDURE [dbo].[xpCA_SlotsHorarios]
AS
BEGIN
DECLARE
@Dia INT =1,
@Fecha DATE,
@Day INT, 
@Month INT, 
@Year INT,
@Hora VARCHAR(5),
@Recepcion int,
@Inicio			VARCHAR(5),
@Fin			VARCHAR(5),
@Sucursal INT


CREATE TABLE #Horario (
Agente VARCHAR(20),
Fecha DATE,
Hora VARCHAR(5)
)

CREATE TABLE #CA_SlotHorarios(
	[Fecha] [date] NOT NULL,
	[DiaHabil] [bit] NOT NULL,
	[Inicio] [varchar](5) NOT NULL,
	[Fin] [varchar](5) NOT NULL,
	[Disponible] [bit] NOT NULL,
	[Sucursal] [int] NOT NULL
) 


DECLARE Horarios CURSOR FOR   
SELECT Sucursal FROM Sucursal WHERE Sucursal%2=1
OPEN Horarios  
FETCH NEXT FROM Horarios INTO @Sucursal  
WHILE @@FETCH_STATUS = 0  
BEGIN  
----------------------------------------------------------
	SET @Dia=1
	SELECT @Recepcion = CCTRecepcion FROM Sucursal WHERE Sucursal = @Sucursal 

	;WHILE  @Dia < 61
	BEGIN
		SELECT @Inicio='07:00',@Fin='19:00',@Hora = NULL
		SELECT @Fecha = DATEADD(DAY, @Dia ,GETDATE())
		SELECT @Day =DAY(@Fecha),@Month=MONTH(@Fecha),@Year=YEAR(@Fecha)
		--SELECT @Day,@Month,@Year


		DELETE FROM #Horario
		INSERT INTO #Horario
		EXEC xpCA_HorarioAgente @Sucursal,@Year,@Month,@Day,'SePaSlot'

		WHILE ISNULL(@Hora,@Inicio) BETWEEN @Inicio AND @Fin--< @IFin  
		BEGIN 
			--SI LA HORA ES NULL QUIERE DECIR QUE ES EL PRIMER HORARIO Y SE LE ASIGNA EL INICIO DE CASO CONTRARIO SE LE INCREMENTA LOS MINITOS DE TIEMPO EN RECEPCION 
			IF @Hora IS NULL
				SELECT @Hora=@Inicio
			ELSE
				SELECT @Hora = CONVERT(varchar(5),DATEADD( MI ,@Recepcion,ISNULL(@Hora,@Inicio)), 108)
		
			IF @Hora < @Fin
			BEGIN
				INSERT INTO #CA_SlotHorarios
				SELECT @Fecha,0,@Hora ,CONVERT(varchar(5),DATEADD( MI ,@Recepcion,ISNULL(@Hora,@Inicio)), 108),0,@Sucursal
			END

			--UPDATE  SlotHorarios SET DiaHabil=1  WHERE Fecha IN (SELECT DISTINCT Fecha FROM #Horario)
		END
		UPDATE #Horario SET Agente=''
	
		UPDATE SH SET SH.Disponible=1
		FROM #CA_SlotHorarios AS SH 
		INNER JOIN #Horario AS H ON H.Fecha=SH.fecha AND H.Hora=SH.Inicio
		WHERE SH.Sucursal=@Sucursal
		SELECT @Dia = @Dia+1

	END 
	--DROP TABLE #Horario
----------------------------------------------------------
FETCH NEXT FROM Horarios INTO @Sucursal  
END  
  
CLOSE Horarios  
DEALLOCATE Horarios  



UPDATE  #CA_SlotHorarios SET DiaHabil=1  WHERE Fecha IN (SELECT DISTINCT Fecha FROM #CA_SlotHorarios WHERE Disponible=1) 


TRUNCATE TABLE CA_SlotHorarios

INSERT INTO CA_SlotHorarios

SELECT * FROM #CA_SlotHorarios


END


GO
/*************************************************************************************/
/********************xpCA_DespuesAfectarAgendamientoCitasSeekop***********************/
/*************************************************************************************/

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.xpCA_DespuesAfectarAgendamientoCitasSeekop') AND TYPE = 'P')
DROP PROCEDURE dbo.xpCA_DespuesAfectarAgendamientoCitasSeekop;
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* =============================================
-- Autor:Giovanni Trujillo 
-- Creación: 17/06/2020
-- Descripción: Validaciones y acciones que se detonaran para seekop despues de afectaciones
-- Parámetros: todos los parametros del DespuesAfectar
-- =============================================*/
CREATE PROCEDURE [dbo].[xpCA_DespuesAfectarAgendamientoCitasSeekop](
@Modulo          char(5) ,      
@ID              int     ,      
@Accion          char(20),      
@Base            char(20),      
@GenerarMov      char(20),      
@Usuario         char(10),         
@Ok              int          OUTPUT,
@OkRef           varchar(255) OUTPUT)
AS 
BEGIN
DECLARE      
@Origen VARCHAR(50),
@OrigenId VARCHAR(50),
@Movimiento  VARCHAR(50),
@EstatusPedido VARCHAR(30),
@Empresa VARCHAR(10),
@Anticipos VARCHAR(1000),
@Cliente VARCHAR(50),
@Concepto VARCHAR(50)='',
@ConceptoVenta VARCHAR(50),
@Mov VARCHAR(50),
@OrigenVenta VARCHAR(50),
@OrigenIDVenta VARCHAR(50)

	SELECT TOP 1 @Empresa=Empresa FROM Empresa

	IF @Modulo='VTAS'
	BEGIN
		SELECT @Mov=Mov FROM Venta WHERE ID=@ID
		
		IF @Mov='Cita Servicio'
		BEGIN 
			--EXEC xpCA_ConcluirCitaSePa @ID
			EXEC xpCA_ActualizacionEstatusMonitor @ID
		END
	END
END

GO