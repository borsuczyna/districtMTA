function Position(name)
    return {
        name = name,
        type = 'position',
        default = {x = 0, y = 0, z = 0},
        check = function(value)
            return type(value) == 'table' and value.x and value.y and value.z
        end,
        toCode = function(value)
            return string.format('{x=%.4f, y=%.4f, z=%.4f}', value.x, value.y, value.z)
        end
    }
end