local f11Loaded, f11Visible, f11Timer = false, false, false
local lastBlips = {}

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
    local data = {}
    local deleteBlips = {}
    local blips = getElementsByType('blip')

    for i, blip in ipairs(blips) do
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

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f11', 'down', toggleF11)

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