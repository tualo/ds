Ext.define('Tualo.cmp.cmp_ds.field.LinkedComboBoxDS', {
    extend: 'Ext.form.field.ComboBox',
    xtype: 'tualo_ds_linkedcomboboxfield',
    value: 'To Do',

    triggers: {
        opends: {
            cls: 'fa-solid fa-arrow-up-right-from-square',
            tooltip: "Den Datensatz öffnen",
            handler: function(btn) {
                console.log('wnd',btn);
                window.btn = btn;
                let tn = btn.getSelectedRecord().get('__table_name'),
                    name = btn.getName(),
                    route = "#ds/"+tn+'/'+name+'/'+btn.getValue();
                window.open(route,'_blank');
            }
        }
    },

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