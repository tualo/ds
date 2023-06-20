Ext.define('Tualo.ds.lazy.models.ImportPanel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.lazy_ds_import_panel',
    data:{
        filesize: 1024,
        currentSheetIndex: 0,
        importIndex: 0,
        importOffset:0,
        filechecked: false,
        fileextracted: false,
        filesourceed: false,
        importing: false,
        rows: 0,
        prevButtonText: 'Zurück',
        nextButtonText: 'Weiter'
    },
    stores: {
        sheets: {
            type:'array',
            fields: ['id', 'name'],
            idIndex: 0
        },
        fields: {
            fields: ['id','name'],
            proxy: {
                type: 'ajax',
                timeout: 6000000,
                url: './dsimport/combo',
                reader: {
                type: 'json',
                    root: 'data'
                }
            }
        },
        source: {
            fields: ['id','text','position', 'name','dataindex'],
            proxy: {
                type: 'ajax',
                timeout: 6000000,
                url: './dsimport/source',
                reader: {
                type: 'json',
                    root: 'list'
                }
            }
        }
    },
    formulas: {
        importProgress: function(get){
            if (get('importing')){
                return get('importIndex')/get('rows');
            }
        },
        importHtml: function(get){
            if (!get('importing'))
                return 'Klicken Sie auf "Importieren" um den Import von '+get('rows')+' Datensätzen zu starten.';
            return '';
        },
        uploadFormHtml: function(get){
            return 'Bitte wählen Sie eine Datei aus, die importiert werden soll. Die Datei darf nicht größer als '+
            Tualo.ds.lazy.util.Format.formatSizeUnits(get('filesize'))+' sein.';
        },
        checkformHtml: function(get){
            if (get('filechecked')){
                return 'Bitte wählen Sie ein Tabellenblatt, welches importiert werden soll.';
            }else{
                return 'Der Upload wird geprüft ...';
            }
        },
        extractHtml: function(get){
            if (get('fileextracted')){
                return 'Analyse angeschlossen ...';
            }else{
                return 'Die Daten werden analysiert ...';
            }
        },
        sourceHtml: function(get){
            if (get('filesourceed')){
                return '';
            }else{
                return 'Einen moment bitte ...';
            }
        }
    }
});