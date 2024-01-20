DELIMITER ;

insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.DataSets.grid.Grid",
        "Tualo.DataSets.grid.Grid",
        
        "widget.dsgrid",
        "Ext.grid.Panel",
        "widget.dsgrid",

        "Tualo.DataSets.grid.Grid",
        "Basic Tualo Grid",
        0,
        0
    )
;



insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.DataSets.ListView",
        "Tualo.DataSets.ListView",
        
        "widget.dslistview",
        "Tualo.DataSets.grid.Grid",
        "widget.dsgrid",

        "Tualo.DataSets.ListView",
        "Basic Tualo Grid",
        0,
        0
    )
    
;




insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.DataSets.ListViewAutoNew",
        "Tualo.DataSets.ListViewAutoNew",
        
        "widget.dslistviewautonew",
        "Tualo.DataSets.ListView",
        "widget.dslistviewautonew",

        "Tualo.DataSets.ListViewAutoNew",
        "Basic Tualo Grid Auto New",
        0,
        0
    )
;



insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.DataSets.ListViewFileDrop",
        "Tualo.DataSets.ListViewFileDrop",
        
        "widget.dslistviewfiledrop",
        "Tualo.DataSets.ListView",
        "widget.dslistviewfiledrop",

        "Tualo.DataSets.ListViewFileDrop",
        "Tualo Grid FileDrop",
        0,
        0
    )
;



insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.DS.fields.FormXtypeComboBox",
        "Tualo.DS.fields.FormXtypeComboBox",
        
        "widget.formxtype_combobox",
        "Ext.form.field.ComboBox",
        "widget.formxtype_combobox",

        "Tualo.DS.fields.FormXtypeComboBox",
        "Tualo FormXtypeComboBox",
        0,
        1
    )
;
