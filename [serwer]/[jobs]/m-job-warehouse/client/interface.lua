local renderTarget = false
local lastRenderTargetUpdate = 0
local fonts = {}
local courierDumping = false

local marker = createMarker(settings.jobStart + Vector3(0, 0, -1), 'cylinder', 1, 255, 140, 0, 0)
setElementDimension(marker, settings.dimension)
setElementInterior(marker, settings.interior)
setElementData(marker, 'marker:icon', 'work')
setElementData(marker, 'marker:title', 'Magazyn')
setElementData(marker, 'marker:desc', 'Rozpoczęcie pracy')

addEventHandler('onClientMarkerHit', marker, function(player, md)
    if player ~= localPlayer or not md or getPedOccupiedVehicle(player) then return end
    
    exports['m-jobs']:showJobGui('warehouse')
end)

addEventHandler('onClientMarkerLeave', marker, function(player, md)
    if player ~= localPlayer or not md then return end
    
    exports['m-jobs']:hideJobGui()
end)

addEventHandler('jobs:tryStartJob', root, function(job)
    if job ~= 'warehouse' then return end

    
end)