
Ext.define('Tualo.DataSets.ListViewFileDrop',  {
    extend: 'Tualo.DataSets.ListView',
    alias: 'widget.dslistviewfiledrop',

    

    plugins: [
        {
            ptype: 'cellediting',
            clicksToEdit: 1,
            pluginId: 'celleditingplugin',
            listeners: {
                edit: function(editor, fld){
                    console.log('edit',fld);
                    this.grid.checkAutoNewRow(fld.rowIdx);
                    this.grid.fireEvent('edited',fld.record,fld);
                    return true;
                }
            }
        },{
            ptype: 'gridexporter'
        },{
            ptype: 'defaultfilters',
            pluginId: 'gridfiltersplugin',
            menuFilterText: 'Filter'
        },
        {
            ptype:'tualoclipboard'
        }
    ],
    initComponent: function(){
        this.callParent(arguments);
        let controller = this.getController();
        this.on({

            drop: {
                element: 'el',
                fn: controller.onDrop
            },
    
            dragstart: {
                element: 'el',
                fn: controller.addDropZone
            },
    
            dragenter: {
                element: 'el',
                fn: controller.addDropZone
            },
    
            dragover: {
                element: 'el',
                fn: controller.addDropZone
            },
    
            dragleave: {
                element: 'el',
                fn: controller.removeDropZone
            },
    
            dragexit: {
                element: 'el',
                fn: controller.removeDropZone
            },
    
        });
        Ext.defer(this.checkAutoNewRow,100,this);
    },
    checkAutoNewRow: function(rowIndex){
        if(Ext.getApplication().getDebug()===true) console.log('checkAutoNewRow',rowIndex);
        let doNotAdd = false;
        let store = this.getStore();
        if (typeof rowIndex=='undefined') rowIndex=-1;
        if ((doNotAdd===false)&&(rowIndex===store.getCount()-1)){
            store.add({});
        }
        return true;
    }
});
