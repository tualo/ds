<?php

namespace Tualo\Office\DS\v2;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\MYSQL\Database_mysql;

class DSFilter
{
    private DSColumnDefinition $definition;
    private string $column_name;
    private string $operator;
    private string $valueType = 'string';

    private string $stringValue;
    private int $intValue;
    private float $doubleValue;
    private bool $boolValue;
    private string $dateValue;
    private string $dateTimeValue;
    private array $arrayValue;

    public static function fromJSON(string $json, array $definitions): DSFilter
    {
        $data = json_decode($json, true);
        if (!isset($data['column_name'], $data['operator'], $data['valueType'])) {
            throw new \InvalidArgumentException('Invalid JSON format for DSFilter');
        }
        $filter = new self($data['column_name'], $data['operator'], null);
        if (!isset($definitions[$data['column_name']])) {
            throw new \Exception("the requested filter field is not defined");
        }
        $filter->definition = $definitions[$data['column_name']];

        $filter->valueType = $filter->definition->getPHPType(); // Use the data type from the column definition

        switch ($filter->valueType) {
            case 'string':
                $filter->stringValue = $data['stringValue'] ?? '';
                break;
            case 'int':
                $filter->intValue = $data['intValue'] ?? 0;
                break;
            case 'double':
                $filter->doubleValue = $data['doubleValue'] ?? 0.0;
                break;
            case 'bool':
                $filter->boolValue = $data['boolValue'] ?? false;
                break;
            case 'date':
                $filter->dateValue = $data['dateValue'] ?? '';
                break;
            case 'time':
                $filter->dateValue = $data['dateValue'] ?? '';
                break;
            case 'dateTime':
                $filter->dateTimeValue = $data['dateTimeValue'] ?? '';
                break;
            case 'array':

                $filter->arrayValue = $data['arrayValue'] ?? [];
                break;
            default:
                throw new \InvalidArgumentException('Unsupported value type in JSON');
        }
        return $filter;
    }

    function __construct(string $column_name, string $operator, mixed $value)
    {
        $this->column_name = $column_name;
        $this->operator = $operator;
        if (is_string($value)) {
            $this->valueType = 'string';
            $this->stringValue = $value;
        } elseif (is_int($value)) {
            $this->valueType = 'int';
            $this->intValue = $value;
        } elseif (is_float($value)) {
            $this->valueType = 'double';
            $this->doubleValue = $value;
        } elseif (is_bool($value)) {
            $this->valueType = 'bool';
            $this->boolValue = $value;
        } elseif ($value instanceof \DateTime) {
            $this->valueType = 'dateTime';
            $this->dateTimeValue = $value->format('Y-m-d H:i:s');
        } elseif (is_array($value)) {
            $this->valueType = 'array';
            $this->arrayValue = $value;
        } else {
            throw new \InvalidArgumentException('Unsupported value type');
        }
    }
}
