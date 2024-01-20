Ext.define('Tualo.routes.Cmp_ds', {
    url: 'cmp_ds',
    handler: {
        action: function (type, tablename, id) {
            type = 'views';
            let tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1);
            console.log('Tualo.DataSets.' + type + '.' + tablenamecase, arguments);
            let opt = {};
            if (typeof id != 'undefined') {
                opt.loadId = id;
            }
            TualoOffice.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase, tablename, true, opt);

        },
        before: function (action) {

            console.log('Tualo.routes.Cmp_ds', arguments, 'reject');
            action.stop();
            /*
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            let id = null;
            if (typeof xid.resume=='function'){ action=xid; }else{ id = xid;}
            action.resume();
            */
        }
    }
});


Ext.define('Tualo.routes.DS', {
    statics: {
        load: async function() {
            let response = await Tualo.Fetch.post('ds/ds/read',{limit:10000});
            let list = [];
            console.log('Tualo.routes.DS', response);
            if (response.success==true){
                for(let i=0;i<response.data.length;i++){
                    if (!Ext.isEmpty(response.data[i].table_name))
                    list.push({
                        name: response.data[i].title + ' ('+ '#ds/'+response.data[i].table_name+')',
                        path: '#ds/'+response.data[i].table_name
                    });
                }
            }
            return list;
        }
    }, 
    url: 'ds/:{table}(\/:{record_id})',
    handler: {
        action: function (values) {
            let type = 'dsview';
            console.log('Tualo.routes.DS', values);
            let tablename = values.table;
            let mainView = Ext.getApplication().getMainView();
            let tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1);
            let stage = mainView.getComponent('dashboard_dashboard').getComponent('stage');
            let component = null;
            stage.items.each(function(item){
                if (item.xtype==type+'_'+tablename.toLowerCase()){
                    component = item;
                }
            });
            if(!Ext.isEmpty( component )){
                stage.setActiveItem(component);
            }else{
                component = Ext.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase);
            }

            if ((component)&&(typeof values.record_id!='undefined')){
                component.loadById(values.record_id);
            }
        },
        before: function (values, action) {
            let type = 'dsview';
            let tablename = values.table;
            let tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1);


            if(!Ext.isEmpty( Ext.getApplication().getMainView().getComponent('dashboard_dashboard').getComponent('stage').down(type+'_'+tablename.toLowerCase()))){
                action.resume();
            }else{

                if (
                    (Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase])
                    && (Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase].stores)
                ) {
                    let waitFor = 0, resumed = false;
                    try {
                        Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase].stores.forEach(element => {
                            console.log(element, typeof Ext.data.StoreManager.lookup(element.store_id));
                            if (typeof Ext.data.StoreManager.lookup(element.store_id) == 'undefined') {
                                waitFor++;
                                console.log('create store', element.store_id, waitFor);
                                Ext.createByAlias('store.' + element.store_type, {
                                    autoLoad: true,
                                    storeId: element.store_id,
                                    pageSize: element.store_pageSize,
                                    listeners: {
                                        load: function () {
                                            waitFor--;
                                            console.log('create store', element.store_id, waitFor);
                                            if ((waitFor == 0) && (!resumed)) {
                                                resumed = true;
                                                action.resume();
                                            }
                                        }

                                    }
                                });

                            } else {
                                if (Ext.data.StoreManager.lookup(element.store_id).complete != true) {
                                    waitFor++;
                                    Ext.data.StoreManager.lookup(element.store_id).load({
                                        callback: function () {
                                            waitFor--;
                                            console.log('create store', element.store_id, waitFor);
                                            if ((waitFor == 0) && (!resumed)) {
                                                resumed = true;
                                                action.resume();
                                            }
                                        }
                                    });
                                }

                            }
                        });
                        if ((waitFor == 0) && (!resumed)) {
                            resumed = true;
                            action.resume();
                        }
                    } catch (e) {
                        console.error(e);
                        action.stop();
                    }
                } else {
                    action.resume();
                }
            }
        }
    }
});
