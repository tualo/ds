Ext.define('Tualo.DS.Toolbar', {
    extend: "Ext.toolbar.Toolbar",
    alias: 'widget.dstoolbar',
    dock: "top",
    layout: 'hbox',
    cls: "x-panel-header-default",
    listeners: {
        boxready: 'toolbarBoxReady'
    },
    bind: {
        userCls: "{userCls}",
    },
    items: [
        {
            flex: 1,
            itemId: "dssearchfield",
            xtype: "dssearchfield"
        },
        {
            xtype: "glyphtool",
            glyph: "chevron-left",
            itemId: "chevron-left",
            handler: "prev",
            bind: {
                disabled: "{disablePrev}"
            },
            tooltip: "vorheriger"
        },
        {
            xtype: "tbtext",
            itemId: "pagerText",
            cls: "ds-toolbar-text",
            bind: {
                text: "{pagerText}"
            }
        },
        {
            xtype: "glyphtool",
            itemId: "chevron-right",
            glyph: "chevron-right",
            handler: "next",
            bind: {
                disabled: "{disableNext}"
            },

            tooltip: "nächster"
        },
        {
            xtype: "glyphtool",
            glyph: "refresh",
            itemId: "refresh",
            handler: "refresh",
            tooltip: "neu Laden",
            bind: {
                disabled: "{disableRefresh}"
            }
        },



        {
            xtype: "tbspacer",
            width: 20
        },
        {
            xtype: "glyphtool",
            itemId: "save",
            glyph: "save",
            tooltip: "Speichern",
            handler: "save",
            bind: {
                disabled: "{disableSave}",
                hidden: "{hideSave}"
            }
        },
        {
            xtype: "glyphtool",
            glyph: "history",
            itemId: "history",
            tooltip: "Änderungen verwerfen",
            handler: "reject",
            bind: {
                disabled: "{disableSave}",
                hidden: "{hideSave}"
            }
        }, {
            xtype: "glyphtool",
            glyph: "plus",
            itemId: "plus",
            tooltip: "Hinzufügen",
            handler: "append",

            bind: {
                disabled: "{disableAdd}",
                hidden: "{hideAppend}"
            }

        },
        {
            xtype: "glyphtool",
            glyph: "minus",
            itemId: "minus",
            tooltip: "Entfernen",
            handler: "delete",
            bind: {
                disabled: "{disableDelete}",
                hidden: "{hideDelete}"
            },
        },
        {
            xtype: "glyphtool",
            glyph: "upload",
            itemId: "upload",


            tooltip: "Importieren",
            handler: "upload",
            bind: {
                hidden: "{hideAppend}"
            }


        },
        {
            xtype: "glyphtool",
            glyph: "download",
            itemId: "download",
            tooltip: "Exportieren",
            handler: "export",
            bind: {
                hidden: "{hideExport}"
            }

        }
    ]
});
