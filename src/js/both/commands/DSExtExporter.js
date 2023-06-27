
Ext.define('Tualo.cmp.cmp_ds.commands.DSExtExporter', {
    statics: {
        glyph: 'file-excel',
        title: 'Excel exportieren'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.cmp_ds_extexporter_command',
    requires: [
       // 'Ext.exporter.excel.Xlsx',
       // 'Ext.grid.plugin.Exporter'
    ],
    plugins: {
        gridexporter: true
    },
    layout: 'fit',
    items: [
        {
            xtype: 'form',
            itemId: 'form',
            bodyPadding: '25px',
            items: [
                {
                    xtype: 'label',
                    text: 'Klicken Sie auf exportieren, um die aktuelle Ansicht der Liste als Excel-Mappe abzurufen. Achtung es werden nur die geladenen Zeilen exportiert, vergrößern Sie ggf. die Zeilenanzahl.',
                }
            ]
        }
    ],

    getNextText: function () {
        return 'Exportieren';
    },
    loadRecord: function (record, records, selectedrecords, parent) {
        let parent = Ext.getCmp(this.calleeId);
        this.record = record;
        this.records = records;
        this.parent = parent;
        this.selectedrecords = selectedrecords;
        this.list = parent.getList();
    },
    run: function () {
        this.list.saveDocumentAs({
            type: 'xlsx',
            fileName: this.parent.getViewModel().get('dsname') + '.xlsx'
        });

    }
});
