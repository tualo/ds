Ext.define('Tualo.DataSets.Viewport', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.cmp_ds_dsviewport',

    "keyMap": {
        'ctrl+s': {
            handler: function(event,view) {
                event.stopEvent();
                view.getController().save();
            }
        },
        'cmd+s': {
            handler: function(event,view) {
                event.stopEvent();
                view.getController().save();
            }
        },
        esc: {
            handler: function(event,view) {

            }
        }
    },

});