Ext.define("Tualo.DataSets.proxy.Proxy", {
    extend: 'Ext.data.proxy.Ajax',
    alias: 'proxy.tualo_datasets_json',
    requires: [
        'Ext.data.proxy.Ajax',
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'
    ],

    setException: function (operation, response) {
        console.log('exception', proxy, response, operation, eOpts);
        if (response.responseJson) {
            let msg = response.responseJson.msg;
            if (!msg) msg = "Leider ist ein unbekannter Fehler aufgetreten.";
            Ext.toast({
                html: msg,
                title: 'Fehler',
                width: 200,
                align: 't'
            });
        }

        this.callParent(operation, response);
    }
});
