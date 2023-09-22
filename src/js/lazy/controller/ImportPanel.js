Ext.define('Tualo.ds.lazy.util.Format', {
    statics: {
        formatSizeUnits: function(bytes){
            console.log(bytes);
            if      (bytes >= 1073741824) { bytes = (bytes / 1073741824).toFixed(2) + " GB"; }
            else if (bytes >= 1048576)    { bytes = (bytes / 1048576).toFixed(2) + " MB"; }
            else if (bytes >= 1024)       { bytes = (bytes / 1024).toFixed(2) + " KB"; }
            else if (bytes > 1)           { bytes = bytes + " bytes"; }
            else if (bytes == 1)          { bytes = bytes + " byte"; }
            else                          { bytes = "0 bytes"; }
            return bytes;
        }
    }
}
);    

Ext.define('Tualo.ds.lazy.controller.ImportPanel', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.lazy_ds_import_panel',
    boxready: function(){
        var me = this;
        console.log('boxready');
        me.getFileSize();

    },
    getFileSize: async function(){
        let res= await Tualo.Fetch.post('/dsimport/maxfilesize',{});
        if (res.size){
            this.getViewModel().set('filesize',res.size);
        }
    },
    cancel: function(){
        console.log('cancel');
        window.history.back();
    },
    prev: function(){
        let activeItem = this.getView().getLayout().getActiveItem(),
            activeIndex = this.getView().items.indexOf(activeItem);
        if (activeIndex==0){
        }else {
            this.getView().getLayout().setActiveItem(activeIndex-1);
        }

    },
    next: function(){

        var activeItem = this.getView().getLayout().getActiveItem();
        var activeIndex = this.getView().items.indexOf(activeItem);

        console.log(activeIndex);
        if (activeIndex==0){
            this.upload(); 
        }else if (activeIndex==1){
            this.getView().getLayout().setActiveItem(2);
        }else if (activeIndex==3){
            this.getView().getLayout().setActiveItem(4);
        }else if (activeIndex==4){
            this.import();
        }

    },
    upload: function(){
        var form = this.getView().getLayout().getActiveItem().getForm();
        if(form.isValid()) {
            form.submit({
                timeout: 600000,
                url: './dsimport/upload', // +this.getView().tablename,
                waitMsg: 'Die Datei wird hochgeladen ...',
                scope: this,
                success: function(fp, o) {
                    console.log('success', fp,o);
                    this.getView().getLayout().setActiveItem(1);
                }
            });
        }
    },
    onCheckShow: function(){
        this.getViewModel().set('nextButtonText','Weiter')
        setTimeout(()=>{
            this.check();
        },500);
    },
    check: async function(){
        let sheets = this.getViewModel().getStore('sheets'),
            activeItem = this.getView().getLayout().getActiveItem(),
            first = null,
            data = [];
        this.getViewModel().set('filechecked',false);
        let res= await Tualo.Fetch.post('/dsimport/check',{});
        if (res.success){
            sheets.removeAll();
            for (var i = 0; i < res.data.length; i++) {
                if (first == null) {
                    first = res.data[i].id;
                }
                data.push([res.data[i].id, res.data[i].name]);
            }
            sheets.loadData(data);
            activeItem.getComponent('sheets').setValue(first);
            this.getViewModel().set('filechecked',true);
            if (data.length==1){
                this.getView().getLayout().setActiveItem(2);
            }
        }
    },
    onExtractShow: function(){
        this.getViewModel().set('nextButtonText','Weiter')
        setTimeout(()=>{
            this.extract();
        },500);
    },
    extract: async function(){
        this.getViewModel().set('fileextracted',false);
        let res= await Tualo.Fetch.post('/dsimport/extract',{
            tbl: this.getViewModel().get('currentSheetIndex')
        });
        if (res.success){
            this.getViewModel().set('fileextracted',true);
            this.getViewModel().set('rows',res.count);
            this.getViewModel().getStore('fields').getProxy().setExtraParams({
                t: this.getView().tablename
            });
            this.getViewModel().getStore('fields').load();
            this.getView().getLayout().setActiveItem(3);
        }
    },
    onSourceShow: function(){
        this.getViewModel().set('nextButtonText','Weiter')
        setTimeout(()=>{
            this.source();
        },500);
    },
    source: async function(){
        this.getViewModel().set('filesourceed',false);
        this.getViewModel().getStore('source').getProxy().setExtraParams({
            t: this.getView().tablename
        });
        this.getViewModel().getStore('source').load();
    },
    styleColumnContent: function (name,res){
        //COLINDEX
        if (name.substring(0,8)=='COLINDEX'){
            return '<b>'+res+'</b>';
        }else{
            return '<i>'+res+'</i>';
        }
    },
    renderNameColumn: function(value, meta, rec, row, col, store, view){
        let r = this.getViewModel().getStore('fields').getRange();
        for (var i = 0; i < r.length; i++) {
            if (r[i].get('id') == value) {
              return this.styleColumnContent(value,r[i].get('name'));
            }
          }
        return this.styleColumnContent(value,value);
       
    },
    onImportShow: function(){
        console.log('onImportShow');
        this.getViewModel().set('nextButtonText','Importieren')
    },
    import: async function(){
        let range = this.getViewModel().getStore('source').getRange(),
            result = null,
            r = {};
            this.getViewModel().set('importing',true);

          for (var i = 0; i < range.length; i++) {
            var name = range[i].get('id');
            var value = range[i].get('name');
            if(value!=range[i].get('default'))
            r[name] = value;
          }
          result = Ext.JSON.encode(r);

        let res= await Tualo.Fetch.post('/dsimport/import',{
            tbl: this.getViewModel().get('currentSheetIndex'),
            config: result,
            t: this.getView().tablename,
            index: this.getViewModel().get('importIndex'),
            offset: this.getViewModel().get('importOffset')
        });
        if (res.success){
            this.getViewModel().set('importIndex',res.index);
            this.getViewModel().set('importOffset',res.offset);
            if (res.index<res.count){
                this.import();
            }else{
                this.getViewModel().set('importing',true);
                this.cancel();
            }
        }
    }
});