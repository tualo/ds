Ext.define('Tualo.ds.lazy.ViewPanel', {
    //extend: 'Tualo.panel.Accordion',
    extend: 'Ext.panel.Panel',
    layout: 'card',
    alias: 'widget.dsviewpanel',
    config: {
        tablename: null,
    },
    controller: 'dspanelcontroller',

    
    tbar: [{
        xtype: 'breadcrumb',
        showIcons: true,
        store: {
            type: 'tree', 
            
            root: {
                text: 'Ext JS',
                expanded: true,
                children: [
                    {
                        text: 'app',
                        children: [
                            { leaf: true, text: 'Application.js' }
                        ]
                    }
                ]
            },
        },
        items: [{
            xtype: 'component',
            html: 'Navigation:',
            style: {
                'margin-left': '10px',
                'margin-right': '10px'
            }
        }]
    }],
    
    viewModel: {
        data: {
            record: null,
        },
        formulas: {
            listTitle: function(get){
                if (get('record')!=null && get('record').get('__displayfield')!=null){
                    return 'Liste: '+  get('record').get('__displayfield')  ;
                }else{
                    return 'Liste: kein Datensatz ausgewählt';
                }
            },
            disabledForm: function(get){
                return get('record')==null;
            },
            formTitle: function(get){
                if (get('record')!=null && get('record').get('__displayfield')!=null){
                    return 'Formular: '+  get('record').get('__displayfield')  ;
                }else{
                    return 'Formular: kein Datensatz ausgewählt';
                }
            }
        }
    },
    loadExtraPanels: function(){
        console.log('Tualo.ds.lazy.ViewPanel','loadExtraPanels');
        window.p = this;
    },
    constructor: function(config) {
        console.log('Tualo.ds.lazy.ViewPanel',config);
        if (typeof config.listeners=='undefined'){
            config.listeners = {};
        }
        this._afterrender=()=>{ return true };
        if (typeof config.listeners.afterrender=='function'){
            this._afterrender = config.listeners.afterrender;
        }
        if (typeof config.listeners.afterrender=='undefined'){
            config.listeners.afterrender = function(){
                console.log('Tualo.ds.lazy.ViewPanel.afterrender',this,arguments);
                this.loadExtraPanels();
                return  this._afterrender() && this.fireEvent('viewpanelReady',this);
            };
        }

        if (config.tablename!=null){
            config.items = [
                {
                    /*bind:{
                        title: '{listTitle}',
                    },
                    */
                    xtype: 'dslist_'+config.tablename,
                    reference: 'list',

                    listeners: {
                        select: function(me,record){
                            this.up('dsviewpanel').getViewModel().set('record',record);
                            console.log('select',arguments);
                        }
                    }
                },
                /*
                {
                    bind:{
                        title: '{formTitle}',
                       // disabled: '{disabledForm}'
                    },
                    title: '{formTitle}',
                    height: 600,
                    reference: 'form',
                    record: '{record}',
                    xtype: 'dsform_'+config.tablename,
                },
                */
            ];
            
        }else{
            config.items = [
                {
                    title: 'Fehler',
                    xtype: 'panel',
                    html: 'Tablename not set',
                }
            ];
        }
        this.initConfig(config);
        console.log('Tualo.ds.lazy.ViewPanel',this.initialConfig);
        return this.callParent(arguments);
    }
});