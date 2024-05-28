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
        currentWindowTitle: function(get){
            try{
                if (!Ext.isEmpty(get('record'))){
                    return get('title')+" | "+get('record').get('__displayfield');
                }
            }catch(e){}
            return "DS";
        },
        disableSave: function(get){
            return !get('isModified');
        },
        disableRefresh: function(get){
            return get('isModified');
        },
        userCls: function(get){
            return get("isNew")?"new_cmp_ds":"";
        },
    },

    constructor: function () {
        var me = this;
        me.callParent(arguments);
    },
});