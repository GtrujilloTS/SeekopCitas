from rest_framework import serializers
from .models import SKPaquetes,SKModeloVehiculos

class SKPaquetes_Serializer(serializers.ModelSerializer):
    class Meta:
        model =  SKPaquetes
        fields =['Clave','Descripcion','Grupo']

class SKModeloVehiculos_Serializer(serializers.ModelSerializer):
    class Meta:
        model =  SKModeloVehiculos
        fields =['Clave','Descripcion']

