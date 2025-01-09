local helperLoaded, helperVisible, helperTimer = false, false, false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function setUpdates()
    local updates = exports['m-updates']:getUpdates()
    exports['m-ui']:setInterfaceData('helper', 'updates', updates)
end

function updateHelperData()
    local level = getElementData(localPlayer, 'player:level') or 1
    exports['m-ui']:setInterfaceData('helper', 'player', {
        level = level,
        exp = getElementData(localPlayer, 'player:exp'),
        expToNext = exports['m-core']:getNextLevelExp(level),
    })

    setUpdates()
end

addEventHandler('interface:load', root, function(name)
    if name == 'helper' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('helper', 995)
        exports['m-ui']:triggerInterfaceEvent('helper', 'play-animation', true)
        helperLoaded = true
        updateHelperData()
    end
end)

function showHelperInterface()
    exports['m-ui']:loadInterfaceElementFromFile('helper', 'm-helper/data/interface.html')
end

function setHelperVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('helper')

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

function controllerButtonPressed(button)
    if (button == 9 and not helperVisible) or (button == 2 and helperVisible) then
        toggleHelper()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f1', 'down', toggleHelper)
    addEventHandler('controller:buttonPressed', root, controllerButtonPressed)

    addEventHandler('interfaceLoaded', root, function()
        helperLoaded = false
        setHelperVisible(helperVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('helper')
end)