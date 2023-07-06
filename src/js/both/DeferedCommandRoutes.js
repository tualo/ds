Ext.Loader.setPath('Tualo.ds.lazy', './jsds');
Ext.define('Tualo.routes.DSDeferedCommand', {
    statics: {
        load: async function() {
            let list = [];
            return list;
        }
    }, 
    url: 'dscommand/:table/:command/:id',
    handler: {
        action: function (tablename,command,id) {

            Ext.getApplication().addView('Tualo.ds.lazy.DeferedCommand',{
                tablename: tablename,
                command: command,
                calleeId: id
            });
        },
        before: function (tablename,command,id, action) {
            action.resume();
        }
    }
});



