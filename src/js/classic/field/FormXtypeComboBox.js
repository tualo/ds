Ext.define('Tualo.DS.fields.FormXtypeComboBox',  {
	extend: 'Ext.form.field.ComboBox',
	xtype: 'formxtype_combobox',
  requires: [
    'Tualo.DS.fields.controller.FormXtypeComboBox',
    'Tualo.DS.fields.models.FormXtypeComboBox'
  ],
  viewModel: {
    type: 'formxtype_model'
  },
  bind: {
    store: '{types}',
  },
	typeAhead: true,
  valueField: 'id',
  displayField: 'name'
});
