addEvent('jobs:courier:packagePickup', true)
addEvent('jobs:courier:packageDrop', true)

local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local zoom = 1

local lastRequest = 0
local holdingPackage = false

addEvent('jobs:courier:cartLeave', true)
addEventHandler('jobs:courier:cartLeave', resourceRoot, function(objectHash)
    local object = exports['m-jobs']:getObjectByHash(objectHash)
    if not object then return end

    local x, y, z = getElementPosition(object)
    local rx, ry, rz = getElementRotation(object)
    
    triggerServerEvent('jobs:courier:cartLeave', resourceRoot, x, y, z, rx, ry, rz)
end)

local function updatePackageMarks()
    local packages = exports['m-jobs']:getAllLobbyObjectsWithCustomData('package')
    local px, py, pz = getElementPosition(localPlayer)

    for _, package in ipairs(packages) do
        local x, y, z = getElementPosition(package.element)
        local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
        if distance < 3 then
            local sx, sy = getScreenFromWorldPosition(x, y, z)

            if sx and sy then
                local x, y, w, h = sx - 45/zoom, sy - 45/zoom, 90/zoom, 90/zoom
                local over = isMouseInPosition(x, y, w, h)

                if (package.customData.state == 0 or package.customData.state == 2) and not holdingPackage then
                    dxDrawImage(x, y, w, h, 'data/box.png', 0, 0, 0, over and 0xFFFFFFFF or 0xAAFFFFFF)
                end
            end
        end
    end
end

local function updatePackageClick()
    if getTickCount() - lastRequest < 500 then
        exports['m-notis']:addNotification('error', 'Kurier', 'Odczekaj chwilę przed kolejnym zapytaniem')
        return
    end

    local packages = exports['m-jobs']:getAllLobbyObjectsWithCustomData('package')
    local px, py, pz = getElementPosition(localPlayer)

    for _, package in ipairs(packages) do
        local x, y, z = getElementPosition(package.element)
        local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
        if distance < 3 then
            local sx, sy = getScreenFromWorldPosition(x, y, z)

            if sx and sy then
                local x, y, w, h = sx - 45/zoom, sy - 45/zoom, 90/zoom, 90/zoom
                local over = isMouseInPosition(x, y, w, h)
                if over then
                    if (package.customData.state == 0 or package.customData.state == 2) and not holdingPackage then
                        triggerServerEvent('jobs:courier:packagePickup', resourceRoot, package.hash)
                        lastRequest = getTickCount()
                        return
                    end
                end
            end
        end
    end
end

addEventHandler('onClientRender', root, function()
    if getElementData(localPlayer, 'player:job') ~= 'courier' then return end
    if isPedInVehicle(localPlayer) then return end

    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    zoom = zoomOriginal * (25 / interfaceSize)

    updatePackageMarks()
end, true, 'high+999')

addEventHandler('onClientClick', root, function(button, state)
    if button ~= 'left' or state ~= 'down' then return end
    if getElementData(localPlayer, 'player:job') ~= 'courier' then return end

    updatePackageClick()
end)

addEventHandler('jobs:courier:packagePickup', resourceRoot, function(packageHash)
    holdingPackage = packageHash
end)

addEventHandler('jobs:courier:packageDrop', resourceRoot, function()
    holdingPackage = false
end)