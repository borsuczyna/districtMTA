addEvent('factions:openShelfPanel', true)
addEvent('factions:closeShelf', true)

local shelfUILoaded, shelfUIVisible, shelfHideTimer, shelfData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('shelf', 'play-animation', true)
    exports['m-ui']:setInterfaceData('shelf', 'items', shelfData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'shelf' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showShelfInterface()
    exports['m-ui']:loadInterfaceElementFromFile('shelf', 'm-factions/data/shelf.html')
end

function setShelfUIVisible(visible)
    if shelfHideTimer and isTimer(shelfHideTimer) then
        killTimer(shelfHideTimer)
    end

    shelfUIVisible = visible

    if not visible and isTimer(shelfTimer) then
        killTimer(shelfTimer)
    end

    showCursor(visible, false)

    if not shelfUILoaded and visible then
        showShelfInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('shelf', 'play-animation', false)
            shelfHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('shelf')
                shelfUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('shelf', true)
            setInterfaceData()
            shelfUIVisible = true
        end
    end
end

function toggleShelfUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setShelfUIVisible(not shelfUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleShelfUI()
    addEventHandler('interfaceLoaded', root, function()
        shelfUILoaded = false
        setShelfUIVisible(shelfUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('shelf')
end)

addEventHandler('factions:openShelfPanel', resourceRoot, function(data)
    shelfData = data
    toggleShelfUI()
end)

addEventHandler('factions:closeShelf', root, function()
    setShelfUIVisible(false)
end)