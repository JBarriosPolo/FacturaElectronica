# Explicación de uso de la carpeta models y sus archivos ODOO

>[!IMPORTANT]
> Para un mayor entendimiento de los modelos, por favor leer la documentación oficial de **ODOO** sobre [modelos](https://www.odoo.com/documentation/16.0/developer/tutorials/getting_started/04_basicmodel.html)

**ODOO** guarda los modelos en esta carpeta, donde cada uno es hecho de manera separada como un archivo .py, en el cual se define el nombre del modelo, sus atributos y sus métodos (funciones).

## Archivos
#### [\_\_init\_\_.py](__init__.py)

Aquí se importan los modelos que se encuentran en la carpeta models, para que **ODOO** los reconozca. Se hace de la siguiente manera:
~~~Python
from . import models # Importa el modelo models que se encuentra en la carpeta models
from . import res_config_settings # Importa el modelo res_config_settings que se encuentra en la carpeta models
~~~
___
## Modelos
#### [models.py](models.py) 
Modelo principal del módulo facturafiscal
1. Se define de la siguiente manera:
    ~~~Python
    class FacturaFiscal(models.Model):
        _name = 'facturafiscal.facturafiscal' # Nombre del modelo
        _description = 'facturafiscal.facturafiscal' # Descripción del modelo
    ~~~ 


2. Después se definen los atributos del modelo que deseas utilizar en [views](../views/README.md) siguiendo esta estructura:
    ~~~Python
        dverform = fields.Text(string="versión del formato") # Nombre del atributo, tipo de dato, etiqueta del campo
        iamb = fields.Text(string="tipo de ambiente") 
        itpemis = fields.Text(string="tipo de emision")
    ~~~
    <sub>_Para ver todos los atributos utilizados en este modelo, por favor entrar al archivo_ [models.py](models.py)</sub>


#### [res_config_settings.py](res_config_settings.py)
Modelo de configuración del módulo facturafiscal
1. Se define de la siguiente manera:
    ~~~Python
    class ResConfigSettings(models.TransientModel):
        _inherit = 'res.config.settings' # Nombre del modelo que se hereda
    ~~~

2. Definimos los atributos de tipo selection para poder elegir en las configuraciones del módulo siguiendo esta estructura:
    ~~~Python
        dverform_conf_options = fields.Selection([('1.00','1.00')], string="Versión del formato", config_parameter='factura_fiscal.dverform_conf_options',default='1')
        iamb_conf_options = fields.Selection([('1','Producción'),('2','Pruebas')], string="Tipo de ambiente", config_parameter='factura_fiscal.iamb_conf_options',default='1')
        itpemis_conf_options = fields.Selection([('1','Normal'),('2','Contingencia')], string="Tipo de emisión", config_parameter='factura_fiscal.itpemis_conf_options',default='1')
    ~~~
    <sub>_Para ver todos los atributos utilizados en este modelo, por favor entrar al archivo_ [res_config_settings.py](res_config_settings.py)</sub>

3. Estructura de un campo de tipo selection:
    ~~~Python
        dverform_conf_options = #Nombre del campo
        
        fields.Selection([('1.00','1.00')], # Tipo de campo, en este caso es un selection, donde se le pasa una lista de tuplas con los valores que se pueden elegir, y el valor que se guarda en la base de datos.
        
        string="Versión del formato", # Etiqueta del campo
        
        config_parameter='factura_fiscal.dverform_conf_options', # Nombre del parámetro de configuración que se guarda en la base de datos
        
        default='1') # Valor por defecto
    ~~~

