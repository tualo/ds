Ext.define('Tualo.ds.lazy.test.BreadCrumbs',{
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.tualo_navigation_breadcrumbs',
    cls: 'x-bread-crumb-box',

    config: {
        /**
         * Defines the maximum number of elements for this BreadCrumbs view
         */
        maxElements: 256
    },

    /*
        constructor: function (config) {
        this.initConfig(config);

        / *
        config.style = config.style || {};
        if (Ext.isString(config.style)) {
            config.style = this.parseStyles(config.style);
        }
        // Make z-index mandatory
        config.style['z-index'] = config.style['z-index'] || 1;
        * /
        // this.addEvents('crumbclick');
        this.callParent(arguments);

        this.addListener('add', function (crumbs, crumb) {
            // Proxy all 'click' events to this 'crumbclick' events
            crumb.addListener({
                click: function () {
                    /* *
                    * @event crumbclick
                    * Fired when breadcrumb is clicked
                    * @param {Mixed} crumb                      Item, that was clicked
                    * @param {Ext.toolbar.BreadCrumbs} crumbs   BreadCrumbs container
                    * /
                    crumbs.fireEvent('crumbclick', crumb, crumbs);
                }
            });
        });

        // Add listeners to pre-defined crumbs
        this.addListener('render', function (crumbs) {
            crumbs.items.each(function (crumb) {
                crumb.addListener({
                    click: function () {
                        crumbs.fireEvent('crumbclick', crumb, crumbs);
                    }
                });
            });
        });
        
    },
    */

    defaults: {
        xtype: 'button',
        cls: 'x-bread-crumb',

        listeners: {
            click: function (crumb) {
                crumb.removeTrail();
            }
        },

        removeTrail: function () {
            var breadcrumbs = this.findParentByType('breadcrumbs');

            // remove trailing crumbs
            var trail = this.nextSibling();
            while (trail != null) {
                var remove = trail;
                trail = trail.nextSibling();
                breadcrumbs.remove(remove);
            }
        }
    },

    /**
     * @method
     * Makes a proper breadcrumb of given item
     * @param {Object} item     Configuration for new item
     * @param {Number} index    Breadcrumb index for item
     * @private
     */
    makeBreadcrumb: function (item, index) {
        if (Ext.isString(item)) {
            var T = Ext.toolbar.Toolbar;
            item = T.shortcutsHV[this.vertical ? 1 : 0][item] || T.shortcuts[item];
        }

        // make object of item.style
        item.style = item.style || {};
        if (Ext.isString(item.style)) {
            item.style = this.parseStyles(item.style);
        }

        var baseZindex = this.maxElements + this.style['z-index'];
        index = index || this.items.getCount();
        // make sure each item lays over previous
        item.style['z-index'] = baseZindex - index - 1;

        return item;
    },

    /**
     * @method
     * This adds some 'crumb' flavor to new elements
     * @inheritdoc
     */
    add: function () {
        var args = Ext.Array.slice(arguments);
        args = args.length == 1 && Ext.isArray(args[0]) ? args[0] : args;

        var items = [];
        Ext.Array.each(args, function (item, index) {
            items.push(this.makeBreadcrumb(item, this.items.getCount() + index));
        }, this);

        this.callParent(items);
    },

    /**
     * @method
     * Shorthand for {@link Ext.toolbar.Toolbar#method-removeAll removeAll()}
     * and then {@link Ext.toolbar.Toolbar#method-add add(arguments)}
     * @inheritdoc Ext.toolbar.Toolbar#method-add
     */
    set: function () {
        this.removeAll();

        this.add.apply(this, arguments);
    }
});