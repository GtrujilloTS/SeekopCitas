from rest_framework import viewsets,status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_api_key.permissions import HasAPIKey
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from django.conf import settings
from django.shortcuts import render, HttpResponse
from django.db.models import F,Q
from django.core.mail import EmailMultiAlternatives
from django.db import connections
from datetime import datetime
import json
import base64
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from .models import Cliente as datacliente
from .serializers import SKPaquetes_Serializer,SKModeloVehiculos_Serializer
from .models import user,sepa_branch,Sucursal,LogIntelisis,SePaVehiculos,CalendarioJornadas,sepa_Citas,log_sepa_Citas,SePaCitasConfirmadas,SepaConfigSuc,SepaDevice,SepaConnection,sepa_log,AuthBackend,SKPaquetes,SKModeloVehiculos,SKCitasConfirmadas


# Function for tracking changes or queries
# Params cliente,branch,tipo_movimiento,tabla,device,connection,post,url,sql
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
def loggeractions(cliente,branch,tipo_movimiento,tabla,device,connection,post,url,sql):
    poststr = str(post)
    sqlstr = json.dumps(sql)
    historico = sepa_log.objects.create(id_branch_id = branch,id_usuario_id = cliente)
    historico.tipo_movimiento = tipo_movimiento
    historico.tabla = tabla
    historico.url = url
    historico.post = poststr
    historico.sql_query = sqlstr
    if(device!=None and device!="None"):
        isDevice = "Si" if device["isDevice"] else "No"
        if SepaDevice.objects.filter(isDevice=isDevice,brand=device["brand"],manufacturer=device["manufacturer"],modelName=device["modelName"],modelId=device["modelId"],designName=device["designName"],productName=device["productName"],deviceYearClass=device["deviceYearClass"],totalMemory=device["totalMemory"],supportedCpuArchitectures=device["supportedCpuArchitectures"][0],osName=device["osName"],osBuildId=device["osBuildId"],osInternalBuildId=device["osInternalBuildId"],osBuildFingerprint=device["osBuildFingerprint"],platformApiLevel=device["platformApiLevel"],deviceName=device["deviceName"]).exists():
            objdevice = SepaDevice.objects.filter(isDevice=isDevice,brand=device["brand"],manufacturer=device["manufacturer"],modelName=device["modelName"],modelId=device["modelId"],designName=device["designName"],productName=device["productName"],deviceYearClass=device["deviceYearClass"],totalMemory=device["totalMemory"],supportedCpuArchitectures=device["supportedCpuArchitectures"][0],osName=device["osName"],osBuildId=device["osBuildId"],osInternalBuildId=device["osInternalBuildId"],osBuildFingerprint=device["osBuildFingerprint"],platformApiLevel=device["platformApiLevel"],deviceName=device["deviceName"])[0]
        else:
            objdevice = SepaDevice.objects.create()
            objdevice.isDevice = isDevice
            objdevice.brand = device["brand"]
            objdevice.manufacturer = device["manufacturer"]
            objdevice.modelName = device["modelName"]
            objdevice.modelId = device["modelId"]
            objdevice.designName = device["designName"]
            objdevice.productName = device["productName"]
            objdevice.deviceYearClass = device["deviceYearClass"]
            objdevice.totalMemory = device["totalMemory"]
            objdevice.supportedCpuArchitectures = device["supportedCpuArchitectures"][0]
            objdevice.osName = device["osName"]
            objdevice.osBuildId = device["osBuildId"]
            objdevice.osInternalBuildId = device["osInternalBuildId"]
            objdevice.osBuildFingerprint = device["osBuildFingerprint"]
            objdevice.platformApiLevel = device["platformApiLevel"]
            objdevice.deviceName = device["deviceName"]
            objdevice.save()
        historico.idDevice = objdevice.Id
    if(connection!=None and connection!="None"):
        if "strength" in connection["details"]:
            strength = connection["details"]["strength"]
        else:
            strength = ""
        if "ssid" in connection["details"]:
            ssid = connection["details"]["ssid"]
        else:
            ssid = ""
        if "ipAddress" in connection["details"]:
            ipAddress = connection["details"]["ipAddress"]
        else:
            ipAddress = ""
        if "subnet" in connection["details"]:
            subnet = connection["details"]["subnet"]
        else:
            subnet = ""
        wifiisConnectionExpensive = "Si" if connection["details"]["isConnectionExpensive"] else "No"
        if(connection["type"]=="wifi"):
            if SepaConnection.objects.filter(connectiontype=connection["type"],detailswifiisConnectionExpensive=wifiisConnectionExpensive,detailswifissid=ssid,detailswifistrength=strength,detailswifiipAddress=ipAddress,detailswifisubnet=subnet).exists():
                objconnection = SepaConnection.objects.filter(connectiontype=connection["type"],detailswifiisConnectionExpensive=wifiisConnectionExpensive,detailswifissid=ssid,detailswifistrength=strength,detailswifiipAddress=ipAddress,detailswifisubnet=subnet)[0]
            else:
                objconnection = SepaConnection.objects.create()
                objconnection.connectiontype = connection["type"]
                objconnection.detailswifissid = ssid
                objconnection.detailswifistrength = strength
                objconnection.detailswifiipAddress = ipAddress
                objconnection.detailswifisubnet = subnet
                objconnection.detailswifiisConnectionExpensive = wifiisConnectionExpensive
                objconnection.save()
        else:
            objconnection = SepaConnection.objects.create()
            objconnection.connectiontype = connection["type"]
            objconnection.save()
        historico.idConnection = objconnection.Id
    historico.save()

