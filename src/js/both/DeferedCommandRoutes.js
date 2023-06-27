Ext.Loader.setPath('Tualo.ds.lazy', './jsds');
Ext.define('Tualo.routes.DSDeferedCommand', {
    statics: {
        load: async function() {
            let list = [];
            return list;
        }
    }, 
    url: 'dscommand/:table/:command',
    handler: {
        action: function (tablename,command) {

            Ext.getApplication().addView('Tualo.ds.lazy.DeferedCommand',{
                tablename: tablename,
                command: command,
                callee: Ext.getApplication().getCurrentView()
            });
        },
        before: function (tablename,command, action) {
            action.resume();
        }
    }
});
