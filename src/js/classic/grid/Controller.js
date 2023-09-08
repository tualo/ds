Ext.define('Tualo.DataSets.grid.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsgridcontroller',
    onDropGrid: function(node, data, overModel, dropPosition, eOpts){
        if(Ext.getApplication().getDebug()===true)  console.log('onDropGrid',node, data, overModel, dropPosition, eOpts);
    }
});

