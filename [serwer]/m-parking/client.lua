addEvent('parking:hideInterface', true)

local parkingUILoaded, parkingUIVisible, parkingHideTimer = false, false, false
local parkingId = false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('parking', 'play-animation', true)
    exports['m-ui']:setInterfaceData('parking', 'parkingId', parkingId)
end

addEventHandler('interface:load', root, function(name)
    if name == 'parking' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showParkingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('parking', 'm-parking/data/interface.html')
end

function setParkingUIVisible(visible)
    
    if parkingHideTimer and isTimer(parkingHideTimer) then
        killTimer(parkingHideTimer)
    end

    parkingUIVisible = visible

    if not visible and isTimer(parkingTimer) then
        killTimer(parkingTimer)
    end

    showCursor(visible, false)

    if not parkingUILoaded and visible then
        showParkingInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('parking', 'play-animation', false)
            parkingHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('parking')
                parkingUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('parking', true)
            setInterfaceData()
            parkingUIVisible = true
        end
    end
end

function toggleParkingUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setParkingUIVisible(not parkingUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        parkingUILoaded = false
        setParkingUIVisible(parkingUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('parking')
end)

addEventHandler('onClientMarkerHit', resourceRoot, function(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    parkingId = getElementData(source, 'parking:take')
    if not parkingId then return end

    setParkingUIVisible(true)
end)

addEventHandler('onClientMarkerLeave', resourceRoot, function(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    local parkingId = getElementData(source, 'parking:take')
    if not parkingId then return end

    setParkingUIVisible(false)
end)

addEventHandler('parking:hideInterface', resourceRoot, function()
    setParkingUIVisible(false)
end)