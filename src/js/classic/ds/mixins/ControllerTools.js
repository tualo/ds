Ext.define('Tualo.DS.panel.mixins.ControllerTools', {
    refresh: function(){
        let store = this.getStore();
        store.load();
    },
    next: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber'));
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    prev: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber')-2);
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    reject: function(){ 
        var model = this.getViewModel(),
            store = this.getStore();
        store.rejectChanges();
    },
    
});