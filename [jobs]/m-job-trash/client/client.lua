local renderTarget = false
local lastRenderTargetUpdate = 0
local fonts = {}
local trashDumping = false

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

local function updateDumpingObject()
    local object = exports['m-jobs']:getJobDataAsObject('trashDumping')
    if not object then
        trashDumping = false
        return
    end

    local jobVehicle = getElementData(localPlayer, 'player:jobVehicle')
    if not jobVehicle or not isElement(jobVehicle) then return end

    if not trashDumping then
        trashDumping = getTickCount()
    end

    local progress = (getTickCount() - trashDumping) / 1400
    if progress >= 1.2 then
        progress = 1 - (progress - 1.2)
    end

    progress = math.max(math.min(getEasingValue(progress, 'OutBack'), 1), 0)

    local x, y, z = getPositionFromElementOffset(jobVehicle, 0, -4 + progress * 0.5, progress)
    local rx, ry, rz = getVehicleRotation(jobVehicle)
    setElementCollisionsEnabled(object.element, false)
    setElementPosition(object.element, x, y, z)
    setElementRotation(object.element, rx + 130 * progress, ry, rz + 180)
end

local function updateJobVehicle()
    local jobVehicle = getElementData(localPlayer, 'player:jobVehicle')
    if not jobVehicle or not isElement(jobVehicle) then return end

    local x, y, z = getPositionFromElementOffset(jobVehicle, 0, -4, 0)
    local lx, ly, lz = getPositionFromElementOffset(jobVehicle, 0, -5, 0)

    if not renderTarget or getTickCount() - lastRenderTargetUpdate > 1000 then
        updateRenderTarget()
        lastRenderTargetUpdate = getTickCount()
    end

    dxDrawMaterialLine3D(x, y, z + 0.25, x, y, z - 0.25, renderTarget, 0.5 * (430 / 100), tocolor(255, 255, 255), lx, ly, lz)
end

addEventHandler('onClientPreRender', root, function()
    if getElementData(localPlayer, 'player:job') ~= 'trash' then return end

    updateDumpingObject()
    updateJobVehicle()
end)

addEventHandler('jobs:tryStartJob', root, function(job)
    if job ~= 'trash' then return end

    if not exports['m-core']:doesPlayerHaveLicense(localPlayer, 'C') then
        exports['m-notis']:addNotification('error', 'Praca', 'Nie posiadasz prawa jazdy kategorii C.')
        cancelEvent()
    end
end)