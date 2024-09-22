addEvent('animpanel:playAnimation', true)

local animPanelUILoaded, animPanelUIVisible, animPanelHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('animpanel', 'play-animation', true)
    exports['m-ui']:setInterfaceData('animpanel', 'anims', anims)
end

addEventHandler('interface:load', root, function(name)
    if name == 'animpanel' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showAnimPanelInterface()
    exports['m-ui']:loadInterfaceElementFromFile('animpanel', 'm-animpanel/data/interface.html')
end

function setAnimPanelUIVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('animpanel')

    if animPanelHideTimer and isTimer(animPanelHideTimer) then
        killTimer(animPanelHideTimer)
    end

    animPanelUIVisible = visible

    if not visible and isTimer(animPanelTimer) then
        killTimer(animPanelTimer)
    end

    showCursor(visible, false)

    if not animPanelUILoaded and visible then
        showAnimPanelInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('animpanel', 'play-animation', false)
            animPanelHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('animpanel')
                animPanelUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('animpanel', true)
            setInterfaceData()
            animPanelUIVisible = true
        end
    end
end

function toggleAnimPanelUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setAnimPanelUIVisible(not animPanelUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f2', 'down', toggleAnimPanelUI)
    addEventHandler('interfaceLoaded', root, function()
        animPanelUILoaded = false
        setAnimPanelUIVisible(animPanelUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('animpanel')
end)

addEventHandler('animpanel:playAnimation', root, function(category, index)
    triggerServerEvent('animpanel:playAnimation', resourceRoot, category, index)
end)