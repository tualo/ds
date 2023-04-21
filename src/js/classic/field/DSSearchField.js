Ext.define('Tualo.DS.field.SearchField', {
    extend: 'Ext.form.field.Text',
    xtype: "dssearchfield",
    flex: 1,
    minWidth: 300,
    emptyText: "Suchen ...",
    triggers: {
        bar: {
            weight: 0,
            cls: Ext.baseCSSPrefix + "form-clear-trigger",
            handler: function(field) {
                field.setValue("");
                let store = field.up().up().getComponent('list').getStore(),
                    params = store.getProxy().getExtraParams();
                    if (Ext.isEmpty(params)){ params = {}; };
                delete params.filter_by_search;
                delete params.search;
                store.getProxy().setExtraParams(params);
                store.load();
                field.up().up().getController().setViewType("list");
            }
        }
    },
    listeners: {
        specialkey: function(field, e){
            if (e.getKey() == e.ENTER) {
                let store = field.up().up().getComponent('list').getStore();
                store.getProxy().setExtraParam("filter_by_search",1);
                store.getProxy().setExtraParam("search",field.getValue());
                store.load();
                field.up().up().getController().setViewType("list");
            }
        }
    }
});