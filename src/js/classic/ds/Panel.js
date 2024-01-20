Ext.define('Tualo.DS.Panel', {
    extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    config: {
        additionalTools: [],
    },
    requires: [
        'Tualo.ds.data.field.PropertyValue',
    ],
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
    loadById: function(id){
        this.getController().loadById(id);
        
    },
    filterBy: function(filter){
        this.getController().filterBy(filter);
    },
    searchFor: function(search){
        this.getController().searchFor(search);
    },
    dockedItems: [
        
    ]
})