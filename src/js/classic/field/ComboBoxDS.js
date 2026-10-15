Ext.define('Tualo.cmp.cmp_ds.field.ComboBoxDS', {
    extend: 'Ext.form.field.ComboBox',
    xtype: 'cmp_ds_comboboxfield',
    value: 'To Do',

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

    config: {
        filterFields: null
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