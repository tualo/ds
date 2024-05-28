Ext.define('Tualo.DS.Panel', {
    extend: "Tualo.panel.Accordion",
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
    loadById: function(field,id){
        this.getController().loadById(id);

    },
    filterField: function(filter,value){
        this.getController().filterField(filter,value);
    },
    searchFor: function(search){
        this.getController().searchFor(search);
    },
    dockedItems: [
        
    ]
})