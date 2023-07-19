Ext.define('Tualo.DataSets.grid.Grid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.dsgrid',
    constructor: function(config){
        let store = Ext.data.StoreManager.lookup('ds_'+this.tablename),
            storeConst = Ext.ClassManager.getByAlias('store.ds_'+this.tablename);
        if (typeof store=='undefined'){
            new storeConst();
        }
        console.debug(this.$className,'constructor')
        this.callParent([config]);
    }
});

