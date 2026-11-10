Ext.define("Tualo.DataSets.proxy.Proxy", {
    extend: 'Ext.data.proxy.Ajax',
    alias: 'proxy.tualo_datasets_json',
    requires: [
        'Ext.data.proxy.Ajax',
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'
    ],

    isCached: function (tablename) {
        if (
            (typeof Tualo == 'object') &&
            (typeof Tualo.ds == 'object') &&
            (typeof Tualo.ds.Cached == 'object') &&
            (typeof Tualo.ds.Cached.cached == 'object') &&
            (typeof Tualo.ds.Cached.cached[tablename] == 'object') &&
            (typeof Tualo.ds.Cached.cached[tablename]['data'] != 'undefined')
        ) {
            return true;
        }
        return false;
    },


    doRequest: function (operation) {
        var me = this,
            tablename = me.tablename,
            action = operation.getAction();
        if (action === 'read') {

            if (me.isCached(tablename)) {
                let request = me.buildRequest(operation);
                console.log('Tualo.DataSets.proxy.Proxy', tablename, 'isCached');

                id = operation.getId ? operation.getId() : null;
                method = (result, event) => {
                    let payload = Tualo.ds.Cached.cached[tablename];
                    let success = true;
                    response = {
                        request: request,
                        status: 200,
                        statusText: 'OK',
                        responseText: Ext.JSON.encode(payload),
                        responseJson: payload
                    }

                    me.processResponse(success, operation, request, response);
                }
                args = [tablename, id];
                console.log('Tualo.DataSets.proxy.Proxy', '>>>>>>>>>>><', tablename, 'isCached');
                method.apply(window, args);
                return request;
            }
        }
        return me.callParent(arguments);
    },

    setException: function (operation, response) {
        console.log('exception', response, operation);
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

        this.callParent([operation, response]);
    }
});
