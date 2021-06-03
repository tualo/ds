Ext.define('TualoOffice.routes.DS',{
    url: 'ds/:type/:tablename',
    handler: {
        actionOld: function(type,tablename){
            
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);

            var view = TualoOfficeApplication.getApplication().getMainView(),
            newNode = view.down(type);
            console.log('newNode',newNode)
//            TualoOfficeApplication.getApplication().addView('Tualo.DataSets.'+type+'.'+tablenamecase,tablename,true);

        },
        action: function(type,tablename){
            if (type=='form' && (
                (typeof TualoOfficeApplication.getApplication().record=='undefined') ||
                (TualoOfficeApplication.getApplication().record==null)
            )){
               // TualoOfficeApplication.getApplication().redirectTo('ds/list/'+tablename);
            }

            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1),
                view = TualoOfficeApplication.getApplication().getMainView(),
                xtype = 'ds'+type+'_'+tablename,
                newNode = view.down(xtype);

            if (!newNode) {
                newNode = Ext.create({
                    xtype: xtype
                });
            }

            if (type == 'form') {
                //console.log(TualoOfficeApplication.getApplication().record);
                if (TualoOfficeApplication.getApplication().record){
                    newNode.setRecord(TualoOfficeApplication.getApplication().record)
                    TualoOfficeApplication.getApplication().record = null;
                }
            }

            TualoOfficeApplication.getApplication().getMainView().down('dashboard_dashboard').getComponent('stage').add( newNode  );
            TualoOfficeApplication.getApplication().getMainView().down('dashboard_dashboard').getComponent('stage').setActiveItem(newNode);

        },
        before: function (type,tablename,action) {
            let tablenamecase = tablename.toLocaleUpperCase().substring(0,1) + tablename.toLowerCase().slice(1);
            Ext.require([
                'Tualo.DataSets.grid.Controller',
                'Tualo.DataSets.grid.Grid',
                'Tualo.DataSets.form.Controller',
                'Tualo.DataSets.form.Form',
                'Tualo.DataSets.grid.PagingToolbar',
                'Tualo.DataSets.model.'+tablenamecase,
                'Tualo.DataSets.store.'+tablenamecase,
                'Tualo.DataSets.'+type+'.'+tablenamecase
            ],function(){
                
                action.resume();
            },this)
            
        }
    },
    
    
});