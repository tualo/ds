Ext.define('Tualo.DataSets.model.Schema', {
    extend: 'Ext.data.Model',

    // This configures the default schema because we don't assign an "id":
    schema: {
        proxy: {
            type: 'ajax',
            noCache: false,
            api: {
              create  : './ds/crontab/create',
              read    : './ds/crontab/read',
              update  : './ds/crontab/update',
              destroy : './ds/crontab/delete'
            },
            listeners: {
              scope: this,
              exception: function(proxy, response, operation, eOpts) {
                  this.fireEvent('proxyerror',response);
              }
            },
            reader: {
                type: 'json',
                rootProperty: 'data',
                idProperty: '__id'
            },
            writer: {
              type: 'json',
              writeAllFields: false,
              transform: {
                fn: function(data, request) {
                    let result = {}, key;
                    for (key in data) {
                      if (
                        data.hasOwnProperty(key) && ( 
                          ( data[key]!=null ) ||
                          ( this.model.getField(key).critical )
                        )
                      ) {
                          result[key] = data[key];
                      }
                  }
                  return result;
                },
                scope: this
            }
            }
        }
    }
});