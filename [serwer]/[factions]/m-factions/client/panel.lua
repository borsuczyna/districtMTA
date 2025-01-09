addEvent('factions:openManagePanel', true)
addEvent('factions:closeManagePanel', true)
addEvent('interface:includes-finish', true)

local factionPanelUILoaded, factionPanelUIVisible, factionPanelHideTimer, factionData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('faction-panel', 'play-animation', true)
    exports['m-ui']:setInterfaceData('faction-panel', 'faction', factionData)
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'faction-panel' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showFactionPanelInterface()
    exports['m-ui']:loadInterfaceElementFromFile('faction-panel', 'm-factions/data/interface.html')
end

function setFactionPanelUIVisible(visible)
    if factionPanelHideTimer and isTimer(factionPanelHideTimer) then
        killTimer(factionPanelHideTimer)
    end

    factionPanelUIVisible = visible

    if not visible and isTimer(factionPanelTimer) then
        killTimer(factionPanelTimer)
    end

    showCursor(visible, false)

    if not factionPanelUILoaded and visible then
        showFactionPanelInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('faction-panel', 'play-animation', false)
            factionPanelHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('faction-panel')
                factionPanelUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('faction-panel', true)
            setInterfaceData()
            factionPanelUIVisible = true
        end
    end
end

function toggleFactionPanelUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setFactionPanelUIVisible(not factionPanelUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleFactionPanelUI()
    addEventHandler('interfaceLoaded', root, function()
        factionPanelUILoaded = false
        setFactionPanelUIVisible(factionPanelUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('faction-panel')
end)

addEventHandler('factions:openManagePanel', resourceRoot, function(data)
    factionData = data
    toggleFactionPanelUI()
end)

addEventHandler('factions:closeManagePanel', root, function()
    setFactionPanelUIVisible(false)
end)