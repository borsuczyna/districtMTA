addEvent('tablet:hide', true)
addEvent('tablet:open', true)

local tabletUILoaded, tabletUIVisible, tabletHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('tablet', 'play-animation', true)
    exports['m-ui']:setInterfaceData('tablet', 'data', {
        uid = getElementData(localPlayer, 'player:uid'),
        nickname = getPlayerName(localPlayer),
    })
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'tablet' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showTabletInterface()
    exports['m-ui']:loadInterfaceElementFromFile('tablet', 'm-faction-sapd/data/tablet.html')
end

function setTabletUIVisible(visible)
    if tabletHideTimer and isTimer(tabletHideTimer) then
        killTimer(tabletHideTimer)
    end

    tabletUIVisible = visible

    if not visible and isTimer(tabletTimer) then
        killTimer(tabletTimer)
    end

    showCursor(visible, false)

    if not tabletUILoaded and visible then
        showTabletInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('tablet', 'play-animation', false)
            tabletHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('tablet')
                tabletUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('tablet', true)
            setInterfaceData()
            tabletUIVisible = true
        end
    end
end

function toggleTabletUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setTabletUIVisible(not tabletUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleTabletUI()
    addEventHandler('interfaceLoaded', root, function()
        tabletUILoaded = false
        setTabletUIVisible(tabletUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('tablet')
end)

addEventHandler('tablet:hide', root, function()
    setTabletUIVisible(false)
end)

addEventHandler('tablet:open', root, function()
    setTabletUIVisible(true)
end)