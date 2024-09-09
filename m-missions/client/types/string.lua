function String(name, default)
    return {
        name = name,
        type = 'string',
        default = default,
        check = function(value)
            return type(value) == 'string'
        end,
        toCode = function(value)
            return string.format('%q', value)
        end
    }
end