# :floppy_disk: Confección y diseño del script de la base de datos postgresql :floppy_disk:

Se explicará cómo se confeccionó y realizó el **QUERY** para la recaudación de datos de la base de datos
que permite la creacion del contenedor **XML** que se usa para enviar la factura electronica a la **DGI**.

>[!WARNING]
>El script se realizó en **Postgresql** y se usó el lenguaje **PLPGSQL** para la confección del mismo, deberá consultar la documentación de **postgresql** para poder entender el script.

## Crearemos una **FUNCTION** que nos permita la creación del **XML** que se enviará a la **DGI**.

1. Se agregarán columnas a tablas ya existentes para poder realizar el **QUERY**.

    ```sql
        ALTER TABLE res_partner
        ADD X_DV TIPO_DE_DATO;
    ```
2. Se definirá la estructrura inicial del **QUERY**
    ```sql
        CREATE OR REPLACE FUNCTION Update_facturafiscal_facturafiscal() RETURNS TRIGGER AS
        $$
    ```
3. Se define la variable que usará el **QUERY** tanto para sus operaciones, como su almacenamiento.
    ```sql
        DECLARE
        -- Variables de Comprobacion
        nf_check TEXT;

        -- Variables de Sistema
        VerForm record;

        -- Variables de Ejecucion
        PartIdDest INTEGER;
    ```
>[!NOTE]
>Consulte **[Script.sql](script.sql)** para ver de manera más detallada las variables.

4. Inicie la composisicon del script.
    ```sql
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
                SELECT id INTO PartIdDest
                FROM res_partner
                WHERE name = 'DGI';
            END IF;
    ```
En el código anterior se realiza la consulta de los datos que se usarán para realizar una comprobación de existencia donde se define por medio de selección cuál es el registro a usar.

>[!WARNING]
>Puede aparentar una comprobación innecesaria, pero no lo es, ya que sirve para evitar errores en el script, dado que los registros de la tabla acoount_move no se crean de manera ordenada y cambian constántemente según el uso del sistema.

5. El resto del **QUERY** se desarrolla con herramientas comunes en el uso de las base de datos que usan la estructura de lenguajes **SQL**, dado esto, no se explicará el resto del **QUERY**, a menos que se considere necesario en alguno de sus pasos.

>[!NOTE]
>Consulte **[Script.sql](script.sql)** para ver el resto del **QUERY**.

6. En el **QUERY** encontrarán dos **FUNCTION** que se usan para la creación del **XML** el cual se enviará a la **DGI**, estas funciones son autónomas y se crean al momento de ejecutar el **QUERY**.

>[!WARNING]
>Las **FUNCTION** controlan parámetros esenciales como consulta de datos y la generación de un número de seguridad, el funcionamiento de este script depende de estas **FUNCTION**, no las modifique a menos que sepa lo que está haciendo y revise que se encuentren creadas después de ejecutar el **QUERY**.

## 📝 Nota:
En este script podrá encontrar **RAISE <span style="color:#F8D01A"> WARNING</span>**
esto es para que el script le avise de posibles errores que puedan ocurrir en el momento de ejecutar el script, si no desea que el script le avise de estos errores solo deberá comentar las lineas que contengan **RAISE <span style="color:#F8D01A"> WARNING </span>**.
