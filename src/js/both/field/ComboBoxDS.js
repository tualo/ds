Ext.define('Tualo.cmp.cmp_ds.field.ComboBoxDS', {
    extend: 'Ext.field.ComboBox',
    xtype: 'cmp_ds_comboboxfield',
    value: 'To Do',
    constructor: function(config){
        this.callParent([config]);
        this.getStore().load();
    }
})