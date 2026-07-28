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
            fn = function (val, record, dataIndex, cell, column) {
                if (typeof me.data === 'object') {
                    return me.data[val] || val;
                }
                me.fetchData();
                console.debug('not loaded', me.config.table_name, cell);
                return 'not loaded'; // me.config.table_name;
            }
        o['ds_' + this.config.table_name + '__' + this.config.name] = fn;
        Ext.merge(Ext.util.Format, o);
        // this.fetchData();
    },
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
        // return o;
    }
});