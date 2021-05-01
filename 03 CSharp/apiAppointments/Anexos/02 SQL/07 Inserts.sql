
/*==============================
Angel Javier Lopez Balderas
Registro de Empresa, sucursales y version dentro de base de datos de api

===============================*/
INSERT INTO api_sepa_companies
    (clave,razonsocial,rfc,fecha_creacion,fecha_actualizacion,id_intelisis,foto,foto_alt,eliminado)
VALUES
    ('XXXXX', 'Nombre de razon social empresa', 'XAXX010101000', '08/04/2021 11:04', '08/04/2021 11:04', 1, '', '', '0');
INSERT INTO api_sepa_branch
    (id_company_id,clave,nombre,telefono,correo,fecha_creacion,fecha_actualizacion,conf_ip_ext,conf_ip_int,conf_user,conf_pass,conf_db,conf_port,id_intelisis,empresa_intelisis,foto,foto_alt,eliminado,direccion,latitud,longitud)
VALUES
    ('1', 'XXXXX1', 'Nombre de sucursal', '', '', '02/04/2020 12:04', '02/04/2020 12:04', '127.0.0.1', '127.0.0.1', 'SA', '?', 'DBINTELISIS', '', '0', 'HOCON', '', '', '0','','',''),
    ('1', 'XXXXX2', 'Nombre de sucursal', '', '', '02/04/2020 12:04', '02/04/2020 12:04', '127.0.0.1', '127.0.0.1', 'SA', '?', 'DBINTELISIS', '', '2', 'HOCON', '', '', '0','','','');

INSERT INTO api_sepa_current_version
    (nombre,features,fixes,fecha_creacion,fecha_actualizacion,eliminado)
VALUES
    ('Version 1.0','INITIAL','2021-04-16T09:32:27','2021-04-16T09:32:27','0');

