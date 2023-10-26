Ext.define('Tualo.ds.lazy.DeferedCommand',{
    extend: "Ext.panel.Panel",
    layout: 'card',
    requires:[
        'Tualo.ds.lazy.controller.DeferedCommand',
        'Tualo.ds.lazy.models.DeferedCommand'
    ],
    bodyPadding: 10,
    listeners: {
        boxReady: 'boxready'
    },
    controller: 'lazy_ds_defered_command',
	viewModel: {
		type: 'lazy_ds_defered_command'
	},
    items: [
        { 
            xtype: 'panel',
            bodyPadding: 10,
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{deferedCommandHtml}'
                }
            }],
        }
    ],
    bodyPadding: 10,
    bbar: [
        '->',
        {
            text: 'Abbrechen',
            handler: 'cancel',
            bind: {
                disabled: '{cancelDisabled}'
            }
        },
        {
            bind: {
                text: '{prevButtonText}',
                disabled: '{prevDisabled}'
            },
            handler: 'prev'
        },
        {
            bind: {
                text: '{nextButtonText}',
                disabled: '{nextDisabled}'
            },
            handler: 'next'
        }   
    ]
});