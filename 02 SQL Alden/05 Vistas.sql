
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[vwCA_CCVistaAgentes]
AS
SELECT Ag.Agente, Ag.Nombre, Ag.Jornada, Ag.Tipo, 'EstadoAgente' = Ag.Estatus,
V.ID, V.Mov, V.MovID, V.Estatus, V.Situacion, V.FechaEmision, V.HoraRecepcion, V.FechaRequerida, V.HoraRequerida, V.FechaOriginal,
'dtRequeridaIni' = CASE WHEN V.Mov = 'Servicio' THEN ISNULL(V.FechaOriginal, CONVERT(datetime, CONVERT(varchar(10),V.FechaRequerida,103) + ' ' + CASE WHEN ISDATE(V.HoraRequerida) = 1 AND CHARINDEX(':',V.HoraRequerida) > 0 THEN V.HoraRequerida ELSE '00:00' END ) )
ELSE CONVERT(datetime, CONVERT(varchar(10), V.FechaEmision,103) + ' ' + CASE WHEN ISDATE(V.HoraRecepcion) = 1 AND CHARINDEX(':',V.HoraRecepcion) > 0 THEN V.HoraRecepcion ELSE '00:00' END )  END,
'dtRequeridaFin' = CASE WHEN V.Mov = 'Servicio' THEN DATEADD(MI,ISNULL(S.CCTEntrega,0), ISNULL(V.FechaOriginal, CONVERT(DATETIME, CONVERT(VARCHAR(10),V.FechaRequerida,103) + ' ' + CASE WHEN ISDATE(V.HoraRequerida) = 1 AND CHARINDEX(':',V.HoraRequerida) > 0 THEN V.HoraRequerida ELSE '00:00' END)) )
ELSE DATEADD(MI,ISNULL(S.CCTRecepcion,0), CONVERT(datetime, CONVERT(varchar(10), V.FechaEmision,103) + ' ' + CASE WHEN ISDATE(V.HoraRecepcion) = 1 AND CHARINDEX(':',V.HoraRecepcion) > 0 THEN V.HoraRecepcion ELSE '00:00' END) ) END,
S.CCTLavado,S.CCTEntrega, S.CCTRecepcion
FROM Venta V
LEFT OUTER JOIN Agente Ag ON Ag.Agente = V.Agente
LEFT OUTER JOIN Jornada J ON Ag.Jornada = J.Jornada
LEFT OUTER JOIN Sucursal S on S.Sucursal = V.Sucursal
WHERE ((V.Mov = 'Servicio' AND V.Estatus = 'PENDIENTE') OR (V.Mov = 'Cita Servicio' AND V.Estatus = 'CONFIRMAR'))
GO


/* =============================================
 Autor:Giovanni Trujillo Silvas
 Creación: 12/02/2021
 Descripción:MOSTRAR CITAS EN ESTADO CONFIRMAR 
*/
ALTER VIEW vwCA_SKCitas
AS
SELECT 'IDCita'=V.ID,V.Empresa,'Movimiento'=V.Mov,'Folio'=V.MovID,'Fecha'=V.FechaEmision,'Hora'=V.HoraRecepcion, V.Estatus, 
C.SKCTE AS 'Cliente', C.SKNombreCompleto AS  'Nombre',A.Articulo,'Vehiculo'=A.Descripcion1,'Vin'=V.ServicioSerie,'Agente'=AG.Nombre,'Comentarios' = REPLACE(CONVERT(VARCHAR(255),V.Comentarios),'Creada desde APP SePa ',''),
'Sucursal'=S.nombre,'DireccionSucursal'=S.direccion,S.longitud,S.latitud
--,V.* 
FROM Venta AS V 
INNER JOIN CA_Venta AS C ON V.ID=C.ID
INNER JOIN Art AS A ON V.ServicioArticulo=A.Articulo
INNER JOIN Agente AS AG ON V.Agente=AG.Agente
INNER JOIN vwCA_SePaBranchAddress AS S ON V.Sucursal=S.id_intelisis
WHERE V.Mov='Cita Servicio' AND V.Estatus='CONFIRMAR'
AND V.FechaEmision>=CONVERT(VARCHAR(10),GETDATE(),126)  + 'T' +'00:00:00.000'
GO
