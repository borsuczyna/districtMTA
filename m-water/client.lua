local waters = {
    -- {1476, -1610, 12, 1, 1},
}

local function createWaterBox(x, y, z, w, h)
    local water = createWater(x - w, y - h, z, x + w, y - h, z, x - w, y + h, z, x + w, y + h, z)
    return water
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i, v in ipairs(waters) do
        createWaterBox(unpack(v))
    end
end)