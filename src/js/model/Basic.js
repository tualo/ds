Ext.define('Tualo.DataSets.model.Basic', {
    extend: 'Ext.data.Model',
    fields: [
        {name: '__id',  type: 'string'},
    ],
    
    get: function(fieldName) {
        if (this.data.hasOwnProperty(fieldName)) return this.data[fieldName];
        if (this.data.hasOwnProperty("__table_name") && this.data.hasOwnProperty(this.data["__table_name"]+"__"+fieldName)) return this.data[this.data["__table_name"]+"__"+fieldName];
        return this.data[fieldName];
    }
});