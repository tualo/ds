Ext.define('Tualo.DS.Panel', {
    extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    viewModel: {
        data: {
            record: null,
            isNew: false,
            disablePrev: false,
            referencedList: false,
            selectRecordRecordNumber: 0,
            isModified: false,
        },
        formulas: {
            disableSave: function(get){
                return !get('isModified');
            }
        }
    },
    dockedItems: [
        {   
            xtype: "toolbar",
            dock: "top",
            layout: 'hbox',
            cls: "x-panel-header-default",
            items: [
                {
                    flex: 1,
                    xtype: "dssearchfield"
                },
                {
                    xtype: "glyphtool",
                    glyph: "chevron-left",
                    handler: "prev",
                    bind:{
                        disabled: "{disablePrev}"
                    },
                    tooltip: "vorheriger"
                },
                {
                    xtype: "tbtext",
                    cls: "ds-toolbar-text",
                    bind:{
                        text: "{pagerText}"
                    }
                },
                {
                    xtype: "glyphtool",
                    glyph: "chevron-right",
                    handler: "next",
                    bind:{
                        disabled: "{disableNext}"
                    },
                    tooltip: "nächster"
                },
                {
                    xtype: "glyphtool",
                    glyph: "refresh",
                    handler: "refresh",
                    tooltip: "neu Laden"
                },
        
        
        
                {
                    xtype: "tbspacer",
                    width: 20
                },
                {
                    xtype: "glyphtool",
                    glyph: "save",
                    tooltip: "Speichern",
                    reference: "savebtn",
                    handler: "save",
                    bind:{
                        disabled: "{disableSave}",
                        hidden: "{hideSave}"
                    }
                },
                {
                    xtype: "glyphtool",
                    glyph: "history",
                    tooltip: "Änderungen verwerfen",
                    reference: "historybtn",
                    handler: "reject",
                    bind:{
                        disabled: "{disableSave}",
                        hidden: "{hideSave}"
                    }
                },{
                    xtype: "glyphtool",
                    glyph: "plus",
                    tooltip: "Hinzufügen",
                    handler: "append",
                    bind:{
                        disabled: "{disableAdd}",
                        hidden: "{hideAppend}"
                    }
                },
                {
                    xtype: "glyphtool",
                    glyph: "minus",
                    tooltip: "Entfernen",
                    handler: "delete",
                    bind:{
                        disabled: "{disableDelete}",
                        hidden: "{hideDelete}"
                    },
                },
                { 
                    xtype: "glyphtool",
                    glyph: "upload",
        
        
                    tooltip: "Importieren",
                    handler: "import",
                    bind: {
                        hidden: "{hideAppend}"
                    }
                    
        
                },
                {
                    xtype: "glyphtool",
                    glyph: "download",
                    tooltip: "Exportieren",
                    handler: "export",
                    bind: {
                        hidden: "{hideExport}"
                    }
        
                }
            ]
        }
    ]
})