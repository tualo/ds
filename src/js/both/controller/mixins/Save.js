Ext.define('Tualo.cmp.cmp_ds.controller.mixins.Save', {
    onSave: function(){
        var model = this.getViewModel(),
            store = this.lookup('list').getStore();

        store.on({
            proxyerror:{fn: this.onProxyError, scope: this, single: true}
        });//',this.onProxyError,this);
        store.sync({
            scope: this,
            success: this.onSaveSuccess,
            failure: this.onSaveFailure
        });
    },
    onSaveSuccess: function(){
        let model = this.getViewModel(),
            view = this.getView(),
            form = this.lookup('form'),
            list = this.lookup('list'),
            store = list.getStore(),
            range = store.getRange();
        model.set('isNew',false);
    },
    onSaveFailure: function(){
    },
    onProxyError: function(response){
        let model = this.getViewModel(),
            view = this.getView(),
            form = this.lookup('form'),
            list = this.lookup('list'),
            store = list.getStore(),
            range = store.getRange(),
            showToast = true;
        if (response.responseJson){
            if (response.responseJson.msg.indexOf('foreign key constraint fails ')){
                m = response.responseJson.msg.match(/FOREIGN\sKEY\s\((.*?)\)/)
                if (m && m[1]){
                    
                    let l =  m[1].split('`,`');
                    l.forEach(function(fld){
                        fld = fld.replace(/\`/g,'');
                        let el = form.down('[name='+ fld+']');
                        el.addCls('panel-shake');
                        //el.labelElement.addCls('label-shake');
                        
                        Ext.defer(()=>{  el.removeCls('panel-shake') }, 1000 );
                        Ext.toast('Für '+el.config.placeholder+' muss ein gültiger Wert angegeben werden');
                        showToast = false;
                    })
                }
                m = response.responseJson.msg.match(/Duplicate\sentry/)
                if (m){
                    Ext.toast('Es gibt bereits einen solchen Eintrag');
                    showToast = false;
                }
            }
            if (showToast) Ext.toast(response.responseJson.msg);
        }
    }
});