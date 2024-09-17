function Rotation3D(name)
    return {
        name = name,
        type = 'rotation3d',
        default = {x = 0, y = 0, z = 0},
        check = function(value)
            return type(value) == 'table' and value.x and value.y and value.z
        end,
        toCode = function(value)
            return string.format('{x=%.4f, y=%.4f, z=%.4f}', value.x, value.y, value.z)
        end
    }
end

function Rotation(name)
    return {
        name = name,
        type = 'rotation',
        default = 0,
        check = function(value)
            return type(value) == 'number'
        end,
        toCode = function(value)
            return string.format('%.4f', value)
        end
    }
end