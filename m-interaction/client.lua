addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('interaction:useOption', true)
addEvent('interaction:action-feedback', true)
addEvent('interaction:window', true)

local interactionLoaded, interactionVisible, interactionTimer = false, false, false
local openDoors = {trunks = {}, hoods = {}}
local options = {
    {
        text = function(vehicle)
            local state = openDoors.trunks[vehicle]
            if state == nil then
                state = getVehicleDoorOpenRatio(vehicle, 1) > 0
            end
            openDoors.trunks[vehicle] = state
            return state and 'Zamknij bagażnik' or 'Otwórz bagażnik'
        end,
        icon = 'trunk',
        key = 'trunk',
        serverAction = 'trunk',
    },
    {
        text = function(vehicle)
            local state = openDoors.hoods[vehicle]
            if state == nil then
                state = getVehicleDoorOpenRatio(vehicle, 0) > 0
            end
            openDoors.hoods[vehicle] = state
            return state and 'Zamknij maskę' or 'Otwórz maskę'
        end,
        icon = 'hood',
        key = 'hood',
        serverAction = 'hood',
    },
    {
        text = function(vehicle)
            local state = getVehicleEngineState(vehicle)
            return state and 'Zgaś silnik' or 'Odpal silnik'
        end,
        icon = 'engine',
        key = 'engine',
        serverAction = 'engine',
    },
    {
        text = function(vehicle)
            local state = getVehicleOverrideLights(vehicle) == 2
            return state and 'Wyłącz światła' or 'Włącz światła'
        end,
        icon = 'headlights',
        key = 'lights',
        serverAction = 'lights',
    },
    {
        text = function(vehicle)
            local seat = getPedOccupiedVehicleSeat(localPlayer)
            local state = isVehicleWindowOpen(vehicle, seatsWindows[seat])
            return state and 'Zamknij szybę' or 'Otwórz szybę'
        end,
        icon = 'window',
        key = 'window',
        action = function(vehicle)
            local seat = getPedOccupiedVehicleSeat(localPlayer)
            local open = isVehicleWindowOpen(vehicle, seatsWindows[seat])
            triggerServerEvent('interaction:action', resourceRoot, 'window', open)
        end,
        passenger = true,
    },
}

function useInteraction(key, state)
    if not state then return end

    if key == 'arrow_l' or key == 'arrow_r' or key == 'mouse_wheel_down' or key == 'mouse_wheel_up' then
        changeOption(key == 'arrow_l' or key == 'mouse_wheel_down' or key == 'a')
    elseif key == 'enter' or key == 'space' or key == 'mouse1' then
        useOption()
    end
end

function getInteractionOptions()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return {} end

    local availableOptions = {}
    local isPassenger = getVehicleOccupant(vehicle, 0) ~= localPlayer

    for i, option in ipairs(options) do
        if not isPassenger or option.passenger then 
            local text = type(option.text) == 'function' and option.text(vehicle) or option.text
            local icon = type(option.icon) == 'function' and option.icon(vehicle) or option.icon
            table.insert(availableOptions, {text, icon, option.key})
        end
    end

    return availableOptions
end

function updateInteractionData(firstLoad)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local availableOptions = getInteractionOptions()

    if firstLoad then
        setOptions(availableOptions)
    else
        for i, option in ipairs(availableOptions) do
            setOptionData(i - 1, option)
        end
    end
end

function setOptions(options)
    exports['m-ui']:setInterfaceData('interaction', 'setOptions', options)
end

function setOptionData(id, data)
    exports['m-ui']:setInterfaceData('interaction', 'setOptionData', {id = id, data = data})
end

function changeOption(next)
    exports['m-ui']:triggerInterfaceEvent('interaction', 'changeOption', next and 'next' or 'prev')
end

function useOption()
    exports['m-ui']:triggerInterfaceEvent('interaction', 'useOption')
end

addEventHandler('interaction:useOption', root, function(key)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local option = false
    for i, o in ipairs(options) do
        if o.key == key then
            option = o
            break
        end
    end

    if not option then return end

    if option.action then
        option.action(vehicle)
        updateInteractionData()
    elseif option.serverAction then
        triggerServerEvent('interaction:action', resourceRoot, option.serverAction)
    end
end)

addEventHandler('interaction:action-feedback', root, function(action)
    if action == 'hood' then
        openDoors.hoods[getPedOccupiedVehicle(localPlayer)] = not openDoors.hoods[getPedOccupiedVehicle(localPlayer)]
    elseif action == 'trunk' then
        openDoors.trunks[getPedOccupiedVehicle(localPlayer)] = not openDoors.trunks[getPedOccupiedVehicle(localPlayer)]
    end

    updateInteractionData()
end)

addEventHandler('interaction:window', root, function(vehicle, window, open)
    setVehicleWindowOpen(vehicle, window, not open)
end)

addEventHandler('interface:load', root, function(name)
    if name == 'interaction' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('interaction', 995)
        exports['m-ui']:triggerInterfaceEvent('interaction', 'play-animation', true)
        interactionLoaded = true
        updateInteractionData(true)
    end
end)

function showInteractionInterface()
    exports['m-ui']:loadInterfaceElementFromFile('interaction', 'm-interaction/data/interface.html')
end

function setInteractionVisible(visible)
    if interactionHideTimer and isTimer(interactionHideTimer) then
        killTimer(interactionHideTimer)
    end

    interactionVisible = visible

    if not visible and isTimer(interactionTimer) then
        killTimer(interactionTimer)
    end

    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientKey', root, useInteraction)
    toggleControl('chatbox', not visible)

    if not interactionLoaded and visible then
        showInteractionInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('interaction', 'play-animation', false)
            interactionHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('interaction')
                interactionLoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('interaction', true)
            exports['m-ui']:triggerInterfaceEvent('interaction', 'play-animation', true)
            interactionVisible = true
        end
    end
end

function toggleInteraction(key, state)
    if not getElementData(localPlayer, 'player:spawn') then return end
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local interactionOptions = getInteractionOptions()
    if #interactionOptions == 0 then return end

    setInteractionVisible(state == 'down')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('lshift', 'both', toggleInteraction)

    addEventHandler('interfaceLoaded', root, function()
        interactionLoaded = false
        setInteractionVisible(interactionVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('interaction')
end)

addEventHandler('onClientVehicleStartExit', root, function(player)
    if player == localPlayer then
        setInteractionVisible(false)
    end
end)

addEventHandler('onClientVehicleExit', root, function(player)
    if player == localPlayer then
        setInteractionVisible(false)
    end
end)