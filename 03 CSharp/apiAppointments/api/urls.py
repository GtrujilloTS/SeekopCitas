from django.urls import path, include
from . import views
from rest_framework import routers
from .views import createUser,createtkn,updatetkn,Vehiculos,Calendario,HorarioAgente,SaveCites,CitasConfirmadas,ConcludeAppointments,Auth,TipoServicio,CategoriasServicio,Crearcliente,SearchCustumer,Vehiculoscliente,CitasFechas,CitasCancelar

router = routers.DefaultRouter()


urlpatterns = [
    path('', include(router.urls)),
    path('Auth/',Auth.as_view(),name='Auth'),
    path('createUser/',createUser.as_view(),name='createUser'),
    path('createtkn/', createtkn.as_view(), name='createtkn'),
    path('updatetkn/', updatetkn.as_view(), name='updatetkn'),
    path('vehiculos/', Vehiculos.as_view(), name='vehiculos'),
    path('vehiculoscliente/', Vehiculoscliente.as_view(), name='vehiculoscliente'),
    path('calendario/', Calendario.as_view(), name='calendario'),
    path('horario/', HorarioAgente.as_view(), name='horario'),
    path('creaCitas/', SaveCites.as_view(), name='creaCitas'),
    path('citasConfirmadas/', CitasConfirmadas.as_view(), name='citasConfirmadas'),
    path('concludeAppointments/', ConcludeAppointments.as_view(), name='concludeAppointments'),
    path('tipos/', TipoServicio.as_view(), name='tipos'),
    path('categorias/', CategoriasServicio.as_view(), name='categorias'),
    path('crearcliente/', Crearcliente.as_view(), name='crearcliente'),
    path('cliente/', SearchCustumer.as_view(), name='cliente'),
    path('CitasFechas/', CitasFechas.as_view(), name='CitasFechas'),
    path('cancelarCita/', CitasCancelar.as_view(), name='cancelarCita')
]