Ext.define('Tualo.DSTable', {
    constructor: function (tablename = 'test') {
        let baseUrl = './ds';
        this.baseUrl = baseUrl.replace(/\/+$/, '');
        this._limit = 100000;
        this._start = 0;
        this._filter = [];
        this._sorter = [];
        this._data = [];
        this._isQueried = false;
        this._hasError = false;
        this._errorMessage = '';
        this._warnings = [];
        this._moreResults = [];
        this.t(tablename);
    },

    t: function (tablename) {
        if (typeof tablename !== 'string' || !/^\w+$/.test(tablename)) {
            throw new TypeError('Invalid DS table name');
        }
        this.tablename = tablename;
        return this.invalidate();
    },

    invalidate: function () {
        this._data = [];
        this._isQueried = false;
        return this;
    },

    f: function (field, operator, value) {
        return this.filter(field, operator, value);
    },

    filter: function (field, operator, value) {
        this._filter.push({ property: field, operator: operator, value: value });
        return this.invalidate();
    },

    s: function (field, direction) {
        return this.sort(field, direction);
    },

    sort: function (field, direction) {
        this._sorter.push({ property: field, direction: direction });
        return this.invalidate();
    },

    start: function (start) {
        if (!Number.isInteger(start) || start < 0) {
            throw new TypeError('Start must be a non-negative integer');
        }
        this._start = start;
        return this.invalidate();
    },

    limit: function (limit) {
        if (!Number.isInteger(limit) || limit < 1) {
            throw new TypeError('Limit must be a positive integer');
        }
        this._limit = limit;
        return this.invalidate();
    },

    empty: function () {
        return this._data.length === 0;
    },

    queried: function () {
        return this._isQueried;
    },

    error: function () {
        return this._hasError;
    },

    errorMessage: function () {
        return this._errorMessage;
    },

    warnings: function () {
        return this._warnings;
    },

    moreResults: function () {
        return this._moreResults;
    },

    readWarnings: function () {
        return this.warnings();
    },

    readMoreResults: function () {
        return this.moreResults();
    },

    differentRows: function (records) {
        const keys = new Set(records.flatMap(record => Object.keys(record)));
        return records.some(record => Array.from(keys).some(key =>
            !Object.prototype.hasOwnProperty.call(record, key) || record[key] == null
        ));
    },

    prepareRecords: function (records) {
        const result = Array.isArray(records) ? records : [records];
        if (result.some(record =>
            record === null || typeof record !== 'object' || Array.isArray(record)
        )) {
            throw new TypeError('Records must be objects or an array of objects');
        }
        return result;
    },

    appendFileFromUploadForm: async function (record, attribute) {
        const file = typeof attribute === 'string'
            ? Array.from(document.getElementsByName(attribute))
                .find(input => input.files && input.files.length)?.files[0]
            : attribute;
        if (!(file instanceof File)) {
            throw new TypeError('No upload file found');
        }
        const data = await new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(reader.error);
            reader.onabort = () => reject(new Error('File reading aborted'));
            reader.readAsDataURL(file);
        });
        return Object.assign({}, record, {
            __file_data: data,
            __file_id: '',
            __file_name: file.name,
            __file_size: file.size,
            __file_type: file.type || 'application/octet-stream',
            error: 0
        });
    },

    request: function (action, input) {
        this._hasError = false;
        this._errorMessage = '';
        try {
            const response = new XMLHttpRequest();
            response.open(
                'POST',
                this.baseUrl + '/' + encodeURIComponent(this.tablename) + '/' + action,
                false
            );
            response.setRequestHeader('Accept', 'application/json');
            response.setRequestHeader('Content-Type', 'application/json');
            response.send(JSON.stringify(input));
            // Preserve HTTP errors even when a proxy returns HTML instead of JSON.
            if (response.status < 200 || response.status >= 300) {
                const text = response.responseText;
                let message = 'HTTP ' + response.status + ' ' + response.statusText;
                try {
                    const result = JSON.parse(text);
                    if (result && typeof result === 'object') {
                        message = result.msg || result.message || message;
                    }
                } catch (error) {
                    if (!(error instanceof SyntaxError)) throw error;
                }
                const error = new Error(message);
                error.status = response.status;
                throw error;
            }
            const result = JSON.parse(response.responseText);
            if (!result || typeof result !== 'object' || Array.isArray(result)) {
                throw new Error('Invalid DS response');
            }
            if (Array.isArray(result.warnings)) {
                this._warnings.push(...result.warnings);
            }
            if (Array.isArray(result.moreResults)) {
                this._moreResults.push(...result.moreResults);
            }
            if (result.success !== true) {
                throw new Error(result.msg || result.message || 'DS request failed');
            }
            return result;
        } catch (error) {
            this._hasError = true;
            this._errorMessage = error.message;
            throw error;
        }
    },

    r: function () {
        return this.read();
    },

    read: function () {
        this.invalidate();
        const result = this.request('read', {
            start: this._start,
            shortfieldnames: 1,
            limit: this._limit,
            filter: this._filter,
            sort: this._sorter
        });
        if (!Array.isArray(result.data)) {
            this._hasError = true;
            this._errorMessage = 'Invalid DS response: data must be an array';
            throw new Error(this._errorMessage);
        }
        this._data = result.data;
        this._isQueried = true;
        return this;
    },

    g: function (hashKey = '', valueKey = '') {
        return this.get(hashKey, valueKey);
    },

    get: function (hashKey = '', valueKey = '') {
        this.read();
        if (hashKey === '') return this._data;
        const hash = {};
        this._data.forEach(record => {
            Object.defineProperty(hash, record[hashKey], {
                value: valueKey !== '' && record[valueKey] != null ? record[valueKey] : record,
                enumerable: true,
                configurable: true,
                writable: true
            });
        });
        return hash;
    },

    getSingle: function () {
        if (!this._isQueried) this.read();
        return this._data.length > 0 ? this._data[0] : [];
    },

    getSingleValue: function (column) {
        const record = this.getSingle();
        return record[column] == null ? false : record[column];
    },

    write: function (action, records, options) {
        try {
            if (options === null || typeof options !== 'object' || Object.keys(options).length > 0) {
                throw new TypeError('DS HTTP routes do not support write options');
            }
            const input = this.prepareRecords(records);
            this.invalidate();
            return this.request(action, input);
        } catch (error) {
            this._hasError = true;
            this._errorMessage = error.message;
            throw error;
        }
    },

    insert: function (record = [], options = {}) {
        return this.write('create', record, options);
    },

    update: function (record = [], options = {}) {
        return this.write('update', record, options);
    },

    delete: function (record = [], options = {}) {
        return this.write('delete', record, options);
    }
});

window.dstable = function (tablename) {
    return new Tualo.DSTable(tablename);
};
