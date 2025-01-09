local cache = {}

addCommandHandler('spec', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:spec') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local foundPlayerName = getPlayerName(foundPlayer)
    exports['m-notis']:addNotification(player, 'success', 'Obserwowanie', ('Obserwujesz gracza %s'):format(foundPlayerName))

    cache[player] = {

        pos = {getElementPosition(player)},

    }

    setCameraTarget(player, foundPlayer)
    attachElements(player, foundPlayer, 0, 0, 10)
end)

addCommandHandler('specoff', function(player)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:spec') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local target = getCameraTarget(player)
    if target ~= player then
        setCameraTarget(player, player)
        detachElements(player, target)
    else
        local x, y, z = unpack(cache[player].pos)
        setElementPosition(player, x, y, z)
        setCameraTarget(player, player)
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie obserwujesz nikogo')
        return
    end

    exports['m-notis']:addNotification(player, 'success', 'Obserwowanie', 'Wyłączono obserwację gracza')
end)
