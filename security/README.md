# Explicación de uso de la carpeta security y sus archivos ODOO

>[!IMPORTANT]
> Para un mayor entendimiento de security, por favor leer la documentación oficial de **ODOO** sobre [security](https://www.odoo.com/documentation/15.0/es/developer/tutorials/getting_started/05_securityintro.html)

## Archivos
#### [ir.model.access.csv](ir.model.access.csvs)
Este archivo es esencial para la definición de permisos y roles en Odoo. Define los modelos a los que se puede acceder y los niveles de acceso (lectura, escritura, eliminación) para diferentes grupos de usuarios.

~~~csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_facturafiscal_facturafiscal,facturafiscal.facturafiscal,model_facturafiscal_facturafiscal,base.group_user,1,1,1,1
~~~
<sub>Para poder ver claramente este archivo, se puede usar la extensión de Visual Studio Code [Rainbow CSV](https://marketplace.visualstudio.com/items?itemName=mechatroner.rainbow-csv)</sub>