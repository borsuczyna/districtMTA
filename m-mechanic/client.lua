if getPlayerName(localPlayer) ~= 'borsuczyna' then return end
local mechanicUILoaded, mechanicUIVisible, mechanicHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('mechanic', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'mechanic' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showMechanicInterface()
    exports['m-ui']:loadInterfaceElementFromFile('mechanic', 'm-mechanic/data/interface.html')
end

function setMechanicUIVisible(visible)
    if mechanicHideTimer and isTimer(mechanicHideTimer) then
        killTimer(mechanicHideTimer)
    end

    mechanicUIVisible = visible

    if not visible and isTimer(mechanicTimer) then
        killTimer(mechanicTimer)
    end

    showCursor(visible, false)

    if not mechanicUILoaded and visible then
        showMechanicInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('mechanic', 'play-animation', false)
            mechanicHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('mechanic')
                mechanicUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('mechanic', true)
            setInterfaceData()
            mechanicUIVisible = true
        end
    end
end

function toggleMechanicUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setMechanicUIVisible(not mechanicUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    toggleMechanicUI()
    addEventHandler('interfaceLoaded', root, function()
        mechanicUILoaded = false
        setMechanicUIVisible(mechanicUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('mechanic')
end)