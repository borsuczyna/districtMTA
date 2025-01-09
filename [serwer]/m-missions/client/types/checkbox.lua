function Checkbox(name, default)
    return {
        name = name,
        type = 'checkbox',
        default = default or false,
        check = function(value)
            return type(value) == 'boolean'
        end,
        toCode = function(value)
            return value == true and 'true' or 'false'
        end
    }
end