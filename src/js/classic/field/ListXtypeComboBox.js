Ext.define('Tualo.DS.fields.fields.ListXtypeComboBox',  {
	extend: 'Ext.form.field.ComboBox',
	xtype: 'listxtype_combobox',
  requires: [
    'Tualo.DS.fields.models.ListXtypeComboBox'
  ],
  viewModel: {
    type: 'listxtype_model'
  },
  bind: {
    store: '{types}',
  },
	typeAhead: true,
  valueField: 'id',
  displayField: 'name'
});
