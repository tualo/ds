Ext.define('Tualo.DS.panel.Model', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.dspanelmodel',
    data: {
        isNew: false,
        referencedList: false,
        selectRecordRecordNumber: 0,
        viewTypeOnLoad: 'list',
        isModified: false,
        pagerText: '0/0',
        disableNext: false,
        disablePrev: false,
        loading: false,
        saving: false
    },
    formulas: {
        currentTitle: function (get) {
            try {
                if (!Ext.isEmpty(get('record'))) {
                    return get('record').get('__displayfield') + " | " + get('title');
                }
            } catch (e) { }
            return "Formular";
        },
        currentIcon: function (get) {
            return "fa-solid fa-list";
            // <i class="fa-regular fa-pen-to-square"></i>
        },
        currentWindowTitle: function (get) {
            try {
                if (!Ext.isEmpty(get('record'))) {
                    return get('title') + " | " + get('record').get('__displayfield');
                }
            } catch (e) { }
            return "DS";
        },
        disableSave: function (get) {
            return !get('isModified');
        },
        disableRefresh: function (get) {
            return get('isModified');
        },
        userCls: function (get) {
            return get("isNew") ? "new_cmp_ds" : "";
        },
        datatransmissions: function (get) {
            return get('saving') || get('loading')
        }
    },

    constructor: function () {
        var me = this;
        me.callParent(arguments);
    },
});