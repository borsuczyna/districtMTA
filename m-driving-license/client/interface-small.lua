local smallInfoUILoaded, smallInfoUIVisible, smallInfoHideTimer = false, false, false
local smallInfoText = ''

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('driving-license-small', 'play-animation', true)
    exports['m-ui']:setInterfaceData('driving-license-small', 'text', smallInfoText)
end

addEventHandler('interface:load', root, function(name)
    if name == 'driving-license-small' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showSmallInfoInterface()
    exports['m-ui']:loadInterfaceElementFromFile('driving-license-small', 'm-driving-license/data/interface-small.html')
end

function setSmallInfoUIVisible(visible)
    if smallInfoHideTimer and isTimer(smallInfoHideTimer) then
        killTimer(smallInfoHideTimer)
    end

    smallInfoUIVisible = visible

    if not visible and isTimer(smallInfoTimer) then
        killTimer(smallInfoTimer)
    end

    if not smallInfoUILoaded and visible then
        showSmallInfoInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('driving-license-small', 'play-animation', false)
            smallInfoHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('driving-license-small')
                smallInfoUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('driving-license-small', true)
            setInterfaceData()
            smallInfoUIVisible = true
        end
    end
end

function toggleSmallInfoUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setSmallInfoUIVisible(not smallInfoUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        smallInfoUILoaded = false
        setSmallInfoUIVisible(smallInfoUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('driving-license-small')
end)

addEventHandler('smallInfo:finish', root, function()
    setSmallInfoUIVisible(false)
end)

function setSmallText(text)
    smallInfoText = text

    if not smallInfoUIVisible then
        toggleSmallInfoUI()
    else
        exports['m-ui']:setInterfaceData('driving-license-small', 'text', text)
    end
end