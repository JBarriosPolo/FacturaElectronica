CREATE OR REPLACE FUNCTION Update_facturafiscal_facturafiscal() RETURNS TRIGGER AS
$$

DECLARE
-- Variables de Comprobacion
nf_check TEXT;
mt_check TEXT;
rev_id INT;
rev_num TEXT;
nr_check TEXT;
io_catch TEXT;
io_check TEXT;

-- Variables de Sistema
VerForm record;
Amb record;
TpEmis record;
NroDf record; 
Doc TEXT;
PtoFacdf TEXT;
NumSeg TEXT;
FechaEm TEXT;
NatOp TEXT;
TipoOp TEXT;
Dest TEXT;
FormCafe record;
EntCafe record;
EnvFe record;
ProGen record;
TipoTranVenta record;
TipoRuc TEXT;
Ruc record;
DvEmi record;
NombEm record;
SucEm TEXT;
CoordEm TEXT;
DirecEm TEXT;
CodUbi TEXT;
Correg TEXT;
Dist TEXT;
Prov TEXT;
TfnEm record;
CorElectEmi record;
TipoRec TEXT;
TipoRucRec TEXT;
DirecRec TEXT;
CodUbiRec TEXT;
CorregRec TEXT;
DistRec TEXT;
ProvRec TEXT;
PaisRec TEXT;
SecItem TEXT;
DescProd TEXT;
CodProd TEXT;
CantCodInt TEXT;
CodCpBn TEXT;
LisProCat JSONB := '{}'::JSONB;
PrUnit TEXT;
PrUnitDesc TEXT;
PrItem TEXT;
ValTotItem TEXT;
TasaItbms TEXT;
ValItbms TEXT;
EstadoFactura TEXT;

-- Variables de Ejecucion
PartIdDest INTEGER;
CountIdDest INTEGER;
CompanyEmi INTEGER;
PartnerIdEmi INTEGER;
EmInfo record;
RecInfo record;
ProdInfo record;
DocRes VARCHAR;
Descuento NUMERIC;
Cantidad NUMERIC;
PrecioUnit NUMERIC;
SubTotal NUMERIC;


