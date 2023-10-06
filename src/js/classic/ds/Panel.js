Ext.define('Tualo.DS.Panel', {
    extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    config: {
        additionalTools: [],
    },
    viewModel: {
        type:'dspanelmodel',
    },
    getWindowTitle: function(){
        return this.getViewModel().get('currentWindowTitle');
    },
    bind: {
        disabled: "{saving}"
    },
    "keyMap": {
        'ctrl+s': {
            handler: function(event,view) {
                event.stopEvent();
                view.getController().save();
            }
        },
        'cmd+s': {
            handler: function(event,view) {
                event.stopEvent();
                view.getController().save();
            }
        }
    },
    constructor: function(config){

        

        this.callParent([config]);


        

    },
    getStore: function(){
        return this.getComponent('list').getStore();
    },
    getList: function(){
        return this.getComponent('list');
    },
    dockedItems: [
        
    ]
})