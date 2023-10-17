Ext.define('Tualo.ds.data.field.PropertyValue', {
    extend: 'Ext.data.field.Field',
    alias: [
        'data.field.tualo_ds_property_value'
    ],
    calculate: function (data) {
        console.log('tualo_ds_property_value',data);
        v=data.value;
        return v;
    },
    critical:true,
    persist: true,
    depends: ['value'],
});