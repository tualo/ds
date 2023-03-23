Ext.define('Tualo.DataSets.form.Controller', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.dsformcontroller',
    doSearch: function(field) {
        var list = this.lookup('searchlist'),
            store = list.getStore(),
            proxy = store.getProxy(),
            value = field.getValue();

        proxy.setExtraParam('query', value);
        this.getViewModel().set('query', value);

        if (value) {
            store.load();
        }
        else {
            store.removeAll();
        }
    },
    onReject: function(){
        //console.log(this.getView().getRecord().data);
        //this.getView().getRecord().reject();
        if (this.getView().getRecord()!=null){
            this.getView().updateRecord(this.getView().getRecord());
        }
    },
    onCloseClick: function(){
        //TualoOfficeApplication.getApplication().redirectTo('ds/list/'+this.getView().tablename);
        Ext.util.History.back();
    },
    onFormFieldChanged: function(fld,nv,ov,opt){
        if (fld){
            let cls = fld.getLabelCls();
            if (cls==null) cls='';
            if (fld.isDirty()){
                cls=cls.replace(' form-label-changed','');
                cls+=' '+'form-label-changed';
            }else{
                cls=cls.replace(' form-label-changed','');
            }
            fld.setLabelCls(cls);
            
        }
    },
    onFormFieldLabelClass: function(fld){
        if (fld){
            let cls = fld.getLabelCls();
            if (cls==null) cls='';
            if (fld.isDirty()){
                cls=cls.replace(' form-label-changed','');
                cls+=' '+'form-label-changed';
            }else{
                cls=cls.replace(' form-label-changed','');
            }
            fld.setLabelCls(cls);
        }
    },

    onSave: function(){
        var model = this.getViewModel(),
            form = this.getView(),
            record = this.getView().getRecord(),
            store = record.store,
            values = form.getValues();
            //store = this.lookup('list').getStore();
        console.log(record.data,values);

        store.findRecord('__id', record.data.__id).set(values);

        if (record){
            record.store.on({
                proxyerror:{fn: this.onProxyError, scope: this, single: true}
            });
            record.store.save({
                scope: this,
                success: this.onSaveSuccess,
                failure: this.onSaveFailure
            });
        }
        
        return;
    },
    onSaveSuccess: function(){
        let model = this.getViewModel(),
        form = this.getView();
        model.set('isNew',false);
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { formField.resetOriginalValue(); })
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { form.getController().onFormFieldLabelClass(formField); })

    },
    onSaveFailure: function(){
    },
    onProxyError: function(response){
        let model = this.getViewModel(),
            form = this.getView(),
            showToast = true;
        if (response.responseJson){
            if (response.responseJson.msg.indexOf('foreign key constraint fails ')){
                m = response.responseJson.msg.match(/FOREIGN\sKEY\s\((.*?)\)/)
                if (m && m[1]){
                    
                    let l =  m[1].split('`,`');
                    l.forEach(function(fld){
                        fld = fld.replace(/\`/g,'');
                        let el = form.down('[name='+form.tablename+'__'+fld+']');
                        el.addCls('panel-shake');
                        //el.labelElement.addCls('label-shake');
                        
                        Ext.defer(()=>{  el.removeCls('panel-shake') }, 1000 );
                        Ext.toast('Für '+el.config.placeholder+' muss ein gültiger Wert angegeben werden',2000);
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
        form.queryBy(function(component) { return !!component.isFormField; }).forEach(function(formField) { form.getController().onFormFieldLabelClass(formField); })

    }
})
