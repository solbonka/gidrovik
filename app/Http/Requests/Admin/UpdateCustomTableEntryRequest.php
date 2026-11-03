<?php

namespace App\Http\Requests\Admin;

use App\Models\CustomTable;
use Illuminate\Foundation\Http\FormRequest;

class UpdateCustomTableEntryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    protected function getTable(): CustomTable
    {
        $route = $this->route("custom_table");
        $id = null;
        if ($route instanceof CustomTable) {
            $id = $route->id;
        } elseif (is_numeric($route)) {
            $id = (int) $route;
        }
        if (!$id) {
            abort(404);
        }
        return CustomTable::findOrFail($id);
    }

    public function validated($key = null, $defaults = [])
    {
        $validated = parent::validated($key, $defaults);

        if ($key !== null) {
            return $validated;
        }

        $rawData = $validated["data"] ?? [];
        if (! is_array($rawData)) {
            return [];
        }

        $allowed = array_fill_keys($this->getTable()->columnKeys(), true);

        return array_intersect_key($rawData, $allowed);
    }

    public function rules(): array
    {
        $rules = [];

        foreach ($this->getTable()->columnList() as $column) {
            $key = $column["key"];
            $type = $column["type"];

            // All rules are nullable
            $rule = match ($type) {
                "integer" => ["nullable", "integer"],
                "decimal" => ["nullable", "decimal:0,8"],
                "boolean" => ["nullable", "boolean"],
                "date" => ["nullable", "date"],
                "text" => ["nullable", "string", "max:10000"],
                "json" => ["nullable", "json"],
                default => ["nullable", "string", "max:255"],
            };

            $rules["data.{$key}"] = $rule;
        }

        return $rules;
    }

    public function attributes(): array
    {
        $attributes = [];

        foreach ($this->getTable()->columnList() as $column) {
            $attributes["data.{$column["key"]}"] = $column["name"];
        }

        return $attributes;
    }

    protected function prepareForValidation(): void
    {
        $data = $this->input("data", []);

        if (! is_array($data)) {
            return;
        }

        // Convert empty strings to null so nullable rules pass
        foreach ($data as $key => $value) {
            if ($value === "") {
                $data[$key] = null;
            }
        }

        foreach ($this->getTable()->columnList() as $column) {
            if ($column["type"] !== "boolean") {
                continue;
            }

            $key = $column["key"];

            if (array_key_exists($key, $data)) {
                $value = $data[$key];

                if (is_string($value)) {
                    $data[$key] = filter_var(
                        $value,
                        FILTER_VALIDATE_BOOLEAN,
                        FILTER_NULL_ON_FAILURE,
                    ) ?? $value;
                }
            }
        }

        $this->replace(["data" => $data]);
    }
}
