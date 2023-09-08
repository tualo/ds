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
        saving: false
    },
    formulas: {
        currentTitle: function(get){
            try{
                if (!Ext.isEmpty(get('record'))){
                    return get('title')+" | Formular: "+get('record').get('__displayfield');
                }
            }catch(e){}
            return "Formular";
        },
        disableSave: function(get){
            return !get('isModified');
        },
        userCls: function(get){
            console.log('userCls',get('isNew'));
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