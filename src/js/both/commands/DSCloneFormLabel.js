Ext.define('Tualo.cmp.cmp_ds.commands.DSCloneFormLabel', {
    statics:{
      glyph: 'cogs',
      title: 'Labels übernehmen',
      tooltip: 'Labels übernehmen'
    },
    extend: 'Ext.panel.Panel',
    alias: ['widget.ds_cloneformlabel_command'],
    layout: 'fit',
    items: [
      {
        xtype: 'form',
        itemId: 'ds_cloneformlabel_commandform',
        bodyPadding: '25px',
        items: [
          {
            xtype: 'label',
            text: 'Durch klicken auf *Übernehmen*, werden die Labels aus dem Formular in die Liste übernommen',
          }
        ]
      }
    ],
    getNextText: function(){
    return 'Übernehmen';
    },
    run: async function(){
        let res= await Tualo.Fetch.post('./dsrun/ds_cloneformlabel',{
            list: Ext.JSON.encode([this.record.get('table_name')])
        });
        this.record.store.load();
        return res;
    },
    loadRecord: function(record,records,selectedrecords){
      this.record = record;
      this.records = records;
      this.selectedrecords = selectedrecords;
        console.log('loadRecord',arguments);
    }
  });
  