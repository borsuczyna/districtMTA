local stationsUILoaded, stationsUIVisible, stationsHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('stations', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'stations' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showStationsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('stations', 'm-stations/data/interface.html')
end

function setStationsUIVisible(visible)
    if stationsHideTimer and isTimer(stationsHideTimer) then
        killTimer(stationsHideTimer)
    end

    stationsUIVisible = visible

    if not visible and isTimer(stationsTimer) then
        killTimer(stationsTimer)
    end

    showCursor(visible, false)

    if not stationsUILoaded and visible then
        showStationsInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('stations', 'play-animation', false)
            stationsHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('stations')
                stationsUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('stations', true)
            setInterfaceData()
            stationsUIVisible = true
        end
    end
end

function toggleStationsUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setStationsUIVisible(not stationsUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    toggleStationsUI()
    addEventHandler('interfaceLoaded', root, function()
        stationsUILoaded = false
        setStationsUIVisible(stationsUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('stations')
end)