local fishingUILoaded, fishingUIVisible, fishingHideTimer, fishingIcon = false, false, false, false
local sx, sy = guiGetScreenSize()

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('fishing', 'play-animation', true)
    exports['m-ui']:setInterfaceData('fishing', 'icon', fishingIcon)
end

addEventHandler('interface:load', root, function(name)
    if name == 'fishing' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showFishingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('fishing', 'm-fishing/data/interface.html')
end

function renderFishingUI()
    setCursorPosition(sx / 2, sy / 2)
end

function setFishingUIVisible(visible, icon)
    if fishingHideTimer and isTimer(fishingHideTimer) then
        killTimer(fishingHideTimer)
    end

    fishingUIVisible = visible
    fishingIcon = icon

    if not visible and isTimer(fishingTimer) then
        killTimer(fishingTimer)
    end

    showCursor(visible)
    exports['m-ui']:setCursorAlpha(visible and 0 or 255)
    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientRender', root, renderFishingUI)

    if not fishingUILoaded and visible then
        showFishingInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('fishing', 'play-animation', false)
            fishingHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('fishing')
                fishingUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('fishing', true)
            setInterfaceData()
            fishingUIVisible = true
        end
    end
end

function toggleFishingUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setFishingUIVisible(not fishingUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        fishingUILoaded = false
        setFishingUIVisible(fishingUIVisible, fishingIcon)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('fishing')
end)