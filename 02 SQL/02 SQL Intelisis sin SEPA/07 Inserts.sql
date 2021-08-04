/*==============================
Giovanni Trujillo Silvas
Registro para nuevo consecutivo


===============================*/
INSERT INTO Consecutivo VALUES('CitasSK','Global',0,'SKS',0,'Normal',0,0)

/*==============================
Giovanni Trujillo Silvas
Parametros a usar para Seekop
===============================*/
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SeekopCitas', N'Empresa', N'Nissan',  N'Interfaz', N'Interfaz Ciitas Seekop', N'Si la agencia tiene ativo este parametro significa que estara reviviendo y compartiendo informacion a Seekop de las citas Generadas')
GO
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKUsuario', N'Sucursal', N'Nissan', N'SeekopCitas', N'Usuario de Intelisis que detona Citas', N'Este parametro contendra al usuario que ara el proceso de afectacion en Intelisis')
GO
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKAgenteCitas', N'Sucursal', N'Nissan', N'SeekopCitas', N'Agente de Servicio configurado para citas', N'Agente de Servicio que se usa para Citas, este agente se guarda en el Campo AgenteServicio y se ve en la pestaña Informacion Adicional')
GO
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKEndPointConcludeAppointments', N'Empresa', N'Nissan', N'SeekopCitas', N'Endpoint de la Api usada para concluir citas', N'Endpoint de la Api usada para concluir citas')
GO
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKClienteSeekop', N'Sucursal', N'Nissan', N'SeekopCitas', N'Cliente Generico para citas de Seekop', N'Todas las citas Seekop usaran el cliente que se configure para cada Sucursal')
GO
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKAgenteDefaultSeekop', N'Sucursal', N'Nissan', N'SeekopCitas', N'Agente Principal de la Cita Default', N'Agente de Cita a usar de Manera Default, se pondra en la cita solo ne el caso que seekop no mande la informacion')
GO
---el siguiente parametro aplica solo para Inlosa
INSERT [dbo].[CA_CatParametros] ([Clave], [Tipo], [Marca], [Grupo], [DescCorta], [DescCompleta]) VALUES (N'SKAlmacenCitas', N'Sucursal', N'Nissan', N'SeekopCitas', N'Almacen a usar para creacion de Citas Seekop', N'Almacion especifico en el cual se estaran generando las citas de Servicio Provemientes de Seekop')
GO

--/*==============================
--Giovanni Trujillo Silvas
--Registros para catalogos de paquetes y modelos de vehiculos (SOLO PARA PRUEBAS)
--===============================*/
--INSERT INTO CA_SKPaquetes VALUES('NSERV10KM','SERVICIO DE 10 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV100KM','SERVICIO DE 100 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV105KM','SERVICIO DE 105 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV110KM','SERVICIO DE 110 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV115KM','SERVICIO DE 115 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV120KM','SERVICIO DE 120 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV125KM','SERVICIO DE 125 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV130KM','SERVICIO DE 130 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV135KM','SERVICIO DE 135 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV140KM','SERVICIO DE 140 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV145KM','SERVICIO DE 145 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV15KM','SERVICIO DE 15 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV150KM','SERVICIO DE 150 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV155KM','SERVICIO DE 155 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV160KM','SERVICIO DE 160 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV165KM','SERVICIO DE 165 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV170KM','SERVICIO DE 170 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV175KM','SERVICIO DE 175 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV180KM','SERVICIO DE 180 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV190KM','SERVICIO DE 190 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV20KM','SERVICIO DE 20 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV200KM','SERVICIO DE 200 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV210KM','SERVICIO DE 210 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV220KM','SERVICIO DE 220 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV25KM','SERVICIO DE 25 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV260KM','SERVICIO DE 260 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV','SERVICIO DE 290 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV30KM','SERVICIO DE 30 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV35KM','SERVICIO DE 35 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV40KM','SERVICIO DE 40 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV45KM','SERVICIO DE 45 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV5KM','SERVICIO DE 5 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV5MO','SERVICIO DE 5 MIL KM A MOTOR','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV50KM','SERVICIO DE 50 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV55KM','SERVICIO DE 55 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV60KM','SERVICIO DE 60 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV70KM','SERVICIO DE 70 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV75KM','SERVICIO DE 75 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV80KM','SERVICIO DE 80 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV85KM','SERVICIO DE 85 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV90KM','SERVICIO DE 90 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERV95KM','SERVICIO DE 95 MIL KM','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERVAÑO','SERVICIO DE UN AÑO','Mantenimiento')
--INSERT INTO CA_SKPaquetes VALUES('NSERVMENORI','Reparacion ','Reparacion')

