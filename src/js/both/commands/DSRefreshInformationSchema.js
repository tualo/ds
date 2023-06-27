Ext.define('Tualo.cmp.cmp_ds.commands.DSRefreshInformationSchema', {
    statics:{
      glyph: 'database',
      title: 'Auffrischen',
      tooltip: 'Auffrischen'
    },
    extend: 'Ext.panel.Panel',
    alias: ['widget.ds_refresh_information_schema_command'],
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
    buttons: [
      {
        text: 'Schliessen',
        handler: function(btn){
          btn.up('ds_refresh_information_schema_command').fireEvent('cancled');
        }
      },
      {
        text: 'Aktualisieren',
        handler: function(btn){
          var me = btn.up('ds_rmcache_command');
          var vals = btn.up('ds_refresh_information_schema_command').getComponent('syncform').getForm().getValues();
          Tualo.Ajax.request({
            showWait: true,
            url: './dssetup/ds-update',
            
            
            scope: this,
            json: function(o){
              btn.up('ds_refresh_information_schema_command').fireEvent('cancled');
            }
          })
        }
      }
    ]
  });
