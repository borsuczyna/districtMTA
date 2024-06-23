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