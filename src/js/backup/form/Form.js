Ext.define('Tualo.DataSets.form.Form', {
    extend: 'Ext.form.Panel',
    tools: [
        {
            xtype: "combobox",
            reference: "quicksearchComboBox",
            // queryParam: 'quicksearchquery',
            displayField: "__displayfield",
            flex: 2,
            valueField: "__id",
            placeholder: "  Suchen ...",
            typeAhead: false,

            hideLabel: true,
            hideTrigger:true,
            ui: "alt",
            minChars: 3,
            flex: 1,
            store: "ds_ds"
        }
    /*,{
        xtype: 'list',
        reference: 'searchlist',
        emptyText: 'No matching posts found.',
        style: 'position: relative;',
        flex: 1,
        hidden: true,
        bind: {
            hidden: '{!query}'
        },
        plugins: {
            pullrefresh: true
        },
        store: {
            type: 'ds_ds',
            pageSize: 10
        },
        itemTpl: '<a class="search-item" ' +
                'href="http://www.sencha.com/forum/showthread.php?t={topicId}&p={id}">' +
            '<h3><span>{[Ext.Date.format(values.lastPost, "M j, Y")]}' +
                '<br>by {author}</span>{title}' +
            '</h3>' +
            '{excerpt}' +
        '</a>'
    }*/,{
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
            },
            {
                iconCls: 'x-fa fa-redo',
                handler: 'onReject',
                bind:{
                    disabled: '{!hasModifiedRecords}'
                }
            },{
                iconCls: 'x-fa fa-window-close',
                handler: 'onCloseClick'
            }
        ]
    }],
    constructor: function(config){
        let store = Ext.data.StoreManager.lookup('ds_'+this.tablename),
            storeConst = Ext.ClassManager.getByAlias('store.ds_'+this.tablename);
        if (typeof store=='undefined'){
            new storeConst();
        }
        this.callParent(config);
        this.changedDataItems = new Ext.util.Collection({
            
        })
        this.initEvents();
    },
    initEvents: function(){
        this.on('dirtychange',this.onDirtychange,this);
        var form = this; // Your selector may be different.
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { formField.resetOriginalValue(); });
        form.queryBy(function(component) { return !!component.isDataView; }).forEach(function(grid) { grid.getStore().on('datachanged',form.onSubListDataChanged,form); });
    },
    "controller": "dsformcontroller",
    onSubListDataChanged: function(store,opts){
        console.log('onSubListDataChanged',store.getModifiedRecords(),store.id,store.tablename,this.changedDataItems)
        if (this.changedDataItems){
            if ( store.getModifiedRecords().length>0 ){
                this.changedDataItems.add(store);
            }else{
                this.changedDataItems.removeByKey(store.id);
            }
        }
    },
    onDirtychange: function(view,dirty,opts){
        console.log('onDirtychange',dirty);
        //this.getViewModel().set('hasModifiedRecords',dirty);
    },
    updateRecord: function(nv,ov){
        this.callParent([nv,ov]);
        var form = this; // Your selector may be different.
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { formField.resetOriginalValue(); })
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { form.getController().onFormFieldLabelClass(formField); })
    },
    layout: "fit",
    bodyPadding: "0px",
    viewModel: {
        data: {
            isNew: false,
            hasModifiedRecords: false
        },
        formulas: {
            iconListForm: function(get){
                if (get('visibleReference')=='list'){
                    return 'x-fa fa-edit';
                }else{
                    return 'x-fa fa-table';
                }
            },
            style: function(get){
                if (get('isNew')){
                    return {
                        'background-color': 'var(--confirm-color)'
                    }
                }
                return {
                    'background-color': 'var(--base-color)'
                }
            }
        }
    },

});