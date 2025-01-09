addEvent('factions:openVirtualParkingPanel', true)
addEvent('factions:closeVirtualParkingPanel', true)

local virtualParkingUILoaded, virtualParkingUIVisible, virtualParkingHideTimer, virtualParkingData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('virtual-parking', 'play-animation', true)
    exports['m-ui']:setInterfaceData('virtual-parking', 'data', virtualParkingData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'virtual-parking' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showVirtualParkingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('virtual-parking', 'm-factions/data/virtual-parking.html')
end

function setVirtualParkingUIVisible(visible)
    if virtualParkingHideTimer and isTimer(virtualParkingHideTimer) then
        killTimer(virtualParkingHideTimer)
    end

    virtualParkingUIVisible = visible

    if not visible and isTimer(virtualParkingTimer) then
        killTimer(virtualParkingTimer)
    end

    showCursor(visible, false)

    if not virtualParkingUILoaded and visible then
        showVirtualParkingInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('virtual-parking', 'play-animation', false)
            virtualParkingHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('virtual-parking')
                virtualParkingUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('virtual-parking', true)
            setInterfaceData()
            virtualParkingUIVisible = true
        end
    end
end

function toggleVirtualParkingUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setVirtualParkingUIVisible(not virtualParkingUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleVirtualParkingUI()
    addEventHandler('interfaceLoaded', root, function()
        virtualParkingUILoaded = false
        setVirtualParkingUIVisible(virtualParkingUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('virtual-parking')
end)

addEventHandler('factions:openVirtualParkingPanel', resourceRoot, function(data)
    virtualParkingData = data
    toggleVirtualParkingUI()
end)

addEventHandler('factions:closeVirtualParkingPanel', root, function()
    setVirtualParkingUIVisible(false)
end)