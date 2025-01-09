local tuningUILoaded, tuningUIVisible, tuningHideTimer = false, false, false
compatibleParts = {}

addEvent('interface:includes-finish', true)
addEvent('tuning:returnCompatibleUpgrades', true)

function setInterfaceData()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    exports['m-ui']:triggerInterfaceEvent('tuning', 'play-animation', true)
    vehicleTuningCategories = {}
    originalTuning = getVehicleOriginalUpgrades(vehicle)
    exports['m-ui']:setInterfaceData('tuning', 'tuning', vehicleTuningCategories)

    triggerServerEvent('tuning:getCompatibleUpgrades', resourceRoot)
end

addEventHandler('tuning:returnCompatibleUpgrades', resourceRoot, function(compatible)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    compatibleParts = compatible
    vehicleTuningCategories = getVehicleUpgradeCategories(vehicle, compatible)
    exports['m-ui']:setInterfaceData('tuning', 'tuning', vehicleTuningCategories)
end)

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'tuning' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showTuningInterface()
    exports['m-ui']:loadInterfaceElementFromFile('tuning', 'm-tuning/data/interface.html')
end

function setTuningUIVisible(visible)
    if tuningHideTimer and isTimer(tuningHideTimer) then
        killTimer(tuningHideTimer)
    end

    tuningUIVisible = visible

    if not visible and isTimer(tuningTimer) then
        killTimer(tuningTimer)
    end

    showCursor(visible)

    if not tuningUILoaded and visible then
        showTuningInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('tuning', 'play-animation', false)
            tuningHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('tuning')
                tuningUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('tuning', true)
            setInterfaceData()
            tuningUIVisible = true
        end
    end
end

function toggleTuningUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setTuningUIVisible(not tuningUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleTuningUI()
    addEventHandler('interfaceLoaded', root, function()
        tuningUILoaded = false
        setTuningUIVisible(tuningUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('tuning')
end)