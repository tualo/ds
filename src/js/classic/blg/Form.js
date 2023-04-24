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
    html: 'editor',
    loadRecord: function(record){
        console.log('loadRecord',record);
    }
});
