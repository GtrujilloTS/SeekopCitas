<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="./static/images/icono-intelisis.png" alt="Project logo"></a>
</p>

<h3 align="center">Proyecto Api Citas</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> En las siguientes lineas se describe el contenido del proyecto y lo necesario para su uso e implementación.
<br> 
</p>

## 📝 Indice de contenidos

- [Introducción](#about)
- [Modo local](#getting_started)
- [Probar](#test)
- [Despliegue](#deployment)
- [Uso](#usage)
- [Requisitos](#built_using)
- [Autores](#authors)
- [Recomendaciones](#acknowledgement)

## 🧐 Introducción <a name = "about"></a>

Este proyecto esta diseñado para complementar la herramienta de intelisis y exponer un conjunto de recursos (endpoints) que nos permitirían procesar el flujo de agendamiento de citas desde sistemas anexos que necesiten convivir con intelisis.

## 🏁 Modo local <a name = "getting_started"></a>

Instalar python 3.6 o superior

#### Sistema windows
```
python -m venv venv
source venv/Scripts/activate
pip3 install -r requirements.txt
```

#### Sistema Linux
```
python -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

*Nota para los casos que tienen instaladas varias versiones pueda que requieras un alias (alias python=python3)*


#### Configurar acceso a bases de datos
Nececitaras entrar a tu archivo `/sepa/settings.py` y cambiar dentro de la configuración tus accesos correspondientes para comunicar con gestor de base de datos
```
'default': {
    'ENGINE': 'sql_server.pyodbc',
    'NAME': 'DBAPI',
    'USER': 'SA',
    'PASSWORD': '',
    'HOST': '',
    'PORT': '',
    'OPTIONS': {
        'driver': 'ODBC Driver 17 for SQL Server'
    },
},
'DBINTELISIS': {
    'ENGINE': 'sql_server.pyodbc',
    'NAME': 'DBINTELISIS',
    'USER': 'SA',
    'PASSWORD': '',
    'HOST': '',
    'PORT': '',
    'OPTIONS': {
        'driver': 'ODBC Driver 17 for SQL Server'
    },
},
```

#### Migrar base de datos
Dentro de tu carpeta raiz del proyecto se necesita inicializar tu base de datos
```
python manage.py makemigrations
python manage.py migrate
```

#### Migrar base de datos
Dentro de tu carpeta raiz del proyecto se necesita inicializar tu base de datos
```
python manage.py makemigrations
python manage.py migrate
```

#### Inicializar un usuario
Dentro de tu carpeta raiz del proyecto se necesita ejecutar el contenido destinado para la base de datos de la api que se encuentra en el script base `/Anexos/02 SQL/07 Inserts.sql` .
Posteriormente dentro de su entorno creará un usuario con los siguientes parametros
```
python manage.py createsuperuser

Usuario: TESTDEV
Id branch (sepa_branch.id): 1
Id current version (sepa_current_version.id): 1
Code verification: TESTDEV
Correo: mail@mail.com
Telefono: 0000000000
Password: TESTDEV
```

#### Generar llave de conexion
Dentro del proyecto entraremos al shell para generar una llave y que esta sea la utilizada para generar una conexion desde el api
```
python magane.py shell
from rest_framework_api_key.models import APIKey
api_key, key = APIKey.objects.create_key(name="seekop-prod")
print(key) 
```

*Tu key es necesaria guardarse para poder generar una autenticación desde tu api*

#### Para confirmar su funcionalidad puede verificar su servidor local
```
python manage.py runserver 0.0.0.0:8000
```
abre tu navegador en tu servidor local : localhost:8000
panel administracion http://localhost:8000/admin/
Usuario: TESTDEV
Contraseña: TESTDEV


## 🔧 Ejecutar pruebas <a name = "tests"></a>

* La documentación sobre los endpoints en español esta en el siguiente link

https://documenter.getpostman.com/view/8589169/TVzUCGEb

* La documentación sobre los endpoints en ingles esta en el siguiente link

https://documenter.getpostman.com/view/8589169/TzJoE1VN

Dentro del proyecto se cuenta con un anexo con la documentación

`Anexos/Manuales/IntelisisCitasEN` o `Anexos/Manuales/IntelisisCitasES`

Y se cuenta con un apartado de pruebas basado en un proyecto de POSTMAN

`Anexos/Pruebas/IntelisisCitas(EN).postman_collection` o `Anexos/Pruebas/IntelisisCitas(ES).postman_collection`


## 🚀 Despliegue <a name = "deployment"></a>

El despliegue requiere de un sistema con un servidor como NGINX o IIS con los que se requiere que se cuenta previamente con los pasos anteriores.

*Recomendaciones para publicar por medio de iis*

Se recomienda usar su archivo requirements_iss.txt
Un ejemplo de su archivo de configuración web

```
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="Python FastCGI" 
      path="*" 
      verb="*" 
      modules="FastCgiModule" 
      scriptProcessor="C:\Python39\python.exe|C:\Python39\Lib\site-packages\wfastcgi.py" 
      resourceType="Unspecified" 
      requireAccess="Script" />
    </handlers>
  </system.webServer>

  <appSettings>
    <add key="PYTHONPATH" value="C:\inetpub\wwwroot\apiappointments" />
    <add key="WSGI_HANDLER" value="django.core.wsgi.get_wsgi_application()" />
    <add key="DJANGO_SETTINGS_MODULE" value="sepa.settings" />
  </appSettings>
</configuration>
```

#### Como anexo habra que modificar su configuracion de dominio al archivo de configuración `sepa/settings.py` como se representa en el siguiente formato ejemplificado

```
ALLOWED_HOSTS = [
    '*',
    'apinissan-dev.intelisis-solutions.com'
]
```
```
CORS_ORIGIN_WHITELIST = [
    'http://localhost:8080',
    'https://apinissan-dev.intelisis-solutions.com:8443'
]
CORS_ORIGIN_REGEX_WHITELIST = [
    'http://localhost:8080',
    'https://apinissan-dev.intelisis-solutions.com:8443'
]
```

## 🎈 Uso <a name="usage"></a>

Sigue las instrucciones descritas en tu proyecto postman las cuales incluyen de forma ejemplificada el uso de tu api.

Para su uso se requiere tener los siguientes puntos a considerar:

En su endpoint de autentificación incluir la siguiente cabecera
```
header: {
  Int-Key: KEY (previamente generado como su llave de conexion descrito en las instrucciones para su modo local)
}
```
Dentro de este endpoint incluir sus credenciales de usuario
###### Request
```
body: {
  "username":"TESTDEV",
  "password":"TESTDEV",
  "IdDistribuidor":"1",
}
```
###### Response
```
Response: {
    "token": "X",
    "IdDistribuidor": 1,
    "status": "0"
}
```

Donde el token retornado servirá para acceder al resto de los endpoints y donde se modificaron incluida la información en la documentación las peticiones para recibir el body codificado en base64

## ⛏️ Requisitos <a name = "built_using"></a>

- [SQLServer](https://www.microsoft.com/es-mx/sql-server/sql-server-downloads) - Database
- [Python](https://www.python.org/) - Language BackEnd
- [Django](https://www.djangoproject.com/) - Framework Backend

## ✍️ Autores <a name = "authors"></a>

- [@Angelin20](https://bitbucket.org/Angelin20) - Software Development Management at Intelisis
- [@gtrujillo](https://github.com/GtrujilloTS) Full Stack Developer at Intelisis

## 🎉 Recomendaciones <a name = "acknowledgement"></a>

#### Estilos de codigo

Lo incluido dentro del proyecto consiste en el siguiente tipo de commits:

* FIX: Correcciones a bugs, fallas de integridad de información o fallas de programación.

* REFACTOR: Reconstrucción, modificación o anexo a funcionalidades y modulos ya existentes.

* FEAT: Nueva funcionalidad.

* SQL: Acciones a base de datos, archivos sql, actividades a migrations.

* STYLE: Desarrollo referente a ajustes de estetica.

* DOCS: Carga o modificacion de archivos de documentacion, minutas, acuerdos y soporte a modificaciones.


