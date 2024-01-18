Ext.define("Tualo.DataSets.data.Store", {
  extend: 'Ext.data.Store',
  alias: 'store.tualo_datasets_json',
  requires: [
    'Ext.data.proxy.Ajax',
    'Ext.data.reader.Json',
    'Ext.data.writer.Json'
  ],
  getUpdatedRecords: function () {
    let records = this.callParent(arguments);
    console.log('getUpdatedRecords', records);
    return records;
  },
  constructor: function (config) {
    let me = this;
    config = Ext.apply({
      proxy: {
        type: 'ajax',
        noCache: false,
        api: {
          create: './ds/tbl/create',
          read: './ds/tbl/read',
          update: './ds/tbl/update',
          destroy: './ds/tbl/delete'
        },
        listeners: {
          scope: this,
          exception: function (proxy, response, operation, eOpts) {
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
            this.fireEvent('proxyerror', response);
          }
        },
        reader: {
          type: 'json',
          rootProperty: 'data',
          idProperty: '__id',
          clientIdProperty: '__clientid',
        },
        writer: {
          type: 'json',
          writeAllFields: false,

          transform: {
            fn: function (data, request) {
              let keySet = [];
              data.forEach(function (row) {
                let rec = me.findRecord('__id', row.__id, 0, false, false, true);
                if (rec.get('__virtual') && rec.get('__virtual') == 1) {
                  let r = rec.getData(
                    {
                      changes: false,
                      serialize: true
                    }
                  )
                  Object.keys(r).forEach((k) => {
                    keySet.indexOf(k) == -1 && keySet.push(k);
                  });
                }
                Object.keys(row).forEach((k) => {
                  keySet.indexOf(k) == -1 && keySet.push(k);
                });
              });

              data.forEach(function (row) {
                let rec = me.findRecord('__id', row.__id, 0, false, false, true);
                if (rec.get('__virtual') && rec.get('__virtual') == 1) {
                  console.log('virtual',

                    rec.getData(
                      {
                        changes: false,
                        serialize: true
                      }
                    )
                  );
                }
                keySet.forEach((k) => {
                  if (!row.hasOwnProperty(k))
                    row[k] = me.findRecord('__id', row.__id, 0, false, false, true).get(k);
                });
              });

              console.log('transform', data, request, keySet);
              return data;
            },
            scope: this
          }
        }
      }
    }, config);

    this.callParent([config]);

    this.proxy.setTimeout(6000000);
    this.proxy.tablename = this.tablename;
    this.getProxy().setApi({
      read: './ds/' + this.tablename + '/read',
      create: './ds/' + this.tablename + '/create',
      update: './ds/' + this.tablename + '/update',
      destroy: './ds/' + this.tablename + '/delete'
    });

    // console.log(this.$className,'constructor')
    //console.log(this,this.tablename);

  },
  remoteFilter: true,
  remoteSort: true,
  pageSize: 1000,
  autoLoad: false,
  autoSync: false

});