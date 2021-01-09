Ext.define('Tualo.cmp.cmp_ds.view.DS', {
    extend: 'Ext.panel.Panel',
    viewModel: {
        data: {
            empty: '',
            selectRecordRecordNumber: 1,
            activeItem: 0,
            pageSize: 0
        }
    },
    listeners: {
        painted: 'onPainted'
    },
    bbar: [
        '->',
        {
            xtype: 'container',
            defaults: {
                flex: '1 1 auto'
            },
            defaultType: 'button',
            layout: {
                type: 'box',
                vertical: false,
                align: 'stretch'
            },
            items: [{
                iconCls: 'x-fa fa-angle-left',
                handler: 'onPrev'
            }, {
                // cls: 'x-paneltitle',
                bind: {
                    html: '{selectRecordRecordNumber} / {total}'
                },
                style: {
                    paddingTop: '8px'
                },
                xtype: 'component'
            }, {
                xtype: 'spacer',
                width: 24
            }, {
                xtype: 'combobox',
                width: 85,
                store: {
                    type: 'array',
                    fields: ['size'],
                    data: [[25],[50],[100],[500],[1000],[5000],[10000],[100000]]
                },

                displayField: 'size',
                valueField: 'size',
                bind: {
                    value: '{pageSize}'
                },
            }, {
                iconCls: 'x-fa fa-angle-right',
                handler: 'onNext',
            }]
        }
    ],
    tools: [
        {
            xtype: 'container',
            defaults: {
                flex: '1 1 auto'
            },
            defaultType: 'button',
            layout: {
                type: 'box',
                vertical: false,
                align: 'stretch'
            },
            items: [{
                iconCls: 'x-fa fa-save',
                handler: 'onSave'
            },
            ]
        },
        {
            xtype: 'container',
            defaults: {
                flex: '1 1 auto'
            },
            defaultType: 'button',
            layout: {
                type: 'box',
                vertical: false,
                align: 'stretch'
            },
            items: [{
                iconCls: 'x-fa fa-list',
                //text: 'Liste',
                useReference: 'list',
                handler: 'onSegClicked'
            }, {
                iconCls: 'x-fa fa-edit',
                handler: 'onSegClicked',
                useReference: 'form',
                // text: 'Formular'
            }]
        }
    ],
    bind: {
        activeItem: '{activeItem}'
    }
});