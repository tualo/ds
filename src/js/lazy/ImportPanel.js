Ext.define('Tualo.ds.lazy.ImportPanel', {
    extend: "Ext.panel.Panel",
    layout: 'card',
    requires: [
        'Tualo.ds.lazy.controller.ImportPanel',
        'Tualo.ds.lazy.models.ImportPanel'
    ],
    bodyPadding: 10,
    listeners: {
        boxReady: 'boxready'
    },
    controller: 'lazy_ds_import_panel',
    viewModel: {
        type: 'lazy_ds_import_panel'
    },


    items: [
        {
            xtype: 'form',
            bodyPadding: 10,
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{uploadFormHtml}'
                }
            }, {
                xtype: 'filefield',
                name: 'userfile',
                fieldLabel: 'Datei',
                labelWidth: 50,
                msgTarget: 'side',
                allowBlank: false,
                anchor: '100%',
                buttonText: 'Datei auswählen...'
            }],
        },
        {
            xtype: 'form',
            bodyPadding: 10,
            listeners: {
                show: 'onCheckShow'
            },
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{checkformFormHtml}'
                }
            }, {
                fieldLabel: 'Tabellenblatt',
                itemId: 'sheets',
                xtype: 'combobox',
                anchor: '100%',
                allowBlank: false,
                bind: {
                    store: '{sheets}',
                    value: '{currentSheetIndex}'
                },
                queryMode: 'local',
                displayField: 'name',
                valueField: 'id'
            }],
        },
        {
            xtype: 'form',
            bodyPadding: 10,
            listeners: {
                show: 'onExtractShow'
            },
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{extractHtml}'
                }
            }],
        },
        {
            //flex: 1,
            //border: true,
            xtype: 'grid',
            bind: {
                store: '{source}'
            },
            listeners: {
                show: 'onSourceShow'
            },
            selType: 'cellmodel',
            plugins: [
                {
                    ptype: 'cellediting',
                    clicksToEdit: 1
                }
            ],
            columns: [{
                header: 'Feld',
                dataIndex: 'text',
                width: 300
            }, {
                header: 'interne Bezeichnung',
                dataIndex: 'dataindex',
                width: 100
            }, {
                header: 'Zuordnung',
                dataIndex: 'name',
                renderer: 'renderNameColumn',
                field: {
                    xtype: 'combobox',
                    allowBlank: true,
                    bind: {
                        store: '{fields}'
                    },
                    queryMode: 'local',
                    displayField: 'name',
                    valueField: 'id'
                },
                flex: 1,

            }]
        }/*
        {
            xtype: 'panel',
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{sourceGridHtml}'
                }
            },
            
            ]
        }*/,
        {
            xtype: 'form',
            bodyPadding: 10,
            listeners: {
                show: 'onImportShow'
            },
            items: [{
                xtype: 'panel',
                bind: {
                    html: '{importHtml}'
                }
            }, {
                xtype: 'progressbar',
                bind: {
                    value: '{importProgress}'
                },
                width: '100%'
            }],
        }
    ],
    bodyPadding: 10,
    bbar: [
        '->',
        {
            text: 'Abbrechen',
            handler: 'cancel'
        },
        {
            bind: {
                text: '{prevButtonText}'
            },
            handler: 'prev'
        },
        {
            bind: {
                text: '{nextButtonText}'
            },
            handler: 'next'
        }
    ]
});