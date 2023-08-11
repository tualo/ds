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
    },
    initComponent: function(){
        var me = this;
        me.callParent(arguments);
        me.getView().getRowClass = function(record, rowIndex, rowParams, store) {
            // console.log('getRowClass',record, rowIndex, rowParams, store);
            if ((rowIndex%2==0)&&(typeof record.get( "_rowclass_even")=="string")){
                return record.get("_rowclass_even");
            }else if ((rowIndex%2==1)&&(typeof record.get("_rowclass_odd")=="string")){
                return record.get("_rowclass_odd");
            }

            me.fireEvent('rowclass',record, rowIndex, rowParams, store);
            return '';
        };
    }
});
