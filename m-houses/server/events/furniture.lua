addEvent('houses:editFurnitures')
addEventHandler('houses:editFurnitures', resourceRoot, function(hash, player)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local houseUid = getElementData(player, 'player:house')
    if not houseUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Tryb edycji mebli jest dostępny tylko wewnątrz domu.'})
        return
    end

    local house = houses[houseUid]
    if not house then return end

    local canEdit = house.owner == uid
    if not canEdit then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz dostępu do edycji mebli w tym domu.'})
        return
    end

    local editing = getElementData(player, 'player:editingFurnitures')
    setPlayerFurnitureEditMode(player, not editing)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = editing and 'Zakończono tryb edycji mebli.' or 'Rozpoczęto tryb edycji mebli.'})
end)

function setPlayerFurnitureEditMode(player, state, furnitureId)
    setElementData(player, 'player:editingFurnitures', state, false)
    triggerClientEvent(player, 'houses:setFurnitureEditMode', resourceRoot, state, furnitureId)
end