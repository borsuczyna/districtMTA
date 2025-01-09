local atmUILoaded, atmUIVisible, atmHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('atm', 'play-animation', true)
    exports['m-ui']:setInterfaceData('atm', 'balance', getElementData(localPlayer, 'player:bankMoney'))
end

addEventHandler('interface:load', root, function(name)
    if name == 'atm' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showAtmInterface()
    exports['m-ui']:loadInterfaceElementFromFile('atm', 'm-atm/data/interface.html')
end

function setAtmUIVisible(visible)
    if atmHideTimer and isTimer(atmHideTimer) then
        killTimer(atmHideTimer)
    end

    atmUIVisible = visible

    if not visible and isTimer(atmTimer) then
        killTimer(atmTimer)
    end

    showCursor(visible, false)

    if not atmUILoaded and visible then
        showAtmInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('atm', 'play-animation', false)
            atmHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('atm')
                atmUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('atm', true)
            setInterfaceData()
            atmUIVisible = true
        end
    end
end

function toggleAtmUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setAtmUIVisible(not atmUIVisible)
end

function onAtmHit(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    setAtmUIVisible(true)
end

function onAtmLeave(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    setAtmUIVisible(false)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        atmUILoaded = false
        setAtmUIVisible(atmUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('atm')
end)