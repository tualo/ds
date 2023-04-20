Ext.define('Tualo.routes.Cmp_ds',{
    url: 'cmp_ds',
    handler: {
        action: function(type,tablename,id){
            type='views';
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            console.log('Tualo.DataSets.'+type+'.'+tablenamecase,arguments);
            let opt = {};
            if (typeof id!='undefined'){ 
                opt.loadId=id;
            }
            TualoOffice.getApplication().addView('Tualo.DataSets.'+type+'.'+tablenamecase,tablename,true,opt);

        },
        before: function (action) {

            console.log('Tualo.routes.Cmp_ds',arguments,'reject');
            action.stop();
            /*
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            let id = null;
            if (typeof xid.resume=='function'){ action=xid; }else{ id = xid;}
            action.resume();
            */
        }
    }
});


Ext.define('Tualo.routes.DS',{
    url: 'ds/:table',
    handler: {
        action: function(tablename){
            type='dsview';
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            console.log('Tualo.DataSets.'+type+'.'+tablenamecase,arguments);
            Ext.getApplication().addView('Tualo.DataSets.'+type+'.'+tablenamecase);
        },
        before: function (values,action) {
            console.log('Tualo.routes.Ds',values,'values');
            action.resume();
            /*
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            let id = null;
            if (typeof xid.resume=='function'){ action=xid; }else{ id = xid;}
            
            */
        }
    }
});


Ext.define('Tualo.routes.DsByID',{
    url: 'ds/:table/:id',
    handler: {
        action: function(values,action){
            type='dsview';
            let tablename = values.table;
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            console.log('Tualo.DataSets.'+type+'.'+tablenamecase,arguments);
            Ext.getApplication().addView('Tualo.DataSets.'+type+'.'+tablenamecase);

        },
        before: function (values,action) {

            console.log('Tualo.routes.Ds',values,'values');
            action.stop();
            /*
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            let id = null;
            if (typeof xid.resume=='function'){ action=xid; }else{ id = xid;}
            action.resume();
            */
        }
    }
});