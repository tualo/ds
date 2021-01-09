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
                create  : './ds/lager/create',
                read    : './ds/lager/read',
                update  : './ds/lager/update',
                destroy : './ds/lager/delete'
              },
              reader: {
                  type: 'json',
                  rootProperty: 'data',
                  idProperty: '__id'
              },
              writer: 'json'
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

      //console.log(this,this.tablename);

  },

  remoteFilter: true,
  remoteSort: true,
  pageSize: 1000,
  autoLoad: false,
  autoSync: false

});
/*
{
    extends: "Ext.data.JsonStore",

    proxy: {
         type: 'ajax',
         api: {
            create  : './ds/tablename/create',
            read    : './ds/tablename/read',
            update  : './ds/tablename/update',
            destroy : './ds/tablename/delete'
         },
         reader: {
             type: 'json',
             rootProperty: 'data',
             idProperty: '__id'
         }
     },

     listeners: {
        beforesync: function( options, eOpts ){
          var store = null;
          if ((options.destroy) && (options.destroy[0])) store=options.destroy[0].store;
          if ((options.create) && (options.create[0])) store=options.create[0].store;
          if ((options.update) && (options.update[0])) store=options.update[0].store;
          store.proxy.setTimeout(60000);
          store.proxy.tablename = store.tablename;
          store.getProxy().setApi({
            read: './ds/'+store.tablename+'/read',
            create: './ds/'+store.tablename+'/create',
            update: './ds/'+store.tablename+'/update',
            destroy: './ds/'+store.tablename+'/delete'
          });
          return true;
        },
    
    
        beforeload: function(store,operation,eOpts){
          var store = this;
          store.proxy.setTimeout(60000);
          store.proxy.tablename = store.tablename;
          store.getProxy().setApi({
            read: './ds/'+store.tablename+'/read',
            create: './ds/'+store.tablename+'/create',
            update: './ds/'+store.tablename+'/update',
            destroy: './ds/'+store.tablename+'/delete'
          });
          return true;
        },
    
        write: function(store,operation,eOpts){
          var store = this;
          store.proxy.setTimeout(60000);
          store.proxy.tablename = store.tablename;
          store.getProxy().setApi({
              read: './ds/'+store.tablename+'/read',
              create: './ds/'+store.tablename+'/create',
              update: './ds/'+store.tablename+'/update',
              destroy: './ds/'+store.tablename+'/delete'
          });
         return true;
       },
    
       datachanged: function(store,eOpts){
        var store = this;
        store.proxy.setTimeout(60000);
        store.proxy.tablename = store.tablename;
        store.getProxy().setApi({
          read: './ds/'+store.tablename+'/read',
          create: './ds/'+store.tablename+'/create',
          update: './ds/'+store.tablename+'/update',
          destroy: './ds/'+store.tablename+'/delete'
        });
        return true;
       }
     },

     remoteFilter: true,
     remoteSort: true,
     pageSize: 1000,
     autoLoad: false,
     autoSync: false
});
*/