# Function for authenticate the user
# Params username,password,idDistribuidor
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class Auth(APIView):
    permission_classes = [HasAPIKey]
    def post(self, request, *args, **kwargs):
        response1 = AuthBackend.authenticate(self,request, *args, **kwargs)
        print(response1)
        try:
            token = Token.objects.get(key=response1['token'])
            usuario = user.objects.get(id=token.user_id)
            return Response({'token': token.key, 'IdDistribuidor': usuario.id_branch_id,'status':response1['status']})
            #return Response(response)
        except Token.DoesNotExist:
            return Response({'token': '', 'IdDistribuidor': '','status':response1['status']})

# Function for get cars by model
# Params idsucursal (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class Vehiculos(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        preformatrequest=base64.b64decode(request.body)
        preformatrequestdecode=preformatrequest.decode("ascii")
        preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
        formatrequest = json.loads(preformatrequestdecode)
        try:
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            device=None
            connection=None

            rows = SKModeloVehiculos.objects.using(empresa.empresa_intelisis)
            querySet=SKModeloVehiculos_Serializer(rows,many=True)
            response = {'data':querySet.data,'status':'0','message':'OK'}
            
            return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener vehículos: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for get client cars
# Params cliente (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class Vehiculoscliente(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        preformatrequest=base64.b64decode(request.body)
        preformatrequestdecode=preformatrequest.decode("ascii")
        preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
        formatrequest = json.loads(preformatrequestdecode)
        try:
            users = user.objects.get(id=formatrequest["cliente"])
        except user.DoesNotExist:
            response = {'data':{},'status':'1','message':'Cliente no encontrado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        device=None
        connection=None
        try:
            empresa = sepa_branch.objects.get(id=users.id_branch_id)
            querySet=SePaVehiculos.objects.using(empresa.empresa_intelisis).filter(Cliente=users.id_intelisis).values('ServicioSerie','ArtDescripcion','ServicioPlacas','ServicioModelo')
            response = {'data':querySet,'status':'0','message':'OK'}
            loggeractions(formatrequest["cliente"],users.id_branch_id,"Consultar vehiculos","SePaVehiculos",device,connection,formatrequest,"vehiculos/",{'data':"notjson",'message':'OK'})
            return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            loggeractions(formatrequest["cliente"],users.id_branch_id,"Consultar vehiculos","SePaVehiculos",device,connection,formatrequest,"vehiculos/",{'data':'','message': 'Sin Vehiculos: '+ str(e)})
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener vehiculos: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for get service categories
# Params idsucursal (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class CategoriasServicio(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            device=None
            connection=None
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                cursor.execute("select distinct Grupo AS Categoria from CA_SKPaquetes")
                row = dictfetchall(cursor)

            response = {'data':row,'status':'0','message':'OK'}
            return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener tipos de servicio: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for get service type
# Params idsucursal (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class TipoServicio(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            device=None
            connection=None

            rows = SKPaquetes.objects.using(empresa.empresa_intelisis)
            querySet=SKPaquetes_Serializer(rows,many=True)
            response = {'data':querySet.data,'status':'0','message':'OK'}
            
            return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener los tipos de servicio: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for create client
# Params idsucursal, nombre, apaterno,amaterno,cp,Email,Telefono (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class Crearcliente(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        
        preformatrequest=base64.b64decode(request.body)
        preformatrequestdecode=preformatrequest.decode("ascii")
        preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
        formatrequest = json.loads(preformatrequestdecode)
        headtok= request.META['HTTP_AUTHORIZATION'][6:46]
        nombre=formatrequest["nombre"]
        apaterno=formatrequest["apaterno"]
        amaterno=formatrequest["amaterno"]
        cp=''
        email=''
        telefono=''
        if "cp" in formatrequest:
            cp=formatrequest["cp"]
        if "email" in formatrequest:
            email=formatrequest["email"]
        if "telefono" in formatrequest:
            telefono=formatrequest["telefono"]
        device=None
        connection=None
        
        try:
            token = Token.objects.get(key=headtok)
        except Token.DoesNotExist:
            response = {'data':{},'status':'2','message':'Token no autorizado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        try:
            users = user.objects.get(id=token.user_id)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                cursor.execute("xpCA_GeneraClienteSC %s,%s,%s,%s,%s,%s",[nombre,apaterno,amaterno,cp,email,telefono])
                row = dictfetchall(cursor)
                cursor.close()
            response = {'data':row,'status':'0','message':'OK'}
            loggeractions(token.user_id,users.id_branch_id,"Crear cliente","Crearcliente",device,connection,formatrequest,"Crearcliente/",{'data':"notjson",'message':'OK'})
            return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            loggeractions(token.user_id,users.id_branch_id,"Crear cliente","Crearcliente",device,connection,formatrequest,"Crearcliente/",{'data':'','message': 'Error al crear el cliente: '+ str(e)})
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo crear cliente: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for 
# Params 
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: gtrujillo@intelisis.com
# date: 19/01/2021
class SearchCustumer(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        headtok= request.META['HTTP_AUTHORIZATION'][6:46]
        try:
            token = Token.objects.get(key=headtok)
        except Token.DoesNotExist:
            response = {'data':{},'status':'1','message':'Usuario no encontrado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            device=None
            connection=None
            nombre=formatrequest["nombre"]
            apaterno=''
            amaterno=''
                
            if "apaterno" in formatrequest:
                apaterno=formatrequest["apaterno"]
            if "amaterno" in formatrequest:
                amaterno=formatrequest["amaterno"]
            users = user.objects.get(id=token.user_id)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                if "apaterno" not in formatrequest or  "amaterno" not in formatrequest:
                    cursor.execute("xpCA_BuquedaClinteSK %s",[nombre])
                else:
                    cursor.execute("xpCA_BuquedaClinteSK %s,%s,%s",[nombre,apaterno,amaterno])
                row = dictfetchall(cursor)
                result = {'data':row,'status':'0','message':'OK'}
                return Response(result,status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener cliente: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for get aviable  calendar for appointment
# Params cliente,mes,anio,device,connection
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 20/01/2021
class Calendario(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        headtok= request.META['HTTP_AUTHORIZATION'][6:46]
        device=None
        connection=None
        try:
            token = Token.objects.get(key=headtok)
            users = user.objects.get(id=token.user_id)
        except Token.DoesNotExist:
            response = {'data':{},'status':'1','message':'Token no autorizado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)

            calendario=CalendarioJornadas.objects.using(empresa.empresa_intelisis).filter(Anio=formatrequest["anio"], Mes=formatrequest["mes"],Sucursal=(empresa.id_intelisis+1)).values('Fecha')
            result = {'data':calendario,'status':'0','message':'OK'}
            loggeractions(users.id,users.id_branch_id,"Consultar dias citas","CalendarioJornadas",device,connection,formatrequest,"calendario/",{'data':"notjson",'message':'OK'})
            return Response(result,status=status.HTTP_200_OK)
        except Exception as e:
            loggeractions(users.id,users.id_branch_id,"Consultar dias citas","CalendarioJornadas",device,connection,request.data,"calendario/",{'data':'','message': 'Sin horarios: '+ str(e)})
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener horarios: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for format information for class Calendario
# Params cursor query
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: gtrujillo@intelisis.com  (https://github.com/Angelin20)
# date: 20/01/2021
def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

# Function for get schedules for appointment
# Params cliente,anio,mes,dia (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 19/01/2021
class HorarioAgente(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        headtok= request.META['HTTP_AUTHORIZATION'][6:46]
        device=None
        connection=None
        try:
            token = Token.objects.get(key=headtok)
            users = user.objects.get(id=token.user_id)
        except Token.DoesNotExist:
            response = {'data':{},'status':'1','message':'Token no autorizado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                cursor.execute("xpCA_HorarioAgente %s,%s,%s,%s,%s",[(empresa.id_intelisis+1),formatrequest["anio"],formatrequest["mes"],formatrequest["dia"],'SePa'])
                result = {'data':dictfetchall(cursor),'status':'0','message':'OK'}
            loggeractions(users.id,users.id_branch_id,"Consultar horario disponible","HorarioDisponible",device,connection,formatrequest,"horario/",{'data':'notjson','message':'OK'})
            return Response(result)
        except Exception as e:
            loggeractions(users.id,users.id_branch_id,"Consultar horario disponible","HorarioDisponible",device,connection,request.data,"horario/",{'data':'','message': 'Sin horarios: '+ str(e)})
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener horarios: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for save appointments
# Params cliente, idsucursal, dia, agente, hora, tipo, observaciones, Km, vehiculo, servicioserie, servicioplacas, serviciomodelo, articulopaquete (base64 encoding)
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#81a7972d-947b-4e39-a068-4e7af921d279
# by: abalderas@intelisis.com , gtrujillo@intelisis.com  (https://github.com/Angelin20)
# date: 19/01/2021
class SaveCites(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        headtok= request.META['HTTP_AUTHORIZATION'][6:46]
        device=None
        connection=None
        preformatrequest=base64.b64decode(request.body)
        preformatrequestdecode=preformatrequest.decode("ascii")
        preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
        formatrequest = json.loads(preformatrequestdecode)
        try:
            token = Token.objects.get(key=headtok)
            users = user.objects.get(id=token.user_id)
        except Token.DoesNotExist:
            response = {'data':{},'status':'1','message':'Token no autorizado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
            empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
        else:
            response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
            return Response(response,status=status.HTTP_400_BAD_REQUEST)
        fecha=datetime.strptime(formatrequest["dia"]+'00:00:00', '%d/%m/%Y%H:%M:%S')
        if "IdBorrador" in formatrequest:
            #Actualizacion de Datos
            try:
                cita = sepa_Citas.objects.get(Id=formatrequest["IdBorrador"])
                cita.FechaEmision = fecha
                cita.Agente = formatrequest["agente"]
                cita.HoraRequerida = formatrequest["hora"]
                cita.ServicioArticulo = formatrequest["vehiculo"]
                cita.ServicioSerie = formatrequest["servicioserie"]
                cita.ServicioPlacas = formatrequest["servicioplacas"]
                cita.ServicioKms = formatrequest["Km"]
                cita.ServicioNumeroEconomico = 'hh'#servicio.ServicioNumeroEconomico
                cita.ServicioTipoOperacion = formatrequest["tipo"]
                cita.ServicioModelo = formatrequest["serviciomodelo"]
                cita.Ejercicio = fecha.year
                cita.Periodo = fecha.month
                cita.Sucursal = int(empresa.id_intelisis)+1
                cita.Comentarios = formatrequest["observaciones"]
                cita.SucursalOrigen = int(empresa.id_intelisis)+1
                cita.save()
                if cita.IdlogIntelisis:
                    log = log_sepa_Citas.objects.using(empresa.empresa_intelisis).get(Id=cita.IdlogIntelisis)
                    log.Empresa = empresa.empresa_intelisis
                    log.FechaEmision = fecha
                    log.Cliente = formatrequest["cliente"]
                    log.Agente = formatrequest["agente"]
                    log.HoraRequerida = formatrequest["hora"]
                    log.ServicioArticulo = formatrequest["vehiculo"]
                    log.ServicioSerie = formatrequest["servicioserie"]
                    log.ServicioPlacas = formatrequest["servicioplacas"]
                    log.ServicioKms = formatrequest["Km"]
                    log.ServicioTipoOperacion = formatrequest["tipo"]
                    log.ServicioModelo = formatrequest["serviciomodelo"]
                    log.Ejercicio = fecha.year
                    log.Periodo = fecha.month
                    log.Sucursal = int(empresa.id_intelisis)+1
                    log.Comentarios = formatrequest["observaciones"]
                    log.SucursalOrigen = int(empresa.id_intelisis)+1
                    log.ArticuloPaquete = formatrequest["articulopaquete"]
                    log.Id_sepa_Citas =cita.Id
                    log.save()
                else:
                    log = log_sepa_Citas.objects.using(empresa.empresa_intelisis).create()
                    log.Empresa = empresa.empresa_intelisis
                    log.FechaEmision = fecha
                    log.Estatus ='SINAFECTAR'
                    log.Cliente = formatrequest["cliente"]
                    log.Agente = formatrequest["agente"]
                    log.HoraRequerida = formatrequest["hora"]
                    log.ServicioArticulo = formatrequest["vehiculo"]
                    log.ServicioSerie = formatrequest["servicioserie"]
                    log.ServicioPlacas = formatrequest["servicioplacas"]
                    log.ServicioKms = formatrequest["Km"]
                    log.ServicioTipoOperacion = formatrequest["tipo"]
                    log.ServicioModelo = formatrequest["serviciomodelo"]
                    log.Ejercicio = fecha.year
                    log.Periodo = fecha.month
                    log.Sucursal = int(empresa.id_intelisis)+1
                    log.Comentarios = formatrequest["observaciones"]
                    log.SucursalOrigen = int(empresa.id_intelisis)+1
                    log.ArticuloPaquete = formatrequest["articulopaquete"]
                    log.Id_sepa_Citas = cita.Id
                    log.save()
            except Exception as e:
                loggeractions(users.id,users.id_branch_id,"Guardar citas","sepa_Citas",device,connection,formatrequest,"saveCites/",{'data':{"IdBorrador":cita.Id},'message':'Por el momentos su cita no puede ser agendada, intente mas tarde.'+ str(e)})
                return Response({'data':{"IdBorrador":cita.Id},'status':'2','message':'Por el momentos su cita no puede ser agendada, intente mas tarde.'+ str(e)} )
        else:
            #Creacion de registros
            try:
                cita = sepa_Citas.objects.create()
                cita.UsuarioSepa = users.id
                cita.Empresa = empresa.empresa_intelisis
                cita.FechaEmision = fecha
                cita.Estatus ='SINAFECTAR'
                cita.Cliente = formatrequest["cliente"]
                cita.Agente = formatrequest["agente"]
                cita.HoraRequerida = formatrequest["hora"]
                cita.ServicioArticulo = formatrequest["vehiculo"]
                cita.ServicioSerie = formatrequest["servicioserie"]
                cita.ServicioPlacas = formatrequest["servicioplacas"]
                cita.ServicioKms = formatrequest["Km"]
                cita.ServicioTipoOperacion = formatrequest["tipo"]
                cita.ServicioModelo = formatrequest["serviciomodelo"]
                cita.Ejercicio = fecha.year
                cita.Periodo = fecha.month
                cita.Sucursal = int(empresa.id_intelisis)+1
                cita.Comentarios = formatrequest["observaciones"]
                cita.SucursalOrigen = int(empresa.id_intelisis)+1
                cita.ArticuloPaquete = formatrequest["articulopaquete"]
                cita.save()

                log = log_sepa_Citas.objects.using(empresa.empresa_intelisis).create()
                log.Empresa = empresa.empresa_intelisis
                log.FechaEmision = fecha
                log.Estatus ='SINAFECTAR'
                log.Cliente = formatrequest["cliente"]
                log.Agente = formatrequest["agente"]
                log.HoraRequerida = formatrequest["hora"]
                log.ServicioArticulo = formatrequest["vehiculo"]
                log.ServicioSerie = formatrequest["servicioserie"]
                log.ServicioPlacas = formatrequest["servicioplacas"]
                log.ServicioKms = formatrequest["Km"]
                log.ServicioTipoOperacion = formatrequest["tipo"]
                log.ServicioModelo = formatrequest["serviciomodelo"]
                log.Ejercicio = fecha.year
                log.Periodo = fecha.month
                log.Sucursal = int(empresa.id_intelisis)+1
                log.Comentarios = formatrequest["observaciones"]
                log.SucursalOrigen = int(empresa.id_intelisis)+1
                log.ArticuloPaquete = formatrequest["articulopaquete"]
                log.Id_sepa_Citas = cita.Id
                log.save()
            except Exception as e:
                loggeractions(users.id,users.id_branch_id,"Guardar citas","sepa_Citas",device,connection,formatrequest,"saveCites/",{'data':{"IdBorrador":cita.Id},'message':'Por el momento su cita no puede ser agendada, intente mas tarde.'+ str(e)})
                return Response({'data':{"IdBorrador":cita.Id},'status':'2','message':'Por el momento su cita no puede ser agendada, intente mas tarde.'+ str(e)} )
        #mandamos afectar lo que tengamos en Borrador de intelisis   
        if log.Id:
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                cursor.execute("xpCA_GenerarCitaSePa %s",[log.Id])
                row = {'data':dictfetchall(cursor),'status':'0','message':'OK'}
            if row['data'][0]["Folio"]:
                cs = sepa_Citas.objects.get(Id=cita.Id)
                cs.Estatus ='CONFIRMAR'
                cs.MovId=row['data'][0]["Folio"]
                cs.IdlogIntelisis = log.Id
                cs.save()  
                row['data'][0]["IdlogIntelisis"]=cita.Id
                #if formatrequest["mail"]==True:
                #    sendMailConfirmation(cita.Id,empresa.empresa_intelisis)
                loggeractions(users.id,users.id_branch_id,"Guardar citas","sepa_Citas",device,connection,formatrequest,"saveCites/",row)
                return Response(row,status=status.HTTP_200_OK) 
            else:
                loggeractions(users.id,users.id_branch_id,"Guardar citas","sepa_Citas",device,connection,formatrequest,"saveCites/",{'data':{"IdBorrador":cita.Id},'message':'Valor Incorrecto '+str(row['data'][0]["OkRef"])})
                return Response({'data':{"IdBorrador":cita.Id},'status':'2','message':'Valor Incorrecto '+str(row['data'][0]["OkRef"])},status=status.HTTP_400_BAD_REQUEST)
        else:#fallo el guardado del Borrador en Intelisis
            loggeractions(users.id,users.id_branch_id,"Guardar citas","sepa_Citas",device,connection,formatrequest,"saveCites/",{'data':{"IdBorrador":cita.Id},'message':'Por el momento su cita no puede ser agendada, intente mas tarde.'})
            return Response({'data':{"IdBorrador":cita.Id},'status':'2','message':'Por el momento su cita no puede ser agendada, intente mas tarde.'},status=status.HTTP_400_BAD_REQUEST )

# Function for get client appointments
# Params diadesde,diahasta,horadesde,horahasta
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class CitasFechas(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST'])
    def post(self, request, format=None):
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            FechaD=formatrequest["FechaD"]
            FechaA=formatrequest["FechaA"]

            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'1','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            if SKCitasConfirmadas.objects.using(empresa.empresa_intelisis).filter(Fecha__gte=FechaD, Fecha__lte=FechaA).exists():
                
                querySet=SKCitasConfirmadas.objects.using(empresa.empresa_intelisis).filter(Fecha__gte=FechaD, Fecha__lte=FechaA).values('IDCita','Empresa','Movimiento','Folio','Fecha','Hora','Estatus','Cliente','Nombre','Articulo','Vehiculo','Vin','Agente','Comentarios','Sucursal','DireccionSucursal','latitud','longitud').order_by('-Fecha')[:60]
                
                response = {
                    'data':querySet,
                    'status':'0',
                    'message':'OK'
                }
                return Response(response,status=status.HTTP_200_OK)
            else:
                response = {
                    'data':{},
                    'status':'0',
                    'message':'Sin citas que presentar'
                }
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener citas: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for set cancel an appointment
# Params diadesde,diahasta,horadesde,horahasta
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class CitasCancelar(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        try:
            preformatrequest=base64.b64decode(request.body)
            preformatrequestdecode=preformatrequest.decode("ascii")
            preformatrequestdecode = preformatrequestdecode.replace("\'", "\"")
            formatrequest = json.loads(preformatrequestdecode)
            if sepa_branch.objects.filter(id=formatrequest["idsucursal"]).exists():
                empresa = sepa_branch.objects.get(id=formatrequest["idsucursal"])
            else:
                response = {'data':{},'status':'3','message':'Distribuidor no encontrado'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            device=None
            connection=None
            if sepa_Citas.objects.filter(MovId=formatrequest["folio"]).exists():
                cita=sepa_Citas.objects.filter(MovId=formatrequest["folio"]).values('Id')[0]
            else:
                response = {'data':{},'status':'1','message':'Cita no encontrada'}
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
            with connections[empresa.empresa_intelisis].cursor() as cursor:
                cursor.execute("xpCA_CancelarCitaSePa %s,%s",[cita['Id'],formatrequest["folio"]])
                row = dictfetchall(cursor)
            if(row[0]['Tipo']=="404"):
                response = {'data':row[0],'status':'1','message':row[0]['Respuesta']}
                return Response(response,status=status.HTTP_200_OK)
            else:
                citaorigen=sepa_Citas.objects.get(Id=cita["Id"])
                citaorigen.Estatus=row[0]['Estatus']
                citaorigen.save()
                response = {'data':row[0],'status':'0','message':'OK'}
                return Response(response,status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo cancelar cita: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

# Function for get client appointments
# Params cliente,device,connection
# Documentation: https://documenter.getpostman.com/view/8589169/TVzUCGEb#d4c84465-b1f6-4379-bf91-f5808b99eba9
# by: abalderas@intelisis.com  (https://github.com/Angelin20)
# date: 18/01/2021
class CitasConfirmadas(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST'])
    def post(self, request, format=None):
        clientes=request.data["cliente"]
        device=request.data["device"]
        connection=request.data["connection"]
        try:
            users = user.objects.get(id=clientes)
        except user.DoesNotExist:
            result = {'data':{},'status':'1','message':'Cliente no encontrado'}
            return Response(result,status=status.HTTP_400_BAD_REQUEST)
        try:
            empresa = sepa_branch.objects.get(id=users.id_branch_id)
            if SePaCitasConfirmadas.objects.using(empresa.empresa_intelisis).filter(Cliente=users.id_intelisis).exists():
                #rows
                querySet=SePaCitasConfirmadas.objects.using(empresa.empresa_intelisis).filter(Cliente=users.id_intelisis).values('IDCita','Empresa','Movimiento','Folio','Fecha','Hora','Estatus','Cliente','Nombre','Articulo','Vehiculo','Vin','Agente','Comentarios','Sucursal','DireccionSucursal','latitud','longitud').order_by('Fecha')[:10]
                
                response = {
                    'data':querySet,
                    'status':'0',
                    'message':'OK'
                }
                loggeractions(clientes,users.id_branch_id,"Consultar citas","SePaCitasConfirmadas",device,connection,request.data,"citasConfirmadas/",{'message':'OK','data':'notjson'})
                return Response(response,status=status.HTTP_200_OK)
            else:
                response = {
                    'data':'',
                    'status':'0',
                    'message':'Sin citas programadas'
                }
                loggeractions(clientes,users.id_branch_id,"Consultar citas","SePaCitasConfirmadas",device,connection,request.data,"citasConfirmadas/",response)
                return Response(response,status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            loggeractions(clientes,users.id_branch_id,"Consultar citas","SePaCitasConfirmadas",device,connection,request.data,"citasConfirmadas/",{'data':'','message': 'No se pudo obtener citas: '+ str(e)})
            return Response({
                        'data':'',
                        'status':'2',
                        'message': 'No se pudo obtener citas: '+ str(e)
                    },status=status.HTTP_400_BAD_REQUEST)

#Not use
class createUser(APIView):
    
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        empresa = sepa_branch.objects.get(id=int(request.data["idbranch"]))
        device=request.data["device"]
        connection=request.data["connection"]
        try:
            #Funcion para crear usuario 
            usuario = user.objects.create_user(request.data["idbranch"],request.data["currentversion"],request.data["code"],request.data["correo"],request.data["telefono"],request.data["nombre"])
            usuario.id_intelisis=request.data["cliente"]
            usuario.set_password(request.data["pass"])
            
            json_data = {
                'name':request.data["nombre"],
                'email':request.data["correo"],
                'phone':request.data["telefono"]
            }
            #gts inicia bloque para saber si tienes check de Conekta activado   
            if SepaConfigSuc.objects.using(request.data["code"][2:7]).filter(Empresa=request.data["code"][2:7],Sucursal=int(request.data["code"][8:10]),PagoConekta=True ):
                ConfSuc = SepaConfigSuc.objects.using(request.data["code"][2:7]).get(Empresa=request.data["code"][2:7],Sucursal=int(request.data["code"][8:10]),PagoConekta=True )
                
                conekta.api_key = ConfSuc.cktPrivateKey
    
                ckt = conekta.Customer.create(json_data)
                usuario.id_ckt = ckt.id

            usuario.save()
            res = {
                    'id_usuario':usuario.id,
                    'data':'Usuario creado con exito',
                    'Mensaje':'OK'
                }
            loggeractions(usuario.id,request.data["idbranch"],"Crear usuario","users",device,connection,request.data,"createUser/",res)
            return Response(res,status=status.HTTP_200_OK)
        except Exception as e:
            res = {
                    'data':'Fallo en el registro del usuario:' + str(e),
                    'Mensaje': 'NONE'
                }
            loggeractions(clientes,users.id_branch_id,"Consultar Ordenes principal","SepaOrdenes",device,connection,request.data,"ordenesgeneral/",res)
            return Response(res,status=status.HTTP_400_BAD_REQUEST)

#Not use
class createtkn(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        cliente = request.data["cliente"]
        device=request.data["device"]
        connection=request.data["connection"]
        users = user.objects.get(id=cliente)
        try:
            #Funcion para crear usuario 
            empresa = sepa_branch.objects.get(id=users.id_branch_id)
            

            #Modificacion para revisar que tenga activado conekta en la sucursal

            if SepaConfigSuc.objects.using(users.code_verification[2:7]).filter(Empresa=users.code_verification[2:7],Sucursal=int(users.code_verification[8:10]),PagoConekta=True ):
                ConfSuc = SepaConfigSuc.objects.using(users.code_verification[2:7]).get(Empresa=users.code_verification[2:7],Sucursal=int(users.code_verification[8:10]),PagoConekta=True )
            
                conekta.api_key = ConfSuc.cktPrivateKey
                
                if users.id_ckt is None:
                    json_data = {
                        'name':users.usuario,
                        'email':users.correo,
                        'phone':users.telefono
                    }
                    ckt = conekta.Customer.create(json_data)
                    customer = conekta.Customer.find(ckt.id)
                    users.id_ckt = ckt.id
                    users.save()
                else:
                    customer = conekta.Customer.find(users.id_ckt)
                customer.createPaymentSource({
                "type": "card",
                "token_id": request.data["id"]
                })
                loggeractions(cliente,users.id_branch_id,"Agregar tarjeta conekta","ConektacreatePaymentSource",device,connection,request.data,"createtkn/",{'data':'Tarjeta creada con exito','Mensaje':'OK'})
                return Response({
                        'data':'Tarjeta creada con exito',
                        'Mensaje':'OK'
                    },status=status.HTTP_200_OK)
            else:
                loggeractions(cliente,users.id_branch_id,"Agregar tarjeta conekta","ConektacreatePaymentSource",device,connection,request.data,"createtkn/",{'data':'','Mensaje':'No esta activado el pago de conekta para esta Sucursal'})
                return Response({
                        'data':'',
                        'Mensaje':'No esta activado el pago de conekta para esta Sucursal'
                    },status=status.HTTP_200_OK)    
        except Exception as e:
            loggeractions(cliente,users.id_branch_id,"Agregar tarjeta conekta","ConektacreatePaymentSource",device,connection,request.data,"createtkn/",{'data':'Fallo en el registro de la tarjeta'+ str(e),'Mensaje': 'NONE'})
            return Response({
                        'data':'Fallo en el registro de la tarjeta'+ str(e),
                        'Mensaje': 'NONE'
                    },status=status.HTTP_400_BAD_REQUEST)

#Not Use
class updatetkn(APIView):
    authentication_classes = (TokenAuthentication, )
    permission_classes = (IsAuthenticated,)
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):
        try:
            #Funcion para crear usuario 
            cliente = request.data["cliente"]
            index = int(request.data["index"])
            users = user.objects.get(id=cliente)
            empresa = sepa_branch.objects.get(id=users.id_branch_id)
            
            if SepaConfigSuc.objects.using(users.code_verification[2:7]).filter(Empresa=users.code_verification[2:7],Sucursal=int(users.code_verification[8:10]),PagoConekta=True ):
                ConfSuc = SepaConfigSuc.objects.using(users.code_verification[2:7]).get(Empresa=users.code_verification[2:7],Sucursal=int(users.code_verification[8:10]),PagoConekta=True )
            
                conekta.api_key = ConfSuc.cktPrivateKey
                customer = conekta.Customer.find(users.id_ckt)
            
                payment_source = customer.payment_sources[index].update({"exp_month":11,"name":"Angelin","exp_year":2021})
             
                return Response({
                        'data':'Tarjeta creada con exito',
                        'Mensaje':'OK'
                        },status=status.HTTP_200_OK)
            else:
                return Response({
                        'data':'',
                        'Mensaje':'No esta activado el pago de conekta para esta Sucursal'
                    },status=status.HTTP_400_BAD_REQUEST)  
        except Exception as e:
            return Response({
                        'data':'Fallo en la actualización de tu tarjeta: '+ str(e),
                        'Mensaje': 'NONE'
                    },status=status.HTTP_400_BAD_REQUEST)

#Unknown called
class ConcludeAppointments(APIView):
    @action(detail=True, methods=['POST']) 
    def post(self, request, format=None):

        cliente = request.data["cliente"]
        empresa = request.data["empresa"]
        folio = request.data["folio"]
        print(cliente,empresa,folio)
        if sepa_branch.objects.filter(empresa_intelisis=empresa).exists():
            if sepa_Citas.objects.filter(Id=folio,Cliente=cliente,Estatus='CONFIRMAR').exists():
                try:
                    cita = sepa_Citas.objects.get(Id=folio,Cliente=cliente)
                    cita.Estatus='CONCLUIDA'
                    cita.save()
                    return Response("Estatus de cita Actualizado correctamente")
                except Exception as e:
                    return Response("Error:"+ str(e))
            else:
                return Response("No hay cita por CONFIRMAR")
        else:
            return Response("No se encontro la empresa solicitada")    

