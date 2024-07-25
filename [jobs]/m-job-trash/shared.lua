settings = {
    jobStart = Vector3(1922.129, -1610.362, 13.383),
    trashDump = Vector3(1941.664, -1631.658, 12.383),
    vehicleSpawn = Vector3(1910.667, -1614.267, 13.925),
    vehicleSpawnRot = Vector3(0, 0, -90),
}

trash = {
    {1860.495, -1598.156, 13.555, -0.000, 0.000, 178.621},
    {1913.356, -1598.267, 13.555, -0.000, 0.000, 178.331},
    {1962.969, -1632.231, 15.961, -0.000, 0.000, 89.970},
    {1965.598, -1669.686, 15.969, -0.000, 0.000, 89.657},
    {1983.759, -1684.631, 15.969, -0.000, 0.000, 271.682},
    {1974.696, -1705.964, 15.969, -0.000, 0.000, 181.104},
    {1968.218, -1705.621, 15.969, -0.000, 0.000, 180.164},
    {2013.587, -1730.965, 13.555, -0.000, 0.000, 91.200},
    {2067.242, -1658.600, 13.547, -0.000, 0.000, 273.248},
    {2068.053, -1646.170, 13.547, -0.000, 0.000, 270.428},
    {2160.805, -1612.953, 14.346, -0.000, 0.000, 156.397},
    {2172.712, -1613.346, 14.352, -0.000, 0.000, 68.663},
    {2179.076, -1598.447, 14.352, -0.000, 0.000, 69.266},
    {2163.091, -1590.219, 14.341, -0.000, 0.000, 160.111},
    {2148.763, -1584.030, 14.347, -0.000, 0.000, 160.401},
    {1938.380, -1910.054, 15.257, -0.000, 0.000, 91.153},
    {1927.440, -1916.318, 15.257, -0.000, 0.000, 177.924},
    {1890.879, -1914.541, 15.257, -0.000, 0.000, 182.309},
    {1871.146, -1911.983, 15.257, -0.000, 0.000, 180.721},
    {2388.290, -1281.010, 25.129, -0.000, 0.000, 88.888},
    {2488.073, -1645.082, 14.070, -0.000, 0.000, 181.277},
    {2497.177, -1642.575, 13.783, -0.000, 0.000, 179.397},
    {2512.312, -1649.367, 14.356, -0.000, 0.000, 135.840},
    {2514.915, -1688.641, 13.583, -0.000, 0.000, 49.676},
    {2462.183, -1690.876, 13.512, -0.000, 0.000, 0.169},
}

objectModels = {
    {1337, -0.4, {23, 0.44, 0, 0.45, 0, 220, 90}, true},
    {1265, -0.5, {24, 0.2, 0, -0.1, 0, -90, 0}, false}
}

function getRandomTrashModel()
    return unpack(objectModels[math.random(1, #objectModels)])
end

function getTrashInfoByModel(model)
    for k,v in pairs(objectModels) do
        if v[1] == model then
            return unpack(v)
        end
    end
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end