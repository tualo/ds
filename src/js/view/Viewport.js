Ext.define('Tualo.cmp.cmp_ds.view.Viewport', {
    extend: 'Ext.panel.Panel',
    requires: [
        'Tualo.DataSets.store.Basic'
    ],
    statics: {
        routes: function() {
            return 'abc';
        }
    },
    requires: [
      //'Tualo.cmp.cmp_dashboard.models.Viewport',
    ],
    routeTokens: function(tokens){
        let tablename = tokens[1];
        console.log(tablename);
        Ext.require(['Tualo.DataSets.store.'+tablename.charAt(0).toUpperCase() + tablename.slice(1)],function(){
            let itm = Ext.create('Tualo.DataSets.store.'+tablename.charAt(0).toUpperCase() + tablename.slice(1),{
            });
            console.log('done',itm);
            itm.load();
        })
        /*
        let itm = Ext.create('Tualo.DataSets.store.Basic',{
            tablename: 'lager'
        });
        console.log(itm);
        */
    },
    constructor: function(config){
        /*
        Ext.require([
            'Tualo.DataSets.model.Ds',
            'Tualo.DataSets.model.Ds_column',
            'Tualo.DataSets.model.Ds_column_list_label',
            'Tualo.DataSets.model.Ds_column_form_label'
        ],function(){
            Ext.define('Tualo.DataSets.stores.Ds',
            {
                extend: "Tualo.DataSets.store.Basic",
                statics: {
                    tablename: 'ds'
                },
                statefulFilters: true,
                tablename: "ds",
                alias: "store.ds_store",
                model: "Tualo.DataSets.model.Ds",
                storeId: 'ds_store',
                autoSync: false,
                pageSize: 100000
            });

            Ext.define('Tualo.DataSets.stores.Ds_column',
            {
                extend: "Tualo.DataSets.store.Basic",
                statics: {
                    tablename: 'ds_column'
                },
                statefulFilters: true,
                tablename: "ds_column",
                alias: "store.ds_column_store",
                model: "Tualo.DataSets.model.Ds",
                storeId: 'ds_column_store',
                autoSync: false,
                pageSize: 100000
            });

            Ext.define('Tualo.DataSets.stores.Ds_column_list_label',
            {
                extend: "Tualo.DataSets.store.Basic",
                statics: {
                    tablename: 'ds_column_list_label'
                },
                statefulFilters: true,
                tablename: "ds_column_list_label",
                alias: "store.ds_column_list_label_store",
                model: "Tualo.DataSets.model.Ds",
                autoSync: false,
                pageSize: 100000
            });

            Ext.define('Tualo.DataSets.stores.Ds_column_form_label',
            {
                extend: "Tualo.DataSets.store.Basic",
                statics: {
                    tablename: 'ds_column_form_label'
                },
                statefulFilters: true,
                tablename: "ds_column_form_label",
                alias: "store.ds_column_form_label_store",
                model: "Tualo.DataSets.model.Ds",
                autoSync: false,
                pageSize: 100000
            });


            
            Ext.create('Tualo.DataSets.stores.Ds_column_form_label',{
                storeId: 'ds_column_form_label_store',
                tablename: "ds_column_form_label",
                autoLoad: true
            }).load();
            Ext.create('Tualo.DataSets.stores.Ds_column_list_label',{
                storeId: 'ds_column_list_label_store',
                tablename: "ds_column_list_label",
                autoLoad: true
            }).load();
            Ext.create('Tualo.DataSets.stores.Ds_column',{
                storeId: 'ds_column_store',
                tablename: "ds_column",
                autoLoad: true
            }).load();
            Ext.create('Tualo.DataSets.stores.Ds',{
                storeId: 'ds',
                tablename: "ds",
                autoLoad: true
            }).load();

        });
        */
        this.callParent(arguments);
    },
    layout: 'card',
    items: [{
        xtype: 'panel',
        itemId: 'loading',
        layout: {
            type: 'vbox',
            align: 'center',
            pack: 'center'
        },
        items:[{
            xtype: 'panel',
            width: 80,
            height: 80,
            html: 'Datenstamm'//'<div class="lds-ring"><div></div><div></div><div></div><div></div></div>'
        }]
    }]
});