BEGIN

        SELECT sequence_number INTO nf_check
        FROM account_move
        ORDER BY id DESC
        LIMIT 1;

        SELECT move_type INTO mt_check 
        FROM account_move
        ORDER BY id DESC
        LIMIT 1;

        SELECT reversed_entry_id INTO rev_id
        FROM account_move
        ORDER BY id DESC
        LIMIT 1;

        SELECT (reverse(substring(reverse(name), 1, strpos(reverse(name), '/') - 1))) INTO rev_num
        FROM account_move
        ORDER BY id DESC
    LIMIT 1;

        SELECT name INTO nr_check
        FROM account_move 
        ORDER BY id DESC 
        LIMIT 1; 

        SELECT invoice_origin INTO io_catch 
        FROM account_move
        ORDER BY id DESC
        LIMIT 1;

        IF io_catch IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM sale_order WHERE name = io_catch) THEN
                        io_check := '1';
                ELSIF EXISTS (SELECT 1 FROM pos_order WHERE name = io_catch) THEN
                        io_check := '2';
                ELSE io_check := '0';
                END IF;
        ELSE io_check := '1';
        END IF;

    IF nf_check <> '0' AND mt_check = 'out_invoice' AND io_check = '1' THEN 

                -- version del formato
                SELECT value INTO VerForm FROM ir_config_parameter WHERE key = 'factura_fiscal.dverform_conf_options';

                -- Tipo de ambiente
                SELECT value INTO Amb FROM ir_config_parameter WHERE key = 'factura_fiscal.iamb_conf_options';

                -- Tipo de emision
                SELECT value INTO TpEmis FROM ir_config_parameter WHERE key = 'factura_fiscal.itpemis_conf_options';

                -- Tipo de documento
                SELECT (regexp_matches(name, '([^/]+)'))[1] INTO DocRes
                FROM account_move
                ORDER BY id DESC
                LIMIT 1;


                RAISE WARNING 'DocRes %', DocRes;
                RAISE WARNING 'VerForm %', VerForm;

                -- Funcion de tipo de documento
            Doc := idoc2_validator(ARRAY[DocRes]);

                -- Numero de Factura
                SELECT lpad(reverse(substring(reverse(name), 1, strpos(reverse(name), '/') - 1)), 10, '0') INTO NroDf
                FROM account_move
                ORDER BY id DESC
        LIMIT 1;

                -- Punto de factura
                SELECT
                CASE
                        WHEN invoice_origin IS NULL THEN '001'
                        ELSE NULL
                END
                INTO PtoFacdf
                FROM account_move
                ORDER BY id DESC
                LIMIT 1;

                -- Seguridad
                NumSeg := floor(random() * (999999999 - 100000000) + 100000000)::integer;

                -- Fecha de emision
                SELECT to_char(now() AT TIME ZONE 'America/Panama', 'YYYY-MM-DD"T"HH24:MI:SS"-05:00"') INTO FechaEm;

                -- Naturaleza de la operacion
                NatOp = NatOp_validator(ARRAY[DocRes]);

                -- Selecion de Naturaleza de la operacion
                SELECT move_type INTO mt_check 
                FROM account_move
                ORDER BY id DESC
                LIMIT 1;

                -- Tipo de operacion
                TipoOp := TipoOp_validator(ARRAY[mt_check]);

                -- Destino de la operacion
                SELECT partner_id INTO PartIdDest FROM account_move ORDER BY id DESC LIMIT 1;
                SELECT x_country_id INTO CountIdDest FROM res_partner WHERE id = PartIdDest;
                SELECT name->>'en_US' INTO Dest FROM res_country WHERE id = CountIdDest;

                -- Formato de Generacion
                SELECT value INTO FormCafe FROM ir_config_parameter WHERE key = 'factura_fiscal.iformcafe_conf_options';

                -- Manera de Entrega
                SELECT value INTO EntCafe FROM ir_config_parameter WHERE key = 'factura_fiscal.ientcafe_conf_options';

                -- Envio de Factura
                SELECT value INTO EnvFe FROM ir_config_parameter WHERE key = 'factura_fiscal.denvfe_conf_options';

                -- Proceso de Generacion de la FE
                SELECT value INTO ProGen FROM ir_config_parameter WHERE key = 'factura_fiscal.iprogen_conf_options';

                -- Tipo de Transaccion de Venta
                SELECT value INTO TipoTranVenta FROM ir_config_parameter WHERE key = 'factura_fiscal.itipotranventa_conf_options';

                -- id account_move res_company by emisor
                SELECT company_id INTO CompanyEmi FROM account_move ORDER BY id DESC LIMIT 1;

                -- id res_company res_partner by emisor
                SELECT partner_id INTO PartnerIdEmi FROM res_company WHERE id = CompanyEmi;

                -- Tipo de contribuyente
                SELECT 
                CASE
                        WHEN is_company = 'true' THEN 2
                        ELSE 1
                END 
                INTO TipoRuc
                FROM res_partner
                WHERE id = PartnerIdEmi;

                -- Ruc del emisor
                SELECT vat INTO Ruc FROM res_partner WHERE id = PartnerIdEmi;

                -- Digito Verificador
                SELECT x_dv INTO DvEmi FROM res_partner WHERE id = PartnerIdEmi;

                -- Nombre del Emisor
                SELECT name INTO NombEm FROM res_company WHERE id = CompanyEmi;

                -- Sucursal del emisor
                SELECT
                CASE
                        WHEN id > 1 THEN lpad('id', 4, '0')
                        ELSE '0000'
                END
                INTO SucEm
                FROM res_company
                WHERE id = CompanyEmi;

                -- Informacion del Emisor
                SELECT
                rp.vat AS RucEm,
                rp.x_dv AS DvEm,
                rp.display_name AS NombEm,
                rp.x_coordenadas AS CoordEm,
                rp.x_barrio AS DirecEm,
                rp.x_codubi AS CodUbiEm,
                initcap(correg.name) AS CorregEm,
                initcap(dist.name) AS DistEm,
                initcap(prov.name) AS ProvEm,
                pais.code AS PaisEm
                INTO EmInfo
                FROM res_partner rp
                LEFT JOIN corregimiento_corregimiento correg ON rp.x_corregimiento = correg.id
                LEFT JOIN distritos_distritos dist ON rp.x_distrito = dist.id
                LEFT JOIN provincias_provincias prov ON rp.x_provincia = prov.id
                LEFT JOIN res_country pais ON rp.x_country_id = pais.id
                WHERE rp.id = PartnerIdEmi;

                -- Telefono del Emisor
                SELECT phone INTO TfnEm FROM res_company WHERE id = CompanyEmi;

                -- Correo Electronico
                SELECT email INTO CorElectEmi FROM res_company WHERE id = CompanyEmi;

                -- Tipo de Receptor
                SELECT x_panama_company INTO TipoRec FROM res_partner WHERE id = PartIdDest;

                -- Informacion del Receptor
                SELECT 
        rp.vat AS RucRec, -- Ruc del Receptor
        rp.x_dv AS DvRec, -- Digito Verificador del Receptor
        rp.display_name AS NombRec, -- Nombre del Receptor
                rp.x_barrio AS DirecRec, -- Direccion del Receptor
                rp.x_codubi AS CodUbiRec, -- Codigo de Ubicacion
                initcap(correg.name) AS CorregRec, -- Corregimiento
                initcap(dist.name) AS DistRec, -- Distrito
                initcap(prov.name) AS ProvRec, -- Provincia
                pais.code AS PaisRec -- Pais
                INTO RecInfo
                FROM res_partner rp
                LEFT JOIN corregimiento_corregimiento correg ON rp.x_corregimiento = correg.id
                LEFT JOIN distritos_distritos dist ON rp.x_distrito = dist.id
                LEFT JOIN provincias_provincias prov ON rp.x_provincia = prov.id
                LEFT JOIN res_country pais ON rp.x_country_id = pais.id
                WHERE rp.commercial_partner_id = PartIdDest;

                -- Tipo de Contribuyente (Receptor)
                SELECT 
                CASE
                        WHEN is_company = 'true' THEN '2'
                        ELSE '1'
                END 
                INTO TipoRucRec
                FROM res_partner
                WHERE commercial_partner_id = PartIdDest;

                -- lista de Productos
                LisProCat := obtener_ids_json();

                -- Productos
                SELECT 
                        pt.name->>'es_PA' AS description,
                        CAST(aml.quantity AS INTEGER) AS quantity,
                        pp.default_code AS default_code,
                        aml.price_unit AS price_unit,
                        aml.discount AS discount,
                        aml.price_subtotal AS price_subtotal,
                        aml.price_total AS price_total,
                        tax_info.tax_line_id as tax_type,
                        tax_info.credit as tax_credit
                INTO ProdInfo
                FROM account_move am
                JOIN account_move_line aml ON am.id = aml.move_id
                JOIN product_product pp ON aml.product_id = pp.id
                JOIN product_template pt ON pp.product_tmpl_id = pt.id
                LEFT JOIN (SELECT tax_line_id, move_id, credit FROM account_move_line WHERE display_type = 'tax') tax_info ON aml.move_id = tax_info.move_id
                ORDER BY am.id DESC
                LIMIT 1;

                Descuento := ProdInfo.discount;
                Cantidad := ProdInfo.quantity;
                PrecioUnit := ProdInfo.price_unit;
                SubTotal := ProdInfo.price_subtotal;

                IF Descuento IS NULL THEN
                        Descuento := 0;
                ELSIF Descuento IS NOT NULL THEN
                        Descuento := PrecioUnit * Cantidad - SubTotal;
                END IF;

                -- Insertar en la tabla de facturas fiscales
                INSERT INTO facturafiscal_facturafiscal(
                        dverform, -- Version del formato
                        iamb, -- Ambiente
                        itpemis, -- Tipo de emision
                        idoc, -- Tipo de documento
                        dnrodf, -- Numero de Factura
                        dptofacdf, -- Punto de Facturacion
                        dseg, -- Seguridad
                        dfechaem, -- Fecha de emision
                        inatop, -- Naturaleza de la operacion
                        itipoop, -- Tipo de operacion
                        idest, -- Destino
                        iformcafe, -- Formato de Generacion
                        ientcafe, -- Manera de Entrega
                        denvfe, -- Envio de Factura
                        iprogen, -- Proceso de Generacion de la FE
                        itipotranventa, -- Tipo de Transaccion de Venta
                        dtiporuc, -- Tipo de Contribuyente
                        druc, -- Ruc del Emisor
                        ddv, -- Digito Verificador del Emisor
                        dnombem, -- Nombre del Emisor
                        dsucem, -- Sucursal del Emisor
                        dcoordem,
                        ddirecem,
                    dcodubi,
                        dcorreg,
                        ddist,
                        dprov,
                        dtfnem, -- Telefono del Emisor
                        dcorelectemi, -- Correo Electronico del Emisor
                        itiporec,
                        dtiporucrec, -- Tipo de Contribuyente (Receptor)
                        drucrec, -- Ruc del Receptor
                        ddvrec, -- Digito Verificador del Receptor
                        dnombrec, -- Nombre del Receptor
                        ddirecrec,
                        dcodubirec,
                        dcorregrec,
                        ddistrec,
                        dprovrec,
                        dpaisrec,
                        dsecitem,
                        ddescprod, -- Descripcion del Producto ***
                        dcodprod, -- Codigo del Producto
                        dcantcodint, -- Cantidad en Unidad de medida del codigo interno
                        --dcodcpbsabr,
                        "LisProduct",
                        dprunit, -- Precio Unitario
                        dprunitdesc, -- Descuento
                        dpritem, -- Precio Total (Precio Unitario - Descuento)
                        dvaltotitem, -- Valor Total del Item
                        dtasaitbms, -- Tasa de ITBMS
                        dvalitbms -- Valor de ITBMS
                        )
                VALUES(
                        VerForm.value, -- Version del formato
                        Amb.value, -- Ambiente;
                        TpEmis.value, -- Tipo de emision
                        Doc, -- Tipo de documento
                        NroDf.lpad, -- Numero de Factura
                        PtoFacdf, -- Punto de Facturacion
                        NumSeg,
                        FechaEm,
                        NatOp,
                        TipoOp,
                        Dest,
                        FormCafe.value,
                        EntCafe.value,
                        EnvFe.value,
                        ProGen.value,
                        TipoTranVenta.value,
                        TipoRuc,
                        Ruc.vat,
                        DvEmi.x_dv,
                        NombEm.name,
                        SucEm,
                        EmInfo.CoordEm,
                        EmInfo.DirecEm,
                        EmInfo.CodUbiEm,
                        EmInfo.CorregEm,
                        EmInfo.DistEm,
                        EmInfo.ProvEm,
                        TfnEm.phone,
                        CorElectEmi.email,
                        TipoRec,
                        TipoRucRec,
                        RecInfo.RucRec,
                        RecInfo.DvRec,
                        RecInfo.NombRec,
                        RecInfo.DirecRec,
                        RecInfo.CodUbiRec,
                        RecInfo.CorregRec,
                        RecInfo.DistRec,
                        RecInfo.ProvRec,
                        RecInfo.PaisRec,
                        SecItem,
                        ProdInfo.description,
                        ProdInfo.default_code,
                        ProdInfo.quantity,
                        --CodCpBn,
                        LisProCat,
                        ProdInfo.price_unit,
                        Descuento,
                        ProdInfo.price_subtotal,
                        ProdInfo.price_total,
                        ProdInfo.tax_type,
                        ProdInfo.tax_credit
                        );

        ELSIF rev_id <> 0 AND mt_check = 'out_refund' AND rev_num <> '0' AND nr_check <> '/' THEN

                -- version del formato
                SELECT value INTO VerForm FROM ir_config_parameter WHERE key = 'factura_fiscal.dverform_conf_options';

                -- Tipo de ambiente
                SELECT value INTO Amb FROM ir_config_parameter WHERE key = 'factura_fiscal.iamb_conf_options';

                -- Tipo de emision
                SELECT value INTO TpEmis FROM ir_config_parameter WHERE key = 'factura_fiscal.itpemis_conf_options';

                -- Tipo de documento
                SELECT (regexp_matches(name, '([^/]+)'))[1] INTO DocRes
                FROM account_move 
                ORDER BY id DESC
                LIMIT 1;

                -- Funcion de tipo de documento
                Doc := idoc2_validator(ARRAY[DocRes]);

                -- Numero de Factura
                SELECT lpad(reverse(substring(reverse(name), 1, strpos(reverse(name), '/') - 1)), 10, '0') INTO NroDf
                FROM account_move
                ORDER BY id DESC
        LIMIT 1;

                -- Punto de factura
                SELECT
                        CASE
                                WHEN invoice_origin IS NULL THEN '001'
                                ELSE NULL
                        END
                INTO PtoFacdf
                FROM account_move
                ORDER BY id DESC
                LIMIT 1;

                -- Numero de Seguridad
                NumSeg := floor(random() * (999999999 - 100000000) + 100000000)::integer;

                -- Fecha de Emision
                SELECT to_char(now() AT TIME ZONE 'America/Panama', 'YYYY-MM-DD"T"HH24:MI:SS"-05:00"') INTO FechaEm;

                -- Naturaleza de la operacion
                NatOp = NatOp_validator(ARRAY[DocRes]);

                -- Selecion de Naturaleza de la operacion
                SELECT move_type INTO mt_check 
                FROM account_move
                ORDER BY id DESC
                LIMIT 1;

                -- Tipo de operacion
                TipoOp = TipoOp_validator(ARRAY[mt_check]);

                -- Destino de la operacion
                SELECT partner_id INTO PartIdDest FROM account_move ORDER BY id DESC LIMIT 1;
                SELECT country_id INTO CountIdDest FROM res_partner WHERE id = PartIdDest;
                SELECT name->>'en_US' INTO Dest FROM res_country WHERE id = CountIdDest;

                -- Formato de Generacion
                SELECT value INTO FormCafe FROM ir_config_parameter WHERE key = 'factura_fiscal.iformcafe_conf_options';

                -- Manera de Entrega
                SELECT value INTO EntCafe FROM ir_config_parameter WHERE key = 'factura_fiscal.ientcafe_conf_options';

                -- Envio de Factura
                SELECT value INTO EnvFe FROM ir_config_parameter WHERE key = 'factura_fiscal.denvfe_conf_options';

                -- Proceso de Generacion de la FE
                SELECT value INTO ProGen FROM ir_config_parameter WHERE key = 'factura_fiscal.iprogen_conf_options';

                -- Tipo de Transaccion de Venta
                SELECT value INTO TipoTranVenta FROM ir_config_parameter WHERE key = 'factura_fiscal.itipotranventa_conf_options';

                -- id account_move res_company by emisor
                SELECT company_id INTO CompanyEmi FROM account_move ORDER BY id DESC LIMIT 1;

                -- id res_company res_partner by emisor
                SELECT partner_id INTO PartnerIdEmi FROM res_company WHERE id = CompanyEmi;

                -- Tipo de contribuyente
                SELECT 
                CASE
                        WHEN is_company = 'true' THEN 2
                        ELSE 1
                END 
                INTO TipoRuc
                FROM res_partner
                WHERE id = PartnerIdEmi;

                -- Ruc del emisor
                SELECT vat INTO Ruc FROM res_partner WHERE id = PartnerIdEmi;

                -- Digito verificador
                SELECT x_dv INTO DvEmi FROM res_partner WHERE id = PartnerIdEmi;

                -- nombre del emisor
                SELECT name INTO NombEm FROM res_company WHERE id = CompanyEmi;

                -- Sucursal del emisor
                SELECT
                CASE
                        WHEN id > 1 THEN lpad(CompanyEmi, 4, '0')
                        ELSE '0000'
                END
                INTO SucEm
                FROM res_company
                WHERE id = CompanyEmi;

                -- coordenadas del emisor
                SELECT x_coordenadas INTO CoordEm FROM res_partner WHERE id = PartnerIdEmi;
                -- direccion del emisor
                -- ubicacion del emisor
                -- corregimiento del emisor
                SELECT x_corregimiento INTO Correg FROM res_partner WHERE id = PartnerIdEmi;
                -- distrito del emisor
                SELECT x_distrito INTO Dist FROM res_partner WHERE id = PartnerIdEmi;
                -- provincia del emisor
                SELECT x_provincia INTO Prov FROM res_partner WHERE id = PartnerIdEmi;

                -- Telefono del Emisor
                SELECT phone INTO TfnEm FROM res_company WHERE id = CompanyEmi;

                -- Correo Electronico
                SELECT email INTO CorElectEmi FROM res_company WHERE id = CompanyEmi;

                -- Informacion del Receptor
                SELECT 
                vat, -- Ruc del Receptor
                x_dv, -- Digito Verificador del Receptor
                display_name -- Nombre del Receptor
                INTO RecInfo
                FROM res_partner
                WHERE commercial_partner_id = PartIdDest;

                -- Tipo de Contribuyente (Receptor)
                SELECT 
                CASE
                        WHEN is_company = 'true' THEN '2'
                        ELSE '1'
                END 
                INTO TipoRucRec
                FROM res_partner
                WHERE commercial_partner_id = PartIdDest;

                -- lista de Productos

                LisProCat := obtener_ids_json();

