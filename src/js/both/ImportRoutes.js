Ext.Loader.setPath('Tualo.ds.lazy', './jsds');

Ext.define('Tualo.routes.DSImport', {
    statics: {
        load: async function() {
            let list = [];
            return list;
        }
    }, 
    url: 'dsimport/:table',
    handler: {
        action: function (tablename) {
            Ext.getApplication().addView('Tualo.ds.lazy.ImportPanel',{
                tablename: tablename
            });
        },
        before: function (tablename, action) {
            action.resume();
        }
    }
});


Ext.define('Tualo.routes.DSImport', {
    statics: {
        load: async function() {
            let list = [];
            return list;
        }
    }, 
    url: 'dsimport/:table/:cmpId',
    handler: {
        action: function (tablename,cmpId) {
            Ext.getApplication().addView('Tualo.ds.lazy.ImportPanel',{
                tablename: tablename,
                cmpId: cmpId
            });
        },
        before: function (tablename,cmpId, action) {
            action.resume();
        }
    }
});
