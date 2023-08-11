Ext.define('Tualo.DataSets.grid.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsgridcontroller',
    onDropGrid: function(node, data, overModel, dropPosition, eOpts){
        console.log('onDropGrid',node, data, overModel, dropPosition, eOpts);
    },
    onRowClass: function(record, rowIndex, rowParams, store){
        try{
            var tn = store.tablename||"";
            console.log('onRowClass',record, rowIndex, rowParams, store);
            if ((rowIndex%2==0)&&(typeof record.get( "_rowclass_even")=="string")){
                return record.get("_rowclass_even");
            }
            if ((rowIndex%2==1)&&(typeof record.get("_rowclass_odd")=="string")){
                return record.get("_rowclass_odd");
            }
    
        }catch(e){
            console.error(e);
        }
        return "";
    }
});