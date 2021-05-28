Ext.define('Tualo.cmp.cmp_ds.controller.DS', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.cmp_ds_dsview_controller',

    initViewModel: function(vm) {
        //console.debug(this.$className,'initViewModel',vm);
//        vm.bind('{selectedCompany}', 'onSelect', this);
        vm.bind('{activeItem}', 'onActiveItem', this);
        vm.bind('{pageSize}', 'onPageSizeChanged', this);
        //
    },

    onPageSizeChanged: function(nv,ov){
        if ((nv>0) && (ov==="") ){
            console.debug(this.$className,'onPageSizeChanged',nv,ov);
            let store = this.lookup('list').getStore();
            store.setPageSize(nv);
            store.loadPage(1);
        }
    },
    onPainted: function(){
        this.lookup('list').getStore().on('load',this.onStoreLoad,this);
    },

    onChildDoubleTab: function(){
        console.log( this.lookup('form') );
        console.log( this.getViewModel().get( 'selectedRecord' ) );
        this.getView().setActiveItem( this.lookup('form') );
        console.debug(this.$className,'onChildDoubleTab',arguments);
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
        console.debug(this.$className,'onBeforeStoreLoad',this.getView().tablename,view.referencedList);
    },

    onStoreLoad: function(store, records, successful, operation, eOpts){
        // con sole.de bug(this.$className,'onStoreLoad',arguments)
        var model = this.getViewModel(),
            view = this.getView();
            model.set('total',store.getTotalCount());
        
            console.log(this.$className,view.referencedList);
        model.set('pageSize',store.getPageSize());
        
        if (model.get('isNew')){
            model.set('isNew',false);
        }
        Ext.defer(this.doSelectRecordIndex,1000,this,[]);


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

    doSelectRecordIndex: function(){
        // con sole.de bug('doSelectRecordIndex',this.alias);
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
    },

    skipRecord: function(){
        ;
    },
    onActiveItem: function(item){
        console.debug('X',item);
    },
    onSelect: function(selection) {
        var dataview;

        if (selection) {
            this.lookup('grid').ensureVisible(selection);
            dataview = this.lookup('dataview');
            dataview.getScrollable().scrollIntoView(dataview.getNode(selection));
        }
    },

    onSave: function(){
        var model = this.getViewModel(),
            store = this.lookup('list').getStore();
        console.log(this.lookup('form').getValues());
        store.sync();
    },

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
            list = this.lookup('list');

        if (model.get('isNew')){
            model.set('isNew',false);
            view.setActiveItem( list );
        }
        store.rejectChanges();
    },

    showSpecialAppend: function(){
        return false;
    }
});

