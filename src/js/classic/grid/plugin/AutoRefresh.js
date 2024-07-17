/**
 * This {@link Ext.grid.Panel grid} plugin adds clipboard support to a grid.
 *
 * *Note that the grid must use the
 * {@link Ext.grid.selection.SpreadsheetModel spreadsheet selection model}
 * to utilize this plugin.*
 *
 * This class supports the following `{@link Ext.plugin.AbstractClipboard#formats formats}`
 * for grid data:
 *
 *  * `cell` - Complete field data that can be matched to other grids using the same
 *    {@link Ext.data.Model model} regardless of column order.
 *  * `text` - Cell content stripped of HTML tags.
 *  * `html` - Complete cell content, including any rendered HTML tags.
 *  * `raw` - Underlying field values based on `dataIndex`.
 *
 * The `cell` format is not valid for the `{@link Ext.plugin.AbstractClipboard#system system}`
 * clipboard format.
 */
Ext.define('Tualo.DataSets.grid..plugin.AutoRefresh', {
    extend: 'Ext.plugin.Abstract',
    alias: 'plugin.tualo_plugin_autorefresh',
    requires: [
        'Ext.util.DelayedTask'
    ],
    config: {
        /**
         * @cfg {Number} [refreshInterval=30000]
         * The interval in milliseconds to refresh the grid.
         */
        refreshInterval: 30000
    },
    init: function(grid) {
        var me = this;
        me.grid = grid;
        me.task = new Ext.util.DelayedTask(me.refresh, me);
        me.grid.on('render', me.start, me);

        let store = me.grid.getStore();
        store.on('load', function(){
            console.log('tualo_plugin_autorefresh','store load');
            me.task.delay(me.getRefreshInterval());
        },this);

        store.on('datachanged', function(){
            console.log('tualo_plugin_autorefresh','store datachanged');
            me.task.delay(me.getRefreshInterval());
        },this);
    },
    destroy: function() {
        this.task.cancel();
        this.grid.un('render', this.start, this);
    },
    start: function() {
        this.task.delay(this.getRefreshInterval());
    },
    refresh: function() {
        this.grid.getStore().load();
        this.task.delay(this.getRefreshInterval());
    }

 
});