local housesUILoaded, housesUIVisible, housesHideTimer, housesData = false, false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('houses', 'play-animation', true)
    exports['m-ui']:setInterfaceData('houses', 'houses', housesData)
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'houses' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showHousesInterface()
    exports['m-ui']:loadInterfaceElementFromFile('houses', 'm-houses/data/interface.html')
end

function setHousesUIVisible(visible, data)
    if housesHideTimer and isTimer(housesHideTimer) then
        killTimer(housesHideTimer)
    end

    housesUIVisible = visible
    if data then
        housesData = data
    end

    if not visible and isTimer(housesTimer) then
        killTimer(housesTimer)
    end

    showCursor(visible, false)
    guiSetInputMode(visible and 'no_binds' or 'allow_binds')

    if not housesUILoaded and visible then
        showHousesInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('houses', 'play-animation', false)
            housesHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('houses')
                housesUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('houses', true)
            setInterfaceData()
            housesUIVisible = true
        end
    end
end

function toggleHousesUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setHousesUIVisible(not housesUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleHousesUI()
    addEventHandler('interfaceLoaded', root, function()
        housesUILoaded = false
        setHousesUIVisible(housesUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('houses')
end)

guiSetInputMode('allow_binds')