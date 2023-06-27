Ext.define('Tualo.cmp.cmp_ds.commands.DSCloneFormLabelExport', {
    statics:{
      glyph: 'cogs',
      title: 'Labels übernehmen',
      tooltip: 'Labels übernehmen'
    },
    extend: 'Ext.panel.Panel',
    alias: ['widget.ds_cloneformlabel_export_command'],
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
    buttons: [
      {
        text: 'Schliessen',
        handler: function(btn){
          btn.up('ds_cloneformlabel_export_command').fireEvent('cancled');
        }
      },
      {
        text: 'Übernehmen',
        handler: function(btn){
          var me = btn.up('ds_cloneformlabel_export_command');
          Tualo.Ajax.request({
            showWait: true,
            params: {
              cmp: 'cmp_ds',
              p: 'proc/run',
              proc: 'ds_cloneformlabelexport',
              list: Ext.JSON.encode([me.record.get('ds_column_list_export__table_name')])
              
            },
            scope: this,
            json: function(o){
              btn.up('ds_cloneformlabel_export_command').fireEvent('cancled');
            }
          });
        }
      }
    ]
  });
  