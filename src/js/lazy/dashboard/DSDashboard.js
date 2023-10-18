Ext.define('Tualo.ds.lazy.dashboard.DSDashboard', {
    requires: [
        // 'Ext.chart.CartesianChart'
    ],
    extend: 'Ext.dashboard.Part',
    alias: 'part.tualodashboard_ds',
    createView: function(config) {
        let me=this, view = this.callParent([config]);
        
        
        if (view._partConfig && view._partConfig.addConfiguration){
            view.title = view._partConfig.addConfiguration.title;
            let subqueries = [];
            let gridid=Ext.id()
            if (typeof view._partConfig.addConfiguration.subqueries=='object'){
                let tablenamecase = view._partConfig.addConfiguration.tablename.toLocaleUpperCase().substring(0, 1) + view._partConfig.addConfiguration.tablename.toLowerCase().slice(1);
                view._partConfig.addConfiguration.subqueries.forEach((item)=>{
                    let griditemid=Ext.id(),store = Ext.create('Tualo.DataSets.store.'+tablenamecase,{
                        autoLoad: false
                    });
                    store.setFilters(item.filter);
                    store.load({
                        callback: function(records, operation, success) {
                            try{
                                let grid_store = Ext.getCmp(gridid).getStore();
                                let rec = grid_store.findRecord('id',griditemid);
                                rec.set('count',records.length);
                                rec.commit();
                                store.destroy();
                            }catch(e){
                                console.error(e);
                            }
                        }
                    });
                    subqueries.push({
                        id: griditemid,
                        title: item.title,
                        count: 0,
                        filters: item.filter,
                        tablename: view._partConfig.addConfiguration.tablename
                    });
                });
            }

            view.items = [
                {
                    xtype: 'panel',
                    layout: {
                        type: 'vbox',
                        align: 'stretch'
                    },
                    bodyPadding: 8,
                    items: [
                        {
                            xtype: "textfield",
                            width: '100%',
                            emptyText: "Suchen ...",
                            tablename: view._partConfig.addConfiguration.tablename,
                            triggers: {
                                bar: {
                                    weight: 0,
                                    cls: Ext.baseCSSPrefix + "form-clear-trigger",
                                    handler: function(field) {
                                        field.setValue("");
                                    }
                                }
                            },
                            listeners: {
                                specialkey: function(field, e){
                                    if (e.getKey() == e.ENTER) {
                                        let type = 'dsview';
                                        let tablenamecase = field.tablename.toLocaleUpperCase().substring(0, 1) + field.tablename.toLowerCase().slice(1);
                                        Ext.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase,{
                                            searchFor: field.getValue()
                                        });
                                    }
                                }
                            }
                        },{
                            xtype: 'grid',
                            border: false,
                            id: gridid,
                            listeners: {
                                itemdblclick: function( me, record, item, index, e, eOpts ){
                                    let type = 'dsview';
                                    let tablenamecase = record.get('tablename').toLocaleUpperCase().substring(0, 1) + record.get('tablename').toLowerCase().slice(1);
                                    Ext.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase,{
                                        filterBy: record.get('filters')
                                    });
                                }
                            },
                            store: {
                                type: 'json',
                                fields: ['id','title','count','filters','tablename'],
                                idProperty: 'id',
                                data: subqueries
                            },
                            hideHeaders: true,
                            columns: [
                                {
                                    dataIndex: 'title',
                                    text: 'Title',
                                    flex: 1

                                },
                                {
                                    dataIndex: 'count',
                                    align: 'end',
                                    renderer: function(v){
                                        return Ext.util.Format.number(v,'0.000/i');
                                    },
                                    text: 'Count'
                                }
                            ],
                            flex: 1
                        }
                    ]
                }
            ]
        }
        return view;
    },
    config:{
        addConfiguration: true,
    },

    viewTemplate: {
        layout: 'fit',
        title: 'Dashboard',
        
    }
});