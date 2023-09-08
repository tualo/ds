
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
        let me = this,container = this.getEl().dom;
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
              
              Array.from(files).forEach((file) => {
                me.fileHandler(file, file.name, file.type,this);
              });
              
            },
            false
          );
          
    },
    fileHandler: function (file, name, type,container) {
        let reader = new FileReader();
        let store = this.getStore();
        reader.readAsDataURL(file);
        reader.onloadend = () => {
            console.log(reader.result);
            
            let record = container.up().up().getController().append();
            record.set('__file_data',reader.result);
            record.set('__file_size',file.size);
            record.set('__file_name',file.name);
            record.set('__file_type',file.type);
        };
    },
    onShow: function(){
        this.callParent(arguments);
        this.createFileDropZone();
    },
    initComponent: function(){
        this.callParent(arguments);
        Ext.defer(this.checkAutoNewRow,100,this);
        this.on('boxReady',this.createFileDropZone,this);
        // this.createFileDropZone();
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
