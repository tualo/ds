Ext.define('Tualo.routes.TestDS', {
    statics: {
        load: async function() {
            let list = [];
            return list;
        }
    }, 
    url: 'dstest',
    handler: {
        action: function () {
            Ext.getApplication().addView('Tualo.ds.lazy.test.Navigation',{
            });
        },
        before: function (  action) {
            action.resume();
        }
    }
});
