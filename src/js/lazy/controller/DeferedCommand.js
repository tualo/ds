Ext.define('Tualo.ds.lazy.controller.DeferedCommand', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.lazy_ds_defered_command',
    boxready: function(){
        var me = this;
        console.log('boxready',me.getView().tablename,me.getView().command,me.getView().callee );

    },
    cancel: function(){
        console.log('cancel');
        window.history.back();
    },
    prev: function(){
         

    },
    next: function(){
 

    }   
});