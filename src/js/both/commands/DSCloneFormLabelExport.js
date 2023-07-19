Ext.define('Tualo.cmp.cmp_ds.commands.DSCloneFormLabelExport', {
    statics:{
      glyph: 'cogs',
      title: 'Labels übernehmen',
      tooltip: 'Labels übernehmen'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.ds_cloneformlabel_export_command',
    layout: 'fit',
    items: [
      {
        xtype: 'form',
        itemId: 'ds_cloneformlabel_export_commandform',
        bodyPadding: '25px',
        items: [
          {
            xtype: 'label',
            text: 'Durch klicken auf *Übernehmen*, werden die Labels aus dem Formular in die Liste übernommen',
          }
        ]
      }
    ],
    loadRecord: function(record,records,selectedrecords){
      this.record = record;
      this.records = records;
      this.selectedrecords = selectedrecords;
        console.log('loadRecord',arguments);
    },
    getNextText: function(){
      return 'Übernehmen';
    },
    run: async function(){
      let res= await Tualo.Fetch.post('./dsrun/ds_cloneformlabelexport',{
        list: Ext.JSON.encode([this.record.get('table_name')])
      });
      return res;
    }
  });
  