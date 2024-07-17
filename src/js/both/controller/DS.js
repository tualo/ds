Ext.define('Tualo.cmp.cmp_ds.controller.DS', {
    extend: 'Ext.app.ViewController',
    mixins: ['Tualo.cmp.cmp_ds.controller.mixins.Save'],

    alias: 'controller.cmp_ds_dsview_controller',

    initViewModel: function(vm) {
        /*
        var me = this;
        me.callParent(arguments);
        vm.bind('{selectRecordRecordNumber}', function(nv,ov){
            me.doSelectRecordIndex();
        });
        */
    },

    onFormPainted: function(view){
        console.log('onFormPainted',this.alias);
    },
    onListPainted: function(view){
        console.log('onListPainted',this.alias);
        window.view = view;
        
        //view.getView().refresh();
        //view.realign();

    },

    onListSelect: function(listview,record){
        console.debug('onListSelect',this.alias);
        let model = this.getViewModel(),
            view = this.getView(),
            store = this.lookup('list').getStore(),
            list = this.lookup('list'),
            form = this.lookup('form');

        form.items.each(function(elmform){
            elmform.items.each(function(elm){
                if (elm.referencedList){
                    elm.getViewModel().set('referencedRecord',record[0]);
                }
            });
        });
        form.fireEvent("recordchanged",record[0]);
    },

    onPageSizeChanged: function(nv,ov){
        if ((nv>0) && (ov==="") ){
            let store = this.lookup('list').getStore();
            store.setPageSize(nv);
            store.loadPage(1);
        }
    },
    onPainted: function(){
        let form = this.lookup('form'),
            view = this.getView(),
            list = this.lookup('list'),
            me = this;

        list.getStore().on('beforeload',this.onBeforeStoreLoad,this);
        list.getStore().on('datachanged',this.onDatachange,this);
        list.getStore().on('load',this.onStoreLoad,this);

        form.items.each(function(elmform){
            elmform.items.each(function(elm){
                if (elm.referencedList){
                    elm.lookup('list').getStore().on('datachanged',me.onDatachange,me);
                }
            });
        });


    },
    onDatachange: function(store,eopts){
        let modified=false,
            model = this.getViewModel(),
            view = this.getView(),
            form = this.lookup('form');
        modified = store.getModifiedRecords().length!==0;
        form.items.each(function(elmform){
            elmform.items.each(function(elm){
                if (elm.referencedList){
                    modified = modified || elm.getViewModel().get('hasModifiedRecords');
                }
            });
        });
        console.log(store.tablename,modified);
        view.fireEvent('datachanged',store,eopts);
        model.set('hasModifiedRecords',modified);
    },
    onChildDoubleTab: function(){
        this.onSegClicked(null);
    },
    onSegClicked: function(btn){
        var model = this.getViewModel(),
            view = this.getView(),
            store = this.lookup('list').getStore(),
            list = this.lookup('list'),
            form = this.lookup('form');
        if (this.getView().getActiveItem().reference=='list' ){
            view.setActiveItem( form );
            model.set('visibleReference',form.reference);
        }else{
            view.setActiveItem( list )
            model.set('visibleReference',list.reference);
        }
    },


    onBeforeStoreLoad: function(store){
        var model = this.getViewModel(),
            view = this.getView(),
            referencedRecord = model.get('referencedRecord'),
            reference = {},
            listfilter = [],//this.lookup('list').getStore().getFilters(),
            listsorters =this.lookup('list').getStore().getSorters(),
            filters = [],
            sorters = [],
            extraParams = store.getProxy().getExtraParams();
            //console.log('onBeforeQuicksearchStoreLoad','listfilter',listfilter)
            //console.log('onBeforeQuicksearchStoreLoad','listsorters',listsorters)
        /*
        listfilter.forEach(function(item){

            filters.push({
                operator: item._operator,
                value: item._value,
                property: item._property
            });

        });

        listsorters.forEach(function(item){
            sorters.push(item.getConfig());
        });
        */

        if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (view.referencedList===true){
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

    onStoreLoad: function(store, records, successful, operation, eOpts){
        var model = this.getViewModel(),
            view = this.getView();
            model.set('total',store.getTotalCount());
        model.set('pageSize',store.getPageSize());
        
        if (model.get('isNew')){
            model.set('isNew',false);
        }
        Ext.defer(this.doSelectRecordIndex,1000,this,[]);
    },
    onReload: function(){
        let store = this.lookup('list').getStore();
        store.load();
    },
    onPrev: function(){
        if (Ext.isEmpty(this.getViewModel().get('selectedRecord'))) return;
        let store = this.lookup('list').getStore(),
            model = this.getViewModel(),
            record = model.get('selectedRecord'),
            pageSize = store.getPageSize(),
            currentPage = store.currentPage,
            pageToLoad = Math.ceil( record.get('__rownumber')*1/pageSize );

        if (record.get('__rownumber')*1-1<1){
            return;
        }

        model.set('selectRecordRecordNumber',  record.get('__rownumber')*1-1  );
        if (record.get('__rownumber')*1-1 <= currentPage*(pageSize)-pageSize){
            
            store.loadPage(pageToLoad-1);
        }else{
            this.doSelectRecordIndex();
        }
    },
    onNext: function(){
        if (Ext.isEmpty(this.getViewModel().get('selectedRecord'))) return;
        let store = this.lookup('list').getStore(),
            model = this.getViewModel(),
            record = model.get('selectedRecord'),
            pageSize = store.getPageSize(),
            currentPage = store.currentPage,
            pageToLoad = Math.ceil( record.get('__rownumber')*1/pageSize );

            if (record.get('__rownumber')*1+1>store.getTotalCount()){
                return;
            }
    
            model.set('selectRecordRecordNumber',  record.get('__rownumber')*1+1  );
            if (record.get('__rownumber')*1+1 > currentPage*pageSize){
                store.loadPage(pageToLoad+1);
            }else{
                this.doSelectRecordIndex();
            }
    },

    onSyncStore: function(){
        console.debug('onSyncStore',this.alias,arguments);
        model.set('isNew',false);
    },

    doSelectRecordIndex: function(){
        console.debug('doSelectRecordIndex',this.alias);
        /*
        try{
            var model = this.getViewModel(),
                view = this.getView(),
                list = this.lookup('list'),
                store = list.getStore(),
                range = store.getRange(),
                record = store.findRecord('__rownumber',model.get('selectRecordRecordNumber'),0,false,false,true);

            if ( Ext.isEmpty(record) ){
                if (range.length>0){
                    record=range[0];
                }else{
                   // this.append();
                }
            }
            if ( !Ext.isEmpty(record) ){
                list.setSelection( null );
                list.setSelection( record );

                list.scrollToRecord(record);
            }else{

            }
            // con sole.de bug('doSelectRecordIndex','OK',this.alias);
        }catch(e){
            console.debug('doSelectRecordIndex','error',e);
        }
        */
    },

    skipRecord: function(){
    },
    onActiveItem: function(item){

    },
    /*
    onSelect: function(selection) {
        var dataview;

        if (selection) {
            this.lookup('grid').ensureVisible(selection);
            dataview = this.lookup('dataview');
            dataview.getScrollable().scrollIntoView(dataview.getNode(selection));
        }
    },
    */
    

    onAdd: function(){
        var model = this.getViewModel(),
            store = this.lookup('list').getStore(),
            view = this.getView(),
            referencedList = model.get('referencedList'),
            referencedRecord = model.get('referencedRecord'),
            
            fields = store.getModel().getFields(),
            values = {};


        for(i=0;i<fields.length;i++){
            if(!Ext.isEmpty(fields[i].defaultValue)){
                values[fields[i].name] = fields[i].defaultValue;
            }
        }
        if (referencedList==true){
            for(var ref in view.referenced){
                if (typeof view.referenced[ref]== 'string')
                    values[ref.toLowerCase()]=referencedRecord.get(view.referenced[ref].toLowerCase());
                if (typeof view.referenced[ref]== 'object'){
                    if (typeof view.referenced[ref].v== 'string')
                        values[ref.toLowerCase()]=view.referenced[ref].v;
                }
            }
        }

        var record = Ext.create('Tualo.DataSets.model.'+view.dsName,values);
        if (this.showSpecialAppend()){ return; }
        this.appendRecord(record);
    },

    appendRecord: function(record){
        var model = this.getViewModel(),
            view = this.getView(),
            store = this.lookup('list').getStore(),
            list = this.lookup('list');
        
        store.add(record);
        model.set('record',record);
        list.setSelection( record );
        model.set('isNew',true);

        if (model.get('showFormOnAddRecord')){
            view.setActiveItem( this.lookup('form') );
        }
        
    },

    onReject: function(){
        let model = this.getViewModel(),
            store = this.lookup('list').getStore(),
            view = this.getView(),
            list = this.lookup('list'),
            form = this.lookup('form');

        if (model.get('isNew')){
            model.set('isNew',false);
            view.setActiveItem( list );
        }
        store.rejectChanges();

        form.items.each(function(elmform){
            elmform.items.each(function(elm){
                if (elm.referencedList){
                    elm.lookup('list').getStore().rejectChanges();
                }
            });
        });
    },

    showSpecialAppend: function(){
        return false;
    }
});

