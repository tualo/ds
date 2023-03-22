Ext.define('Tualo.DataSets.store.Basic', {
  
    extend: 'Ext.data.Store',
    alias: 'store.tualobasicstore',
    type: 'json',
    autoLoad: false,
    autoSync: true,
    remoteFilter: true,
    remoteSort: true,
    pageSize: 100,

    
    proxy: {
        type: 'ajax',
        noCache: false,
        api: {
          read: './',
          create: './',
          update: './',
          destroy: './'
        },
        extraParams: {
        },
        writer: {
          type: 'json',
          writeAllFields: true,
          rootProperty: 'data'
        },
        reader: {
          type: 'json',
          rootProperty: 'data'
        },
        listeners: {
          exception: function(proxy, response, operation,eopts){
            var o,msg;
            try{
    
              if (typeof response.responseJson=='object'){
                o=response.responseJson;
              }else{
                o = Ext.JSON.decode(response.responseText);
              }
              
              msg = o.msg;
              Ext.toast({
               html: msg,
               title: 'Fehler ('+proxy.tablename+')',
               width: 400,
               align: 't'
             });
    
            }catch(e){
              msg = response.responseText;
            }
            operation.setException(msg);
          }
        }
      }
})  