
Ext.define('Tualo.DS.field.DSFilesField', {
    extend: 'Ext.form.field.Base',
    alias: 'widget.dsfilesfield',
    requires: [
        'Ext.util.Format',
        'Ext.XTemplate'
    ],
    fieldSubTpl: [
        '<div id="{id}" data-ref="inputEl" role="textbox" aria-readonly="true"',
        ' aria-labelledby="{cmpId}-labelEl" {inputAttrTpl}',
        ' tabindex="<tpl if="tabIdx != null">{tabIdx}<tpl else>-1</tpl>"',
        '<tpl if="fieldStyle"> style="{fieldStyle}"</tpl>',
        ' class="{fieldCls} {fieldCls}-{ui}">{value}',
        '</div>',

        '<label for="{id}-fileinput" class="tualo-dsfilesfield">',
        '<i class="fa fa-upload"></i>',
        '</label>',
        '<label><input type="file" id="{id}-fileinput" style="display:none;" />',

        {
            compiled: true,
            disableFormats: true
        }
    ],

    ariaRole: undefined,
    focusable: false,
    skipLabelForAttribute: true,
    readOnly: true,
    fieldCls: Ext.baseCSSPrefix + 'form-display-field',
    fieldBodyCls: Ext.baseCSSPrefix + 'form-display-field-body dsfiles-body',
    htmlEncode: false,
    noWrap: false,
    validateOnChange: false,
    submitValue: false,
    getValue: function() {
        this.initUploader();
        return this.value;
    },
    valueToRaw: function(value) {
        this.initUploader();
        if (value || value === 0 || value === false) {
            return value;
        }
        else {
            return '';
        }
    },


    initUploader: function(){
        if (this.uploaderInitialized) return;
        const inputElement = document.getElementById(this.id+"-inputEl-fileinput");
        if (inputElement===null) return;
        inputElement.addEventListener("change", this.handleFiles.bind(this), false);
        this.uploaderInitialized = true;
    },
    handleFiles: function(){
        const inputElement = document.getElementById(this.id+"-inputEl-fileinput");
        let record = this.up('form').getRecord()
        const fileList = inputElement.files;
        if (fileList.length>0){
            const file = fileList[0];
            this.fileHandler(file, record);
        }
    },

    fileHandler: function (file, record) {
        let reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onloadend = () => {
            record.set('__file_data',reader.result);
            if (Ext.isEmpty(record.get('titel'))) record.set('titel',file.name);
            if (Ext.isEmpty(record.get('title'))) record.set('title',file.name);
            
            record.set('__file_size',file.size);
            record.set('__file_name',file.name);
            record.set('__file_type',file.type);
        };
    },

 
    isDirty: function() {
        return false;
    },
 
    isValid: Ext.returnTrue,
    validate: Ext.returnTrue,
    getRawValue: function() {
        return this.rawValue;
    },
    setRawValue: function(value) {
        var me = this;
        value = Ext.valueFrom(value, '');
        me.rawValue = value;
        if (me.rendered) {
            me.inputEl.dom.innerHTML = me.getDisplayValue();
            me.updateLayout();
        }
        return value;
    },
    getDisplayValue: function() {
        this.initUploader();
        var me = this,
            value = this.getRawValue(),
            renderer = me.renderer,
            display;
 
        if (renderer) {
            display = Ext.callback(renderer, me.scope, [value, me], 0, me);
        }
        else {
            display = me.htmlEncode ? Ext.util.Format.htmlEncode(value) : value;
        }
        try{
            display = this.renderFileInfo();
        }catch(e){
            // console.error(e);
        }
        return display;
    },

    getReadableFileSizeString: function (fileSizeInBytes) {
        var i = -1;
        var byteUnits = [' kB', ' MB', ' GB', ' TB', 'PB', 'EB', 'ZB', 'YB'];
        do {
          fileSizeInBytes = fileSizeInBytes / 1024;
          i++;
        } while (fileSizeInBytes > 1024);
    
        return Math.max(fileSizeInBytes, 0.1).toFixed(1) + byteUnits[i];
    },

    renderFileInfo: function () {
        let r = this.up('form').getRecord(), result = '';
        if (!r) throw new Error('Record not found');
        if (!r.get('__file_size')) throw new Error('Field __file_size doesn`t exists');
        if (!r.get('__file_type')) throw new Error('Field __file_type doesn`t exists');
        if (!r.get('__file_name')) throw new Error('Field __file_name doesn`t exists');
        if (!r.get('__file_id')) throw new Error('Field __file_id doesn`t exists');
        result=[
            '<a target="_blank" href="./dsfiles/'+r.get('__table_name')+'/'+r.get('__file_id')+'">'+r.get('__file_name')+' ('+this.getReadableFileSizeString(r.get('__file_size'))+')'+'</a>',
        ].join('');  
        return result;
    },

    
    getSubTplData: function(fieldData) {
        var ret = this.callParent(arguments);
        ret.value = this.getDisplayValue();
        return ret;
    }

});