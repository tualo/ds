Ext.define('TualoOffice.routes.DS',{
    url: 'ds/:type/:tablename',
    handler: {
        action: function(type,tablename){
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            TualoOfficeApplication.getApplication().addView('Tualo.DataSets.'+type+'.'+tablenamecase,tablename,true);
        },
        before: function (type,tablename,action) {
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            Ext.require([
                
                'Tualo.DataSets.model.'+tablenamecase,
                'Tualo.DataSets.store.'+tablenamecase,
                'Tualo.DataSets.'+type+'.'+tablenamecase
            ],function(){
                action.resume();
            },this)
            
        }
    }
});