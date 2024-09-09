function Position(name)
    return {
        name = name,
        type = 'position',
        check = function(value)
            return type(value) == 'userdata' and value.x and value.y and value.z
        end,
        toCode = function(value)
            return string.format('Vector3(%.4f, %.4f, %.4f)', value.x, value.y, value.z)
        end
    }
end