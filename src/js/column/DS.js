
Ext.define("Tualo.cmp.cmp_ds.column.DS",{
    extend: 'Ext.grid.column.Column',
    alias: 'widget.tualo_cmp_ds_column',
    config:{
        renderer: function(val,record,dataIndex,cell,column){
            try{
                var store = Ext.data.StoreManager.lookup(this.configStore.storeId);
                if (store){
                    var renderRecord = store.findRecord( this.tablename+"__"+this.idField , val,0,false,false,true);
                    if (renderRecord){
                        val =  renderRecord.get(this.tablename+"__"+this.displayField);
                    }else{
                        cell.setStyle({
                            color: 'rgb(200,30,30)'
                        });
                    }
                }
            }catch(e){
                console.debug(e)
            }
            return val;
        }
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
            
            this.store = Ext.createByAlias('store.'+this.configStore.type, this.configStore );

        }
    }
    
});
  