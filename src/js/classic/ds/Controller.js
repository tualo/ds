Ext.define('Tualo.DS.panel.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dspanelcontroller',
    onListSelect: function(view,record){
        console.log('onListSelect',arguments)
        let form = view.view.up().up().down('dsform_kandidaten');
        form.loadRecord(record)
    }
});