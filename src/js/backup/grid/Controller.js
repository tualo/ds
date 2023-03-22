Ext.define('Tualo.DataSets.grid.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsgridcontroller',
    onReload: function(){
        console.log('onReload',this.getView());
        this.getView().getStore().load();
    }
})
