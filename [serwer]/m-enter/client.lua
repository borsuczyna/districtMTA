local enterUILoaded, enterUIVisible, enterHideTimer = false, false, false
local enterData = false
local entering = false

function setInterfaceData()
    local renting = getElementData(localPlayer, 'enter:rented')
    exports['m-ui']:triggerInterfaceEvent('enter', 'play-animation', true)
    exports['m-ui']:setInterfaceData('enter', 'enterData', enterData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'enter' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showEnterInterface()
    exports['m-ui']:loadInterfaceElementFromFile('enter', 'm-enter/data/interface.html')
end

function setEnterUIVisible(visible)
    if enterHideTimer and isTimer(enterHideTimer) then
        killTimer(enterHideTimer)
    end

    enterUIVisible = visible

    if not visible and isTimer(enterTimer) then
        killTimer(enterTimer)
    end

    if not enterUILoaded and visible then
        showEnterInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('enter', 'play-animation', false)
            enterHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('enter')
                enterUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('enter', true)
            setInterfaceData()
            enterUIVisible = true
        end
    end
end

function toggleEnterUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setEnterUIVisible(not enterUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        enterUILoaded = false
        setEnterUIVisible(enterUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('enter')
end)

addEventHandler('onClientMarkerHit', resourceRoot, function(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension or getPedOccupiedVehicle(localPlayer) then return end
    if getElementInterior(source) ~= getElementInterior(localPlayer) then return end

    local enterId = getElementData(source, 'marker:enter')
    if not enterId then return end

    setEnterUIVisible(true)

    enterData = {
        id = enterId,
        name = getElementData(source, 'marker:desc'),
        description = getElementData(source, 'marker:longDesc'),
        target = getElementData(source, 'marker:target'),
    }

    bindKey('Q', 'down', enterInterior)
end)

addEventHandler('onClientMarkerLeave', resourceRoot, function(leaveElement, matchingDimension)
    if leaveElement ~= localPlayer or not matchingDimension then return end
    local enterId = getElementData(source, 'marker:enter')
    if not enterId then return end

    setEnterUIVisible(false)
    unbindKey('Q', 'down', enterInterior)
end)

function enterInterior()
    if not enterData or entering then return end

    if enginePreloadWorldArea then -- since 1.6.0 r22678
        local x, y, z = unpack(enterData.target)
        enginePreloadWorldArea(x, y, z, 'all')
    end

    entering = true
    exports['m-loading']:setLoadingVisible(true, getElementInterior(localPlayer) == 0 and 'Ładowanie interioru...' or 'Ładowanie...', 1000)
    setElementFrozen(localPlayer, true)

    setTimer(triggerServerEvent, 1000, 1, 'enter:interior', resourceRoot, enterData.id)
    setTimer(function()
        setElementFrozen(localPlayer, false)
        entering = false
    end, 2000, 1)
end