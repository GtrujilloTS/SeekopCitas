
[Forma]
Clave=CA_HorarioAgenteRecepcion
Icono=710
Modulos=(Todos)
Nombre=Horario Agente Recepcion

ListaCarpetas=lista
CarpetaPrincipal=lista
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
PosicionInicialIzquierda=125
PosicionInicialArriba=32
PosicionInicialAlturaCliente=701
PosicionInicialAncho=1040
ListaAcciones=(Lista)
[lista]
Estilo=Hoja
Clave=lista
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=CA_HorarioAgenteRecepcion
Fuente={Tahoma, 8, Negro, []}
HojaTitulos=S
HojaMostrarColumnas=S
HojaMostrarRenglones=S
HojaColoresPorEstatus=S
HojaPermiteInsertar=S
HojaPermiteEliminar=S
HojaVistaOmision=Automática
HojaColorFondo=Plata
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=(Lista)

CarpetaVisible=S
PermiteEditar=S

BusquedaRapidaControles=S
FiltroModificarEstatus=S
FiltroCambiarPeriodo=S
FiltroBuscarEn=S
FiltroFechasCambiar=S
FiltroFechasNormal=S
FiltroFechasNombre=&Fecha
BusquedaRapida=S
BusquedaInicializar=S
BusquedaRespetarControles=S
BusquedaAncho=20
BusquedaEnLinea=S
FuenteBusqueda={MS Sans Serif, 8, Negro, []}

HojaAjustarColumnas=S
[lista.CA_HorarioAgenteRecepcion.Agente]
Carpeta=lista
Clave=CA_HorarioAgenteRecepcion.Agente
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=10
ColorFondo=Blanco

[lista.CA_HorarioAgenteRecepcion.Nombre]
Carpeta=lista
Clave=CA_HorarioAgenteRecepcion.Nombre
Editar=N
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=200
ColorFondo=Blanco

[lista.CA_HorarioAgenteRecepcion.HoraInicio]
Carpeta=lista
Clave=CA_HorarioAgenteRecepcion.HoraInicio
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=5
ColorFondo=Blanco

[lista.CA_HorarioAgenteRecepcion.HoraFin]
Carpeta=lista
Clave=CA_HorarioAgenteRecepcion.HoraFin
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=5
ColorFondo=Blanco

[lista.Columnas]
ID=64
Agente=64
Nombre=324
HoraInicio=76
HoraFin=77

0=105
1=247

NombreSucursal=184
[Acciones.Guardar]
Nombre=Guardar
Boton=3
NombreEnBoton=S
NombreDesplegar=Guardar
EnBarraHerramientas=S
TipoAccion=Controles Captura
ClaveAccion=Guardar Cambios
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
NombreEnBotonX=S
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda

GuardarAntes=S
[Acciones.Eliminar]
Nombre=Eliminar
Boton=5
NombreEnBoton=S
NombreDesplegar=Eliminar
EnBarraHerramientas=S
EspacioPrevio=S
ConfirmarAntes=S
Carpeta=(Carpeta principal)
TipoAccion=Controles Captura
ClaveAccion=Registro Eliminar
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
NombreEnBotonX=S
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda


DialogoMensaje=EstaSeguroEliminar
Multiple=S
ListaAccionesMultiples=(Lista)
[Acciones.Cerrar]
Nombre=Cerrar
Boton=21
NombreEnBoton=S
NombreDesplegar=Cerrar
EnBarraHerramientas=S
EspacioPrevio=S
TipoAccion=Ventana
ClaveAccion=Cerrar
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
NombreEnBotonX=S
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda

































[Acciones.NuevoRegistro]
Nombre=NuevoRegistro
Boton=62
NombreEnBoton=S
NombreDesplegar=Nuevo Registro
EnBarraHerramientas=S
EspacioPrevio=S
Carpeta=(Carpeta principal)
TipoAccion=Controles Captura
ClaveAccion=Registro Agregar
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
NombreEnBotonX=S
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda











[Acciones.Actualizar]
Nombre=Actualizar
Boton=76
NombreEnBoton=S
NombreDesplegar=Actualizar
EnBarraHerramientas=S
EspacioPrevio=S
TipoAccion=Controles Captura
ClaveAccion=Actualizar Vista
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
NombreEnBotonX=S
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda











[Acciones.Eliminar.Eliminar]
Nombre=Eliminar
Boton=0
Carpeta=(Carpeta principal)
TipoAccion=Controles Captura
ClaveAccion=Registro Eliminar
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda

[Acciones.Eliminar.Guardar]
Nombre=Guardar
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Guardar Cambios
Activo=S
Visible=S
BarraBtnFondo=Plata
BarraBtnFuente={MS Sans Serif, 8, Negro, []}
BarraBtnTxtAlign=Izquierda
BarraBtnTxtPos=Arriba
BarraBtnSubtitFuente={MS Sans Serif, 8, Negro, []}
BarraBtnDescripFuente={MS Sans Serif, 8, Negro, []}
BarraBtnImgPos=Arriba
BarraBtnImgAlign=Izquierda
BarraBtnSubtituloAli=Izquierda
BarraBtnDescripcionAli=Izquierda
BarraBtnSubtituloPos=Arriba
BarraBtnDescripcionPos=Arriba
AccionSecTextoFuente={MS Sans Serif, 8, Negro, []}
AccionSecColor=Plata
AccionSecAli=Izquierda





[Acciones.Eliminar.ListaAccionesMultiples]
(Inicio)=Eliminar
Eliminar=Guardar
Guardar=(Fin)
















[lista.ListaEnCaptura]
(Inicio)=CA_HorarioAgenteRecepcion.Agente
CA_HorarioAgenteRecepcion.Agente=CA_HorarioAgenteRecepcion.Nombre
CA_HorarioAgenteRecepcion.Nombre=NombreSucursal
NombreSucursal=CA_HorarioAgenteRecepcion.HoraInicio
CA_HorarioAgenteRecepcion.HoraInicio=CA_HorarioAgenteRecepcion.HoraFin
CA_HorarioAgenteRecepcion.HoraFin=(Fin)

[lista.NombreSucursal]
Carpeta=lista
Clave=NombreSucursal
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=30
ColorFondo=Blanco







[Forma.ListaAcciones]
(Inicio)=Guardar
Guardar=NuevoRegistro
NuevoRegistro=Actualizar
Actualizar=Eliminar
Eliminar=Cerrar
Cerrar=(Fin)