--









-- debera ponerse en contacto con el creador de esta documentacion el resto de codigo













--

CREATE OR REPLACE FUNCTION idoc2_validator(arr VARCHAR[])
RETURNS VARCHAR AS $$
DECLARE
    resultado VARCHAR := '';
    elemento VARCHAR;
BEGIN
    FOREACH elemento IN ARRAY arr
    LOOP
        IF elemento = 'RINV' THEN 
            resultado := resultado || '09';
        ELSIF elemento = 'INV' THEN 
            resultado := resultado || '01';
        ELSE 
            resultado := resultado || 'fallo';
        END IF;
    END LOOP;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION NatOp_validator(arr VARCHAR[])
RETURNS VARCHAR AS $$
DECLARE
    resultado VARCHAR := '';
    elemento VARCHAR;
BEGIN
    FOREACH elemento IN ARRAY arr
    LOOP
        IF elemento = 'RINV' THEN 
            resultado := resultado || '11';
        ELSIF elemento = 'INV' THEN 
            resultado := resultado || '01';
        ELSE 
            resultado := resultado || 'fallo';
        END IF;
    END LOOP;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION TipoOp_validator(arr VARCHAR[])
RETURNS VARCHAR AS $$
DECLARE
    resultado VARCHAR := '';
    elemento VARCHAR;
