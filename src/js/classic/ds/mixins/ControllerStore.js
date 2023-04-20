Ext.define('Tualo.DS.panel.mixins.ControllerStore', {
    
    initStoreEvents: function(){
        let cntrl = this;
        let store = cntrl.getStore();
       
        
        store.on('load',function(store,records,successful,operation,eOpts){
            console.log('store load',store,records,successful,operation,eOpts);
        });
        store.on('beforeload',function(store,operation,eOpts){
            console.log('store beforeload',store,operation,eOpts);
        });
        store.on('add',function(store,records,index,eOpts){
            console.log('store add',store,records,index,eOpts);
        });
        store.on('remove',function(store,record,index,isMove,eOpts){
            console.log('store remove',store,record,index,isMove,eOpts);
        });
        store.on('update',function(store,record,operation,eOpts){
            console.log('store update',store,record,operation,eOpts);
        });
        store.on('datachanged',function(store,eOpts){
            console.log('store datachanged',store,eOpts);
        });
        store.on('metachange',function(store,metaData,eOpts){
            console.log('store metachange',store,metaData,eOpts);
        });
        store.on('refresh',function(store,eOpts){
            console.log('store refresh',store,eOpts);
        });
        store.on('clear',function(store,eOpts){
            console.log('store clear',store,eOpts);
        });

        store.load();
    },

    

    onStoreBeforeLoad: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeLoad',store,operation,eOpts);
    },
    onStoreAdd: function(store, records, index, eOpts){
        console.debug(this.$className,'onStoreAdd',store,records,index,eOpts);
    },
    onStoreRemove: function(store, record, index, isMove, eOpts){
        console.debug(this.$className,'onStoreRemove',store,record,index,isMove,eOpts);
    },
    onStoreUpdate: function(store, record, operation, eOpts){
        console.debug(this.$className,'onStoreUpdate',store,record,operation,eOpts);
    },
    onStoreDataChanged: function(store, eOpts){
        console.debug(this.$className,'onStoreDataChanged',store,eOpts);
    },
    onStoreMetaChange: function(store, metaData, eOpts){
        console.debug(this.$className,'onStoreMetaChange',store,metaData,eOpts);
    },
    onStoreRefresh: function(store, eOpts){
        console.debug(this.$className,'onStoreRefresh',store,eOpts);
    },
    onStoreClear: function(store, eOpts){
        console.debug(this.$className,'onStoreClear',store,eOpts);
    },
    onListSelectionChange: function(selModel, selected, eOpts){
        console.debug(this.$className,'onStoreSelectionChange',selModel,selected,eOpts);
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
    onStoreLoad: function(store, records, successful, operation, eOpts){
        console.debug(this.$className,'onStoreLoad',store,records,successful,operation,eOpts);
        let me = this,
            model = me.getViewModel(),
            selModel = me.getView().getComponent('list').getSelectionModel(),
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
    onStoreBeforePrefetch: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforePrefetch',store,operation,eOpts);
    },
    onStorePrefetch: function(store, records, successful, operation, eOpts){
        console.debug(this.$className,'onStorePrefetch',store,records,successful,operation,eOpts);
    },
    onStoreBeforePage: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforePage',store,operation,eOpts);
    },
    onStorePage: function(store, records, successful, operation, eOpts){
        console.debug(this.$className,'onStorePage',store,records,successful,operation,eOpts);
    },
    onStoreBeforeSort: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeSort',store,operation,eOpts);
    },
    onStoreSort: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreSort',store,operation,eOpts);
    },
    onStoreBeforeGroup: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeGroup',store,operation,eOpts);
    },
    onStoreGroup: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreGroup',store,operation,eOpts);
    },
    onStoreBeforeFilter: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeFilter',store,operation,eOpts);
    },
    onStoreFilter: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreFilter',store,operation,eOpts);
    },
    onStoreBeforeClear: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeClear',store,operation,eOpts);
    },
    onStoreClearData: function(store, operation, eOpts){

        console.debug(this.$className,'onStoreClearData',store,operation,eOpts);
    },
    onStoreBeforeSync: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeSync',store,operation,eOpts);
    },
    onStoreSync: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreSync',store,operation,eOpts);
    },
    onStoreException: function(proxy, response, operation, eOpts){
        console.debug(this.$className,'onStoreException',proxy,response,operation,eOpts);
    },
    onStoreBeforeLoadPage: function(store, operation, eOpts){

        console.debug(this.$className,'onStoreBeforeLoadPage',store,operation,eOpts);
    },
    onStoreLoadPage: function(store, records, successful, operation, eOpts){
        console.debug(this.$className,'onStoreLoadPage',store,records,successful,operation,eOpts);
    },
    onStoreBeforeDestroy: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeDestroy',store,operation,eOpts);
    },
    onStoreDestroy: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreDestroy',store,operation,eOpts);
    },
    onStoreBeforeCreate: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeCreate',store,operation,eOpts);
    },
    onStoreCreate: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreCreate',store,operation,eOpts);
    },
    onStoreBeforeUpdate: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeUpdate',store,operation,eOpts);
    },
    onStoreUpdate: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreUpdate',store,operation,eOpts);
    },
    onStoreBeforeDestroy: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeDestroy',store,operation,eOpts);
    },
    onStoreDestroy: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreDestroy',store,operation,eOpts);
    },
    onStoreBeforeWrite: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeWrite',store,operation,eOpts);
    },
    onStoreWrite: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreWrite',store,operation,eOpts);
    },
    onStoreBeforeCommit: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeCommit',store,operation,eOpts);
    },
    onStoreCommit: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreCommit',store,operation,eOpts);
    },
    onStoreBeforeReject: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeReject',store,operation,eOpts);
    },
    onStoreReject: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreReject',store,operation,eOpts);
    },
    onStoreBeforeBatch: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeBatch',store,operation,eOpts);
    },
    onStoreBatch: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBatch',store,operation,eOpts);
    },
    onStoreBeforeAdd: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeAdd',store,operation,eOpts);
    },
    onStoreAdd: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreAdd',store,operation,eOpts);
    },
    onStoreBeforeRemove: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreBeforeRemove',store,operation,eOpts);
    },
    onStoreRemove: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreRemove',store,operation,eOpts);
    },
    onStoreBeforeEdit: function(store, operation, eOpts){

        console.debug(this.$className,'onStoreBeforeEdit',store,operation,eOpts);
    },
    onStoreEdit: function(store, operation, eOpts){
        console.debug(this.$className,'onStoreEdit',store,operation,eOpts);
    }
});