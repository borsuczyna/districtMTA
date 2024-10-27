addEvent('story:gunFire', true)

local guns = {}
local gunPositions = {
    {-70.950, 824.076, 29.197},
    {-61.031, 827.434, 30.982},
    {-51.827, 830.551, 32.129},
    {-41.000, 834.216, 33.169},
    {-30.669, 837.714, 33.689},
    {-25.465, 839.476, 33.883},
    {-16.647, 845.162, 33.787},
    {-6.206, 848.697, 33.759},
    {5.363, 849.389, 34.801},
    {16.340, 851.257, 35.782},
    {27.355, 852.714, 36.792},
    {38.615, 854.387, 37.677},
    {49.426, 854.255, 37.934},
    {61.430, 856.446, 37.516},
    {71.821, 856.679, 38.061},
    {82.485, 855.678, 38.204},
    {94.521, 856.672, 36.049},
    {75.902, 901.970, 23.208},
    {64.697, 899.873, 23.907},
    {53.819, 899.439, 23.667},
    {42.255, 898.291, 23.884},
    {2.445, 896.346, 23.722},
    {40.380, 911.625, 23.398},
    {-304.235, 762.940, 26.505},
    {-312.740, 768.533, 28.515},
    {-322.605, 765.944, 29.664},
    {-333.135, 764.384, 30.200},
    {-343.825, 766.926, 29.929},
    {-351.030, 772.845, 28.940},
    {-360.330, 780.849, 25.422},
    {-360.164, 793.367, 22.678},
    {-366.446, 803.812, 19.309},
    {-369.484, 815.215, 15.956},
    {-367.649, 825.291, 12.825},
    {-366.711, 839.209, 12.329},
    {-365.851, 851.968, 11.483},
    {-363.767, 865.397, 10.375},
    {80.447, 846.874, 37.274},
    {72.193, 842.141, 37.441},
    {62.753, 837.806, 37.672},
    {53.628, 836.808, 37.915},
    {41.937, 833.871, 38.128},
    {31.150, 830.897, 37.662},
    {21.714, 829.591, 36.942},
    {9.806, 826.311, 36.158},
    {-0.342, 822.247, 35.818},
    {-11.730, 824.843, 34.994},
    {-233.921, 1536.719, 74.812},
    {-229.582, 1527.413, 74.131},
    {-222.548, 1518.514, 73.951},
    {-215.337, 1510.233, 73.834},
    {-205.699, 1501.813, 72.982},
    {-196.240, 1495.062, 73.351},
    {-192.126, 1485.435, 72.919},
    {-189.669, 1475.891, 72.378},
    {-170.663, 1487.434, 73.565},
    {749.938, 1046.040, 30.484},
    {741.055, 1041.545, 30.484},
    {731.774, 1036.391, 30.484},
    {724.250, 1030.226, 30.484},
    {714.048, 1034.797, 30.484},
    {703.767, 1039.026, 30.345},
    {696.605, 1047.637, 30.227},
    {697.935, 1057.336, 30.484},
    {703.606, 1067.116, 30.484},
    {710.037, 1072.464, 30.484},
    {719.943, 1077.128, 30.484},
    {727.873, 1080.069, 30.484},
    {736.758, 1082.653, 30.484},
    {746.060, 1085.285, 30.484},
    {754.307, 1080.247, 30.484},
    {762.968, 1080.613, 30.484},
    {770.554, 1086.922, 30.479},
    {774.718, 1081.288, 30.479},
    {768.699, 1077.182, 30.484},
    {756.778, 1074.920, 30.479},
    {70.334, 847.404, 37.398},
    {59.791, 847.297, 37.971},
    {49.890, 847.543, 38.539},
    {38.316, 844.767, 38.154},
    {28.717, 842.711, 37.150},
    {18.711, 841.113, 36.324},
    {7.060, 839.203, 35.374},
    {-5.213, 836.656, 34.637},
    {-18.302, 832.734, 34.450},
    {-23.923, 824.171, 34.081},
    {-30.264, 827.871, 33.804},
    {-37.995, 819.019, 33.189},
    {722.736, 1064.759, 30.484},
    {735.572, 1068.105, 30.484},
    {745.802, 1067.089, 30.479},
    {755.032, 1065.182, 30.484},
    {764.545, 1067.167, 30.484},
    {771.576, 1062.690, 30.484},
    {766.531, 1052.591, 30.484},
    {759.063, 1057.604, 30.484},
    {748.909, 1055.974, 30.484},
    {739.462, 1052.196, 30.484},
    {731.463, 1048.504, 30.484},
    {719.913, 1045.983, 30.479},
    {715.565, 1051.981, 30.479},
    {729.466, 1057.466, 30.484},
    {783.162, 1138.413, 28.474},
    {771.341, 1133.894, 28.667},
    {759.049, 1130.533, 28.364},
    {748.598, 1126.684, 28.098},
    {739.726, 1124.609, 27.845},
    {728.362, 1121.505, 27.658},
    {717.772, 1117.514, 27.424},
    {706.567, 1113.724, 27.385},
    {698.174, 1114.984, 27.467},
    {684.613, 1111.349, 27.548},
    {673.648, 1108.868, 27.750},
    {855.685, 1239.234, 33.067},
    {857.171, 1226.516, 33.288},
    {859.732, 1216.372, 33.071},
    {862.473, 1206.860, 33.132},
    {862.364, 1198.386, 33.384},
    {862.299, 1188.700, 33.654},
    {862.487, 1179.812, 33.506},
    {869.863, 1161.987, 32.802},
    {863.518, 1151.515, 33.135},
    {863.913, 1141.624, 33.415},
    {872.415, 1134.927, 33.460},
    {876.947, 1124.951, 33.576},
    {-138.564, 791.307, 23.725},
    {-145.969, 785.513, 24.891},
    {-155.145, 778.367, 25.727},
    {-164.158, 776.782, 25.841},
    {-174.899, 774.929, 26.014},
    {-185.566, 771.710, 26.441},
    {-194.065, 768.541, 26.468},
    {-202.889, 764.485, 26.405},
    {-212.154, 762.545, 25.884},
    {-219.753, 759.144, 26.044},
    {-232.872, 753.141, 26.348},
    {-241.629, 750.238, 26.261},
    {-249.702, 747.226, 26.166},
    {-247.003, 739.315, 26.009},
    {-236.023, 742.228, 25.872},
    {-225.979, 745.371, 26.547},
    {-217.011, 748.178, 26.755},
    {-206.052, 751.609, 26.716},
    {-196.215, 754.688, 26.975},
    {-185.875, 759.112, 26.523},
    {-175.017, 762.511, 25.832},
    {-165.207, 765.581, 25.147},
    {-155.498, 768.621, 25.201},
}

