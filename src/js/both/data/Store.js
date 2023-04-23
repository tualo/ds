Ext.define("Tualo.DataSets.data.Store",{
    extend: 'Ext.data.Store',
    alias: 'store.tualo_datasets_json',
    requires: [
        'Ext.data.proxy.Ajax',
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'
    ],
    constructor: function(config) {
        config = Ext.apply({
            proxy: {
                type: 'ajax',
                noCache: false,
                api: {
                  create  : './ds/tbl/create',
                  read    : './ds/tbl/read',
                  update  : './ds/tbl/update',
                  destroy : './ds/tbl/delete'
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
        }, config);
  
        this.callParent([config]);
        
        this.proxy.setTimeout(60000);
        this.proxy.tablename = this.tablename;
        this.getProxy().setApi({
          read: './ds/'+this.tablename+'/read',
          create: './ds/'+this.tablename+'/create',
          update: './ds/'+this.tablename+'/update',
          destroy: './ds/'+this.tablename+'/delete'
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