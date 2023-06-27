Ext.define('Tualo.ds.lazy.models.DeferedCommand', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.lazy_ds_defered_command',
    data:{
        prevButtonText: 'Zurück',
        nextButtonText: 'Weiter'
    },
    stores: {
        
    },
    formulas: {
        deferedCommandHtml: function(get){
            return '...';
        },
        nextDisabled: function(get){
            return true;
        },
        prevDisabled: function(get){
            return true;
        },
        cancelDisabled: function(get){
            return false;
        }
        
        
    }
});