Ext.define('Tualo.DS.panel.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dspanelcontroller',
    mixins: {
        util: 'Tualo.DS.panel.mixins.ControllerTools'
    },
    constructor: function(config){
        this.callParent([config]);
    },
    onBoxReady: function(x){
        this.initEvents();
        window[this.getView().xtype]=this;
        if (this.getView().referencedList===true){
            if (!Ext.isEmpty(this.getReferencedRecord())){
                this.getReferencedView().getViewModel().bind('{record}', this.onReferencedRecordChange, this);
            }
        }
    },
    toolbarBoxReady: function(toolbar){
        let id = this.getView().getId(),
            tn = this.getViewModel().get('table_name');
        if (this.getView().additionalTools.length>0){
            if(Ext.getApplication().getDebug()===true) console.log('Tualo.DS.Panel',this,this.additionalTools,toolbar);

            this.getView().additionalTools.forEach(element => {
                if(!Ext.isEmpty(Ext.ClassManager.getByAlias('widget.'+element.defered))){
                    if (!Ext.isEmpty(Ext.ClassManager.getByAlias('widget.'+element.defered).glyph)){
                        element.glyph = Ext.ClassManager.getByAlias('widget.'+element.defered).glyph;
                    }
                    toolbar.add({
                        xtype: "glyphtool",
                        glyph: element.glyph,
                        handler: function(){
                            Ext.getApplication().redirectTo('dscommand/'+tn+'/'+element.defered+'/'+id);
                        },
                        tooltip: element.text
                    });
                }
            });
        }
    },
    onAddCommandClick: function(){
        var me = this,

            view = me.getView(),
            store = me.getStore()
            ;
            if(Ext.getApplication().getDebug()===true) console.log('onAddCommandClick',view,store,arguments);
    },
    onReferencedRecordChange: function(record){
        if (record){
            if(Ext.getApplication().getDebug()===true) console.log('referenced record changed',this.$className,record);
            this.getStore().load();
        }
    },
    getReferencedView: function(){
        let view = this.getView().up().up().up();
        if(Ext.getApplication().getDebug()===true) console.log('getReferencedView',this.getView().referencedList,view);
        return view;
    },
    getReferencedRecord: function(){
        if (
            this.getView().referencedList===true &&
            (this.getReferencedView().getViewModel())){
            return this.getReferencedView().getViewModel().get('record');
        }

        return null;
    },
    initEvents: function(){
       let c = this;

       let store = this.getStore(),
           list = this.getView().getComponent('list');

       store.on('datachanged',this.onDataChanged,this);
       store.on('beforeload',this.onBeforeStoreLoad,this);
       store.on('load',this.onStoreLoad,this);
       list.on('selectionchange',c.onListSelectionChange,this);
       list.on('select',c.onListSelect,this);
       store.load();
    },
    
    
    onDropGrid: function(){
        this.numberRows();
    },
    
    numberRows: function(){
        var i,
            grid = this.getView(),
            model = this.getViewModel(),
            store = this.getStore(),
            records = store.getRange(),
            min = Number.POSITIVE_INFINITY,
            fld_name =  model.get('reorderfield');
        if (!Ext.isEmpty(fld_name)){
            //vc.getView().getComponent('list').getStore().getRange();


            for(i=0;i<records.length;i++){
                min=Math.min(min,records[i].get(fld_name));
            }
            min = 0;
            
            for(i=0;i<records.length;i++){
                console.log('onDropGrid',records[i],fld_name,min+i);
                records[i].set(fld_name,min+i);
            }
        }
    },
    onDataChanged: function(t,e){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore();
        console.log('onDataChanged',model.$className,store.getModifiedRecords().length,model.get('disableSave'));

        model.set('isModified',store.getModifiedRecords().length!=0);
    },
    
    onListSelect: function(selModel, record, eOpts){
        console.log('onListSelect',arguments);
        let me = this,
            model = me.getViewModel(),
            form = this.getView().getComponent('form'),
            list = this.getView().getComponent('list'),
            store = list.getStore(),
            record = selModel.getSelection()[0];

        

        if (record){
            console.log('onListSelect',store.indexOf(record)+1);
            model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            model.set('record',record);
            form.loadRecord(record);

        } else {
            model.set('selectRecordRecordNumber',0);
            model.set('record',null);
            //form.load   Record(null);
        }
        model.set('disablePrev',model.get('selectRecordRecordNumber')<=1);
        model.set('disableNext',model.get('selectRecordRecordNumber')>=store.getCount());
        model.set('pagerText',model.get('selectRecordRecordNumber')+'/'+store.getCount());
        
        Ext.getApplication().updateWindowTitle();
    },

    onListSelectionChange: function(selModel, selected, eOpts){
        
        
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            form = this.getView().getComponent('form'),
            record = selModel.getSelection()[0];


        if (record){
            /*
            model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            model.set('record',record);
            form.loadRecord(record);
            */
            form.loadRecord(record);
        } else {
            model.set('selectRecordRecordNumber',0);
            model.set('record',null);
            //form.loadRecord(null);
        }

        /*
        console.log('onListSelectionChange',this.$className);
        model.set('disablePrev',model.get('selectRecordRecordNumber')<=1);
        model.set('disableNext',model.get('selectRecordRecordNumber')>=store.getCount());
        model.set('pagerText',model.get('selectRecordRecordNumber')+'/'+store.getCount());
        */
    },

    
    onItemDblClick: function ( view, record, item, index, e, eOpts ){
        this.setViewType('form');
    },
    setViewType: function(view){
        let v = this.getView().getComponent(view);
        if (this.getView().getLayout().type=='accordion'){
            v.expand();
        }else{
            this.getView().setActiveItem(v);
        }
    },
    getStore: function(){
        return this.getView().getComponent('list').getStore();
    },
    


    onStoreLoad: function(store, records, successful, operation, eOpts){
        console.debug(this.$className,'onStoreLoad',records,successful,operation,eOpts);
        let model = this.getViewModel();
        if (model.get('isNew')){
            model.set('isNew',false);
            this.setViewType(model.get('viewTypeOnLoad'));
        }
        this.updatePager();
        this.preserveSelection();
        this.setViewType('list');
    },
    
    preserveSelection: function(){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            sels = [],
            selIndex=0,
            keys = model.get('oldSelection');
        if (Ext.isEmpty(keys)) return;
        keys.forEach(function(key){
            let record = me.getStore().getById(key);
            if (record){ 
                sels.push(record);
            }else{
                if (sels.length==0) selIndex++;
            }

        });
        if (sels.length==0) return;
        if (Ext.isEmpty(model.get('record'))) return;

        if (me.getView().getComponent('list').getSelectionModel().type =="rowmodel"){ 
            me.getView().getComponent('list').getSelectionModel().select(sels);
            me.getView().getComponent('form').loadRecord(model.get('record'));
        }
        if (me.getView().getComponent('list').getSelectionModel().type =="cellmodel"){
            selIndex = store.find('__id',keys[0]);
            console.log('selIndex',selIndex);
            setTimeout(()=>{
                me.getView().getComponent('list').view.bufferedRenderer.scrollTo(0, true);
            },100);
            setTimeout(()=>{
                me.getView().getComponent('list').view.bufferedRenderer.scrollTo(selIndex, true);
            },300);
            me.getView().getComponent('form').loadRecord(model.get('record'));
        }

    },

    preserveSelectionBeforeLoad: function(){
        let me = this,
            model = me.getViewModel(),
            sels = me.getView().getComponent('list').getSelection(),
            keys = sels.map((item)=>{ return item.getId() });
        model.set('oldSelection', keys);
    },


    updatePager: function(){
        
        let me = this,
            view = me.getView(),
            store = me.getStore(),
            range = store.getRange()
            model = me.getViewModel(),
            selModel = me.getView().getComponent('list').getSelectionModel(),
            record = selModel.getSelection()[0];
            if (Ext.isEmpty(record)&&(range.length>0)){ 
                    record = range[0];
                    selModel.select(record);
            }
            /*
            console.warn( view.$className, view.id,model.$className,model.id,store.$className,store,selModel.$className);
            if (record){
                model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            } else {
                model.set('selectRecordRecordNumber',0);
            }
            //model.set('pager',pagerData);
            model.set('disablePrev',model.get('selectRecordRecordNumber')<=1);
            model.set('disableNext',model.get('selectRecordRecordNumber')>=store.getCount());
            model.set('pagerText',model.get('selectRecordRecordNumber')+'/'+store.getCount());
            */
    },

    onDeferedStoreLoad: function(){
        this.getStore().load();
    },

    onBeforeStoreLoad: function(store){
        var model = this.getViewModel(),
            view = this.getView(),
            referencedRecord = null, // this.getParentRecord()//model.get('referencedRecord'),
            reference = {},
            listfilter = this.getStore().getFilters(),
            listsorters =this.getStore().getSorters(),
            

            filters = [],
            sorters = [],
            extraParams = store.getProxy().getExtraParams();
        
        this.preserveSelectionBeforeLoad();

        if(Ext.getApplication().getDebug()===true){
            console.log('onBeforeStoreLoad','listfilter',listfilter)
            console.log('onBeforeStoreLoad','listsorters',listsorters)
        }
        if (view.isVisible(true)==false){ 
            console.debug(this.$className,'onBeforeStoreLoad','view.isVisible(true)==false');
            view.un('show',this.onDeferedStoreLoad,);
            view.on({ show: {fn: this.onDeferedStoreLoad, scope: this, single: true} });

            return false;
        }

        listsorters.each(function(item){
            sorters.push(item.getConfig());
        });
        listfilter.each(function(item){
            filters.push(item.getConfig());
        });
        if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (view.referencedList===true){
            referencedRecord = this.getReferencedRecord();

            if(Ext.getApplication().getDebug()===true) console.log('referencedRecord',referencedRecord)
            if ( (typeof referencedRecord=='undefined')||(referencedRecord==null) ) return false;
            if (!Ext.isEmpty(referencedRecord)){
                for(var ref in view.referenced){
                    if (ref.indexOf(model.get('table_name')+'__')==0){
                        ref = ref.replace(model.get('table_name')+'__','');
                    }
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
        store.getProxy().setExtraParams(extraParams);
        return true;

    },




    save: function(cb){
        let model = this.getViewModel(),
            store = this.getStore(),
            wasNew = model.get('isNew'),
            keys = model.get('primaryKeys'),
            tablename = model.get('tablename'),
            form = this.getView().getComponent('form'),
            invalidFields = form.query("field{isValid()==false}"),
            ok=true;

        try{
            if (form.isValid()==false){
                invalidFields.forEach(function(fld){
                    if ((fld.hidden==false) && (tablename==fld.tablename)){
                        Ext.toast({
                            html: 'Fehlerhafte Eingabe im Feld: '+fld.fieldLabel+' ',
                            title: 'Fehler',
                            width: 200,
                            align: 't',
                            iconCls: 'fa fa-warning'
                        });
                        ok=false;
                    }
                });
                if (ok===false)    return;
            }
        }catch(e){
            console.error('invalidFields',e);
        }

        if ( !Ext.isEmpty(store.getModifiedRecords()) ){
            model.set('saving',true);

            store.on({
                proxyerror:{fn: this.onProxyError, scope: this, single: true}
            });

            store.on('write',function(store, operation, eOpts){   
                let response = operation.getResponse();
                if (response.status==200){
                    if (response.responseJson){
                        if (response.responseJson.success==true){
                            if (response.responseJson.data){
                                

                                response.responseJson.data.forEach(function(item){

                                    response.request.records.forEach(function(record){
                                        if (record.get('__id')==item['__id']){
                                            record.set(item);
                                            if (item['__newid'])  record.set('__id',item['__newid']);
                                            
                                        }
                                    })
                                    /*
                                    let record = store.getById(item[keys[0]]);
                                    if (record){
                                        record.set(item);
                                    }
                                    */
                                })
                            }
                        }
                    }
                }
                if(Ext.getApplication().getDebug()===true) console.info('operation',operation); 
                if(Ext.getApplication().getDebug()===true) console.debug('write success',arguments); 
            },this,{single:true});


            store.sync({
                scope: this,
                failure: function(){
                    if(Ext.getApplication().getDebug()===true) console.error('save failure',arguments);
                    model.set('saving',false);
                },
                success: function(c,o){
                    //this.saveSubStores();
                    //o.operations.create.forEach(function(item){
                        if(Ext.getApplication().getDebug()===true) console.log('save success',arguments);
                    if (o && o.operations && o.operations.create){
                        o.operations.create.forEach(function(item){
                            console.log('save success',item);
                        });
                    }
                    model.set('saving',false);
                    model.set('isNew',false);
                    model.set('isModified',store.getModifiedRecords().length!=0);
                }
            });
        }else{
            // this.saveSubStores();
            // model.set('saving',false);
        }
        


    },

    onProxyError: function(response){
        let form = this.getView().getComponent('form'),
            showToast = true;
        if (response.responseJson){
            if (response.responseJson.msg.indexOf('foreign key constraint fails ')){
                m = response.responseJson.msg.match(/FOREIGN\sKEY\s\((.*?)\)/)
                if (m && m[1]){
                    
                    let l =  m[1].split('`,`');
                    l.forEach(function(fld){
                        fld = fld.replace(/\`/g,'');
                        let el = form.down('[name='+ fld+']');
                        if (Ext.isEmpty(el)) return;
                        el.addCls('label-shake');
                        Ext.defer(()=>{  el.removeCls('label-shake') }, 1000 );
                    
                        Ext.toast('Für '+el.config.placeholder+' muss ein gültiger Wert angegeben werden');
                        showToast = false;
                    })
                }
                m = response.responseJson.msg.match(/Column\s\'(.*?)\'(.*)/);
                if (m && m[1]){
                    
                    let l =  m[1].split('`,`');
                    l.forEach(function(fld){
                        fld = fld.replace(/\`/g,'');
                        let el = form.down('[name='+ fld+']');
                        if (Ext.isEmpty(el)) return;
                        el.addCls('label-shake');
                        Ext.defer(()=>{  el.removeCls('label-shake') }, 1000 );
                        Ext.toast('Für '+el.config.placeholder+' muss ein gültiger Wert angegeben werden');
                        showToast = false;
                    })
                }

                m = response.responseJson.msg.match(/Duplicate\sentry/)
                if (m){
                    Ext.toast('Es gibt bereits einen solchen Eintrag');
                    showToast = false;
                }
            }
            if (showToast) Ext.toast(response.responseJson.msg);
        }
    },

    saveSubStores: function(){
        var model = this.getViewModel();
        try{
            /*
            model.get('subStores').each(function(item){
                item.sync();
            });
            */
        }catch(e){
            console.error(e);
        }
    },
});