addEvent('factions:useShelf')

local factionsShelfs = {}

local function onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getElementData(source, 'marker:shelf-faction')
    if not faction or not player then return end

    local playerFaction = getElementData(player, 'player:duty')
    if playerFaction ~= faction then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie jesteś na służbie tej frakcji.')
    end

    if not doesPlayerHaveAnyFactionPermission(player, faction, {'shelf', 'manageFaction'}) then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie posiadasz uprawnień do otwarcia tej szafki.')
    end

    triggerClientEvent(player, 'factions:openShelfPanel', resourceRoot, {
        faction = faction,
        items = getElementData(source, 'marker:shelf-items')
    })
end

local function onMarkerLeave(leaveElement, matchingDimension)
    if not matchingDimension or getElementType(leaveElement) ~= 'player' then return end
    local player = leaveElement

    triggerClientEvent(player, 'factions:closeShelf', resourceRoot)
end

function createShelfMarker(faction, position, data)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 255, 255, 0, 150)
    setElementData(marker, 'marker:shelf-faction', faction)
    setElementData(marker, 'marker:shelf-items', data)
    setElementData(marker, 'marker:title', faction)
    setElementData(marker, 'marker:desc', 'Szafka')
    addDestroyOnRestartElement(marker, sourceResource)

    addEventHandler('onMarkerHit', marker, onMarkerHit)
    addEventHandler('onMarkerLeave', marker, onMarkerLeave)
    factionsShelfs[faction] = data
end

addEventHandler('factions:useShelf', root, function(hash, player, faction, category, index)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local items = factionsShelfs[faction]
    if not items then return end

    local category = items[tonumber(category) + 1]
    if not category then return end

    local item = category.items[tonumber(index) + 1]
    if not item then return end

    local playerDuty = getElementData(player, 'player:duty')
    if playerDuty ~= faction then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś na służbie tej frakcji.'})
        return
    end

    if not doesPlayerHaveAnyFactionPermission(player, faction, item.permissions) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz uprawnień do wzięcia tego zestawu.'})
        return
    end

    if item.skin then
        if item.skin == 'default' then
            setElementModel(player, getElementData(player, 'player:skin'))
        else
            setElementModel(player, item.skin)
        end
    end
    if item.weapon then
        giveWeapon(player, item.weapon, item.ammo or 0, true)
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zestaw został pobrany.'})
end)