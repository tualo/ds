<?php

namespace Tualo\Office\DS\v2;

use Tualo\Office\Basic\MYSQL\Database_mysql;

class DSColumnDefinition
{
    private Database_mysql $db;
    private string $tablename;
    private string $columnname;
    private string $default_value;
    private string $default_max_value;
    private string $default_min_value;
    private string $update_value;
    private bool $is_primary;
    private bool $syncable;
    private string $referenced_table;
    private string $referenced_column_name;
    private string $is_nullable;
    private string $is_referenced;
    private bool $writeable;
    private string $note;
    private string $data_type;
    private string $column_key;
    private string $column_type;
    private int $character_maximum_length;
    private int $numeric_precision;
    private int $numeric_scale;
    private string $character_set_name;
    private string $privileges;
    private bool $existsreal;
    private bool $deferedload;
    private string $hint;
    private string $fieldtype;
    private string $is_generated;
    /*
    +--------------------------+--------------+------+-----+----------+-------+
    | Field                    | Type         | Null | Key | Default  | Extra |
    +--------------------------+--------------+------+-----+----------+-------+
    | table_name               | varchar(128) | NO   | PRI | NULL     |       |
    | column_name              | varchar(100) | NO   | PRI |          |       |
    | default_value            | varchar(255) | YES  |     | NULL     |       |
    | default_max_value        | bigint(20)   | YES  |     | 10000000 |       |
    | default_min_value        | bigint(20)   | YES  |     | 0        |       |
    | update_value             | varchar(255) | YES  |     | NULL     |       |
    | is_primary               | tinyint(4)   | YES  |     | 0        |       |
    | syncable                 | tinyint(4)   | YES  |     | 0        |       |
    | referenced_table         | varchar(50)  | YES  |     | NULL     |       |
    | referenced_column_name   | varchar(50)  | YES  |     | NULL     |       |
    | is_nullable              | varchar(20)  | YES  |     | NULL     |       |
    | is_referenced            | varchar(20)  | YES  |     | NULL     |       |
    | writeable                | tinyint(4)   | YES  |     | 1        |       |
    | note                     | varchar(50)  | YES  |     |          |       |
    | data_type                | varchar(255) | YES  |     |          |       |
    | column_key               | varchar(255) | YES  |     |          |       |
    | column_type              | varchar(255) | YES  |     |          |       |
    | character_maximum_length | bigint(20)   | YES  |     | 0        |       |
    | numeric_precision        | int(11)      | YES  |     | 0        |       |
    | numeric_scale            | int(11)      | YES  |     | 0        |       |
    | character_set_name       | varchar(255) | YES  |     |          |       |
    | privileges               | varchar(255) | YES  |     |          |       |
    | existsreal               | tinyint(4)   | YES  |     | 0        |       |
    | deferedload              | tinyint(4)   | YES  |     | 0        |       |
    | hint                     | varchar(255) | YES  |     | NULL     |       |
    | fieldtype                | varchar(100) | YES  |     |          |       |
    | is_generated             | varchar(30)  | YES  |     |          |       |
   */

    function __construct(Database_mysql $db, string $tablename)
    {
        $this->db = $db;
        $this->tablename = $tablename;
    }

    public static function queryStatic(Database_mysql $db, string $tablename): array
    {
        $data = $db->direct(
            '
                select
                    table_name,
                    column_name,
                    default_value,
                    default_max_value,
                    default_min_value,
                    update_value,
                    is_primary,
                    syncable,
                    referenced_table,
                    referenced_column_name,
                    is_nullable,
                    is_referenced,
                    writeable,
                    note,
                    data_type,
                    column_key,
                    column_type,
                    character_maximum_length,
                    numeric_precision,
                    numeric_scale,
                    character_set_name,
                    privileges,
                    existsreal,
                    deferedload,
                    hint,
                    fieldtype,
                    is_generated
                from ds_column
                where table_name = {tablename}
                    
            ',
            [
                'tablename' => $tablename
            ]
        );
        $list = [];
        foreach ($data as $row) {
            $item = new DSColumnDefinition($db, $tablename);
            $list[] = $item->fromColumnDefinition($row);
        }
        return $list;
    }

