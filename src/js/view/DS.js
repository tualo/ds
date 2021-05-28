Ext.define('Tualo.cmp.cmp_ds.view.DS', {
    extend: 'Ext.panel.Panel',
    header:{
        bind: {
            style: '{style}'
        }
    },
    viewModel: {
        data: {
            empty: '',
            selectRecordRecordNumber: 1,
            activeItem: 0,
            pageSize: 0,
            isNew: false,
            showFormOnAddRecord: true,
            visibleReference: 'list'
        },
        formulas: {
            iconListForm: function(get){
                if (get('visibleReference')=='list'){
                    return 'x-fa fa-edit';
                }else{
                    return 'x-fa fa-list';
                }
            },
            style: function(get){
                if (get('isNew')){
                    return {
                        'background-color': 'var(--confirm-color)'
                    }
                }
                return {
                    'background-color': 'var(--base-color)'
                }
            }
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
            items: [
                {
                    iconCls: 'x-fa fa-save',
                    handler: 'onSave'
                },
                {
                    iconCls: 'x-fa fa-plus',
                    handler: 'onAdd'
                },
                {
                    iconCls: 'x-fa fa-redo',
                    handler: 'onReject'
                }
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
                bind: {
                    iconCls: '{iconListForm}'
                },
                handler: 'onSegClicked'
            }]
        }
    ],
    bind: {
        activeItem: '{activeItem}'
    }
});