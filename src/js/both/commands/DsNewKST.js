Ext.define('Ext.cmp.cmp_ds.views.DsNewKST', {
  statics: {
    glyph: 'asterisk',
    title: 'Kostenstelle anlegen',
    tooltip: 'Kostenstelle anlegen'
  },
  extend: 'Ext.panel.Panel',
  alias: 'widget.ds_newkst_command',
  layout: 'fit',
  items: [
    {
      xtype: 'form',
      itemId: 'ds_newkst_commandform',
      bodyPadding: '25px',
      items: [
        {
          xtype: 'label',
          text: 'Durch klicken auf *Anlegen*, wird ein neue Kostenstellensatz erzeugt',
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
    return 'Anlegen';
  },
  run: async function () {
    let parent = Ext.getCmp(this.calleeId);
    var newrecord = parent.getController().cloneRecord();
    newrecord.set(newrecord.get('__table_name') + '__kostenstelle', -1);
    var store = Ext.create(Ext.ClassManager.getName(Ext.ClassManager.getByAlias('store.' + newrecord.get('__table_name') + '_store')), {
      autoLoad: false,
      autoSync: false,
      pageSize: 100000,
      type: newrecord.get('__table_name') + '_store'
    });
    store.setFilters({
      property: newrecord.get('__table_name') + '__kundennummer',
      operator: 'eq',
      value: newrecord.get(newrecord.get('__table_name') + '__kundennummer')
    });
    store.load({
      callback: function () {
        var r = store.getRange();
        var m = 0;
        r.forEach(function (element) {
          m = Math.max(m, element.get(newrecord.get('__table_name') + '__kostenstelle'));
        });
        m++;
        newrecord.set(newrecord.get('__table_name') + '__kostenstelle', m);
      }
    });
    return null;
  }
});
