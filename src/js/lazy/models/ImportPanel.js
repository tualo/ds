Ext.define('Tualo.ds.lazy.models.ImportPanel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.lazy_ds_import_panel',
    data:{
        saving: false,
        initialized: false,
        record: null,
        config: null
    },
    formulas: {
        disabled: function(get){
            return Ext.isEmpty(get('record')) || get('saving');
        }
    }
});