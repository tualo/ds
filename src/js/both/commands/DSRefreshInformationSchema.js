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
      },
      {
        hidden: true,
        xtype: 'panel',
        itemId: 'waitpanel',
        layout:{
          type: 'vbox',
          align: 'center'
        },
        items: [
          {
            xtype: 'component',
            cls: 'lds-container',
            html: '<div class="lds-grid"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>'
            +'<h3>Datenstruktur wird verarbeitet</h3>'
            +'<h3>Einen Moment bitte ...</h3>'
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

      let me = this;
      me.getComponent('syncform').hide();
      me.getComponent('waitpanel').show();


      let res= await Tualo.Fetch.post('./dssetup/ds-update',{
      });
      this.record.store.load();
      return res;
    }
  });
