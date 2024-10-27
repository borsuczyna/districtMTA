local function onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getElementData(source, 'marker:duty-faction')
    if not faction or not player then return end

    if not doesPlayerHaveAnyFactionPermission(player, faction, {'duty', 'manageFaction'}) then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie posiadasz uprawnień do wejścia na służbę.')
    end

    local duty = getElementData(player, 'player:duty')
    
    if duty then
        removeElementData(player, 'player:duty')
        exports['m-notis']:addNotification(player, 'info', ('Frakcja %s'):format(faction), 'Zszedłeś ze służby.')
        takeAllWeapons(player)
        setElementModel(player, getElementData(player, 'player:skin'))
    else
        setElementData(player, 'player:duty', faction)
        exports['m-notis']:addNotification(player, 'info', ('Frakcja %s'):format(faction), 'Wszedłeś na służbę.')
    end
end

function createDutyMarker(faction, position)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 0, 255, 0, 150)
    setElementData(marker, 'marker:duty-faction', faction)
    setElementData(marker, 'marker:title', faction)
    setElementData(marker, 'marker:desc', 'Wejście na służbę')
    addDestroyOnRestartElement(marker, sourceResource)

    addEventHandler('onMarkerHit', marker, onMarkerHit)
end