Ext.define('Tualo.DataSets.model.Basic', {
    extend: 'Ext.data.Model',
    requires: [
        'Tualo.DataSets.model.Schema',
        'Ext.data.proxy.Ajax',
        'Ext.data.reader.Json',
        'Ext.data.writer.Json'
    ],
    

    fields: [
        {name: '__id',  type: 'string'},
    ],
    
    get: function(fieldName) {
        if (this.data.hasOwnProperty(fieldName)) return this.data[fieldName];
        if (this.data.hasOwnProperty("__table_name") && this.data.hasOwnProperty(this.data["__table_name"]+"__"+fieldName)) return this.data[this.data["__table_name"]+"__"+fieldName];
        return this.data[fieldName];
    }
});