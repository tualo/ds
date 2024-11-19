Ext.define('Tualo.cmp.cmp_ds.commands.DSFTIndex', {
    statics:{
      glyph: 'cogs',
      title: 'Labels übernehmen',
      tooltip: 'Labels übernehmen'
    },
    extend: 'Ext.panel.Panel',
    alias: ['widget.ds_ftindex_command'],
    layout: 'vbox',
    items: [
        {
            hidden: false,
            xtype: 'panel',
            itemId: 'startpanel',
            layout:{
              type: 'vbox',
              align: 'center'
            },
            items: [
              {
                xtype: 'component',
                cls: 'lds-container',
                html: '<div class=" "><div class="blobs-container"><div class="blob green"></div></div></div>'
                +'<div><h3>Volltextsuche</h3>'
                +'<span>'
                +[
                    'Mit dem Klick auf *Auffrischen* wird, ',
                    'wenn noch nicht geschehen, ',
                    'eine Volltext-Such-Tabelle mit entsprechendem Index ',
                    'angelegt. ',
                    'In die Suche werden alle durchsuchaben Felder aufgenommen. ',
                    'Zu dem stehen auch die Suchfelder aller Referenztabellen ',
                    '(eine Tiefenebene) zur Verfügung.'
                ].join('')
                +'</span>'
                +'<i>Je nach Tabellengröße, kann dieser Prozess einige Zeit beanspruchen.</i>'
                +'</div>'
              }
            ]
            
    
        }
    ],
    getNextText: function(){
        return 'Auffrischen';
    },
    run: async function(){
        let res= await Tualo.Fetch.post('./dsft/run',{
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
  