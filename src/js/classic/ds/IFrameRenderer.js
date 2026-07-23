
Ext.define('Tualo.DS.IFrameRenderer', {
  extend: 'Ext.panel.Panel',
  alias: 'widget.ds_iframe_renderer_panel',
  requires: [],
  layout: 'fit',
  config: {
    record: null,
    useremote: false,
    template: '',
    viewtype: 'pdf'
  },
  publishes: {
    record: true,
    useremote: true,
    template: true,
    viewtype: true
  },
  tools: [
    {
      xtype: "glyphtool",
      glyph: "refresh",
      handler: function (me) {
        if (
          this.up('ds_iframe_renderer_panel')
          && this.up('ds_iframe_renderer_panel').up()
          && this.up('ds_iframe_renderer_panel').up().getComponent('list')
        ) {
          this.up('ds_iframe_renderer_panel').loadFrame();
          /*
          let list = this.up('cmp_ds_pdfrendererpanel').up().getComponent('list');
          this.up('cmp_ds_pdfrendererpanel').loadBulk( list.getSelection() );
          */
        } else {
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
  updateRecord: function (record) {

    if (this.isVisible() && ((this.collapsed === true) || (this.collapsed == 'left'))) {
      this.getComponent('frame').src = 'about:blank';
      this.on({
        expand: { fn: this.loadFrame, scope: this, single: true }
      });
    } else {
      this.loadFrame();
    }
  },
  loadFrame: function () {
    if (this.record) {
      let id = this.record.get('__id'),
        url = './pugreporthtml/' + this.record.get('__table_name') + '/' + this.template + '';

      if (Ext.isEmpty(this.record.get('__id'))) {
        id = this.record.get('__displayfield');
      }
      this.getComponent('frame').load(url + '/' + id);
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