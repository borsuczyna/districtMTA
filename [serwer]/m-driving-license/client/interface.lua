addEvent('drivingLicense:finish')
addEvent('drivingLicense:goToQuestions')
local drivingLicenseUILoaded, drivingLicenseUIVisible, drivingLicenseHideTimer, insideQuestions = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('driving-license', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'driving-license' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

local function showDrivingLicenseInterface()
    exports['m-ui']:loadInterfaceElementFromFile('driving-license', 'm-driving-license/data/interface.html')
end

function setDrivingLicenseUIVisible(visible, force)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    if not visible and insideQuestions and not force then return end
    exports['m-ui']:addSingleInterface('driving-license')
    insideQuestions = false

    if drivingLicenseHideTimer and isTimer(drivingLicenseHideTimer) then
        killTimer(drivingLicenseHideTimer)
    end

    drivingLicenseUIVisible = visible

    if not visible and isTimer(drivingLicenseTimer) then
        killTimer(drivingLicenseTimer)
    end

    showCursor(visible, false)

    if not drivingLicenseUILoaded and visible then
        showDrivingLicenseInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('driving-license', 'play-animation', false)
            drivingLicenseHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('driving-license')
                drivingLicenseUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('driving-license', true)
            setInterfaceData()
            drivingLicenseUIVisible = true
        end
    end
end

function toggleDrivingLicenseUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setDrivingLicenseUIVisible(not drivingLicenseUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        drivingLicenseUILoaded = false
        setDrivingLicenseUIVisible(drivingLicenseUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('driving-license')
end)

addEventHandler('drivingLicense:finish', root, function()
    setDrivingLicenseUIVisible(false, true)
end)

addEventHandler('drivingLicense:goToQuestions', root, function(value)
    insideQuestions = value == '1'
end)