
Ext.define('Tualo.cmp.cmp_ds.field.MissedXType', {
    extend: 'Ext.form.field.Display',
    alias: 'widget.missedxtypefield',
    text: '*missedxtypefield',
    initComponent: function(){
        console.log(this.$className,'initComponent',this.config.missedXtype)
        this.callParent(arguments);
    },
    setValue: function(value){
        console.debug(this.$className,'setValue',value)
        value = this.config.missedXtype+' not found!';

        try{
            let cls = Ext.ClassManager.getByAlias('widget.'+this.config.missedXtype);
            if (cls){

                let sql = 'insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ';
                sql += '( "Tualo",  "#name", "#name", "widget.#xtype", "#parent", "widget.textarea", "Ext.field.Text" )';
                sql += ' on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);';

                sql = sql.replace('#xtype',this.config.missedXtype);
                sql = sql.replace('#parent',cls.superclass.$className);
                sql = sql.replace('#name',cls.$className);
                sql = sql.replace('#name',cls.$className);
                
                console.info('+++++++++++++++++++++++++++++');
                console.info(sql);
                console.info('+++++++++++++++++++++++++++++');
            }
        }catch(e){
            console.error(e);
        }
        this.callParent(arguments);
    }   
})