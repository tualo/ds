Ext.define('Tualo.DS.Panel', {
    extend: "Tualo.panel.Accordion",
    //extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    config: {
        additionalTools: [],
    },
    requires: [
        'Tualo.ds.data.field.PropertyValue',
    ],
    viewModel: {
        type: 'dspanelmodel',
    },
    getWindowTitle: function () {
        if (this.getComponent('list').collapsed !== false) {
            return this.getViewModel().get('title');
        } else {
            return this.getViewModel().get('currentWindowTitle');
        }
    },



    getCurrentToken: function () {
        try {
            if (this.getComponent('list').collapsed !== false) {
                return 'ds/' + this.tablename + '/__id/' + this.getComponent('list').getSelection()[0].getId();
            } else {
                return 'ds/' + this.tablename;
            }
        } catch (e) {
            return false;
        }
    },

    bind: {
        disabled: "{datatransmissions}"
    },

    "keyMap": {
        'ctrl+s': {
            handler: function (event, view) {
                event.stopEvent();
                view.getController().save();
            }
        },
        'cmd+s': {
            handler: function (event, view) {
                event.stopEvent();
                view.getController().save();
            }
        }
    },
    constructor: function (config) {



        this.callParent([config]);




    },
    getStore: function () {
        return this.getComponent('list').getStore();
    },
    getList: function () {
        return this.getComponent('list');
    },
    loadById: function (field, id) {
        this.getController().loadById(id);

    },
    filterField: function (filter, value) {
        this.getController().filterField(filter, value);
    },
    searchFor: function (search) {
        this.getController().searchFor(search);
    },
    dockedItems: [

    ]
})