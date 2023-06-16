Ext.define('Tualo.DS.fields.models.ListXtypeComboBox', {
  extend: 'Ext.app.ViewModel',
  alias: 'viewmodel.listxtype_model',
  data:{
    record: null
  },
  stores: {
    types: {
      type: 'json',
      autoLoad: true,
      autoSync: false,
      remoteFilter: true,
      pageSize: 1500,
      fields: [
        {name: 'id'},
        {name: 'name'}
      ],
      proxy: {
        type: 'ajax',
        api: {
          read: './dslib/column/xtypes'
        },
        writer: {
          type: 'json',
          writeAllFields: true,
          rootProperty: 'data',
        },
        reader: {
          type: 'json',
          rootProperty: 'data',
          idProperty: '__id'
        },
        listeners: {
          exception: function(proxy, response, operation){
            var o,msg;
            try{
              o = Ext.JSON.decode(response.responseText);
              msg = o.msg;
            }catch(e){
              msg = response.responseText;
            }
            Ext.MessageBox.show({
              title: 'Fehler',
              msg: msg,
              icon: Ext.MessageBox.ERROR,
              buttons: Ext.Msg.OK
            });
          }
        }
      }
    }
  }
});
