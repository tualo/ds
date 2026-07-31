Ext.define('Tualo.DataSets.grid.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsgridcontroller',
    onReload: function(){
        console.log('onReload',this.getView());
        this.getView().getStore().load();
    },

    valueRenderer: function(value, metaData, record, rowIndex, colIndex, store,view) {
        console.log('rendererValue ds/src/js/both/grid/Controller.js ',value, metaData, record, rowIndex, colIndex, store,view);
        if (value === null || value === undefined) return '';
        var headerCt = this.getView().getHeaderContainer(),
        column = headerCt.getHeaderAtIndex(colIndex);
        if (column && column.config && column.config.ds_renderer && (typeof column.config.ds_renderer == 'string')){
            let fn = Tualo.tualojs.Format.Renderer[column.config.ds_renderer];
            if (typeof fn == 'function'){
                return fn.apply(this,[value, metaData, record, rowIndex, colIndex, store,view]);
            }
        }
        console.log('rendererValue ds/src/js/both/grid/Controller.js column',);
        return value;
    },

})
