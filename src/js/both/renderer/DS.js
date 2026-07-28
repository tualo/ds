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
                return 'not loaded'; // me.config.table_name;
            }
        o['ds_' + this.config.table_name + '__' + this.config.name] = fn;
        Ext.merge(Ext.util.Format, o);
        this.fetchData();
    },
    fetchData: async function () {
        let me = this;

        /*
        "extraParams", json_object(
                            "fields", concat('["',ds_dropdownfields.displayfield,'","',ds_dropdownfields.idfield,'"]')
                        ),
        */
        let fields = [this.config.idField, this.config.displayField];
        let response = await fetch('./ds/' + this.config.table_name + '/read?limit=1000000&fields=' + JSON.stringify(fields));
        let data = await response.json();
        let o = {};
        for (let i in data.data) {
            o[data.data[i][this.config.idField]] = data.data[i][this.config.displayField];
        }
        me.data = o;
        // return o;
    }
});