local usedGunPositions = {}
local usedGunPositionsCount = 0

function getUnusedGunPosition()
    if usedGunPositionsCount == #gunPositions then
        return false
    end

    local index = math.random(1, #gunPositions)
    while usedGunPositions[index] do
        index = math.random(1, #gunPositions)
    end

    usedGunPositions[index] = true
    usedGunPositionsCount = usedGunPositionsCount + 1

    return gunPositions[index]
end

function destroyAntiAircraftGun(player)
    if guns[player] and isElement(guns[player].a) then
        detachElements(player, guns[player].a)

        destroyElement(guns[player].a)
    end
end

function attachPlayerGun(player, a, b)
    attachElements(player, a, 0, 0.3, 0.7, 0, 0, 0)
    attachElements(b, a, 0, -0.6, 0.7, 0, 0, 0)
    setPedAnimation(player, 'INT_HOUSE', 'LOU_Loop', -1, false, false, false)
    setTimer(function()
        setPedAnimation(player, 'INT_HOUSE', 'LOU_Loop', -1, false, false, false)
    end, 200, 5)
    triggerClientEvent(player, 'story:gunAttach', resourceRoot, a, b)
end

function createAntiAircraftGun(player, x, y, z, rot)
    destroyAntiAircraftGun(player)
    setElementPosition(player, x, y, z)
    local a = createObject(1337, x, y, z, 0, 0, rot)
    setElementData(a, 'element:model', 'karabin-podstawa')
    
    local b = createObject(1338, x, y, z, 0, 0, rot)
    setElementData(b, 'element:model', 'karabin')
    setElementCollisionsEnabled(b, false)

    setElementData(player, 'player:antiAircraftGun', {a, b})
    
    guns[player] = {a = a, b = b}
    setTimer(attachPlayerGun, 0, 1, player, a, b)
end

-- debug
-- local plr = getPlayerFromName('borsuczyna')
-- local x, y, z = getElementPosition(plr)
-- local _, _, rot = getElementRotation(plr)
-- createAntiAircraftGun(plr, x, y, z - 0.7, rot + 180)

function createPlayerAntiAircraftGun(player)
    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)
    createAntiAircraftGun(player, x, y, z - 0.7, rot + 180)
end

-- local plr1 = getPlayerFromName('borsuczyna')
-- local plr2 = getPlayerFromName('zexty')
-- local plr3 = getPlayerFromName('soth')
-- createPlayerAntiAircraftGun(plr1)
-- -- createPlayerAntiAircraftGun(plr2)
-- createPlayerAntiAircraftGun(plr3)

-- on resource stop detach player
addEventHandler('onResourceStop', resourceRoot, function()
    for player, gun in pairs(guns) do
        destroyAntiAircraftGun(player)
    end
end)

addEventHandler('story:gunFire', resourceRoot, function(x, y, z, tx, ty, tz, hitElement, destroyPos)
    triggerClientEvent(root, 'story:gunFire', resourceRoot, client, x, y, z, tx, ty, tz)

    if hitElement then
        onUfoHit(client, hitElement, destroyPos)
    end
end)

-- on player quits destroy gun
addEventHandler('onPlayerQuit', root, function()
    destroyAntiAircraftGun(source)
end)

function startAntiAircraftGun(player)
    local pos = getUnusedGunPosition()
    if not pos then
        local x, y, z = getElementPosition(player)
        pos = {x, y, z}
    end

    createAntiAircraftGun(player, pos[1], pos[2], pos[3], 0)
end

function startAntiAircraft()
    for _, player in ipairs(getElementsByType('player')) do
        startAntiAircraftGun(player)
    end
    -- local borsuczyna = getPlayerFromName('borsuczyna')
    -- createPlayerAntiAircraftGun(borsuczyna)
end