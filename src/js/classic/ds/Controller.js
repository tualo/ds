Ext.define('Tualo.DS.panel.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dspanelcontroller',
    mixins: {
        util: 'Tualo.DS.panel.mixins.ControllerTools'
    },
    onRowClass: function(record, rowIndex, rowParams, store){
        var tn = store.tablename||"";
        console.log('dspanelcontroller onRowClass',record, rowIndex, rowParams, store);
        if ((rowIndex%2==0)&&(typeof record.get(tn+"___rowclass_even")=="string")){
            return record.get(tn+"___rowclass_even");
        }
        if ((rowIndex%2==1)&&(typeof record.get(tn+"___rowclass_odd")=="string")){
            return record.get(tn+"___rowclass_odd");
        }
        return "";
    },

    constructor: function(config){
        this.callParent([config]);
    },
    onBoxReady: function(x){
        this.initEvents();
        //window[this.getView().xtype]=this;
        if (this.getView().referencedList===true){
            if (!Ext.isEmpty(this.getReferencedRecord())){
                this.getReferencedView().getViewModel().bind('{record}', this.onReferencedRecordChange, this);
            }
        }
    },
    onReferencedRecordChange: function(record){
        if (record){
            console.log('referenced record changed',this.$className,record);
            this.getStore().load();
        }
    },
    getReferencedView: function(){
        let view = this.getView().up().up().up();
        console.log('getReferencedView',this.getView().referencedList,view);
        return view;
    },
    getReferencedRecord: function(){
        if (
            this.getView().referencedList===true &&
            (this.getReferencedView().getViewModel())){
            return this.getReferencedView().getViewModel().get('record');
        }

        return null;
        //return this.getReferencedView().getComponent('list').getSelectionModel().getSelection()[0];
    },
    initEvents: function(){
       let c = this;

       let store = this.getStore(),
           list = this.getView().getComponent('list');

       store.on('datachanged',this.onDataChanged,this);
       store.on('beforeload',this.onBeforeStoreLoad,this);
       store.on('load',this.onStoreLoad,this);
       list.on('selectionchange',c.onListSelectionChange,this);
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
            fld_name = model.get('table_name') + '__' + model.get('reorderfield');
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
    
    onListSelectionChange: function(selModel, selected, eOpts){
        
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            form = this.getView().getComponent('form'),
            record = selModel.getSelection()[0];

        if (record){
            model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            model.set('record',record);
            form.loadRecord(record);

        } else {
            model.set('selectRecordRecordNumber',0);
            model.set('record',null);
            // form.loadRecord(null);
        }

        console.log('onListSelectionChange',model.$className);
        model.set('disablePrev',model.get('selectRecordRecordNumber')<=1);
        model.set('disableNext',model.get('selectRecordRecordNumber')>=store.getCount());
        model.set('pagerText',model.get('selectRecordRecordNumber')+'/'+store.getCount());
        
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
            this.setViewType('list');
        }
        this.updatePager();
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
            
            console.log('onBeforeStoreLoad','listfilter',listfilter)
            console.log('onBeforeStoreLoad','listsorters',listsorters)
        
            

        listsorters.each(function(item){
            sorters.push(item.getConfig());
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
                console.info('operation',operation); 
                console.debug('write success',arguments); 
            },this,{single:true});


            store.sync({
                scope: this,
                failure: function(){
                    console.error('save failure',arguments);
                    model.set('saving',false);
                },
                success: function(c,o){
                    //this.saveSubStores();
                    //o.operations.create.forEach(function(item){
                    console.log('save success',arguments);
                    model.set('saving',false);
                    model.set('isNew',false);
                    model.set('isModified',store.getModifiedRecords().length!=0);
                    // if (typeof cb=='function') cb(c,o);
                }
            });
        }else{
            // this.saveSubStores();
            // model.set('saving',false);
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