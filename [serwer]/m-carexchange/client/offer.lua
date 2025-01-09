addEvent('carExchange:showCarExchangeOfferWindow', true)
addEvent('carExchange:closeCarExchangeOfferWindow', true)

local carExchangeOfferUILoaded, carExchangeOfferUIVisible, carExchangeOfferHideTimer, carExchangeOfferData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('carExchangeOffer', 'play-animation', true)
    exports['m-ui']:setInterfaceData('carExchangeOffer', 'data', carExchangeOfferData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'carExchangeOffer' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showCarExchangeOfferInterface()
    exports['m-ui']:loadInterfaceElementFromFile('carExchangeOffer', 'm-carexchange/data/offer.html')
end

function setCarExchangeOfferUIVisible(visible)
    if carExchangeOfferHideTimer and isTimer(carExchangeOfferHideTimer) then
        killTimer(carExchangeOfferHideTimer)
    end

    carExchangeOfferUIVisible = visible

    if not visible and isTimer(carExchangeOfferTimer) then
        killTimer(carExchangeOfferTimer)
    end

    showCursor(visible, false)

    if not carExchangeOfferUILoaded and visible then
        showCarExchangeOfferInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('carExchangeOffer', 'play-animation', false)
            carExchangeOfferHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('carExchangeOffer')
                carExchangeOfferUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('carExchangeOffer', true)
            setInterfaceData()
            carExchangeOfferUIVisible = true
        end
    end
end

function toggleCarExchangeOfferUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setCarExchangeOfferUIVisible(not carExchangeOfferUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleCarExchangeOfferUI()
    addEventHandler('interfaceLoaded', root, function()
        carExchangeOfferUILoaded = false
        setCarExchangeOfferUIVisible(carExchangeOfferUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('carExchangeOffer')
end)

addEventHandler('carExchange:showCarExchangeOfferWindow', resourceRoot, function(data)
    carExchangeOfferData = data
    toggleCarExchangeOfferUI()
end)

addEventHandler('carExchange:closeCarExchangeOfferWindow', root, function()
    setCarExchangeOfferUIVisible(false)
end)

local function onMarkerHit(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    if not getElementData(localPlayer, 'player:spawn') then return end
    if isPedInVehicle(localPlayer) then return end

    toggleCarExchangeOfferUI()
end

local function onMarkerLeave(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    if not getElementData(localPlayer, 'player:spawn') then return end

    setCarExchangeOfferUIVisible(false)
end

local function createCarExchangeMarker(position)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 0, 255, 0, 150)
    setElementData(marker, 'marker:title', 'Giełda')
    setElementData(marker, 'marker:desc', 'Sprzedaż pojazdów')

    addEventHandler('onClientMarkerHit', marker, onMarkerHit)
    addEventHandler('onClientMarkerLeave', marker, onMarkerLeave)
end

createCarExchangeMarker({1446.212, -1617.934, 13.539})