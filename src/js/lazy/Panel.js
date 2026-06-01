Ext.define('Tualo.ds.lazy.Panel', {
    extend: 'Ext.panel.Panel',
    layout: 'fit',
    alias: 'widget.dsview_lazy_panel',
    config: {
        displaytype: 'list',
        tablename: null,
        record: null,
        dsID: null,
        fieldName: null,
        fieldValue: null,
    },
    initComponent: function () {
        var me = this;
        me.callParent(arguments);
        if (me.displaytype == 'list') {
            me.mainComponent = me.add({
                xtype: 'dslist_' + me.tablename,
                tablename: me.tablename,
                fieldName: me.fieldName,
                fieldValue: me.fieldValue,
                listeners: {
                    "itemdblclick":
                        function (me, record) {
                            console.log('itemdblclick', record);
                            console.log('itemdblclick', record.store.getId(), record.getId(), record.toUrl());

                            Ext.getApplication().redirectTo('lazyds/form/' + record.toUrl());

                            /*
                            let tablename = this.up('dsview_lazy_panel').tablename,
                                fieldName = this.up('dsview_lazy_panel').fieldName,
                                fieldValue = record.get(fieldName);
                            Ext.getApplication().redirectTo('lazyds/form/' + tablename + '/' + fieldName + '/' + fieldValue);
                            */
                        }

                }
            });
        }

        if (me.displaytype == 'form') {

            me.mainComponent = me.add({
                xtype: 'dsform_' + me.tablename,
                tablename: me.tablename,
                record: me.record,
                fieldName: me.fieldName,
                fieldValue: me.fieldValue,
            });

            if (me.dsID != null) {
                let store = Ext.data.StoreManager.lookup('ds_' + me.tablename);
                if (typeof store == 'undefined') {
                    let storeConst = Ext.ClassManager.getByAlias('store.ds_' + me.tablename);
                    if (typeof storeConst != 'undefined') {
                        new storeConst();
                        store = Ext.data.StoreManager.lookup('ds_' + me.tablename);
                    }
                }
                let record = store.findRecord('__id', me.dsID, 0, false, true, true);
                if (record) {
                    me.record = record;
                    me.mainComponent.loadRecord(record);
                    me.mainComponent.setBind({
                        record: record
                    });
                }

                console.log('dsview_lazy_panel', 'initComponent', 'store', record, store);


                /*
                if (typeof store != 'undefined') {
                    store.load({
                        params: {
                            id: me.dsID
                        },
                        callback: function (records, operation, success) {
                            if (success) {
                                if (records.length > 0) {
                                    me.record = records[0];
                                    me.add({
                                        xtype: 'dsform_' + me.tablename,
                                        tablename: me.tablename,
                                        record: me.record,
                                        fieldName: me.fieldName,
                                        fieldValue: me.fieldValue,
                                    });
                                } else {
                                    me.add({
                                        xtype: 'panel',
                                        html: 'Record not found',
                                    });
                                }
                            } else {
                                me.add({
                                    xtype: 'panel',
                                    html: 'Error loading record',
                                });
                            }
                        }
                    });
                } else {
                    me.add({
                        xtype: 'panel',
                        html: 'Store not found',
                    });
                }
                    */
            } else {
                me.add({
                    xtype: 'dsform_' + me.tablename,
                    tablename: me.tablename,
                    fieldName: me.fieldName,
                    fieldValue: me.fieldValue,
                    listeners: {
                        "itemdblclick": 'onItemDblClick'
                    }
                });
            }
        }
        console.log('dsview_lazy_panel', 'initComponent', me.tablename, me.fieldName, me.fieldValue);
    }
});