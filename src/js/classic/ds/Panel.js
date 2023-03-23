Ext.define('Tualo.DS.Panel', {
    extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    onListSelect: function(){
        console.log('onListSelect',arguments)
    }
})