Ext.define('Tualo.routes.ds.Form',{
    statics: {
        load: async function() {
            return [
                {
                    name: 'DS Form Route',
                    path: '#dsform/x'
                }
            ]
        }
    }, 
    url: 'dsform/:{table}(\/:{fieldName}\/:{fieldValue})',
    handler: {
        action: function( values ){
            console.log('values',values);
        },
        before: function ( values, action,cnt) {
            action.resume();
        }
    }
});