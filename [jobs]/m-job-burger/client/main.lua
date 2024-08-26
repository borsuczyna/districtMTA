addEvent('jobs:burger:startJob', true)
addEvent('jobs:burger:finishJob', true)
addEvent('jobs:burger:serverTickResponse', true)

sx, sy = guiGetScreenSize()
zoom = (sx < 2048) and math.min(2.2, 2048/sx) or 1
local serverTick = {
    clientStart = 0,
    serverStart = 0
}

local marker = createMarker(settings.jobStart + Vector3(0, 0, -1), 'cylinder', 1, 255, 140, 0, 0)
setElementData(marker, 'marker:icon', 'work')
setElementData(marker, 'marker:title', 'Burgerownia')
setElementData(marker, 'marker:desc', 'Rozpoczęcie pracy')

addEventHandler('onClientMarkerHit', marker, function(player, md)
    if player ~= localPlayer or not md or getPedOccupiedVehicle(player) then return end
    
    exports['m-jobs']:showJobGui('burger')
end)

addEventHandler('onClientMarkerLeave', marker, function(player, md)
    if player ~= localPlayer or not md then return end
    
    exports['m-jobs']:hideJobGui()
end)

addEventHandler('jobs:burger:startJob', resourceRoot, function(hash)
    showInteriorLoading(true)
    fetchServerTick()
end)

addEventHandler('jobs:burger:finishJob', resourceRoot, function(hash)
    showInteriorLoading(false)
end)

function fetchServerTick()
    triggerServerEvent('jobs:burger:getServerTick', resourceRoot)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    fetchServerTick()
end)

addEventHandler('jobs:burger:serverTickResponse', resourceRoot, function(tick)
    serverTick.clientStart = getTickCount()
    serverTick.serverStart = tick
end)

function getServerTick()
    return serverTick.serverStart + (getTickCount() - serverTick.clientStart)
end