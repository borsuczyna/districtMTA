addEvent('vehicle-shop:show', true)
addEvent('vehicle-shop:close', true)

local vehicleShopsUILoaded, vehicleShopsUIVisible, vehicleShopsHideTimer, vehicleShopsData = false, false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('vehicle-shops', 'play-animation', true)
    exports['m-ui']:setInterfaceData('vehicle-shops', 'shopData', vehicleShopsData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'vehicle-shops' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showVehicleShopsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('vehicle-shops', 'm-vehicle-shops/data/interface.html')
end

function setVehicleShopsUIVisible(visible)
    if vehicleShopsHideTimer and isTimer(vehicleShopsHideTimer) then
        killTimer(vehicleShopsHideTimer)
    end

    vehicleShopsUIVisible = visible

    if not visible and isTimer(vehicleShopsTimer) then
        killTimer(vehicleShopsTimer)
    end

    showCursor(visible, false)

    if not vehicleShopsUILoaded and visible then
        showVehicleShopsInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('vehicle-shops', 'play-animation', false)
            vehicleShopsHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('vehicle-shops')
                vehicleShopsUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('vehicle-shops', true)
            setInterfaceData()
            vehicleShopsUIVisible = true
        end
    end
end

function toggleVehicleShopsUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setVehicleShopsUIVisible(not vehicleShopsUIVisible)
end

addEventHandler('vehicle-shop:show', resourceRoot, function(data)
    setVehicleShopsUIVisible(true)
    vehicleShopsData = data
end)

addEventHandler('vehicle-shop:close', root, function()
    setVehicleShopsUIVisible(false)
    vehicleShopsData = false
end)

addEventHandler('onClientColShapeLeave', root, function(element, matchingDimension)
    if element ~= localPlayer or not matchingDimension then return end
    if not getElementData(source, 'vehicle:shop-vehicle') then return end

    setVehicleShopsUIVisible(false)
    vehicleShopsData = false
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        vehicleShopsUILoaded = false
        setVehicleShopsUIVisible(vehicleShopsUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('vehicle-shops')
end)