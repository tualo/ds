Ext.define('Tualo.DS.panel.mixins.ControllerTools', {
    refresh: function(){
        let store = this.getStore();
        store.load();
    },
    next: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber'));
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    prev: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber')-2);
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    reject: function(){ 
        var model = this.getViewModel(),
            store = this.getStore(),
            record = store.getAt(model.get('lastSelectRecordRecordNumber'));

            if(model.get('isNew')){
                this.refresh();
            }else{
                store.rejectChanges();
            }
    },
    append: function()  {   
        let model = this.getViewModel(),
            view = this.getView(),
            referencedList = view.referencedList,
            referencedRecord = this.getReferencedRecord(),
            store = this.getStore(),
            fields = store.getModel().getFields(),
            values = {};


        for(i=0;i<fields.length;i++){
            if(!Ext.isEmpty(fields[i].defaultValue)){
                values[fields[i].name] = fields[i].defaultValue;
            }
        }
        console.log('append',values,'fields',fields);
        if (referencedList==true){
            if(Ext.isEmpty(referencedRecord)){
            }else{
                for(var ref in view.referenced){
                    if (typeof view.referenced[ref]== 'string')
                        values[ref.toLowerCase()]=referencedRecord.get(view.referenced[ref].toLowerCase());
                    if (typeof view.referenced[ref]== 'object'){
                        if (typeof view.referenced[ref].v== 'string')
                            values[ref.toLowerCase()]=view.referenced[ref].v;
                    }
                }
            }
        }
        let tablenamecase = model.get('table_name').toLocaleUpperCase().substring(0, 1) + model.get('table_name').toLowerCase().slice(1);
        var record = Ext.create('Tualo.DataSets.model.'+tablenamecase,values);
        if (this.showSpecialAppend()){ return; }
        this.appendRecord(record);
        return record;
    },


    showSpecialAppend: function(){
        let model = this.getViewModel(),
            store = this.getStore();
        
        if (!Ext.isEmpty(model.get('special_add_panel'))){
            var wnd = Ext.create('Ext.tualo.Window',{
                layout: 'fit',
                title: model.get('dstitle')+' >> Hinzufügen',
            });
            var panel =Ext.create(Ext.ClassManager.getNameByAlias('widget.'+model.get('special_add_panel') ),{
                record: model.get('record'),
                listeners: {
                    cancled: function(){
                        console.debug('cancled');
                        wnd.close();
                        store.load();
                    },
                    saved: function(){
                        console.debug('saved');
                        wnd.close();
                        store.load();
                    },
                }
            });
        
            wnd.add(panel);
            wnd.show();
            wnd.resizeMe();

            let resizeFn=()=>{
                wnd.resizeMe();
            };
            wnd.on('destroy',()=>{
                view.removeListener('resize',resizeFn);
            })
            view.on('resize',resizeFn);
        
            return true;
        }
        return false;
    },

    appendRecord: function(record){
        var model = this.getViewModel(),
            view = this.getView(),
            store = this.getStore(),
            list = view.getComponent('list');

        record.set('__rownumber',store.getCount()+1,{
            dirty: false
        });
        store.add(record);
        model.set('record',record);
        this.setViewType('form');
        list.setSelection( record );
        list.getView().focusRow(record);
        model.set('lastSelectRecordRecordNumber',model.get('selectRecordRecordNumber'));
        model.set('isNew',true);
        
    },



    delete: function(){
        let model = this.getViewModel(),
            view = this.getView(),
            store = this.getStore(),
            list = view.getComponent('list'),
            selection =list.getSelectionModel().getSelection(),
            selectionCount = selection.length,
            questionText = ((selectionCount==1)?'Möchten Sie wirklich den Datensatz löschen?':'Möchten Sie wirklich die Datensätze ('+selectionCount+' Stück) löschen?');
        
            console.log('delete',selectionCount,selection);

        if (selectionCount>0){
            Ext.MessageBox.confirm('Löschen?',questionText,async function(btn){
                if (btn=='yes'){
                    this.setViewType('list');
                    let payload = [];
                    let fields = store.getModel().getFields();



                    selection.forEach(function(record){
                        let o = {};
                        fields.forEach(function(field){
                            if (field.critical){
                                o[field.name]=record.get(field.name);
                            }
                        });
                        payload.push(o);
                    });
                    console.log('delete',payload);

                    const response = await fetch('./ds/'+model.get('table_name')+'/delete',{
                        method: 'POST',
                        body: JSON.stringify(payload)
                    });

                    const jsonData = await response.json();

                    if (jsonData.success){
                        store.load();
                    }else{
                        let msg = jsonData.msg;
                        if (msg) msg = "Leider ist ein unbekannter Fehler aufgetreten.";
                        Ext.toast({
                            html: msg,
                            title: 'Fehler',
                            width: 200,
                            align: 't'
                        });
                    }
                    
                    console.log(jsonData);

                    /*
                    selection.forEach(function(record){
                        store.remove(record);
                    });
                    model.set('saving',true);
                    store.sync({
                        scope: this,
                        failure: function(){
                            console.error('delete failure',arguments);
                            model.set('saving',false);
                        },
                        success: function(c,o){
                            model.set('saving',false);
                            model.set('isNew',false);
                            model.set('selectRecordRecordNumber',  1);
                            model.set('isModified',store.getModifiedRecords().length!=0);
                            store.load();
                            let record = store.getAt(1);
                            if ((record) ){
                                view.getComponent('list').getSelectionModel().select(record);
                            }
                        }
                    });
                    */
                }
            },this);
        }
    },

    upload: function(){
        let tablename = this.getViewModel().get('table_name');
        Ext.getApplication().redirectTo( "dsimport/"+tablename + "/" + this.getView().getId() );
    },

    export: function(){
        var  view = this.getView(),
            store = this.getStore(),
            tablename = this.getViewModel().get('table_name'),
            referencedRecord = null, // this.getParentRecord()//model.get('referencedRecord'),
            reference = {},
            listfilter = store.getFilters(),
            listsorters =store.getSorters(),
            filters = [],
            sorters = [],
            config = {},
            extraParams = store.getProxy().getExtraParams();

        listsorters.each(function(item){
            sorters.push(item.getConfig());
        });
        
        listfilter.each(function(item){
            filters.push(item.getConfig());
        });
        
        if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (view.referencedList===true){
            referencedRecord = this.getReferencedRecord();

            console.log('referencedRecord',referencedRecord)
            if ( (typeof referencedRecord=='undefined')||(referencedRecord==null) ) return false;
            if (!Ext.isEmpty(referencedRecord)){
                for(var ref in view.referenced){
                    if (typeof view.referenced[ref]== 'string')
                        reference[ref]=referencedRecord.get(view.referenced[ref]);
                    if (typeof view.referenced[ref]== 'object'){
                        if (typeof view.referenced[ref].v== 'string')
                        reference[ref]=referencedRecord.get(view.referenced[ref].v);
                    }
                }
            }
            extraParams.reference = Ext.JSON.encode(reference);
        }
        
        extraParams.filter = Ext.JSON.encode(filters);
        extraParams.sort = Ext.JSON.encode(sorters);

        config = {
            url: './ds/'+tablename+'/export',
            scope: this,
            showWait: true,
            timeout: 300000,
            params: extraParams
        };
        Tualo.Ajax.download(config);
    }

});