--INSERT INTO CA_SKModeloVehiculos VALUES('350Z','350Z')
--INSERT INTO CA_SKModeloVehiculos VALUES('A32','MAXIMA')
--INSERT INTO CA_SKModeloVehiculos VALUES('A60','TITAN')
--INSERT INTO CA_SKModeloVehiculos VALUES('ALTIMA','ALTIMA')
--INSERT INTO CA_SKModeloVehiculos VALUES('APRIO','APRIO')
--INSERT INTO CA_SKModeloVehiculos VALUES('B-13','TSURU')
--INSERT INTO CA_SKModeloVehiculos VALUES('B14-1','SENTRA')
--INSERT INTO CA_SKModeloVehiculos VALUES('D-22','FRONTIER')
--INSERT INTO CA_SKModeloVehiculos VALUES('E-24','URVAN')
--INSERT INTO CA_SKModeloVehiculos VALUES('E-25','URVAN')
--INSERT INTO CA_SKModeloVehiculos VALUES('FRONTIER','FRONTIER')
--INSERT INTO CA_SKModeloVehiculos VALUES('FRONTIER WD22','FRONTIER 2007')
--INSERT INTO CA_SKModeloVehiculos VALUES('K-12','MICRA')
--INSERT INTO CA_SKModeloVehiculos VALUES('L30','MAXIMA')
--INSERT INTO CA_SKModeloVehiculos VALUES('L65','PLATINA')
--INSERT INTO CA_SKModeloVehiculos VALUES('N16','ALMERA')
--INSERT INTO CA_SKModeloVehiculos VALUES('OTROS','OTROS IMPORTADO')
--INSERT INTO CA_SKModeloVehiculos VALUES('PATHFINDER','PATHFINDER')
--INSERT INTO CA_SKModeloVehiculos VALUES('PICK UP','PICK UP')
--INSERT INTO CA_SKModeloVehiculos VALUES('PLATINA','PLATINAL65')
--INSERT INTO CA_SKModeloVehiculos VALUES('QUEST S','QUEST 3.5  S T/A.')
--INSERT INTO CA_SKModeloVehiculos VALUES('R50','PATHFINDER')
--INSERT INTO CA_SKModeloVehiculos VALUES('SENTRA','SENTRA')
--INSERT INTO CA_SKModeloVehiculos VALUES('T-30','XTRAIL')
--INSERT INTO CA_SKModeloVehiculos VALUES('T30-1','X-TRAIL')
--INSERT INTO CA_SKModeloVehiculos VALUES('T-60','PATHFINDER ARMADA')
--INSERT INTO CA_SKModeloVehiculos VALUES('TIIDA','TIIDAC11')
--INSERT INTO CA_SKModeloVehiculos VALUES('TITAN','TITAN')
--INSERT INTO CA_SKModeloVehiculos VALUES('TSURU','TSURU')
--INSERT INTO CA_SKModeloVehiculos VALUES('TSURU GSII T/M','TSURU GSII T/M A/A')
--INSERT INTO CA_SKModeloVehiculos VALUES('URVAN','URVAN')
--INSERT INTO CA_SKModeloVehiculos VALUES('V40-1','QUEST')
--INSERT INTO CA_SKModeloVehiculos VALUES('WD-22','FRONTIER')
--INSERT INTO CA_SKModeloVehiculos VALUES('WD22-1','X-TERRA')
--INSERT INTO CA_SKModeloVehiculos VALUES('XTRAIL','XTRAIL')
--INSERT INTO CA_SKModeloVehiculos VALUES('Y-10','TSUBAME')
--INSERT INTO CA_SKModeloVehiculos VALUES('Y10-1','TSUBAME')
--INSERT INTO CA_SKModeloVehiculos VALUES('Y33-1','INFINITI')
--INSERT INTO CA_SKModeloVehiculos VALUES('Z32-1','300 ZX')
--INSERT INTO CA_SKModeloVehiculos VALUES('Z50','MURANO')
--INSERT INTO CA_SKModeloVehiculos VALUES('OTROS','OTROS')
