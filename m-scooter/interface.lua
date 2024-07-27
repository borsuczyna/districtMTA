local scooterUILoaded, scooterUIVisible, scooterHideTimer = false, false, false

function setInterfaceData()
    local renting = getElementData(localPlayer, 'scooter:rented')
    exports['m-ui']:triggerInterfaceEvent('scooter', 'play-animation', true)
    exports['m-ui']:setInterfaceData('scooter', 'renting', not not renting)
end

addEventHandler('interface:load', root, function(name)
    if name == 'scooter' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showScooterInterface()
    exports['m-ui']:loadInterfaceElementFromFile('scooter', 'm-scooter/data/interface.html')
end

function setScooterUIVisible(visible)
    if scooterHideTimer and isTimer(scooterHideTimer) then
        killTimer(scooterHideTimer)
    end

    scooterUIVisible = visible

    if not visible and isTimer(scooterTimer) then
        killTimer(scooterTimer)
    end

    showCursor(visible, false)

    if not scooterUILoaded and visible then
        showScooterInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('scooter', 'play-animation', false)
            scooterHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('scooter')
                scooterUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('scooter', true)
            setInterfaceData()
            scooterUIVisible = true
        end
    end
end

function toggleScooterUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setScooterUIVisible(not scooterUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        scooterUILoaded = false
        setScooterUIVisible(scooterUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('scooter')
end)