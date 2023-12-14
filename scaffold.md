# Crear la estructura del modulo usando el comando **SCAFFOLD**
Scalfold es un comando que nos permite crear la estructura de un modulo, para ello debemos ejecutar el siguiente comando:
```bash
./odoo-bin scaffold my_module ~/src/odoo-addons/
```
Donde:
- **my_module**: Es el nombre del modulo que vamos a crear.
- **~/src/odoo-addons/**: Es la ruta donde se va a crear el modulo.

Al ejecutar el comando se creará la siguiente estructura:
```bash
~/src/odoo-addons/my_module/
├── __init__.py
├── __manifest__.py
├── controllers
│   ├── __init__.py
│   └── controllers.py
├── demo
│   └── demo.xml
├── models
│   ├── __init__.py
│   └── models.py
├── security
│   └── ir.model.access.csv
└── views
    ├── templates.xml
    └── views.xml
```
Donde:
- **\_\_init\_\_.py**: Es un archivo que indica que la carpeta es un módulo de odoo.
- **\_\_manifest\_\_.py**: Es un archivo que contiene la información del módulo.
- **controllers**: Es una carpeta que contiene los controladores del módulo. (opcional)
- **demo**: Es una carpeta que contiene los datos de demostración del módulo. (opcional)
- **models**: Es una carpeta que contiene los modelos del módulo.
- **security**: Es una carpeta que contiene los archivos de seguridad del módulo.
- **views**: Es una carpeta que contiene las vistas del módulo.