function Number(name, default)
    return {
        name = name,
        type = 'number',
        default = default,
        check = function(value)
            return type(value) == 'number'
        end,
        toCode = function(value)
            return tostring(value)
        end
    }
end