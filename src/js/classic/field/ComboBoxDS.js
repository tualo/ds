Ext.define('Tualo.cmp.cmp_ds.field.ComboBoxDS', {
    extend: 'Ext.form.field.ComboBox',
    xtype: 'cmp_ds_comboboxfield',
    value: 'To Do',
    constructor: function(config){
        this.callParent([config]);
        let store = this.getStore();
        store.on('beforeload',this.onBeforeLoad,this);
        store.load();
    },
    onBeforeLoad: function(store, operation, eOpts){
        console.log('onBeforeLoad',store,this,operation,eOpts);          
        store.getProxy().setExtraParams({

            /*tablename: store.tablename,
            fieldname: store.fieldname,
            value: store.value,
            query: store.query,
            pageSize: store.pageSize
            */
        });
    }
})