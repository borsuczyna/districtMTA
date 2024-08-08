addEvent('fishing:onReeferBuy')

local reeferSpawns = {
    {816.179, -1931.031, -0.353, 359.576, 359.887, 178.144},
    {815.491, -1955.542, -0.369, 359.164, 359.870, 178.344},
    {814.434, -1989.760, -0.364, 359.169, 359.860, 178.236},
    {813.542, -2026.907, -0.370, 359.082, 359.922, 179.429},
    {813.266, -2058.611, -0.351, 359.168, 359.874, 179.530},
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

    exports['m-notis']:addNotification(player, 'success', 'Kuter rybacki', 'Wynająłeś kuter rybacki na ' .. time .. ' minut')
end

addEventHandler('fishing:onReeferBuy', root, onReeferBuy)