Ext.define('Tualo.DS.panel.Model', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.dspanelmodel',
    data: {
        isNew: false,
        referencedList: false,
        selectRecordRecordNumber: 0,
        isModified: false,
        pagerText: '0/0',
        disableNext: false,
        disablePrev: false
    },
    formulas: {
        disableSave: function(get){
            return !get('isModified');
        },
        userCls: function(get){
            return get("isNew")?"new_cmp_ds":"";
        },
    },

    constructor: function () {
        var me = this;
        me.callParent(arguments);

        /*
        me.bind('{selectedItem}', function (value) {
            console.log('combobox selected item changed (bar value): ' + (value === null ? "null": value.get('bar')));
            console.log(me.getView().getController());
        });

        me.bind('{testObj.foo}', function (value) {
            console.log('combobox value (foo value): ' + value);

            // you can access the controller
            console.log(me.getView().getController());
        });
        */
    },
});