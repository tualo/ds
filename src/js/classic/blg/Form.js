Ext.define('Tualo.DS.Report', {
    extend: "Ext.panel.Panel",
    alias: [
        'widget.dsreport',
        'widget.cmp_belege_report_editorform',
        'widget.cmp_belege_report_editor'
    ],
    bind: {
        disabled: "{saving}"
    },
    config: {
        record: null,
    },
    bodyPadding: 10,
    layout: {
        type: 'vbox',
        align: 'stretch'
    },
    items: [
        {
            xtype: 'panel',
            flex: 1,
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'panel',
                    flex: 1,
                    html: 'header a',
                },
                {
                    xtype: 'panel',
                    flex: 1,
                    html: 'header b',
                }
            ]
        },
        {
            xtype: 'dslist_view_editor_blg_pos_angebot',
            flex: 1,
            //html: 'table',
        },
        {
            xtype: 'panel',
            flex: 1,
            html: 'footer',
        }
    ],
    loadRecord: function(record){
        console.log('loadRecord',record);
    }
});
