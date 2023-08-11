Ext.define('Ext.cmp.cmp_ds.views.DSBatchChanges', {
    statics: {
      glyph: 'magic',
      title: 'Stapeländerungen',
      tooltip: 'Stapeländerungen'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.ds_batch_command',
    layout: 'fit',
    items: [
      {
        xtype: 'form',
        itemId: 'ds_batch_commandform',
        bodyPadding: '25px',
        items: [
          {
            xtype: 'label',
            text: 'Durch Klicken auf *Anwenden* werden die Änderungen auf alle Datensätze der aktuellen Liste angewendet',
          }
        ]
      }
    ],
    loadRecord: function (record, records, selectedrecords, view) {
      this.record = record;
      this.records = records;
      this.selectedrecords = selectedrecords;
      this.view = view;
      console.log('loadRecord', arguments);
    },
    getNextText: function () {
      return 'Anwenden';
    },
    run: async function () {
      this.record.store.each((record)=>{
        if (record.id != this.record.id){
            for( var key in this.record.modified){

                record.set(key,this.record.get(key));
            }
        }
        return true;
      });
      return null;
    }
  });
  