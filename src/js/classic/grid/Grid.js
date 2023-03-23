Ext.define('Tualo.DataSets.grid.Grid', {
    extend: 'Ext.grid.Panel',
    viewModel: {
        data: {
            empty: '',
            selectRecordRecordNumber: 1,
            activeItem: 0,
            pageSize: 0,
            isNew: false,
            showFormOnAddRecord: true,
            visibleReference: 'list',
            referencedRecord: null,
            hasModifiedRecords: false
        },
    },
    /*
    tools: [
        {
        xtype: 'container',
        defaults: {
            flex: '1 1 auto'
        },
        defaultType: 'button',
        layout: {
            type: 'box',
            vertical: false,
            align: 'stretch'
        },
        items: [
            {
                iconCls: 'x-fa fa-save',
                handler: 'onSave',
                bind:{
                    disabled: '{!hasModifiedRecords}'
                }
            }
        ]
        }
    ],
    */
    controller: 'dsgridcontroller',
    constructor: function(config){
        let store = Ext.data.StoreManager.lookup('ds_'+this.tablename),
            storeConst = Ext.ClassManager.getByAlias('store.ds_'+this.tablename);
        if (typeof store=='undefined'){
            new storeConst();
        }
        this.callParent([config]);
        this.initEvents();
    },
    initEvents: function(){
        this.on('childdoubletap',this.onChildDoubleTab,this);
        this.on('painted',this.onPainted,this);
        this.getStore().on('beforeload',this.onBeforeStoreLoad,this);
        
    },
    onPainted: function(){
        console.log('onPainted');
        this.getStore().load();
    },
    onChildDoubleTab: function(){

        TualoOfficeApplication.getApplication().record = this.getSelection();
        TualoOfficeApplication.getApplication().redirectTo('ds/form'+'/'+this.getStore().tablename);
    },
    getParentRecord: function(){
        let view = this;
        return view.up(view.referencedXType).getRecord();
    },
    onBeforeStoreLoad: function(store){
        var model = this.getViewModel(),
            view = this,
            referencedRecord = null, // this.getParentRecord()//model.get('referencedRecord'),
            reference = {},
            listfilter = view.getStore().getFilters(),
            listsorters =view.getStore().getSorters(),
            

            filters = [],
            sorters = [],
            extraParams = store.getProxy().getExtraParams();
            
            console.log('onBeforeQuicksearchStoreLoad','listfilter',listfilter)
            console.log('onBeforeQuicksearchStoreLoad','listsorters',listsorters)
        
            
            /*
        listfilter.each(function(item){
            console.log('listfilter',item.getConfig());
            filters.push({
                operator: item.getOperator(),
                value: item.getValue(),
                property: item.getProperty()
            });
        });
            */

        listsorters.each(function(item){
            sorters.push(item.getConfig());
        });
        
        
        if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (view.referencedList===true){
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

    }
});