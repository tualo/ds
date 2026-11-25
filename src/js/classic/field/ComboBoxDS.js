Ext.define('Tualo.cmp.cmp_ds.field.ComboBoxDS', {
    extend: 'Ext.form.field.ComboBox',
    xtype: 'cmp_ds_comboboxfield',
    // value: 'To Do',

    /*
    triggers: {
        opends: {
            cls: 'x-fa fa-link',
            tooltip: "Den Datensatz öffnen",
            handler: function(btn) {
                console.log('wnd',btn);
                window.btn = btn;
            }
        }
    },
    */
    forceSelection: true,
    showInvalidSelection: false,

    invalidSelectionCls: 'cmp-ds-combobox-invalid-selection',
    invalidSelectionText: 'Der Wert ist nicht in der Auswahlliste vorhanden.',

    config: {
        filterFields: null
    },

    getErrors: function (value) {
        var me = this,
            errors = me.callParent(arguments) || [],
            invalid = me.hasInvalidForcedSelection();

        if (invalid) {
            errors.push(me.invalidSelectionText);
        }
        if (me.rendered) {
            me.toggleCls(me.invalidSelectionCls, invalid);
        }
        return errors;
    },

    hasInvalidForcedSelection: function () {
        var me = this,
            store = me.getStore(),
            value = me.getValue();
        if (!me.showInvalidSelection) {
            return false;
        }

        if (!me.forceSelection || Ext.isEmpty(value)) {
            return false; // leeres Feld regelt allowBlank
        }
        if (!store || store.isLoading() || !store.isLoaded()) {
            return false; // noch nicht entscheidbar
        }
        return !me.getSelection()
            && store.findExact(me.valueField, value) === -1;
    },

    applyFilterFields: function (filterFields) {
        console.log('Tualo.cmp.cmp_ds.field.ComboBoxDS', 'applyFilterFields called', filterFields)
        var me = this;
        me._filterFields = filterFields;
        return filterFields;
    },

    updateFilterFields: function (filterFields) {
        console.log('Tualo.cmp.cmp_ds.field.ComboBoxDS', 'updateFilterFields called', filterFields)
        var me = this;
        me._filterFields = filterFields;
        return filterFields;
    },

    setFilterFields: function (filterFields) {
        console.log('Tualo.cmp.cmp_ds.field.ComboBoxDS', 'setFilterFields called', filterFields)
        var me = this;
        me._filterFields = filterFields;
        return filterFields;
    },



    constructor: function (config) {
        this.callParent([config]);
        let store = this.getStore();
        store.on('beforeload', this.onBeforeLoad, this);
        store.on('load', this.revalidateSelection, this);
        store.load();
    },
    revalidateSelection: function () {
        // Nach dem (Nach-)Laden des Stores prüfen, ob der aktuelle Wert gültig ist
        if (this.rendered && !this.destroyed) {
            this.validate();
        }
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
            let record = me.up('form').getRecord();
            if (!Ext.isEmpty(record)) {
                let recordData = record.data;
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
        }
        // field.up('form').getRecord().data
        // e
        store.getProxy().setExtraParams(params);
    },

    /*
    store.getProxy().setExtraParams({

        / *tablename: store.tablename,
        fieldname: store.fieldname,
        value: store.value,
        query: store.query,
        pageSize: store.pageSize
        * /
    });
    */
    // },

    afterRender: function () {
        var me = this;
        me.callParent(arguments);

        me.bodyEl.dom.addEventListener("drop", (ev) => {
            ev.preventDefault();

            if (me.config.allowDrop === false) {
                return;
            }
            const data = ev.dataTransfer.getData("text");
            me.setValue(data);
            setTimeout(() => {
                me.doQuery(data, true, true);
                me.focus();
            }, 500);
        });
        /*
        me.bodyEl.dom.addEventListener("dragover", (ev) => {
            ev.preventDefault();
        });
        */

    }


})