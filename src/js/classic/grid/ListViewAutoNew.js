
Ext.define('Tualo.DataSets.ListViewAutoNew',  {
    extend: 'Tualo.DataSets.ListView',
    alias: 'widget.dslistviewautonew',
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