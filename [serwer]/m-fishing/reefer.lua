addEvent('fishing:onReeferBuy')

local reeferSpawns = {
    -- {174.079, -1942.801, -0.356, 359.603, 359.866, 210.976},
    -- {815.491, -1955.542, -0.369, 359.164, 359.870, 178.344},
    -- {814.434, -1989.760, -0.364, 359.169, 359.860, 178.236},
    -- {813.542, -2026.907, -0.370, 359.082, 359.922, 179.429},
    -- {813.266, -2058.611, -0.351, 359.168, 359.874, 179.530},

    {2980.006, -1960.207, -0.356, 0, 0, 0},
    {2970.006, -1960.207, -0.356, 0, 0, 0},
    {2960.006, -1960.207, -0.356, 0, 0, 0},
    {2950.006, -1960.207, -0.356, 0, 0, 0},
    {2940.006, -1960.207, -0.356, 0, 0, 0},
    {2930.006, -1960.207, -0.356, 0, 0, 0},
    {2980.006, -1984.207, -0.356, 0, 0, 180},
    {2970.006, -1984.207, -0.356, 0, 0, 180},
    {2960.006, -1984.207, -0.356, 0, 0, 180},
    {2950.006, -1984.207, -0.356, 0, 0, 180},
    {2940.006, -1984.207, -0.356, 0, 0, 180},
    {2930.006, -1984.207, -0.356, 0, 0, 180},
}

local function getRandomSpawn()
    return reeferSpawns[math.random(1, #reeferSpawns)]
end

local function despawnReefer(vehicle)
    destroyElement(vehicle)
end

function onReeferBuy(player, time)
    local x, y, z, rx, ry, rz = unpack(getRandomSpawn())
    local vehicle = createVehicle(453, x, y, z, rx, ry, rz)
    warpPedIntoVehicle(player, vehicle)
    setTimer(despawnReefer, time * 60000, 1, vehicle)
    setElementData(vehicle, 'reefer:owner', player, false)

    exports['m-notis']:addNotification(player, 'success', 'Kuter rybacki', 'Wynająłeś kuter rybacki na ' .. time .. ' minut')
end

addEventHandler('fishing:onReeferBuy', root, onReeferBuy)

-- cant enter
addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    local reeferOwner = getElementData(source, 'reefer:owner')
    if reeferOwner and reeferOwner ~= player then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', 'Kuter rybacki', 'Ten kuter należy do innego gracza')
    end
end)