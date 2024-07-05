local helperLoaded, helperVisible, helperTimer = false, false, false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function updateHelperData()
    
end

addEventHandler('interface:load', root, function(name)
    if name == 'helper' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('helper', 995)
        exports['m-ui']:triggerInterfaceEvent('helper', 'play-animation', true)
        exports['m-ui']:setInterfaceData('helper', 'player', {
            level = getElementData(localPlayer, 'player:level') or 1,
            exp = getElementData(localPlayer, 'player:exp'),
            expToNext = 1000,
        })
        helperLoaded = true
        updateHelperData()
    end
end)

function showHelperInterface()
    exports['m-ui']:loadInterfaceElementFromFile('helper', 'm-helper/data/interface.html')
end

function setHelperVisible(visible)
    if helperHideTimer and isTimer(helperHideTimer) then
        killTimer(helperHideTimer)
    end

    helperVisible = visible

    if not visible and isTimer(helperTimer) then
        killTimer(helperTimer)
    end

    showCursor(visible, false)

    if not helperLoaded and visible then
        showHelperInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('helper', 'play-animation', false)
            helperHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('helper')
                helperLoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('helper', true)
            exports['m-ui']:triggerInterfaceEvent('helper', 'play-animation', true)
            helperVisible = true
        end
    end
end

function toggleHelper()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setHelperVisible(not helperVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f2', 'down', toggleHelper)

    addEventHandler('interfaceLoaded', root, function()
        helperLoaded = false
        setHelperVisible(helperVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('helper')
end)

addEventHandler('onClientRender', root, function()
    toggleControl('radar', false) 
end)