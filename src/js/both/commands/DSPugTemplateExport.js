
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
                    text: 'Klicken Sie auf exportieren, um die aktuelle PUGs zu exportieren.',
                },
                {
                    xtype: 'radiogroup',
                    fieldLabel: 'Auswahls',
                    // Arrange radio buttons into two columns, distributed vertically
                    columns: 2,
                    vertical: true,
                    items: [
                        { boxLabel: 'aktueller Datensatz', name: 'fav-color', inputValue: 'current', checked: true },
                        { boxLabel: 'aktuelle Auswahl', name: 'fav-color', inputValue: 'selection' },
                        { boxLabel: 'aktuelle Liste', name: 'fav-color', inputValue: 'list' }
                    ]
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
        let form = this.down('form'),
            values = form.getValues(),
            tasks = [];
        if (values['fav-color'] == 'current') {
            tasks.push(this.record);
        }
        if (values['fav-color'] == 'selection') {
            tasks = this.selectedrecords;
        }
        if (values['fav-color'] == 'list') {
            tasks = this.records;
        }

        for (let i = 0; i < tasks.length; i++) {
            let config = {
                url: './pugtemplates/export/' + tasks[i].get('id') + '',
                scope: this,
                showWait: true,
                timeout: 300000
            };

            Tualo.Ajax.download(config);
        }

    }
});
