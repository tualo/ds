Ext.define('Tualo.cmp.cmp_ds.commands.Compiler', {
    statics:{
      glyph: 'server',
      title: 'Kompilieren',
      tooltip: 'Kompilieren'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.compiler_command',
    layout: 'fit',
    items: [
      {
        xtype: 'form',
        itemId: 'syncform',
        bodyPadding: '25px',
        items: [
          {
            xtype: 'label',
            text: 'Durch klicken auf *Kompilieren* wird der Programmcode neu erstellt.',
          }

        
        ]
      },{
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
            html: '<div class="lds-grid"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div><span>Einen Moment bitte ...</span>'
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
      return 'Kompilieren';
    },
    run: async function(){
      let me = this;
      me.getComponent('syncform').hide();
      me.getComponent('waitpanel').show();
      let res= await Tualo.Fetch.post('./compiler',{      });
      if (res.success !== true){
        Ext.toast({
            html: o.msg,
            title: 'Fehler',
            align: 't',
            iconCls: 'fa fa-warning'
        });
      }
      return res;
    }
  });
