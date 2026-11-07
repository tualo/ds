Ext.define('Tualo.cmp.cmp_ds.commands.DSFTIndex', {
    statics: {
        glyph: 'search',
        title: 'Volltextsuche aufbauen',
        tooltip: 'Suchstruktur erstellen und Bestandsdaten indexieren'
    },
    extend: 'Ext.panel.Panel',

    getWindowTitle: function () {
        return 'Volltextsuche Einrichten'
    },
    getWindowIcon: function () {
        return 'fa-solid fa-gears';
    },
    alias: ['widget.ds_ftindex_command'],
    layout: 'fit',
    bodyPadding: '25px',
    items: [{
        xtype: 'component',
        itemId: 'instructions',
        html: ''
    }],
    loadRecord: function (record, records, selectedrecords) {
        this.record = record;
        this.tableName = record && record.get('table_name') || this.tablename;
        if (!this.tableName || !/^[a-zA-Z0-9_]+$/.test(this.tableName)) {
            throw new Error('Bitte eine Tabelle im Datenstamm auswählen.');
        }
        const table = Ext.String.htmlEncode(this.tableName);
        this.getComponent('instructions').setHtml(
            '<h3>Volltextsuche für ' + table + '</h3>' +
            '<p>Bitte zuerst die durchsuchbaren Felder im Datenstamm festlegen.</p>' +
            '<ol><li>Suchstruktur und Trigger erstellen.</li>' +
            '<li>Vorhandene Datensätze in die Suchtabelle übernehmen.</li></ol>' +
            '<p>Mit „Aufbauen“ werden beide Schritte nacheinander ausgeführt. ' +
            'Je nach Tabellengröße kann dies einige Zeit dauern.</p>'
        );
    },
    getNextText: function () {
        return 'Aufbauen';
    },
    run: async function () {
        try {
            this.setLoading('Schritt 1 von 2: Suchstruktur erstellen …');
            let result = await Tualo.Fetch.post('./dsft/run', {
                table_name: this.tableName,
                stage: 'build'
            });
            if (!result.success) throw new Error(result.msg || 'Suchstruktur konnte nicht erstellt werden.');
            this.setLoading('Schritt 2 von 2: Bestandsdaten indexieren …');
            result = await Tualo.Fetch.post('./dsft/run', {
                table_name: this.tableName,
                stage: 'refresh'
            });
            if (!result.success) throw new Error(result.msg || 'Bestandsdaten konnten nicht indexiert werden.');
            if (this.record && this.record.store) this.record.store.load();
            Ext.Msg.alert('Volltextsuche', 'Die Volltextsuche wurde aufgebaut und die Bestandsdaten wurden indexiert.');
            return result;
        } finally {
            this.setLoading(false);
        }
    }
});
