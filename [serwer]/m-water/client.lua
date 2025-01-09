local waters = {
    -- {X1, Y1, X2, Y2, X3, Y3, X4, Y4, Z}
    {937, -1470, 956, -1470, 937, -1425, 956, -1425, 12.2}
}

local function createWaterBox(x1, y1, x2, y2, x3, y3, x4, y4, z)
    local water = createWater(x1, y1, z, x2, y2, z, x3, y3, z, x4, y4, z)
    return water
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i, v in ipairs(waters) do
        createWaterBox(unpack(v))
    end
end)
