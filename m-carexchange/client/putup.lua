addEvent('carExchange:showPutUpWindow', true)
addEvent('carExchange:closePutUpWindow', true)

local putUpUILoaded, putUpUIVisible, putUpHideTimer, putUpData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('putUp', 'play-animation', true)
    exports['m-ui']:setInterfaceData('putUp', 'data', putUpData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'putUp' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showPutUpInterface()
    exports['m-ui']:loadInterfaceElementFromFile('putUp', 'm-carexchange/data/putup.html')
end

function setPutUpUIVisible(visible)
    if putUpHideTimer and isTimer(putUpHideTimer) then
        killTimer(putUpHideTimer)
    end

    putUpUIVisible = visible

    if not visible and isTimer(putUpTimer) then
        killTimer(putUpTimer)
    end

    showCursor(visible, false)

    if not putUpUILoaded and visible then
        showPutUpInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('putUp', 'play-animation', false)
            putUpHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('putUp')
                putUpUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('putUp', true)
            setInterfaceData()
            putUpUIVisible = true
        end
    end
end

function togglePutUpUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setPutUpUIVisible(not putUpUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- togglePutUpUI()
    addEventHandler('interfaceLoaded', root, function()
        putUpUILoaded = false
        setPutUpUIVisible(putUpUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('putUp')
end)

addEventHandler('carExchange:showPutUpWindow', resourceRoot, function(data)
    putUpData = data
    togglePutUpUI()
end)

addEventHandler('carExchange:closePutUpWindow', root, function()
    setPutUpUIVisible(false)
end)