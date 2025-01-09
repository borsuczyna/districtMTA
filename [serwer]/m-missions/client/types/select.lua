function Select(name, options, default)
    return {
        name = name,
        type = 'select',
        options = options,
        default = default,
        check = function(value)
            return type(value) == 'string' or type(value) == 'number'
        end,
        toCode = function(value)
            return ('%q'):format(value)
        end,
    }
end