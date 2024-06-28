local f11Loaded, f11Visible, f11Timer = false, false, false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function updateF11Data()
    local data = {}
    local blips = getElementsByType('blip')

    for i, blip in ipairs(blips) do
        local x, y = getElementPosition(blip)
        local icon = getBlipIcon(blip)

        table.insert(data, {
            x = x,
            y = y,
            icon = icon,
        })
    end

    exports['m-ui']:setInterfaceData('f11', 'blips', data)
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
        updateF11Data()
        f11Timer = setTimer(updateF11Data, 350, 0)
    end
end)

function showF11Interface()
    exports['m-ui']:loadInterfaceElementFromFile('f11', 'm-f11/data/interface.html')
end

function setF11Text(text)
    f11Data.text = text
    updateF11Data()
end

function setF11Progress(progress, time)
    f11Data.progress = progress
    f11Data.time = time or 0
    updateF11Data()
end

function setF11Visible(visible)
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