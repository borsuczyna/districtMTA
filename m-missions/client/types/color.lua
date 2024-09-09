function Color(name, default)
    return {
        name = name,
        type = 'color',
        default = default,
        check = function(value)
            return type(value) == 'table' and (#value == 3 or #value == 4)
        end,
        toCode = function(value)
            if #value == 3 then
                return string.format('{%s, %s, %s}', value[1], value[2], value[3])
            else
                return string.format('{%s, %s, %s, %s}', value[1], value[2], value[3], value[4])
            end
        end,
    }
end