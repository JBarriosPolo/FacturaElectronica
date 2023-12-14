# -*- coding: utf-8 -*-
from odoo import fields, models, api

class ResConfigSettings(models.TransientModel):
    _inherit = 'res.config.settings'

    dverform_conf_options = fields.Selection([('1.00','1.00')], string="Versión del formato", config_parameter='factura_fiscal.dverform_conf_options',default='1')

    iamb_conf_options = fields.Selection([('1','Producción'),('2','Pruebas')], string="Tipo de ambiente", config_parameter='factura_fiscal.iamb_conf_options',default='1')

    itpemis_conf_options = fields.Selection([('1','Normal'),('2','Contingencia')], string="Tipo de emisión", config_parameter='factura_fiscal.itpemis_conf_options',default='1')

    iformcafe_conf_options = fields.Selection([('1','Sin Generacion'),('2','Cinta de papel'),('3','Tamaño Carta')], string="Formato de generación del CAFE", config_parameter='factura_fiscal.iformcafe_conf_options',default='1')

    ientcafe_conf_options = fields.Selection([('1','Sin Generacion'),('2','Entrega Fisica'),('3','Entrega Electronica')], string="Manera de entrega del CAFE al receptor", config_parameter='factura_fiscal.ientcafe_conf_options',default='1')

    denvfe_conf_options = fields.Selection([('1','Normal'),('2','Excento')], string="Envío del contenedor para el receptor", config_parameter='factura_fiscal.denvfe_conf_options',default='1')

    iprogen_conf_options = fields.Selection([('1','Generación por el sistema de facturación del contribuyente'),('2','Generación por tercero contratado'),('3','Generacion gratuita por tercero proveedor de solucion'),('4','Generación gratuita por la DIRECCION GENERAL DE INGRESOS en página web')], string="Tipo de Generacion segun sistema", config_parameter='factura_fiscal.iprogen_conf_options',default='1')
    
    itipotranventa_conf_options = fields.Selection([('1','Venta de Giro del negocio'),('2','Venta Activo Fijo'),('3',' Venta de Bienes Raíces'),('4','Prestación de Servicio')], string="Tipo de transacción de venta", config_parameter='factura_fiscal.itipotranventa_conf_options',default='2')