Ext.define('Tualo.ds.lazy.ImportPanel',{
    extend: "Ext.form.Panel",
    requires:[
        'Tualo.ds.lazy.controller.ImportPanel',
        'Tualo.ds.lazy.models.ImportPanel'
    ],
    bodyPadding: 10,
    
    controller: 'lazy_ds_import_panel',
	viewModel: {
		type: 'lazy_ds_import_panel'
	},
    bind: {
        disabled: "{disabled}"
    },
    config: {
        record: null,
    },
    bodyPadding: 10,
    layout: {
        type: 'vbox',
        align: 'stretch'
    },
    html: 'test'
});