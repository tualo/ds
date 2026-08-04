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
                let id = Ext.id();
                me.lazyRendering.push({
                    val: val,
                    metaData: metaData,
                    record: record,
                    rowIndex: rowIndex,
                    colIndex: colIndex,
                    store: store,
                    view: view,
                    id: id
                });
                if (!me.isFetching) me.fetchData();
                return '<span id="' + id + '">not loaded</span>'; // me.config.table_name;
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

            console.log('renderLazy', val, metaData, record, rowIndex, colIndex, store, view, cell);
            if (!cell) {
                //                 console.error('cell not found', record, colIndex, view);
                return;
                //                continue;
            }
            let cellElement = cell.dom.querySelector('#' + item.id);
            if (!cellElement) {
                // console.error('cell element not found', record, colIndex, view, cell);
                return;
                //                continue;
            }
            cellElement.innerText = me.data[val] || val;


            /*
            // cell.dom.innerText = me.data[val] || val;
            window.cellTest = {
                val: val,
                metaData: metaData,
                record: record,
                rowIndex: rowIndex,
                colIndex: colIndex,
                store: store,
                view: view,
                cell: cell
            };
            */
            // cell.setValue(me.data[val] || val);
            // cell.setHtml(me.data[val] || val);
        }
    }

});