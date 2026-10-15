Ext.define('Tualo.cmp.cmp_ds.field.LinkedComboBoxDS', {
    extend: 'Ext.form.field.ComboBox',
    xtype: 'tualo_ds_linkedcomboboxfield',
    value: 'To Do',

    triggers: {
        opends: {
            cls: 'x-fa fa-link',
            tooltip: "Den Datensatz öffnen",
            handler: function (btn) {
                let tn = btn.getSelectedRecord().get('__table_name'),
                    xtype = btn.config.xtype,
                    name = btn.name;

                name = xtype.split(tn + '_').pop();
                let route = "#ds/" + tn + '/' + name + '/' + btn.getValue();
                window.open(route, '_blank');
            }
        }
    },

    constructor: function (config) {
        this.callParent([config]);
        let store = this.getStore();
        store.on('beforeload', this.onBeforeLoad, this);
        store.load();
    },
    onBeforeLoad: function (store, operation, eOpts) {
        let me = this;
        let params = store.getProxy().getExtraParams() || {};
        params.searchfield = this.displayField;

        if (typeof me.config.filterFields !== 'undefined'
            && me.config.filterFields !== null
            && Object.keys(me.config.filterFields).length > 0
            && typeof me.up('form') !== 'undefined'
            && typeof me.up('form').getRecord == 'function'
        ) {
            let recordData = me.up('form').getRecord().data;
            let reference = {};

            for (let sourceField in me.config.filterFields) {
                let targetField = me.config.filterFields[sourceField];
                if (me.config.filterFields.hasOwnProperty(sourceField)) {
                    if (recordData[sourceField]) {
                        reference[targetField] = recordData[sourceField];
                    }
                }
            }
            params.reference = Ext.JSON.encode(reference);
        }
        // field.up('form').getRecord().data
        // e
        store.getProxy().setExtraParams(params);
    },

    onFocus: function (e) {
        let me = this;
        this.callParent(e);
        try {
            me.onTriggerClick(me, me.getPickerTrigger(), {});
        } catch (e) {

        }
    }
})