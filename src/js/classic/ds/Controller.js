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
        // window[this.getView().xtype]=this;
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
    onFormExpand: function(){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            form = this.getView().getComponent('form'),
            list = this.getView().getComponent('list'),
            record = model.get('record');
        console.log('onFormExpand',record,form);
        if (form){
            if (form.items){
                if (form.items.getAt(0)){
                        setTimeout(()=>{
                            try{
                                form.items.getAt(0).activeTab.getController().onDeferedStoreLoad();
                            }catch(e){
                                console.error(e);
                            }
                        },10)
                }
            }
        }

        // form.items.getAt(0).activeTab.getController().onDeferedStoreLoad()
        // window.form = form;
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

       let view = this.getView();
        if (typeof view.searchFor=='string'){
            this.searchFor(view.searchFor);
        }else if (typeof view.filterBy=='object'){
            this.filterBy(view.filterBy);
        }else{
            store.load();
        }

    },

    searchFor: function(searchFor){
        let view = this.getView(),
            store = view.getComponent('list').getStore();
        store.getProxy().setExtraParam("filter_by_search",1);
        store.getProxy().setExtraParam("search",searchFor );
        view.down('dssearchfield').setValue(searchFor);
        view.getController().setViewType("list");
        store.load();
    },
    
    filterBy: function(filterBy,cb){
        let view = this.getView(),
            store = view.getComponent('list').getStore(),
            columns = view.getComponent('list').getColumns();
        filterBy.forEach(function(item){
            columns.forEach(function(column){
                if (item.property ==  column.dataIndex ){
                    try{
                        if ((column.filter.acceptedType==='array') && (typeof item.value=='string')){ 
                            column.filter.filter.setValue( [item.value] );
                        }else{
                            column.filter.filter.setValue( item.value );
                        }
                    }catch(e){
                        console.error(e);
                    }
                    column.filter.setActive ( true ) ;
                }
            })
        });
        if (typeof cb=='function') cb=()=>{};
        store.load({
            callback: cb
        });
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
        console.debug('onDataChanged','getModifiedRecords',store.getModifiedRecords());
        model.set('isModified',store.getModifiedRecords().length!=0);
    },
    
    onListSelect: function(selModel, record, eOpts){
        let me = this,
            model = me.getViewModel(),
            form = this.getView().getComponent('form'),
            list = this.getView().getComponent('list'),
            store = list.getStore(),
            record = selModel.getSelection()[0];
        console.log('onListSelect',record,selModel,selModel.getSelection());
        if (record){
            model.set('selectRecordRecordNumber',store.indexOf(record)+1);
            model.set('record',record);
            form.loadRecord(record);
            //this.getView().getComponent('list').getSelectionModel().select(record);
        } else {
            model.set('selectRecordRecordNumber',0);
            model.set('record',null);
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
            form.loadRecord(record);
        } else {
            model.set('selectRecordRecordNumber',0);
            model.set('record',null);
        }
    },

    
    onItemDblClick: function ( view, record, item, index, e, eOpts ){
        let me = this,
            model = me.getViewModel(),
            store = me.getStore(),
            tablename = model.get('table_name')||'None',
            tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1),
                    
            form = this.getView().getComponent('form');

            console.log('onItemDblClick',tablename,model);
        if (record){
            form.loadRecord(record);
            
        } 
        
        /*
        let f = Ext.getApplication().addView(
            'Tualo.DataSets.form.'+    tablenamecase,
            {
                record: record,
                isNew: false,
                viewTypeOnLoad: 'form'
            }
        );

        f.loadRecord(record);
        */
        /*
        console.log('onItemDblClick',arguments);
        Ext.getApplication().redirectTo('dsform/'+this.getViewModel().get('table_name')+'/'+record.get('__id'),{
            force: true
        });
        */


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
            setTimeout(()=>{
                me.getView().getComponent('list').view.bufferedRenderer.scrollTo(0, true);
            },100);
            setTimeout(()=>{
                me.getView().getComponent('list').view.bufferedRenderer.scrollTo(selIndex, true);
            },300);
            console.debug('preserveSelection',model.get('record'));
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
            tablename = model.get('table_name'),
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
            store.sync({
                scope: this,
                failure: function(){
                    if(Ext.getApplication().getDebug()===true) console.error('save failure',arguments);
                    model.set('saving',false);
                },
                success: function(c,o){
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
    filterField: function(field,id){
        var me = this,
            view = me.getView(),
            store = me.getStore(),
            filterBy = [
                {
                    "property": field,
                    "value": id,
                    "operator": "="
                }
            ];
        console.log('filterField',field,id,filterBy);
        if (store.isLoading()){
            console.log('filterField','store is loading');
        }
        else if(!store.isLoaded()){ 
            this.filterBy(filterBy,()=>{
                console.debug(this.$className,'loadById','filterBy','form');
                this.setViewType('form');
            });
        }else{
            store.clearFilter();
            console.debug(this.$className,'loadById','store.clearFilter()');
            this.filterBy(filterBy,()=>{
                this.setViewType('form');
            });
        }
    }
});