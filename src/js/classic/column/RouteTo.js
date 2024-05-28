Ext.define('Tualo.DataSets.grid.column.DSRouteToColumn', {
    extend: 'Ext.grid.column.Widget',
    alias: 'widget.dsroutetocolumn',
    text: 'RT',
    width: 50,
    widget: {
        xtype: 'glyphtool',
        glyph: 'circle-plus',
        handler: function (me) {
            console.log(this,arguments);
        }
    }
});