BEGIN
    FOREACH elemento IN ARRAY arr
    LOOP
        IF elemento = 'entry' THEN 
            resultado := resultado || '2';
        ELSIF elemento = 'out_invoice' THEN 
            resultado := resultado || '1';
        ELSE 
            resultado := resultado || 'fallo';
        END IF;
    END LOOP;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION last_record_to_xml(tablename text, order_column text)
RETURNS xml LANGUAGE plpgsql AS $$
DECLARE
    result xml;
BEGIN
    -- Ejecutar la consulta para obtener el último registro y convertirlo en XML lineal
    EXECUTE format('SELECT query_to_xml(''SELECT * FROM %I ORDER BY %I DESC LIMIT 1'', false, false, '''')', tablename, order_column) INTO result;
    
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION obtener_ids_json()
RETURNS JSONB AS $$
DECLARE 

        v_description TEXT;
        v_default_code TEXT;
        v_quantity TEXT;
        v_price_unit TEXT;
        v_discount TEXT;
        v_price_subtotal TEXT;
        v_price_total TEXT;
        v_tax_type TEXT;
        v_tax_credit TEXT;
  
    resultado JSONB := '{}'::JSONB;
        productos_array JSONB;
    id_actual INT;
    etiqueta_actual INT := 1;
    etiqueta_text TEXT;
    descripcion_producto TEXT;
    cur CURSOR FOR SELECT MAX(id) FROM account_move; -- Seleccionamos solo el ID más grande
    cur_line CURSOR IS 
                                        SELECT 
                                          pt.name->>'es_PA' AS description,
                                          pp.default_code AS default_code,
                                          CAST(aml.quantity AS INTEGER) AS quantity,
                                          aml.price_unit AS price_unit,
                                          aml.discount AS discount,
                                          aml.price_subtotal AS price_subtotal,
                                          aml.price_total AS price_total,
                                          tax_info.tax_line_id as tax_type,
                                          tax_info.credit as tax_credit
                                        FROM account_move am
                                        JOIN account_move_line aml ON am.id = aml.move_id AND aml.move_id = id_actual AND aml.display_type = 'product'
                                        JOIN product_product pp ON aml.product_id = pp.id
                                        JOIN product_template pt ON pp.product_tmpl_id = pt.id
                                        LEFT JOIN (SELECT tax_line_id, move_id, credit FROM account_move_line WHERE display_type = 'tax') tax_info ON aml.move_id = tax_info.move_id
                                        ORDER BY am.id DESC;
BEGIN
    OPEN cur;
    FETCH cur INTO id_actual;
    CLOSE cur; -- Cerramos el cursor cur ya que solo tiene un registro

    OPEN cur_line;
    etiqueta_actual := 1;
    productos_array := '[]'::JSONB;
    FETCH cur_line INTO
        v_description,
        v_default_code,
        v_quantity,
        v_price_unit,
        v_discount,
        v_price_subtotal,
        v_price_total,
        v_tax_type,
        v_tax_credit;

    WHILE FOUND LOOP
        etiqueta_text := lpad(etiqueta_actual::TEXT, 4, '0');
        productos_array = productos_array || jsonb_build_object(
            'dSecItem', etiqueta_text,
            'dDescProd', v_description,
                        'dCodProd', v_default_code,
                        'dCantCodInt', v_quantity,
            'dPrUnit', v_price_unit,
            'dPrUnitDesc', v_discount,
            'dPrItem', v_price_subtotal,
            'dValTotItem', v_price_total,
            'dTasaITBMS', v_tax_type,
            'dValITBMS', v_tax_credit
        );

        etiqueta_actual := etiqueta_actual + 1;
        FETCH cur_line INTO
            v_description,
            v_default_code,
            v_quantity,
            v_price_unit,
            v_discount,
            v_price_subtotal,
            v_price_total,
            v_tax_type,
            v_tax_credit;
    END LOOP;
    CLOSE cur_line;

    RETURN jsonb_build_object('gItems', productos_array);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER Update_facturafiscal_facturafiscal
BEFORE UPDATE ON account_move
FOR EACH ROW
EXECUTE FUNCTION Update_facturafiscal_facturafiscal();