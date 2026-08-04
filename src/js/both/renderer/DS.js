Ext.define("Tualo.ds.renderer.DS", {
    extend: 'Ext.Base',
    config: {
        table_name: 'ds',
        name: 'table_name',
        idField: 'table_name',
        displayField: 'table_name',
    },
    constructor: function (config) {
        let me = this;
        this.initConfig(config);
        let o = {},
            fn = function (val, metaData, record, rowIndex, colIndex, store, view) {
                if (typeof me.data === 'object') {
                    return me.data[val] || val;
                }
                if (typeof record === 'undefined') {
                    console.error('record is undefined, dont use it as formatter, use it as renderer');
                }
                me.lazyRendering.push({
                    val: val,
                    metaData: metaData,
                    record: record,
                    rowIndex: rowIndex,
                    colIndex: colIndex,
                    store: store,
                    view: view
                });
                if (!me.isFetching) me.fetchData();
                return 'not loaded'; // me.config.table_name;
            }
        o['ds_' + this.config.table_name + '_' + this.config.name] = fn;
        Ext.merge(Ext.util.Format, o);
    },
    lazyRendering: [],
    isFetching: false,
    fetchData: async function () {
        let me = this;

        if (me.isFetching) {
            console.debug('already fetching', me.config.table_name);
            return;
        }
        me.isFetching = true;


        /*
        "extraParams", json_object(
                            "fields", concat('["',ds_dropdownfields.displayfield,'","',ds_dropdownfields.idfield,'"]')
                        ),
        */
        let fields = [this.config.idField, this.config.displayField];
        let response = await fetch('./ds/' + this.config.table_name + '/read?limit=1000000&fields=' + JSON.stringify(fields));
        if (!response.ok) {
            console.error('Error fetching data:', response.statusText);
            return;
        }
        let data = await response.json();
        if (!data || !data.data) {
            console.error('Invalid data format:', data);
            return;
        }
        let o = {};
        for (let i in data.data) {
            o[data.data[i][this.config.idField]] = data.data[i][this.config.displayField];
        }
        me.data = o;
        me.renderLazy();
        me.isFetching = false;

        // return o;
    },
    renderLazy: function () {
        let me = this;
        while (me.lazyRendering.length > 0) {


            let item = me.lazyRendering.pop();
            let val = item.val;
            let metaData = item.metaData;
            let record = item.record;
            let rowIndex = item.rowIndex;
            let colIndex = item.colIndex;
            let store = item.store;
            let view = item.view
            let cell = view.getCell(record, colIndex, true);
            call.setHtml(me.data[val] || val);
        }
    }

});