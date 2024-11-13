Ext.define('Tualo.routes.DS', {
    statics: {
        
        load: async function () {
            let response = await Tualo.Fetch.post('ds/ds/read', { limit: 10000 });
            let list = [];
            if (response.success == true) {
                for (let i = 0; i < response.data.length; i++) {
                    if (!Ext.isEmpty(response.data[i].table_name))
                        list.push({
                            name: response.data[i].title + ' (' + '#ds/' + response.data[i].table_name + ')',
                            path: '#ds/' + response.data[i].table_name
                        });
                }
            }
            return list;
        },

        sha1: async function (str) {
            const enc = new TextEncoder();
            if (crypto.subtle){
                const hash = await crypto.subtle.digest('SHA-1', enc.encode(str));
                return Array.from(new Uint8Array(hash))
                    .map(v => v.toString(16).padStart(2, '0'))
                    .join('');
            }else{
                return btoa(str).replace(/[^A-Za-z0-9]/g,'');
            }
        }
    },
    url: 'ds/:{table}(\/:{fieldName}\/:{fieldValue})',
    handler: {
        action: function (values) {
            console.log('ds route','action', values);

            const fnx = async () => {
                let type = 'dsview',
                    tablename = values.table,
                    mainView = Ext.getApplication().getMainView(),
                    tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1),
                    stage = mainView.getComponent('dashboard_dashboard').getComponent('stage'),
                    component = null,
                    cmp_id = type + '_' + tablename.toLowerCase() + '_' + (await Tualo.routes.DS.sha1(JSON.stringify(values)));
                    console.log('ds route','action','cmp_id', cmp_id);
                component = stage.getComponent(cmp_id);

                if (!Ext.isEmpty(component)) {
                    stage.setActiveItem(component);
                    console.log('ds route','action','setActiveItem', component);
                } else {
                    component = Ext.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase, {
                        itemId: cmp_id
                    });
                    console.log('ds route','action','new', component);
                }

                if ((component) && (typeof values.fieldValue != 'undefined')) {
                    component.filterField(values.fieldName, values.fieldValue);
                }
            }
            fnx();
        },
        before: function (values, action) {
            console.log('ds route','before', values);
            

            const fnx = async () => {
                let type = 'dsview',
                    tablename = values.table,
                    tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1),
                    cmp_id = type + '_' + tablename.toLowerCase() + '_' + (await Tualo.routes.DS.sha1(JSON.stringify(values)));
                console.log('ds route','before', 'fnx', cmp_id)

                if (!Ext.isEmpty(Ext.getApplication().getMainView().getComponent('dashboard_dashboard').getComponent('stage').down(cmp_id))) {
                    action.resume();
                } else {
                    console.log('ds route','before', 'fnx zeile 77', cmp_id)
                    if (
                        (Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase])
                        && (Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase].stores)
                    ) {
                        let waitFor = 0, resumed = false;
                        console.log('ds route','before', 'fnx zeile 83', cmp_id)                        
                        try {
                            Ext.ClassManager.classes['Tualo.DataSets.' + type + '.' + tablenamecase].stores.forEach(element => {
                                console.log('create store',element, typeof Ext.data.StoreManager.lookup(element.store_id));
                                if (typeof Ext.data.StoreManager.lookup(element.store_Id) == 'undefined') {
                                    waitFor++;
                                    console.log('create store', element.storeId, waitFor);
                                    Ext.createByAlias('store.' + element.store_type, {
                                        autoLoad: true,
                                        storeId: element.store_Id,
                                        pageSize: element.store_pageSize,
                                        listeners: {
                                            load: function () {
                                                waitFor--;
                                                console.log('create store', element.storeId, waitFor);
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
                        console.log('ds route','before', 'fnx zeile 133', cmp_id)                        
                        action.resume();
                    }
                }
            }
            fnx();
        }
    }
});
