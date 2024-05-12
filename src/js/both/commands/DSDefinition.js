
Ext.define('Tualo.cmp.cmp_ds.commands.DSDefinition', {
    statics: {
        glyph: 'wrench',
        title: 'Definition exportieren'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.cmp_ds_definition_command',
    requires: [
       // 'Ext.exporter.excel.Xlsx',
       // 'Ext.grid.plugin.Exporter'
    ],
    layout: 'fit',
    items: [
        {
            xtype: 'form',
            itemId: 'form',
            bodyPadding: '25px',
            items: [
                {
                    xtype: 'label',
                    text: 'Klicken Sie auf exportieren, um die aktuelle Konfiguration des Datenstammes zu exportieren.',
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
        let config = {
            url: './dssetup/export/definition/'+this.record.get('table_name')+'',
            scope: this,
            showWait: true,
            timeout: 300000
        };
        Tualo.Ajax.download(config);
    }
});
