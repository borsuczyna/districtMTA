addEvent('jobs:burger:startJob', true)
addEvent('jobs:burger:finishJob', true)

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
end)

addEventHandler('jobs:burger:finishJob', resourceRoot, function(hash)
    showInteriorLoading(false)
end)