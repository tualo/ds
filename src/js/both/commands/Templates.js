
Ext.define('Tualo.tualo_job.Templates', {
    statics: {
        glyph: 'magic',
        title: 'Templates',
        tooltip: 'Templates'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.tualo_job_templates',
    layout: 'fit',
    items: [
        {
            xtype: 'form',
            itemId: 'tualo_job_templates',
            bodyPadding: '25px',
            items: [
                {
                    xtype: 'dslist_tech_data_template',
                    store: {
                        autoLoad: true,
                        type: 'tech_data_template_store'
                    }
                }
            ]
        }
    ],
    loadRecord: function (record, records, selectedrecords, view) {
        this.record = record;
        this.records = records;
        this.selectedrecords = selectedrecords;
        this.view = view;
        console.log('loadRecord', arguments);
    },
    getNextText: function () {
        return 'Übernehmen';
    },
    run: async function (btn) {

        let store = Ext.getCmp(this.config.calleeId).getStore(),
            record = this.down('dslist_tech_data_template').getSelectionModel().getSelection()[0];

        // this.down('dslist_tech_data_template').getSelectionModel().getSelection().forEach(async (record) => {
        console.log('record', record.get('urno'));
        let res = await Tualo.Fetch.post('./ds/tech_data_templates_pos/read', {
            filter: JSON.stringify([{ property: 'urno', operator: '=', value: record.get('urno') }]),
            sort: JSON.stringify([{ property: 'pos', direction: 'ASC' }])
        });
        if (res.success == true) {
            res.data.forEach((record) => {
                let newRecord = store.add({
                    pos: record.pos,
                    name: record.name,
                    value: record.value
                })[0];
                newRecord.commit();
            });
        } else {
            Ext.toast({
                html: res.msg,
                title: 'Fehler',
                align: 't'
            });
        }
        //});

        window.btn = btn;
        /*btn.getView().down('dslist_tech_data_template').getSelectionModel().getSelection().forEach((record) => {
            console.log('record', record);
        });*/
        /*
            */
        /*
        this.record.store.each((record)=>{
        if (record.id != this.record.id){
            for( var key in this.record.modified){

                record.set(key,this.record.get(key));
            }
        }
        return true;
        });
        return null;
        */
        return true;
    }
});
/*

insert ignore into ds_addcommands_xtypes (id,name) values ('tualo_job_templates','Job Templates');


INSERT  IGNORE INTO `ds_addcommands` VALUES
-- ('ds','cmp_setup_export_config_command','toolbar',1,'','x-fa fa-plus'),
-- ('ds','cmp_setup_update_history_tables_command','toolbar',1,'','x-fa fa-plus'),
('ds','compiler_command','toolbar',1,'Kompiler',NULL),
('ds','ds_refresh_information_schema_command','toolbar',1,'DDL-Refresh',NULL),
('ds','cmp_ds_definition_command','toolbar',1,'DS-Export',NULL);

*/