    function fromColumnDefinition(array $data): DSColumnDefinition
    {
        $this->columnname = $data['column_name'];
        $this->default_value = $data['default_value'];
        $this->default_max_value = $data['default_max_value'];
        $this->default_min_value = $data['default_min_value'];
        $this->update_value = $data['update_value'];
        $this->is_primary = $data['is_primary'];
        $this->syncable = $data['syncable'];
        $this->referenced_table = $data['referenced_table'];
        $this->referenced_column_name = $data['referenced_column_name'];
        $this->is_nullable = $data['is_nullable'];
        $this->is_referenced = $data['is_referenced'];
        $this->writeable = $data['writeable'];
        $this->note = $data['note'];
        $this->data_type = $data['data_type'];
        $this->column_key = $data['column_key'];
        $this->column_type = $data['column_type'];
        $this->character_maximum_length = $data['character_maximum_length'];
        $this->numeric_precision = $data['numeric_precision'];
        $this->numeric_scale = $data['numeric_scale'];
        $this->character_set_name = $data['character_set_name'];
        $this->privileges = $data['privileges'];
        $this->existsreal = $data['existsreal'];
        $this->deferedload = $data['deferedload'];
        $this->hint = $data['hint'];
        $this->fieldtype = $data['fieldtype'];
        $this->is_generated = $data['is_generated'];
        return $this;
    }

    function getColumnname(): string
    {
        return $this->columnname;
    }

    function getDefaultValue(): string
    {
        return $this->default_value;
    }

    function getDefaultMaxValue(): string
    {
        return $this->default_max_value;
    }

    function getDefaultMinValue(): string
    {
        return $this->default_min_value;
    }

    function getUpdateValue(): string
    {
        return $this->update_value;
    }

    function getIsPrimary(): bool
    {
        return $this->is_primary;
    }

    function getSyncable(): bool
    {
        return $this->syncable;
    }

    function getReferencedTable(): string
    {
        return $this->referenced_table;
    }

    function getReferencedColumnName(): string
    {
        return $this->referenced_column_name;
    }

    function getIsNullable(): string
    {
        return $this->is_nullable;
    }

    function getIsReferenced(): string
    {
        return $this->is_referenced;
    }

    function getWriteable(): bool
    {
        return $this->writeable;
    }

    function getNote(): string
    {
        return $this->note;
    }

    function getDataType(): string
    {
        return $this->data_type;
    }

    function getPHPType(): string
    {
        /*

        | int                 |
        | date                |
        | time                |
        | varchar             |
        | longtext            |
        | text                |
        | tinyint             |
        | decimal             |
        | bigint              |
        | datetime            |
        | double              |
        | char                |
        | enum('live','test') |
        | mediumtext          |
        | uuid                |
        */

        switch ($this->getDataType()) {
            case 'int':
            case 'tinyint':
            case 'bigint':
                return 'int';
            case 'double':
                return 'double';
            case 'date':
                return 'date';
            case 'dateTime':
                return 'dateTime';
            case 'time':
                return 'time';
            case 'varchar':
            case 'text':
            case 'mediumtext':
            case 'longtext':
            case 'uuid':
            case 'char':
                return 'string';
            default:
                return 'string';
        }
    }

    function getColumnKey(): string
    {
        return $this->column_key;
    }

    function getColumnType(): string
    {
        return $this->column_type;
    }

    function getCharacterMaximumLength(): int
    {
        return $this->character_maximum_length;
    }

    function getNumericPrecision(): int
    {
        return $this->numeric_precision;
    }

    function getNumericScale(): int
    {
        return $this->numeric_scale;
    }

    function getCharacterSetName(): string
    {
        return $this->character_set_name;
    }

    function getPrivileges(): string
    {
        return $this->privileges;
    }

    function getExistsReal(): bool
    {
        return $this->existsreal;
    }

    function getDeferedLoad(): bool
    {
        return $this->deferedload;
    }

    function getHint(): string
    {
        return $this->hint;
    }

    function getFieldType(): string
    {
        return $this->fieldtype;
    }

    function getIsGenerated(): string
    {
        return $this->is_generated;
    }
}
