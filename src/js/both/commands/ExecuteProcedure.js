Ext.define('Tualo.cmp.cmp_ds.commands.ExecuteProcedure', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.cmp_ds_executeprocedure',
    layout: 'fit',


    items: [
        {
          xtype: 'form',
          bodyPadding: '25px',
          items: [
            {
              xtype: 'label',
              text: 'Mit "Ausführen" wird die Routine "'+this.param+'" ausgeführt.',
            }
          ]
        }
      ],
      loadRecord: function(record,records,selectedrecords){
        this.record = record;
        this.records = records;
        this.selectedrecords = selectedrecords;
        this.list = [];
        this.selectedrecords.forEach((r)=>{
            this.list.push(r.get('__id'));
        });
      },
      getNextText: function(){
        return 'Ausführen';
      },
      run: async function(){
        let res= await Tualo.Fetch.post('./dsrun/'+this.param,{
          list: Ext.JSON.encode(this.list)
        });
        return res;
      }

  });
  