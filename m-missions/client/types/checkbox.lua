function Checkbox(name, default)
    return {
        name = name,
        type = 'checkbox',
        default = default,
        check = function(value)
            return type(value) == 'boolean'
        end,
        toCode = function(value)
            return value and 'true' or 'false'
        end
    }
end