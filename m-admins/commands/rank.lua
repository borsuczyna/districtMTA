local ranks = {
    [0] = 'Gracz',
    [1] = 'Support',
    [2] = 'Moderator',
    [3] = 'Administrator',
    [4] = 'Administrator RCON',
    [5] = 'Zarząd'
}

function addPlayerRank(player, rank)
    local playerName = getPlayerName(player)
    local playerSerial = getPlayerSerial(player)

    if rank > 0 and ranks[rank] then
        local existingPlayer = exports['m-mysql']:query('SELECT * FROM `m-admins` WHERE `serial` = ?', playerSerial)

        if existingPlayer and #existingPlayer > 0 then
            exports['m-mysql']:query('UPDATE `m-admins` SET `rank` = ? WHERE `serial` = ?', rank, playerSerial)
        else
            exports['m-mysql']:query('INSERT INTO `m-admins` (`username`, `serial`, `rank`) VALUES (?, ?, ?)', playerName, playerSerial, rank)
        end
    elseif rank == 0 then
        exports['m-mysql']:query('DELETE FROM `m-admins` WHERE `serial` = ?', playerSerial)
    else
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawna ranga')
    end    

    if getElementData(player, 'player:rank') then
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Wylogowano ze służby administracyjnej')
        removeElementData(player, 'player:rank')

        triggerClientEvent(player, 'admin:toggleLogs', resourceRoot)
        triggerClientEvent(player, 'admin:toggleReports', resourceRoot)
    end
end

addCommandHandler('ranga', function(player, cmd, playerToFind, rank)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:rank') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not playerToFind or not rank then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /ranga (gracz) (ranga 1-5)')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local playerName = getPlayerName(player)
    local foundPlayerName = getPlayerName(foundPlayer)

    local rank = tonumber(rank)
    local message = rank == 0 and 'Usunięto' or 'Dodano'
    exports['m-notis']:addNotification(player, 'success', 'Ranga', ('%s rangę %s dla gracza %s'):format(message, ranks[rank],foundPlayerName))
    exports['m-notis']:addNotification(foundPlayer, 'success', 'Ranga', ('Twoja ranga została zmieniona na %s'):format(ranks[rank]))

    addPlayerRank(foundPlayer, rank)
end)