Ext.define('Tualo.ds.lazy.controller.ImportPanel', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.lazy_ds_import_panel',

    upload: function(){
        var form = this.up('form').getForm();
        if(form.isValid()) {
            form.submit({
                url: '/dsimport/upload',
                waitMsg: 'Die Datei wird hochgeladen ...',
                success: function(fp, o) {
                    console.log('success', fp,o);
                }
            });
        }
    }
});