
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
    fileZoneActiveClass: 'tualo_filedrop_active',
    createFileDropZone: function(){
        let me = this;
        container.addEventListener(
            "dragenter",
            (e) => {
              e.preventDefault();
              e.stopPropagation();
              console.log("dragenter");
              container.classList.add(me.fileZoneActiveClass);
            },
            false
          );
          
          container.addEventListener(
            "dragleave",
            (e) => {
              e.preventDefault();
              e.stopPropagation();
              console.log("dragleave");
              container.classList.remove(me.fileZoneActiveClass);
            },
            false
          );
          
          container.addEventListener(
            "dragover",
            (e) => {
              e.preventDefault();
              e.stopPropagation();
              console.log("dragover");
              container.classList.add(me.fileZoneActiveClass);
            },
            false
          );
          
          container.addEventListener(
            "drop",
            (e) => {
              e.preventDefault();
              e.stopPropagation();
          
              console.log("drop");
              container.classList.remove(me.fileZoneActiveClass);
              let draggedData = e.dataTransfer;
              let files = draggedData.files;
              console.log("drop",files);
              /*
              imageDisplay.innerHTML = "";
              Array.from(files).forEach((file) => {
                fileHandler(file, file.name, file.type);
              });
              */
            },
            false
          );
          
    },
    onShow: function(){
        this.callParent(arguments);
        this.createFileDropZone();
    },
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
