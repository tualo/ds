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
        if (this.getView().referencedList===true){
            window.referencedListView=this
            if (!Ext.isEmpty(this.getReferencedRecord())){
                this.getView().up().up().up().getViewModel().bind('{record}', this.onReferencedRecordChange, this);
            }
        }
    },
    onReferencedRecordChange: function(record){
        if (record){
            this.getStore().load();
        }
    },
    getReferencedRecord: function(){
        return this.getView().up().up().up().getViewModel().get('record');
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
    onDataChanged: function(t,e){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore();
        model.set('isModified',store.getModifiedRecords().length!=0);
    },
    onListSelectionChange: function(selModel, selected, eOpts){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            record = selModel.getSelection()[0];

        if (record){
            model.set('selectRecordRecordNumber',store.indexOf(record)+1);
        } else {
            model.set('selectRecordRecordNumber',0);
        }
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
        console.debug(this.$className,'onStoreLoad',records.length,successful,operation,eOpts);
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
            model = me.getViewModel(),
            selModel = me.getView().getComponent('list').getSelectionModel(),
            pagerData = {
                total: store.getTotalCount(),
                count: store.getCount(),
                page: store.currentPage,
                pages: store.getTotalCount() / store.pageSize
            },
            record = selModel.getSelection()[0];
            console.warn( view.$className, view.id,model.$className,model.id,store.$className,store.id,selModel.$className);
            if (record){
                model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            } else {
                model.set('selectRecordRecordNumber',0);
            }
            model.set('pager',pagerData);
            model.set('disablePrev',model.get('selectRecordRecordNumber')<=1);
            model.set('disableNext',model.get('selectRecordRecordNumber')>=store.getCount());
            model.set('pagerText',model.get('selectRecordRecordNumber')+'/'+store.getCount());
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
            store.sync({
                scope: this,
                failure: function(){
                    model.set('saving',false);
                },
                success: function(c,o){
                    this.saveSubStores();
                    model.set('saving',false);
                    model.set('isNew',false);
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