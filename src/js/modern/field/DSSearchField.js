Ext.define('Tualo.DS.field.SearchField', {
    extend: 'Ext.field.Text',
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
                let store = field.up().up().getViewModel().getStore("list");
                store.getProxy().setExtraParam("filter_by_search",1);
                store.getProxy().setExtraParam("search",field.getValue());
                store.load();
                field.up().up().getController().setViewType("list");
            }
        }
    },
    listeners: {
        specialkey: function(field, e){
            if (e.getKey() == e.ENTER) {
                window.fld = field;
                let store = field.up().up().getViewModel().getStore("list");
                store.getProxy().setExtraParam("filter_by_search",1);
                store.getProxy().setExtraParam("search",field.getValue());
                store.load();
                field.up().up().getController().setViewType("list");
            }
        }
    }
});