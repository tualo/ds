
Ext.define("Tualo.cmp.cmp_ds.column.DS",{
    extend: 'Ext.grid.column.Column',
    alias: 'widget.tualo_cmp_ds_column',
    
    renderer: function(value, metaData, record, rowIndex, colIndex, store ){
        try{
            let me = this,
                column = me.getColumns()[colIndex],
                configStore = column.configStore,
                storeId = configStore.storeId,
                store = Ext.data.StoreManager.lookup(storeId),
                renderRecord = null;
            if (store){
                renderRecord = store.findRecord( column.tablename+"__"+column.idField , value,0,false,false,true);
                if (renderRecord){
                    value =  renderRecord.get(column.tablename+"__"+column.displayField);
                }else{
                    metaData.tdStyle = "color: rgb(200,30,30)";
                }
            }
        }catch(e){
            console.debug(e)
        }
        return value;
    },
    constructor: function(config) {
        var me = this;
        me.callParent([config]);
        this.initStore();
    },
    initStore: function(){
        if (typeof Ext.data.StoreManager.lookup(this.configStore.storeId)=='undefined'){
            this.configStore.listeners = {
                scope: this,
                load: function(){ try{ this.up('grid').refresh(); }catch(e){ console.debug(e); } }
            }
            
            Ext.createByAlias('store.'+this.configStore.type, this.configStore );

        }else{
            console.debug('store already exists',Ext.data.StoreManager.lookup(this.configStore.storeId).getRange());  

        }
    }
    
});
  