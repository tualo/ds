Ext.define('Tualo.cmp.cmp_ds.commands.DSRefreshInformationSchema', {
    statics:{
      glyph: 'database',
      title: 'Auffrischen',
      tooltip: 'Auffrischen'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.ds_refresh_information_schema_command',
    layout: 'fit',
    items: [
      {
        xtype: 'form',
        itemId: 'syncform',
        bodyPadding: '25px',
        items: [
          {
            xtype: 'label',
            text: 'Durch klicken auf *Aktualisieren*, werden die Metadaten aktualisiert.',
          }
        ]
      }
    ],
    loadRecord: function(record,records,selectedrecords){
      this.record = record;
      this.records = records;
      this.selectedrecords = selectedrecords;
  
    },
    getNextText: function(){
      return 'Aktualisieren';
    },
    run: async function(){
      let res= await Tualo.Fetch.post('./dssetup/ds-update',{
      });
      return res;
    }
  });
