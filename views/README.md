# Explicación de la carpeta views en ODOO

>[!IMPORTANT]
> Para un mayor entendimiento de las vistas, por favor consultar la documentación oficial de **ODOO** sobre [vistas](https://www.odoo.com/documentation/16.0/developer/tutorials/getting_started/07_basicviews.html)

**ODOO** guarda las vistas en esta carpeta, donde cada una es hecha de manera separada como un archivo .xml, en el cual se define el nombre de la vista, su modelo, su tipo y su estructura.

## Archivos
#### [views.xml](views.xml)
Vista principal del módulo facturafiscal

~~~xml
    <odoo>
  <data>
    <!-- Definición de la Vista de Árbol -->
    <record model="ir.ui.view" id="view_tree_fiscal">
      <field name="name">view.tree.fiscal</field>
      <field name="model">facturafiscal.facturafiscal</field>
      <field name="arch" type="xml">
        <tree class="custom_class">
          <!-- Campos que se mostrarán en la vista de árbol -->
          <field name="dverform" optional="none"/>
          <field name="iamb" optional="none"/>
          <field name="itpemis" optional="none"/>
          <field name="idoc" optional="none"/>
          <field name="dnrodf"/>
          <field name="dptofacdf" optional="none"/>
          <field name="dseg" optional="none"/>
          <field name="dfechaem" optional="none"/>
          <field name="inatop" optional="none"/>
          <field name="itipoop" optional="none"/>
          <field name="idest" optional="none"/>
          <field name="iformcafe" optional="none"/>
          <field name="ientcafe" optional="none"/>
          <field name="denvfe" optional="none"/>
          <field name="iprogen" optional="none"/>
          <field name="itipotranventa" optional="none"/>
          <field name="dtiporuc" optional="none"/>
          <field name="druc" optional="none"/>
          <field name="ddv" optional="none"/>
          <field name="dnombem" optional="none"/>
          <field name="dsucem" optional="none"/>
          <field name="dcoordem" optional="none"/>
          <field name="ddirecem" optional="none"/>
          <field name="dcodubi" optional="none"/>
          <field name="dcorreg" optional="none"/>
          <field name="ddist" optional="none"/>
          <field name="dprov" optional="none"/>
          <field name="dtfnem" optional="none"/>
          <field name="dcorelectemi" optional="none"/>
          <field name="itiporec" optional="none"/>
          <field name="dtiporucrec" optional="none"/>
          <field name="drucrec"/>
          <field name="ddvrec"/>
          <field name="dnombrec"/>
          <field name="ddirecrec" optional="none"/>
          <field name="dcodubirec" optional="none"/>
          <field name="dcorregrec" optional="none"/>
          <field name="ddistrec" optional="none"/>
          <field name="dprovrec" optional="none"/>
          <field name="dpaisrec" optional="none"/>
          <field name="dsecitem" optional="none"/>
          <field name="ddescprod" optional="none"/>
          <field name="dcodprod" optional="none"/>
          <field name="dcantcodint" optional="none"/>
          <field name="dcodcpbsabr" optional="none"/>
          <field name="dprunit" optional="none"/>
          <field name="dprunitdesc" optional="none"/>
          <field name="dpritem" optional="none"/>
          <field name="dvaltotitem" optional="none"/>
          <field name="dtasaitbms" optional="none"/>
          <field name="dvalitbms" optional="none"/>
          <field name="LisProduct" optional="none" />
          <field name="estadofactura" optional="none"/>
        </tree>
      </field>
    </record>

    <!-- Definición de la Acción de Ventana -->
    <record id="action_view_facturafiscal" model="ir.actions.act_window">
      <field name="name">Factura Fiscal</field>
      <field name="res_model">facturafiscal.facturafiscal</field>
      <field name="view_mode">tree,form</field>
    </record>

    <!-- Definición del Elemento de Menú -->
    <menuitem id="menu_facturafiscal" action="factura_fiscal.action_view_facturafiscal"/>

  </data>
</odoo>
~~~

#### [res_config_settings.xml](res_config_settings.xml)
Vista de configuración del módulo facturafiscal

~~~xml
    <?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>
        <!-- Definición de la Vista de Configuración -->
        <record id="res_config_settings_view_form" model="ir.ui.view">
            <field name="name">res.config.settings.view.form.factura</field>
            <field name="model">res.config.settings</field>
            <field name="inherit_id" ref="base.res_config_settings_view_form"/>
            <field name="arch" type="xml">
                <xpath expr="//div[hasclass('settings')]" position="inside">
                    
                    <!-- Bloque de configuración "Factura" -->
                    <div class="app_settings_block" data-string="Factura" id="factura" string="Factura" data-key="factura_fiscal">
                        <h2>Ajustes de la facturación fiscal</h2>
                        
                        <!-- Primera fila de opciones de configuración -->
                        <div class="row mt16 o_settings_container" id="factura_setting">
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class="o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Tipo de Ambiente</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="iamb_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Tipo de Ambiente</span>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class "o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Tipo de Emisión</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="itpemis_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Tipo de Emisión</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Segunda fila de opciones de configuración -->
                        <div class="row mt16 o_settings_container" id="factura_setting">
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class="o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Formato de CAFE</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="iformcafe_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Formato de Generación del CAFE</span>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class="o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Formato de CUFE</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="ientcafe_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Tipo de entrega del CUFE</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tercera fila de opciones de configuración -->
                        <div class="row mt16 o_settings_container" id="factura_setting">
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class="o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Versión del Formato</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="dverform_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Versión del Formato</span>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6 col-lg-6 o_setting_box">
                                <div class="o_setting_left_pane"/>
                                <div class="o_setting_right_pane">
                                    <span class="o_form_label">Envío del CUFE</span>
                                    <div class="text-muted content-group mt16">
                                        <field name="denvfe_conf_options" class="text-center" style="width: 100%; min-width: 4rem;" />
                                        <span> Tipo de envío del CUFE</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                </xpath>
            </field>
        </record>

        <!-- Definición de la Acción de Ventana para la Configuración -->
        <record id="factura_config_settings_action" model="ir.actions.act_window">
            <field name="name">Settings</field>
            <field name="type">ir.actions.act_window</field>
            <field name="res_model">res.config.settings</field>
            <field name="view_mode">form</field>
            <field name="target">inline</field>
            <field name="context">{'module' : 'factura_fiscal', 'bin_size': False}</field>
        </record>

        <!-- Elemento de Menú para Acceder a la Configuración -->
        <menuitem id="factura_config_settings_menu" name="Settings"
            parent="factura_fiscal.menu_facturafiscal" sequence="0" action="factura_config_settings_action"
            groups="base.group_system"/>
    </data>
</odoo>

~~~