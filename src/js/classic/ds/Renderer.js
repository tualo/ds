
Ext.define('Tualo.DS.Renderer', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.cmp_ds_pdfrendererpanel',
    requires: [],
    layout: 'fit',
    config: {
        record: null,
        useremote: false,
        template: '',
        viewtype: 'pdf'
    },
    publishes:{
      record: true,
      useremote: true,
      template: true,
      viewtype: true
    },
    tools: [
      {
        xtype: "glyphtool",
        glyph: "table",
        handler: function(me){
          if (
            this.up('cmp_ds_pdfrendererpanel') 
            && this.up('cmp_ds_pdfrendererpanel').up()
            && this.up('cmp_ds_pdfrendererpanel').up().getComponent('list')
          ){
            let list = this.up('cmp_ds_pdfrendererpanel').up().getComponent('list');
            this.up('cmp_ds_pdfrendererpanel').loadBulk( list.getSelection() );
          }else{
            Ext.toast({
              html: 'Die Funktion steht hier leider nicht zur Verfügung',
              title: 'Fehler',
              width: 200,
              align: 't',
              iconCls: 'fa fa-warning'
           });
          }
        },
        tooltip: "Auswahl"
      }
    ],
    loadBulk: function(records,bulkpdf,index){
      if (typeof bulkpdf=='undefined'){
        Tualo.Ajax.request({
          url: './pugreportpdf_bulkpdf',
          showWait: false,
          showProgress: true,
          progressIndex: index,
          progressLength: records.length,
          timeout: 300000,
          scope: this,
          json: function(o){
            if (o.success==true){
              bulkpdf = o.bulkpdf;
              this.loadBulk(records,bulkpdf);
            }else{
              Ext.toast({ html: o.msg, title: 'Fehler', width: 200, align: 't', iconCls: 'fa fa-warning' });
            }
          }
        });
      }else{
        if (typeof index=='undefined') index = 0;
        
        if (index<records.length){
          let record = records[index],
            url = './pugreportpdf/'+record.get('__table_name')+'/'+this.template+'/'+record.get('__id');
          if (this.useremote==true){
            url = './remote/pdf/'+record.get('__table_name')+'/'+this.template+'/'+record.get('__id')
          }
          Tualo.Ajax.request({
            url: url,
            showWait: false,
            showProgress: true,
            progressIndex: index,
            timeout: 300000,
            progressLength: records.length,
            params:{
              bulkpdf: bulkpdf
            },
            scope: this,
            success: function(o){
              this.loadBulk(records,bulkpdf,index+1);
            }
          });
        }else{
          
          Tualo.Ajax.request({
            url: './pugreportpdf_bulkpdf',//?bulkpdf='+ bulkpdf,
            showWait: false,
            showProgress: true,
            progressIndex: index,
            timeout: 300000,
            progressLength: records.length,
            params:{
              bulkpdf: bulkpdf
            },
            scope: this,
            json: function(o){
              Tualo.Ajax.progress.hide();
  
              //this.loadBulk(records,bulkpdf,index+1);
              this.getComponent('frame').load(  o.file );
            }
          });
  
          
        }
      }
    },
    updateRecord: function(record){
  
      if (this.isVisible() && ( (this.collapsed===true) || (this.collapsed=='left') ) ){
        this.getComponent('frame').src='about:blank';
        this.on( {
          expand: {fn: this.loadFrame, scope: this, single: true}
        } );
      }else{
        this.loadFrame();
      }
    },
    loadFrame: function(){
      if (this.record){
        let id = this.record.get('__id'),
            url = './pugreport'+this.viewtype+'/'+this.record.get('__table_name')+'/'+this.template+'';
        if (this.useremote==true){
          url = './remote/'+this.viewtype+'/'+this.record.get('__table_name')+'/'+this.template+'';
        };
        if (Ext.isEmpty(this.record.get('__id'))){
          id = this.record.get('__displayfield');
        }
        this.getComponent('frame').load(  url+'/'+id );
      }
    },
    items: [
      {
        itemId: 'frame',
        xtype: 'tualoiframe',
        src: 'about:blank'
      }
    ]
  });