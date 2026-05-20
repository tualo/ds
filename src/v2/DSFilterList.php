<?php

namespace Tualo\Office\DS\v2;

use Tualo\Office\Basic\TualoApplication;

class DSFilterList
{
    private array $definitions;
    private array $filters = [];

    public static function fromJSON(string $json, array $definitions): DSFilterList
    {
        $data = json_decode($json, true);
        if (!isset($data['table_name'], $data['filters']) || !is_array($data['filters'])) {
            throw new \InvalidArgumentException('Invalid JSON format for DSFilterList');
        }
        $filterList = new self($definitions);
        foreach ($data['filters'] as $filterData) {
            $filterList->addFilter(DSFilter::fromJSON(json_encode($filterData), $definitions));
        }
        return $filterList;
    }

    function __construct(array $definitions)
    {
        $this->definitions = $definitions;
    }

    function addFilter(DSFilter $filter): DSFilterList
    {
        $this->filters[] = $filter;
        return $this;
    }

    function getFilters(): array
    {
        return $this->filters;
    }
}
