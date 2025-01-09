addEvent('onClientVariableDump', true)

local boilerplateUILoaded, boilerplateUIVisible, boilerplateHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('boilerplate', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'boilerplate' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showBoilerplateInterface()
    exports['m-ui']:loadInterfaceElementFromFile('boilerplate', 'm-boilerplate/data/interface.html')
end

function setBoilerplateUIVisible(visible)
    if boilerplateHideTimer and isTimer(boilerplateHideTimer) then
        killTimer(boilerplateHideTimer)
    end

    boilerplateUIVisible = visible

    if not visible and isTimer(boilerplateTimer) then
        killTimer(boilerplateTimer)
    end

    -- showCursor(visible, false)

    if not boilerplateUILoaded and visible then
        showBoilerplateInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('boilerplate', 'play-animation', false)
            boilerplateHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('boilerplate')
                boilerplateUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('boilerplate', true)
            setInterfaceData()
            boilerplateUIVisible = true
        end
    end
end

function toggleBoilerplateUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setBoilerplateUIVisible(not boilerplateUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    toggleBoilerplateUI()
    addEventHandler('interfaceLoaded', root, function()
        boilerplateUILoaded = false
        setBoilerplateUIVisible(boilerplateUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('boilerplate')
end)

addCommandHandler('debugme', function()
    exports['m-ui']:triggerInterfaceEvent('boilerplate', 'dump-variables')
end)

addEventHandler('onClientVariableDump', root, function(variables)
    setClipboard(variables)
    outputChatBox('Zmienne zostały zapisane do schowka.')
end)