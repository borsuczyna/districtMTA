local bwUILoaded, bwUIVisible, bwHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('bw', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'bw' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showBWInterface()
    exports['m-ui']:loadInterfaceElementFromFile('bw', 'm-bw/data/interface.html')
end

function setBWUIVisible(visible)
    if bwHideTimer and isTimer(bwHideTimer) then
        killTimer(bwHideTimer)
    end

    bwUIVisible = visible

    if not visible and isTimer(bwTimer) then
        killTimer(bwTimer)
    end

    if not bwUILoaded and visible then
        showBWInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('bw', 'play-animation', false)
            bwHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('bw')
                bwUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('bw', true)
            setInterfaceData()
            bwUIVisible = true
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        bwUILoaded = false
        setBWUIVisible(bwUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('bw')
end)