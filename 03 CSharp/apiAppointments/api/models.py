from django.db import models
from django.contrib.auth.models import AbstractBaseUser,BaseUserManager
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import PermissionsMixin
from django.db.models import Q
from django.contrib.auth import get_user_model

class sepa_current_version(models.Model):
    id = models.AutoField(primary_key=True)
    nombre  = models.CharField(max_length=120,blank=True)
    features = models.CharField(max_length=120,blank=True)
    fixes = models.TextField(max_length=2400,blank=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    eliminado = models.BooleanField(default=False)

    def __str__(self):
        return self.nombre
class sepa_companies(models.Model):
    id = models.AutoField(primary_key=True)
    clave = models.CharField(max_length=128,blank=True)
    razonsocial = models.CharField(max_length=100)
    rfc = models.CharField(max_length=40)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    id_intelisis = models.IntegerField(blank=True)
    foto = models.ImageField(upload_to='companies')
    foto_alt = models.ImageField(upload_to='companies_alt')
    eliminado = models.BooleanField(default=False)

    def __str__(self):
        return self.clave

class sepa_branch(models.Model):
    id = models.AutoField(primary_key=True)
    id_company = models.ForeignKey(sepa_companies, on_delete=models.CASCADE)
    clave = models.CharField(max_length=128,blank=True)
    nombre = models.CharField(max_length=100,blank=True)
    telefono =  models.CharField(max_length=40,blank=True)
    correo = models.CharField(max_length=240,blank=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    conf_ip_ext =  models.CharField(max_length=40,blank=True)
    conf_ip_int =  models.CharField(max_length=40,blank=True,null=True)
    conf_user =  models.CharField(max_length=40,blank=True)
    conf_pass =  models.CharField(max_length=40,blank=True)
    conf_db =  models.CharField(max_length=80,blank=True)
    conf_port =  models.CharField(max_length=80,blank=True,null=True)
    id_intelisis = models.IntegerField(blank=True)
    empresa_intelisis =  models.CharField(max_length=80,blank=True)
    foto = models.ImageField(upload_to='branch',null=True)
    foto_alt = models.ImageField(upload_to='branch_alt',null=True)
    eliminado = models.BooleanField(default=False)
    direccion = models.CharField(max_length=500,blank=True)
    latitud = models.CharField(max_length=50,blank=True,null=True)
    longitud = models.CharField(max_length=50,blank=True,null=True)

    def __str__(self):
        return self.clave

class sepa_user_groups(models.Model):
    id = models.AutoField(primary_key=True)
    id_branch = models.ForeignKey(sepa_branch, on_delete=models.CASCADE)
    nombre = models.CharField(max_length=180,blank=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    id_intelisis = models.IntegerField(blank=True)
    eliminado = models.BooleanField(default=False)

    def __str__(self):
        return self.nombre

class UserProfileManager(BaseUserManager):
    """Manager for user profiles"""

    def create_user(self, id_branch,id_current_version,code_verification,correo,telefono,usuario, password=None):
        """Create a new user profile"""
        if not correo:
            raise ValueError('El correo es un campo obligatorio')

        correo = self.normalize_email(correo)
        user = self.model(id_branch_id=id_branch,id_current_version_id=id_current_version,code_verification=code_verification,correo=correo,telefono=telefono,usuario=usuario)

        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_superuser(self, id_branch, id_current_version, code_verification, correo, telefono, usuario, password):
        """Create and save a new superuser with given details"""
        user = self.create_user(id_branch,id_current_version,code_verification,correo, telefono, usuario,password)

        user.is_superuser = True
        user.is_staff = True
        user.save(using=self._db)

        return user

class user(AbstractBaseUser, PermissionsMixin):
    id = models.AutoField(primary_key=True)
    id_branch = models.ForeignKey(sepa_branch, to_field='id', on_delete=models.CASCADE)
    id_current_version = models.ForeignKey(sepa_current_version, on_delete=models.CASCADE)
    code_verification = models.CharField(max_length=20,blank=True)
    usuario = models.CharField(max_length=254,blank=True,unique=True)
    password = models.CharField(max_length=100,blank=True)
    nombres = models.CharField(max_length=180,blank=True)
    ap_paterno = models.CharField(max_length=100,blank=True)
    ap_materno = models.CharField(max_length=100,blank=True)
    telefono = models.CharField(max_length=40,blank=True)
    correo = models.CharField(max_length=240,blank=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    id_intelisis = models.CharField(max_length=100,blank=True,null=True)
    id_ckt = models.CharField(max_length=100,blank=True,null=True)
    token_device = models.CharField(max_length=100,blank=True,null=True)
    foto = models.ImageField(upload_to='users')
    foto_alt = models.ImageField(upload_to='users_alt')
    eliminado = models.BooleanField(default=False)
    api_sctoken = models.CharField(max_length=150,blank=True)
    api_scLastLoggedIn = models.DateTimeField(auto_now=False, auto_now_add=True)
    api_scInserted = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserProfileManager()

    USERNAME_FIELD = 'usuario'
    REQUIRED_FIELDS = ['id_branch','id_current_version','code_verification','correo','telefono','password']

    def get_full_name(self):
        """Retrieve full name of user"""
        return self.nombres

    def get_short_name(self):
        """Retrieve shot name of user"""
        return self.nombres

    def __str__(self):
        return self.usuario

class AuthBackend(user):
    supports_object_permissions = True
    supports_anonymous_user = False
    supports_inactive_user = False

    def get_user(self, user_id):
        try:
            from api.models import user
            return user.objects.get(pk=user_id)
        except user.DoesNotExist:
            return None

    def authenticate(self, request):
        from api.models import user
        message=''
        try:
            user1 = user.objects.get(
                Q(usuario=request.data['username']) | Q(correo=request.data['username']),
                Q(id_branch=request.data['IdDistribuidor'])
            )
            token = Token.objects.get(user_id=user1.id)
        except user.DoesNotExist:
            message='1'
            out = {
                'token':'',
                'status':message,
                #'IdDistribuidor':'',
            }
            return out
        if user1.check_password(request.data['password']):
            message='0'
            out = {
                'token':token,
                'status':message,
                #'IdDistribuidor':user1.id_branch_id,
            }
            #token = Token.objects.get(key=response.data['token'])
            return out
        else:
            message='2'
            out = {
                'token':'',
                'status':message,
                #'IdDistribuidor':'',
            }
            return out

class sepa_conf_notifications(models.Model):
    id = models.AutoField(primary_key=True)
    id_branch = models.ForeignKey(sepa_branch, on_delete=models.CASCADE)
    id_situacion = models.IntegerField(blank=True)
    texto = models.CharField(max_length=512,blank=True)
    tipo = models.IntegerField(blank=True)
    icono = models.CharField(max_length=1024,blank=True)
    color = models.CharField(max_length=20,blank=True)
    extras = models.CharField(max_length=512,blank=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    eliminado = models.BooleanField(default=False)

    def __str__(self):
        return self.id

class sepa_log(models.Model):
    id = models.AutoField(primary_key=True)
    id_branch = models.ForeignKey(sepa_branch, to_field='id', on_delete=models.CASCADE)
    id_usuario = models.ForeignKey(user, to_field='id', on_delete=models.CASCADE,db_constraint=False)
    tipo_movimiento = models.CharField(max_length=120,blank=True)
    tabla = models.CharField(max_length=120,blank=True)
    id_row = models.IntegerField(blank=True,null=True)
    sql_query = models.TextField(blank=True,null=True)
    post = models.TextField(blank=True,null=True)
    url = models.CharField(max_length=2048,blank=True,null=True)
    fecha_creacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=False, auto_now_add=True)
    idDevice = models.IntegerField(blank=True,null=True)
    idConnection = models.IntegerField(blank=True,null=True)
    eliminado = models.BooleanField(default=False)

    def __str__(self):
        return self.id

class Cliente(models.Model):
    Cliente = models.CharField(primary_key = True,max_length=180)
    Nombre = models.CharField(max_length=250,null=True,blank=True)
    PersonalNombres = models.CharField(max_length=100,null=True,blank=True)
    PersonalApellidoPaterno = models.CharField(max_length=100,null=True,blank=True)
    PersonalApellidoMaterno = models.CharField(max_length=100,null=True,blank=True)
    Direccion = models.CharField(max_length=200,null=True,blank=True)
    PersonalTelefonoMovil = models.CharField(max_length=200,null=True,blank=True)
    eMail1 = models.CharField(max_length=280,null=True,blank=True)
    Poblacion = models.CharField(max_length=150,null=True,blank=True)
    Estado = models.CharField(max_length=150,null=True,blank=True)
    Pais = models.CharField(max_length=150,null=True,blank=True)
    CodigoPostal = models.CharField(max_length=100,null=True,blank=True)
    class Meta:
        managed = False
        db_table = 'cte'

class Sucursal(models.Model):
    Sucursal = models.IntegerField(primary_key=True)
    Nombre = models.CharField(max_length=100)
    Telefonos = models.CharField(max_length=100)
    class Meta:
        managed = False
        db_table = 'Sucursal'

class LogIntelisis(models.Model):
    Id =models.AutoField(primary_key= True)
    IDVenta = models.IntegerField(blank=True)
    EstatusPag =models.CharField(max_length=50)
    FechaEmision = models.DateTimeField()
    class Meta:
        managed = False
        db_table ='CA_SepaLogPenteFactura'

class SepaConfigSuc(models.Model):
    ID = models.IntegerField(primary_key= True)
    Empresa = models.CharField(max_length=10,blank=True)
    Sucursal = models.IntegerField(blank=True)
    PagoCiti =  models.BooleanField()
    PagoConekta = models.BooleanField()
    cktUsuario = models.CharField(max_length=255,blank=True,null=True)
    cktPrivateKey = models.CharField(max_length=255,blank=True,null=True)
    cktPublicKey = models.CharField(max_length=255,blank=True,null=True)
    citiUsuario = models.CharField(max_length=255,blank=True,null=True)
    citiKey = models.CharField(max_length=255,blank=True,null=True)
    AgenteServicio = models.CharField(max_length=255,blank=True,null=True)
    UsuarioSepaCS = models.CharField(max_length=255,blank=True,null=True)
    CtaDinero = models.CharField(max_length=255,blank=True,null=True)
    Cajero = models.CharField(max_length=255,blank=True,null=True)
    class Meta:
        managed = False
        db_table ='CA_sepa_conf_correo'

class sepa_Citas(models.Model):
    Id =models.AutoField(primary_key= True)
    UsuarioSepa = models.IntegerField(blank=True,null=True)
    Empresa = models.CharField(max_length=5,blank=True,null=True)
    Mov = models.CharField(max_length=20,blank=True,null=True, default='Cita Servicio')
    MovId = models.CharField(max_length=20,blank=True,null=True)
    FechaEmision = models.DateTimeField(null=True)
    Concepto = models.CharField(max_length=50,blank=True,null=True, default='Publico')
    UEN = models.IntegerField(blank=True,null=True)
    Moneda = models.CharField(max_length=10,blank=True,null=True, default='Pesos')
    TipoCambio = models.FloatField(null=True, default=1)
    Usuario = models.CharField(max_length=10,blank=True,null=True)
    Estatus = models.CharField(max_length=15,blank=True,null=True)
    Cliente = models.CharField(max_length=10,blank=True,null=True)
    Almacen = models.CharField(max_length=10,blank=True,null=True)
    Agente = models.CharField(max_length=10,blank=True,null=True)
    FechaRequerida = models.DateTimeField(null=True)
    HoraRequerida = models.CharField(max_length=5,blank=True,null=True)
    HoraRecepcion = models.CharField(max_length=5,blank=True,null=True)
    Condicion = models.CharField(max_length=50,blank=True,null=True, default='Contado')
    ServicioArticulo = models.CharField(max_length=20,blank=True,null=True)
    ServicioDescripcion = models.CharField(max_length=100,blank=True,null=True)
    ServicioSerie = models.CharField(max_length=50,blank=True,null=True)
    ServicioPlacas = models.CharField(max_length=20,blank=True,null=True)
    ServicioKms = models.IntegerField(blank=True,null=True)
    ServicioNumeroEconomico = models.CharField(max_length=20,blank=True,null=True)
    ServicioTipoOrden = models.CharField(max_length=20,blank=True,null=True, default='Publico')
    ServicioTipoOperacion = models.CharField(max_length=50,blank=True,null=True, default='Mtto/Diagnostico')
    ServicioModelo = models.CharField(max_length=4,blank=True,null=True)
    Ejercicio = models.IntegerField(blank=True,null=True)
    Periodo = models.IntegerField(blank=True,null=True)
    ListaPreciosEsp = models.CharField(max_length=20,blank=True,null=True,default='Precio Publico')
    Sucursal = models.IntegerField(blank=True,null=True)
    Comentarios = models.CharField(max_length=500,blank=True,null=True)
    SucursalOrigen = models.IntegerField(blank=True,null=True)
    IdlogIntelisis = models.IntegerField(blank=True,null=True)
    FechaCreacion = models.DateTimeField(auto_now=False, auto_now_add=True, null=True) 
    def __str__(self):
        return self.Id

class SKCitasConfirmadas(models.Model):
    IDCita = models.IntegerField(primary_key= True)
    Empresa = models.CharField(max_length=5,blank=True,null=True)
    Movimiento = models.CharField(max_length=20,blank=True,null=True)
    Folio = models.CharField(max_length=20,blank=True,null=True)
    Fecha = models.DateTimeField(null=True)
    Hora = models.CharField(max_length=5,blank=True,null=True)
    Estatus = models.CharField(max_length=15,blank=True,null=True)
    Cliente = models.CharField(max_length=10,blank=True,null=True)
    Nombre = models.CharField(max_length=150,blank=True,null=True)
    Articulo = models.CharField(max_length=20,blank=True,null=True)
    Vehiculo = models.CharField(max_length=100,blank=True,null=True)
    Vin = models.CharField(max_length=50,blank=True,null=True)
    Agente = models.CharField(max_length=100,blank=True,null=True)
    Comentarios = models.CharField(max_length=255,blank=True, null=True)
    Sucursal = models.CharField(max_length=100,blank=True,null=True)
    DireccionSucursal = models.CharField(max_length=255,blank=True, null=True)
    longitud = models.CharField(max_length=50,blank=True, null=True) 
    latitud = models.CharField(max_length=50,blank=True, null=True)
    class Meta:
        managed = False
        db_table ='vwCA_SKCitas'
class SePaVehiculos(models.Model):
    ServicioSerie =	models.CharField(primary_key=True,max_length=20,blank=True)
    Cliente = models.CharField(max_length=10,blank=True, null=True)
    ServicioArticulo = models.CharField(max_length=20,blank=True, null=True)
    ArtDescripcion = models.CharField(max_length=100,blank=True, null=True)
    ServicioDescripcion = models.CharField(max_length=50,blank=True, null=True)
    ServicioPlacas = models.CharField(max_length=20,blank=True, null=True)
    ServicioKms = models.IntegerField(blank=True, null=True)
    ServicioNumeroEconomico	= models.CharField(max_length=50,blank=True, null=True)
    ServicioTipoOrden = models.CharField(max_length=20,blank=True, null=True)
    ServicioTipoOperacion = models.CharField(max_length=50,blank=True, null=True)
    ServicioModelo = models.CharField(max_length=4,blank=True, null=True)
    class Meta:
        managed = False
        db_table ='vwCA_SePaVehiculos'

class CalendarioJornadas(models.Model):
    Fecha =	models.DateField(primary_key=True)
    Anio = models.CharField(max_length=4,blank=True, null=True)
    Mes = models.CharField(max_length=2,blank=True, null=True)
    Sucursal = models.IntegerField(blank=True, null=True)
    class Meta:
        managed = False
        db_table ='vwCA_SePaHorarios'

class log_sepa_Citas(models.Model):
    Id =models.AutoField(primary_key= True)
    Empresa = models.CharField(max_length=5,blank=True,null=True)
    Mov = models.CharField(max_length=20,blank=True,null=True, default='Cita Servicio')
    FechaEmision = models.DateTimeField(null=True)
    Concepto = models.CharField(max_length=50,blank=True,null=True, default='Publico')
    Moneda = models.CharField(max_length=10,blank=True,null=True, default='Pesos')
    TipoCambio = models.FloatField(null=True, default=1)
    Usuario = models.CharField(max_length=10,blank=True,null=True)
    Estatus = models.CharField(max_length=15,blank=True,null=True)
    Cliente = models.CharField(max_length=10,blank=True,null=True)
    Agente = models.CharField(max_length=10,blank=True,null=True)
    HoraRequerida = models.CharField(max_length=5,blank=True,null=True)
    Condicion = models.CharField(max_length=50,blank=True,null=True, default='Contado')
    ServicioArticulo = models.CharField(max_length=20,blank=True,null=True)
    ServicioDescripcion = models.CharField(max_length=100,blank=True,null=True)
    ServicioSerie = models.CharField(max_length=50,blank=True,null=True)
    ServicioPlacas = models.CharField(max_length=20,blank=True,null=True)
    ServicioKms = models.IntegerField(blank=True,null=True)
    ServicioTipoOrden = models.CharField(max_length=20,blank=True,null=True, default='Publico')
    ServicioTipoOperacion = models.CharField(max_length=50,blank=True,null=True)
    ServicioModelo = models.CharField(max_length=4,blank=True,null=True)
    Ejercicio = models.IntegerField(blank=True,null=True)
    Periodo = models.IntegerField(blank=True,null=True)
    ListaPreciosEsp = models.CharField(max_length=20,blank=True,null=True,default='Precio Publico')
    Sucursal = models.IntegerField(blank=True,null=True)
    Comentarios = models.CharField(max_length=500,blank=True,null=True)
    SucursalOrigen = models.IntegerField(blank=True,null=True)
    Id_sepa_Citas = models.IntegerField(blank=True,null=True)
    Id_CitaIntelisis = models.IntegerField(blank=True,null=True)
    ArticuloPaquete = models.CharField(max_length=50,blank=True,null=True)
    class Meta:
        managed = False
        db_table ='CA_log_sepa_citas'

class SePaCitasConfirmadas(models.Model):
    IDCita = models.IntegerField(primary_key= True)
    Empresa = models.CharField(max_length=5,blank=True,null=True)
    Movimiento = models.CharField(max_length=20,blank=True,null=True)
    Folio = models.CharField(max_length=20,blank=True,null=True)
    Fecha = models.DateTimeField(null=True)
    Hora = models.CharField(max_length=5,blank=True,null=True)
    Estatus = models.CharField(max_length=15,blank=True,null=True)
    Cliente = models.CharField(max_length=10,blank=True,null=True)
    Nombre = models.CharField(max_length=150,blank=True,null=True)
    Articulo = models.CharField(max_length=20,blank=True,null=True)
    Vehiculo = models.CharField(max_length=100,blank=True,null=True)
    Vin = models.CharField(max_length=50,blank=True,null=True)
    Agente = models.CharField(max_length=100,blank=True,null=True)
    Comentarios = models.CharField(max_length=255,blank=True, null=True)
    Sucursal = models.CharField(max_length=100,blank=True,null=True)
    DireccionSucursal = models.CharField(max_length=255,blank=True, null=True)
    longitud = models.CharField(max_length=50,blank=True, null=True) 
    latitud = models.CharField(max_length=50,blank=True, null=True)
    class Meta:
        managed = False
        db_table ='vwCA_SePaCitas'

class SepaDevice(models.Model):
    Id = models.AutoField(primary_key=True)
    isDevice = models.CharField(max_length=150,blank=True,null=True)
    brand = models.CharField(max_length=150,blank=True,null=True)
    manufacturer = models.CharField(max_length=150,blank=True,null=True)
    modelName = models.CharField(max_length=150,blank=True,null=True)
    modelId = models.CharField(max_length=150,blank=True,null=True)
    designName = models.CharField(max_length=150,blank=True,null=True)
    productName = models.CharField(max_length=150,blank=True,null=True)
    deviceYearClass = models.CharField(max_length=150,blank=True,null=True)
    totalMemory = models.CharField(max_length=150,blank=True,null=True)
    supportedCpuArchitectures = models.CharField(max_length=150,blank=True,null=True)
    osName = models.CharField(max_length=150,blank=True,null=True)
    osBuildId = models.CharField(max_length=150,blank=True,null=True)
    osInternalBuildId = models.CharField(max_length=150,blank=True,null=True)
    osBuildFingerprint = models.CharField(max_length=150,blank=True,null=True)
    platformApiLevel = models.CharField(max_length=150,blank=True,null=True)
    deviceName = models.CharField(max_length=150,blank=True,null=True)
    eliminado = models.BooleanField(default=False)
    def __str__(self):
        return self.Id

class SepaConnection(models.Model):
    Id = models.AutoField(primary_key=True)
    connectiontype = models.CharField(max_length=150,blank=True,null=True)
    detailswifiisConnectionExpensive = models.CharField(max_length=150,blank=True,null=True)
    detailswifissid = models.CharField(max_length=150,blank=True,null=True)
    detailswifibssid = models.CharField(max_length=150,blank=True,null=True)
    detailswifistrength = models.CharField(max_length=150,blank=True,null=True)
    detailswifiipAddress = models.CharField(max_length=150,blank=True,null=True)
    detailswifisubnet = models.CharField(max_length=150,blank=True,null=True)
    detailswififrequency = models.CharField(max_length=150,blank=True,null=True)
    detailscellularisConnectionExpensive = models.CharField(max_length=150,blank=True,null=True)
    detailscellularcellularGeneration = models.CharField(max_length=150,blank=True,null=True)
    detailscellularcarrier = models.CharField(max_length=150,blank=True,null=True)
    eliminado = models.BooleanField(default=False)
    def __str__(self):
        return self.Id

class SKPaquetes(models.Model):
    ID = models.AutoField(primary_key=True)
    Clave = models.CharField(max_length=20)
    Descripcion = models.CharField(max_length=100)
    Grupo = models.CharField(max_length=20)
    class Meta:
        managed = False
        db_table ='CA_SKPaquetes'

class SKModeloVehiculos(models.Model):
    ID = models.AutoField(primary_key=True)
    Clave = models.CharField(max_length=20)
    Descripcion = models.CharField(max_length=100)
    class Meta:
        managed = False
        db_table ='CA_SKModeloVehiculos'
        