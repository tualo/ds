/**
 * Optionales Ext.Direct-Batching für DS-Stores.
 *
 * Aktiv nur, wenn der Server den Remoting-Provider ausgeliefert hat
 * (Konfiguration [ds] direct = 1 → Middleware bindet ./.ds/direct/api.js ein).
 * Ohne Provider fällt jeder Request transparent auf den bisherigen
 * Ajax-Weg zurück — bestehende Stores bleiben unverändert nutzbar.
 *
 * Mehrere Store-Loads innerhalb des Pufferfensters (enableBuffer) werden
 * von Ext.direct.Manager automatisch in einen einzigen HTTP-POST an
 * ./.ds/direct/router gebündelt.
 */
Ext.define('Tualo.DataSets.proxy.Direct', {
    override: 'Tualo.DataSets.proxy.Proxy',

    directApi: function () {
        var ns = window.Tualo && Tualo.DS && Tualo.DS.API;
        return (ns && ns.TualoDS) ? ns.TualoDS : null;
    },

    directTablename: function (action) {
        var api, url, m;
        // view_ds_store liefert tablename bereits in der Proxy-Config mit
        if (this.tablename) {
            return this.tablename;
        }
        api = this.getApi() || {};
        url = api[action] || api.read || this.getUrl();
        if (!url) {
            return null;
        }
        m = /(?:^|\/)\.?ds\/([A-Za-z0-9_]+)\//.exec(url);
        return m ? m[1] : null;
    },

    // tualo_datasets_json
    // Tualo.ds.Cached.cached
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
            api = me.directApi(),
            action = operation.getAction(),
            tablename = api && me.useDirect !== false ? me.directTablename(action) : null,
            request, writer, method, args, payload, id;

        if (!api || !tablename) {
            return me.callParent(arguments);
        }

        request = me.buildRequest(operation);
        writer = me.getWriter();

        if (action === 'read') {

            if (me.isCached(tablename)) {
                console.log('Tualo.DataSets.proxy.Direct', tablename, 'isCached');

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
                console.log('Tualo.DataSets.proxy.Direct', '>>>>>>>>>>><', tablename, 'isCached');
                method.apply(window, args);
                return request;
            }

            id = operation.getId ? operation.getId() : null;
            if (id !== null && id !== undefined) {
                method = api.readSingle;
                args = [tablename, id];
            } else {
                method = api.read;
                args = [tablename, request.getParams() || {}];
            }

        } else {
            if (writer && operation.allowWrite()) {
                request = writer.write(request);
            }
            payload = request.getJsonData();
            if (payload === null || payload === undefined) {
                payload = request.getParams() || {};
            }
            method = api[action]; // create | update | destroy
            args = [tablename, payload];
        }

        if (!method) {
            return me.callParent(arguments);
        }

        args.push(function (result, event) {
            var success = !!(event && event.status) && !!result && result.success !== false,
                payload = result || {
                    success: false,
                    msg: (event && event.message) || 'Ext.Direct exception'
                },
                response = {
                    request: request,
                    status: success ? 200 : 500,
                    statusText: success
                        ? 'OK'
                        : ((event && event.message) || (result && result.msg) || 'Ext.Direct exception'),
                    // der JSON-Reader liest aus responseText — muss das Result als String enthalten
                    responseText: Ext.JSON.encode(payload),
                    responseJson: payload
                };
            me.processResponse(success, operation, request, response);
        });

        method.apply(window, args);
        return request;
    }
});
