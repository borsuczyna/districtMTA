addEvent('tickets:close', true)

local ticketsUILoaded, ticketsUIVisible, ticketsHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('tickets', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'tickets' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showTicketsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('tickets', 'm-office/data/tickets.html')
end

function setTicketsUIVisible(visible)
    if ticketsHideTimer and isTimer(ticketsHideTimer) then
        killTimer(ticketsHideTimer)
    end

    ticketsUIVisible = visible

    if not visible and isTimer(ticketsTimer) then
        killTimer(ticketsTimer)
    end

    showCursor(visible, false)

    if not ticketsUILoaded and visible then
        showTicketsInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('tickets', 'play-animation', false)
            ticketsHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('tickets')
                ticketsUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('tickets', true)
            setInterfaceData()
            ticketsUIVisible = true
        end
    end
end

function toggleTicketsUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setTicketsUIVisible(not ticketsUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleTicketsUI()
    addEventHandler('interfaceLoaded', root, function()
        ticketsUILoaded = false
        setTicketsUIVisible(ticketsUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('tickets')
end)

addEventHandler('tickets:close', root, function()
    setTicketsUIVisible(false)
end)

local function onMarkerHit(hitPlayer, matchingDimension)
    if hitPlayer ~= localPlayer or not matchingDimension then return end
    if not getElementData(hitPlayer, 'player:spawn') then return end

    toggleTicketsUI()
end

local function onMarkerLeave(hitPlayer, matchingDimension)
    if hitPlayer ~= localPlayer or not matchingDimension then return end
    if not getElementData(hitPlayer, 'player:spawn') then return end

    setTicketsUIVisible(false)
end

local function createPayTicketMarker(position)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 0, 100, 255, 150)
    setElementData(marker, 'marker:title', 'Mandaty')
    setElementData(marker, 'marker:desc', 'Spłacanie madatów')

    addEventHandler('onClientMarkerHit', marker, onMarkerHit)
    addEventHandler('onClientMarkerLeave', marker, onMarkerLeave)
end

createPayTicketMarker({1478.905, -1804.565, 18.734})