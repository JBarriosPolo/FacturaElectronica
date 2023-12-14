# -*- coding: utf-8 -*-
{
    'name': "factura_fiscal",

    'summary': """
        este modulo es un desarrollo de start
        para mas informacion pongace en contacto con nosotros""",

    'description': """
        este modulo es para la facturacion fiscal electronica de el pais de panama 
        segun las ultimas normativas de la DGI
    """,

    'author': "Start",
    'website': "https://start.com.pa",

    # Categories can be used to filter modules in modules listing
    # Check https://github.com/odoo/odoo/blob/16.0/odoo/addons/base/data/ir_module_category_data.xml
    # for the full list
    'category': 'sales',
    'version': '0.1',

    # any module necessary for this one to work correctly
    'depends': ['base', 'account'],

    # always loaded
    'data': [
        'security/ir.model.access.csv',
        'views/views.xml',
        'views/res_config_settings.xml',
        'security/security.xml',
    ],
    'license': 'LGPL-3',
    'installable': True,
    'auto_install': False,
    'application': True,
}
