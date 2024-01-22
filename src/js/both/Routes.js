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
        }
    },
    url: 'ds/:{table}(\/:{fieldName}\/:{fieldValue})',
    handler: {
        action: function (values) {

            async function sha1(str) {
                const enc = new TextEncoder();
                const hash = await crypto.subtle.digest('SHA-1', enc.encode(str));
                return Array.from(new Uint8Array(hash))
                    .map(v => v.toString(16).padStart(2, '0'))
                    .join('');
            }

            const fnx = async () => {
                let type = 'dsview',
                    tablename = values.table,
                    mainView = Ext.getApplication().getMainView(),
                    tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1),
                    stage = mainView.getComponent('dashboard_dashboard').getComponent('stage'),
                    component = null,
                    cmp_id = type + '_' + tablename.toLowerCase() + '_' + (await sha1(JSON.stringify(values)));
                component = stage.down(cmp_id);
                if (!Ext.isEmpty(component)) {
                    stage.setActiveItem(component);
                } else {
                    component = Ext.getApplication().addView('Tualo.DataSets.' + type + '.' + tablenamecase, {
                        itemId: cmp_id
                    });
                }

                if ((component) && (typeof values.fieldValue != 'undefined')) {
                    component.filterField(values.fieldName, values.fieldValue);
                }
            }
            fnx();
        },
        before: function (values, action) {

            async function sha1(str) {
                const enc = new TextEncoder();
                const hash = await crypto.subtle.digest('SHA-1', enc.encode(str));
                return Array.from(new Uint8Array(hash))
                    .map(v => v.toString(16).padStart(2, '0'))
                    .join('');
            }

            const fnx = async () => {
                let type = 'dsview',
                    tablename = values.table,
                    tablenamecase = tablename.toLocaleUpperCase().substring(0, 1) + tablename.toLowerCase().slice(1),
                    cmp_id = type + '_' + tablename.toLowerCase() + '_' + (await sha1(JSON.stringify(values)));


                if (!Ext.isEmpty(Ext.getApplication().getMainView().getComponent('dashboard_dashboard').getComponent('stage').down(cmp_id))) {
                    action.resume();
                } else {

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
            fnx();
        }
    }
});
