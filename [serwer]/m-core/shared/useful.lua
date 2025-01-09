function removeHex(s)
    return s:gsub('#%x%x%x%x%x%x', '') or false
end

function createHash()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local hash = ''
    for i = 1, 32 do
        local rand = math.random(1, #chars)
        hash = hash .. chars:sub(rand, rand)
    end
    return hash
end

function map(array, func)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end

function mapk(array, func)
    local new_array = {}
    for i, v in pairs(array) do
        table.insert(new_array, func(v, i))
    end
    return new_array
end

function trim(s)
    return s:match('^%s*(.-)%s*$')
end

function splitArray(array, count)
    local new_array = {}
    for i = 1, #array, count do
        local part = {}
        for j = 0, count - 1 do
            if array[i + j] then
                table.insert(part, array[i + j])
            end
        end
        table.insert(new_array, part)
    end
    return new_array
end

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return false
end

function iter(s, e, func)
    local t = {}
    for i = s, e do
        table.insert(t, func(i))
    end
    return t
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end