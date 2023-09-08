Ext.define('Tualo.DataSets.grid.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsgridcontroller',

    onDropGrid: function(node, data, overModel, dropPosition, eOpts){
        if(Ext.getApplication().getDebug()===true)  console.log('onDropGrid',node, data, overModel, dropPosition, eOpts);
    },

    rendererStatus: function(value, metaData, record, rowIndex, colIndex, store) {
        var color = "grey";
        if (value === "Ready") {
            color = "blue";
        } else if (value === "Uploading") {
            color = "orange";
        } else if (value === "Uploaded") {
            color = "green";
        } else if (value === "Error") {
            color = "red";
        }
        metaData.tdStyle = 'color:' + color + ";";
        return value;
    },

    postDocument: function(url, store, i) {
        
        var xhr = new XMLHttpRequest();
        var fd = new FormData();
        fd.append("serverTimeDiff", 0);
        xhr.open("POST", url, true);
        fd.append('index', i);
        fd.append('file', store.getData().getAt(i).data.file);
        //xhr.setRequestHeader("Content-Type","multipart/form-data");
        xhr.setRequestHeader("serverTimeDiff", 0);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                //handle the answer, in order to detect any server side error
                if (Ext.decode(xhr.responseText).success) {
                    store.getData().getAt(i).data.status = "Uploaded";
                } else {
                    store.getData().getAt(i).data.status = Ext.decode(xhr.responseText).msg;
                }
                store.getData().getAt(i).commit();
            } else if (xhr.readyState == 4 && xhr.status == 404) {
                store.getData().getAt(i).data.status = "Error";
                store.getData().getAt(i).commit();
            }
        };
        // Initiate a multipart/form-data upload
        xhr.send(fd);
    },

    onDrop: function(e) {
        // let store = this.getViewModel().getStore('files');
        e.stopEvent();
        /*
        Ext.Array.forEach(Ext.Array.from(e.browserEvent.dataTransfer.files), function(file) {
            store.add({
                file: file,
                name: file.name,
                size: file.size,
                status: 'Ready'

            });
        });
        */
       console.log('onDrop',e);
        this.getView().removeCls('drag-over');
    },

    noop: function(e) {
        e.stopEvent();
    },

    addDropZone: function(e) {
        if (!e.browserEvent.dataTransfer || Ext.Array.from(e.browserEvent.dataTransfer.types).indexOf('Files') === -1) {
            return;
        }

        e.stopEvent();

        this.getView().addCls('drag-over');
    },

    removeDropZone: function(e) {
        var el = e.getTarget(),
            thisEl = this.getView().getEl();

        e.stopEvent();


        if (el === thisEl.dom) {
            this.getView().removeCls('drag-over');
            return;
        }

        while (el !== thisEl.dom && el && el.parentNode) {
            el = el.parentNode;
        }

        if (el !== thisEl.dom) {
            this.getView().removeCls('drag-over');
        }

    },

    onUploadClicked: function() {
        let store = this.getViewModel().getStore('files');
        for (var i = 0; i < store.data.items.length; i++) {
            if (!(store.getData().getAt(i).data.status === "Uploaded")) {
                store.getData().getAt(i).data.status = "Uploading";
                store.getData().getAt(i).commit();
                //replace "insert your upload url here" with the real url
                //this.postDocument("./index.php?TEMPLATE=NO&cmp=cmp_fibuconv&p=upload", store, i);
                this.postDocument("./fibuconv/upload", store, i);
            }
        }

    },

    onEraseSelected: function() {
        let store = this.getViewModel().getStore('files');
        store.remove(this.lookupReference('uploadgrid').getSelection());
    }
});

