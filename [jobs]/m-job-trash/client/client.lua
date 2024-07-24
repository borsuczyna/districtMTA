local renderTarget = false
local lastRenderTargetUpdate = 0
local fonts = {}

local marker = createMarker(settings.jobStart + Vector3(0, 0, -1), 'cylinder', 1, 255, 140, 0, 0)
setElementData(marker, 'marker:icon', 'work')
setElementData(marker, 'marker:title', 'Wywóz śmieci')
setElementData(marker, 'marker:desc', 'Rozpoczęcie pracy')

addEventHandler('onClientMarkerHit', marker, function(player, md)
    if player ~= localPlayer or not md or getPedOccupiedVehicle(player) then return end
    
    exports['m-jobs']:showJobGui('trash')
end)

addEventHandler('onClientMarkerLeave', marker, function(player, md)
    if player ~= localPlayer or not md then return end
    
    exports['m-jobs']:hideJobGui()
end)

function updateRenderTarget()
    if not fonts or not fonts[1] then
        fonts = {
            exports['m-ui']:getFont('Inter-Bold', 25),
            exports['m-ui']:getFont('Inter-Medium', 20)
        }
    end

    if not renderTarget then
        renderTarget = dxCreateRenderTarget(430, 100, true)
    end

    local dumpLevel = exports['m-jobs']:getJobData('trashLevel') or 0

    dxSetRenderTarget(renderTarget, true)
    dxDrawText('Wywóz śmieci', 0, 0, 430, 50, tocolor(255, 255, 255), 1, fonts[1], 'center', 'bottom')
    dxDrawText(('Zapełnienie: %.2fkg'):format(dumpLevel), 0, 50, 430, 50, tocolor(255, 255, 255), 1, fonts[2], 'center', 'top')
    dxSetRenderTarget()
end

addEventHandler('onClientPreRender', root, function()
    if getElementData(localPlayer, 'player:job') ~= 'trash' then return end

    local jobVehicle = getElementData(localPlayer, 'player:jobVehicle')
    if not jobVehicle or not isElement(jobVehicle) then return end

    local x, y, z = getPositionFromElementOffset(jobVehicle, 0, -4, 0)
    local lx, ly, lz = getPositionFromElementOffset(jobVehicle, 0, -5, 0)

    if not renderTarget or getTickCount() - lastRenderTargetUpdate > 1000 then
        updateRenderTarget()
        lastRenderTargetUpdate = getTickCount()
    end

    dxDrawMaterialLine3D(x, y, z + 0.25, x, y, z - 0.25, renderTarget, 0.5 * (430 / 100), tocolor(255, 255, 255), lx, ly, lz)
end)