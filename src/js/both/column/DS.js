
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
                console.log(store,configStore);
                renderRecord = store.findRecord( column.tablename+"__"+column.idField , value,0,false,false,true);
                console.log('######',renderRecord);
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
        console.debug('initStore',this.$className,this.configStore);
        if (typeof Ext.data.StoreManager.lookup(this.configStore.storeId)=='undefined'){
            
            this.configStore.listeners = {
                scope: this,
                load: function(){ try{ this.up('grid').refresh(); }catch(e){ console.debug(e); } }
            }
            
            this.store = Ext.createByAlias('store.'+this.configStore.type, this.configStore );

        }
    }
    
});
  