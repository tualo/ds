Ext.define('Tualo.DataSets.grid.mixins.Contextmenu', {
    onContextmenu: function (view, record, item, index, e) {

        //this.createContextMenu();
        var p = e.getXY();
        if (typeof this.contextmenuCtrl !== 'undefined') {
            this.contextmenuCtrl.showAt(p);
        }
        e.preventDefault();
        e.stopEvent();
        return false;
    },
    onContextmenuItemClicked: function (btn, evt) {
        let contextConfig = btn.contextConfig,
            sel = this.getView().getSelectionModel().getSelection();
        console.debug(this.$className, 'onContextmenuItemClicked', contextConfig, this.getView().getSelectionModel().getSelection());

        sel.forEach((record) => {
            let tpl = new Ext.XTemplate(contextConfig.route);
            let route = tpl.apply(record.data);
            if (evt.ctrlKey === true) {
                window.open('#' + route, '_blank');
            } else {
                Ext.getApplication().redirectTo(route);
            }
        });

    },
    onContainerContextmenu: function (m, e) {
        this.onContextmenu(this.view, null, null, 0, e);
    },
    createContextMenu: function () {
        let cm = [],
            parent = this.getParent(),
            viewModel = parent.getViewModel(),
            selector = this.lowerprefix + 'view-' + this.tablename;

        try {
            console.debug(this.$className, 'createContextMenu', selector);
            let contextconfig = JSON.parse(JSON.stringify(viewModel.get('contextmenu'))),
                model;

            /*
            if (!Ext.isEmpty(this.up(selector))) {
                model = this.up(selector).getViewModel();

                if (model.get('showAction')) {
                    var actionSubMenu = [];
                    if (model.get('disableAdd') == false) {
                        actionSubMenu.push({
                            text: 'Hinzufügen',
                            handler: function (btn, evt) {
                                btn.up().up().up().grid.up(selector).getController().append(btn, evt);
                            }
                        });
                    }

                    if (model.get('disableDelete') == false) {
                        actionSubMenu.push({
                            text: 'Entfernen',

                            handler: function (btn, evt) {
                                btn.up().up().up().grid.up(selector).getController().delete(btn, evt);
                            }
                        });
                    }

                    if (model.get('disableSave') == false) {
                        actionSubMenu.push({
                            text: 'Speichern',
                            handler: function (btn) {
                                btn.up().up().up().grid.up(selector).getController().save();
                            }
                        });
                    }

                    actionSubMenu.push({
                        text: 'Export',
                        handler: function (btn) {
                            btn.up().up().up().grid.up(selector).getController().export();
                        }
                    });

                    if (model.get('disableAdd') == false) {
                        actionSubMenu.push({
                            text: 'Import',
                            handler: function (btn) {
                                btn.up().up().up().grid.up(selector).getController().import();
                            }
                        });
                    }
                    var actionMenu =
                    {
                        text: 'Aktion',
                        xtype: 'menuitem',
                        menu: actionSubMenu
                    };


                    contextconfig.push(actionMenu);
                }
            }
            */

            if (!Ext.isEmpty(contextconfig)) {
                contextconfig.forEach((c) => {
                    let config = {
                        text: c.name,
                        scope: this,
                        contextConfig: c,
                        handler: this.onContextmenuItemClicked
                    }
                    cm.push(config);
                });

                /*
            for (var i = 0; i < contextconfig.length; i++) {
    
                if (contextconfig[i].menu) {
                    cm.push(contextconfig[i]);
                } else if (contextconfig[i].cmd) {
    
                    if (Ext.ClassManager.aliasToName['widget.' + contextconfig[i].cmd]) {
                        cm.push({
                            scope: this,
                            text: contextconfig[i].text,
                            contextconfigIndex: i,
                            handler: this.onContextmenuItemClicked
                        });
                    } else {
                        console.info('widget.' + contextconfig[i].cmd, 'not found');
                    }
    
                } else if (contextconfig[i].handler) {
    
                    if (typeof contextconfig[i].handler == 'string') {
                        var p = this;
                        var handler = contextconfig[i].handler;
                        var foundFn = null;
                        while (!Ext.isEmpty(p) && (Ext.isEmpty(foundFn))) {
                            if (typeof p[handler] == 'function') {
                                foundFn = p[handler]
                            }
                            if (!Ext.isEmpty(p.controller) && (p.controller[handler] == 'function')) {
                                foundFn = p.controller[handler];
                            }
                            p = p.up();
                        }
                        if (!Ext.isEmpty(foundFn)) {
                            contextconfig[i].handler = foundFn;
                        }
                    }
    
                    cm.push({
                        scope: this,
                        text: contextconfig[i].text,
                        contextconfigIndex: i,
                        handler: contextconfig[i].handler
                    });
    
                } else {
                    var view = 'View';
                    if (contextconfig[i].view) {
                        view = contextconfig[i].view;
                    }
                    cm.push({
                        scope: this,
                        text: contextconfig[i].name || contextconfig[i].text,
                        contextconfigIndex: i,
                        handler: this.onContextmenuItemClicked,
                        disabled: (typeof Ext.ClassManager.classes['Ext.cmp.' + contextconfig[i].component + '.context.' + view] === 'undefined')
                    });
                }
            }
                    */
            }

        } catch (e) {
            console.trace('createContextMenu', e);
        }



        if (typeof this.contextmenuCtrl !== 'undefined') {
            this.contextmenuCtrl.destroy();
        }
        this.contextmenuCtrl = new Ext.menu.Menu({
            grid: this,
            items: cm
        });
        // con sole.de bug(this.$className,' after context');
    },
});