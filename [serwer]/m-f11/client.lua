local f11Loaded, f11Visible, f11Timer = false, false, false
local lastBlips = {}
local lastAreas = {}

function table.find(t, callback)
    for k,v in pairs(t) do
        if callback(v) then
            return k
        end
    end
    return false
end

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function getBlipHoverText(blip)
    -- if is attached to player, return player name
    if getElementType(blip) == 'blip' then
        local attachedTo = getElementAttachedTo(blip)
        if attachedTo and getElementType(attachedTo) == 'player' then
            return getPlayerName(attachedTo)
        end
    end

    return getElementData(blip, 'blip:hoverText')
end

function updateF11Data()
    -- blips
    local data = {}
    local deleteBlips = {}
    local blips = getElementsByType('blip')
    local myInterior = getElementInterior(localPlayer)
    local thisInteriorBlips = {}

    for i, blip in ipairs(blips) do
        local attachedTo = getElementAttachedTo(blip)
        local interior = getElementInterior(attachedTo or blip)
        local blipID = getBlipIcon(blip)

        if interior == myInterior then
            table.insert(thisInteriorBlips, blip)
        end
    end

    for i, blip in ipairs(thisInteriorBlips) do
        local blipId = tostring(blip)
        local x, y = getElementPosition(blip)
        local icon = getBlipIcon(blip)
        local lastSendData = lastBlips[blipId]
        local hoverTooltip = getBlipHoverText(blip)

        if not lastSendData or lastSendData.x ~= x or lastSendData.y ~= y or lastSendData.icon ~= icon or lastSendData.hoverTooltip ~= hoverTooltip then
            table.insert(data, {
                x = x,
                y = y,
                icon = icon,
                id = blipId,
                hoverTooltip = hoverTooltip,
            })

            lastBlips[blipId] = {
                x = x,
                y = y,
                icon = icon,
                hoverTooltip = hoverTooltip,
            }
        end
    end

    for blipId in pairs(lastBlips) do
        local found = table.find(blips, function(v)
            local id = tostring(v)
            return id == blipId
        end)

        if not found then
            table.insert(deleteBlips, blipId)
        end
    end

    for i, blipId in ipairs(deleteBlips) do
        lastBlips[blipId] = nil
    end

    -- areas
    local areasData = {}
    local deleteAreas = {}
    local areas = getElementsByType('radararea')
    local myInterior = getElementInterior(localPlayer)
    local thisInteriorAreas = {}

    for i, area in ipairs(areas) do
        local interior = getElementInterior(area)
        if interior == myInterior then
            table.insert(thisInteriorAreas, area)
        end
    end

    for i, area in ipairs(thisInteriorAreas) do
        local areaId = tostring(area)
        local x, y = getElementPosition(area)
        local width, height = getRadarAreaSize(area)
        local lastSendData = lastAreas[areaId]
        local hoverTooltip = getElementData(area, 'area:hoverText')
        local className = getElementData(area, 'area:className')
        local color = { getRadarAreaColor(area) }
        color[4] = color[4] / 255

        if not lastSendData or lastSendData.x ~= x or
            lastSendData.y ~= y or
            lastSendData.width ~= width or
            lastSendData.height ~= height or
            toJSON(lastSendData.color) ~= toJSON(color) or
            lastSendData.hoverTooltip ~= hoverTooltip or
            lastSendData.className ~= className
        then
            table.insert(areasData, {
                x = x,
                y = y+height,
                width = width,
                height = height,
                color = color,
                id = areaId,
                hoverTooltip = hoverTooltip,
                className = className,
            })

            lastAreas[areaId] = {
                x = x,
                y = y,
                width = width,
                height = height,
                color = color,
                hoverTooltip = hoverTooltip,
                className = className,
            }
        end
    end

    for areaId in pairs(lastAreas) do
        local found = table.find(areas, function(v)
            local id = tostring(v)
            return id == areaId
        end)

        if not found then
            table.insert(deleteAreas, areaId)
        end
    end

    for i, areaId in ipairs(deleteAreas) do
        lastAreas[areaId] = nil
    end

    if #areasData > 0 then
        exports['m-ui']:setInterfaceData('f11', 'updateAreas', areasData)
    end
    if #deleteAreas > 0 then
        exports['m-ui']:setInterfaceData('f11', 'deleteAreas', deleteAreas)
    end

    if #data > 0 then
        exports['m-ui']:setInterfaceData('f11', 'updateBlips', data)
    end
    if #deleteBlips > 0 then
        exports['m-ui']:setInterfaceData('f11', 'deleteBlips', deleteBlips)
    end

    local x, y = getElementPosition(localPlayer)
    local _, _, rz = getElementRotation(localPlayer)
    exports['m-ui']:setInterfaceData('f11', 'playerPosition', {
        x = x,
        y = y,
        rot = rz,
    })
end

addEventHandler('onPlayerQuit', root, function()
    local uid = getElementData(source, 'player:uid') or 0
end)

addEventHandler('interface:load', root, function(name)
    if name == 'f11' then
        local x, y = getElementPosition(localPlayer)
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('f11', 998)
        exports['m-ui']:triggerInterfaceEvent('f11', 'play-animation', true)
        exports['m-ui']:setInterfaceData('f11', 'position', { x = x, y = y })
        f11Loaded = true
        lastBlips = {}
        lastAreas = {}
        updateF11Data()
        f11Timer = setTimer(updateF11Data, 10, 0)
    end
end)

function showF11Interface()
    exports['m-ui']:loadInterfaceElementFromFile('f11', 'm-f11/data/interface.html')
end

function setF11Visible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('f11')

    if f11HideTimer and isTimer(f11HideTimer) then
        killTimer(f11HideTimer)
    end

    f11Visible = visible

    if not visible and isTimer(f11Timer) then
        killTimer(f11Timer)
    end

    showCursor(visible, false)
    showChat(not visible)

    if not f11Loaded and visible then
        showF11Interface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('f11', 'play-animation', false)
            f11HideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('f11')
                f11Loaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('f11', true)
            exports['m-ui']:triggerInterfaceEvent('f11', 'play-animation', true)
            f11Visible = true
        end
    end
end

function toggleF11()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setF11Visible(not f11Visible)
end

function controllerButtonPressed(button)
    if (button == 18) or (button == 2 and f11Visible) then
        toggleF11()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f11', 'down', toggleF11)
    addEventHandler('controller:buttonPressed', root, controllerButtonPressed)

    addEventHandler('interfaceLoaded', root, function()
        f11Loaded = false
        setF11Visible(f11Visible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('f11')
end)

addEventHandler('onClientRender', root, function()
    toggleControl('radar', false) 
end)