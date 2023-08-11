Ext.define('Tualo.ds.lazy.models.DeferedCommand', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.lazy_ds_defered_command',
    data:{
        prevButtonText: 'Zurück',
        nextButtonText: 'Weiter',
        enableNext: false,
        enableCancel: true,
    },
    stores: {
        
    },
    formulas: {
        deferedCommandHtml: function(get){
            return '...';
        },
        nextDisabled: function(get){
            return !get('enableNext');
        },
        prevDisabled: function(get){
            return true;
        },
        cancelDisabled: function(get){
            return !get('enableCancel');;
        }
        
        
    }
});