Ext.define('Tualo.ds.lazy.controller.DeferedCommand', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.lazy_ds_defered_command',
    boxready: function(){
        let me = this,range=[],record=null,sel=null;
        try{

            if (me.getView().record){
                record = me.getView().record;
                range = [record];
                sel = [record];
            }else if (me.getView().calleeId){
                let parentView = Ext.getCmp(me.getView().calleeId);

                sel = parentView.getList().getSelection();

                range = parentView.getList().getStore().getRange(),
                record = ((!Ext.isEmpty(sel))?sel[0]:null);
            }

            me.c = Ext.create({
                xtype: me.getView().command,
                tablename: me.getView().tablename,
                calleeId: me.getView().calleeId,
                param: me.getView().param,
                listeners: {
                    enableNext: me.enableNext,
                    disableNext: me.disableNext
                }

            });

            me.c.loadRecord(record,range,sel);
            me.getView().add(me.c);
            me.getView().setActiveItem(me.c);
            if (typeof me.c.getNextText == 'function'){
                
                
                me.getViewModel().set('enableNext',true);
                me.getViewModel().set('nextButtonText',me.c.getNextText());
            }
        }catch(e){
            console.log(e);
            window.history.back();
        }
    },
    enableNext: function(){
        console.log('enableNext');
        this.getViewModel().set('enableNext',true);
        
    },
    disableNext: function(){
        console.log('disableNext');
        this.getViewModel().set('enableNext',false);
    },
    cancel: function(){
        console.log('cancel');
        window.history.back();
    },
    prev: function(){
         

    },
    next: async function(){
        var me = this;
        me.getViewModel().set('enableNext',false);
        await me.c.run();
        window.history.back();

    }   
});