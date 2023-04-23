Ext.define('Tualo.DS.panel.mixins.ControllerTools', {
    refresh: function(){
        let store = this.getStore();
        store.load();
    },
    next: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber'));
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    prev: function(){
        let store = this.getStore();
        let model = this.getViewModel();
        let record = store.getAt(model.get('selectRecordRecordNumber')-2);
        if (record){
            this.getView().getComponent('list').getSelectionModel().select(record);
        }
    },
    reject: function(){ 
        var model = this.getViewModel(),
            store = this.getStore();
        store.rejectChanges();
    },
    append: function()  {   
        let model = this.getViewModel(),
            view = this.getView(),
            referencedList = view.referencedList,
            referencedRecord = this.getReferencedRecord(),
            store = this.getStore(),
            fields = store.getModel().getFields(),
            values = {};
        for(i=0;i<fields.length;i++){
            if(!Ext.isEmpty(fields[i].defaultValue)){
                values[fields[i].name] = fields[i].defaultValue;
            }
        }
        if (referencedList==true){
            for(var ref in view.referenced){
                if (typeof this.view.referenced[ref]== 'string')
                    values[ref.toLowerCase()]=referencedRecord.get(this.view.referenced[ref].toLowerCase());
                if (typeof this.view.referenced[ref]== 'object'){
                    if (typeof this.view.referenced[ref].v== 'string')
                        values[ref.toLowerCase()]=this.view.referenced[ref].v;
                }
            }
        }
        var record = Ext.create('Tualo.DataSets.model.'+view.$className,values);
        if (this.showSpecialAppend()){ return; }
        this.appendRecord(record);
    },


    showSpecialAppend: function(){
        let model = this.getViewModel(),
            store = this.getStore();
        
        if (!Ext.isEmpty(model.get('special_add_panel'))){
            var wnd = Ext.create('Ext.tualo.Window',{
                layout: 'fit',
                title: model.get('dstitle')+' >> Hinzufügen',
            });
            var panel =Ext.create(Ext.ClassManager.getNameByAlias('widget.'+model.get('special_add_panel') ),{
                record: model.get('record'),
                listeners: {
                    cancled: function(){
                        console.debug('cancled');
                        wnd.close();
                        store.load();
                    },
                    saved: function(){
                        console.debug('saved');
                        wnd.close();
                        store.load();
                    },
                }
            });
        
            wnd.add(panel);
            wnd.show();
            wnd.resizeMe();

            let resizeFn=()=>{
                wnd.resizeMe();
            };
            wnd.on('destroy',()=>{
                view.removeListener('resize',resizeFn);
            })
            view.on('resize',resizeFn);
        
            return true;
        }
        return false;
    },

    appendRecord: function(record){
        var model = this.getViewModel(),
            view = this.getView(),
            store = this.getStore(),
            list = view.getComponent('list');

        record.set('__rownumber',store.getCount()+1,{
            dirty: false
        });
        store.add(record);
        model.set('record',record);
        this.setViewType('form');
        list.setSelection( record );
        list.getView().focusRow(record);
        model.set('lastSelectRecordRecordNumber',model.get('selectRecordRecordNumber'));
        model.set('isNew',true);
        
    },


});