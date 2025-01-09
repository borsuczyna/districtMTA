local rankColors = {}

function getPlayerColor(player)
    local rank = getElementData(player, 'player:rank')

    if rank and rank > 0 then
        if rankColors[rank] then
            return rankColors[rank]
        end

        color = rgbToHex(exports['m-admins']:getRankColor(rank))
        rankColors[rank] = color

        return color
    end

    return '#cccccc'
end

function rgbToHex(r, g, b)
    return ('#%02x%02x%02x'):format(r, g, b)
end

addCommandHandler('Admin', function(player, cmd, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:admin') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local message = table.concat({...}, ' ')
    if message == '' then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie podałeś wiadomości do wysłania')
        return
    end

    message = exports['m-core']:removeHex(message)

    local admins = {}
    for i, player in ipairs(getElementsByType('player')) do
        if doesPlayerHavePermission(player, 'command:admin') then
            table.insert(admins, player)
        end
    end

    local color = getPlayerColor(player)
    local playerID = getElementData(player, 'player:id')
    local playerName = getPlayerName(player)

    local fullMessage = ('#f54545(Admin) %s(#ffffff%d%s) #dddddd%s: #eeeeee%s'):format(color, playerID, color, playerName, message)
    outputChatBox(fullMessage, admins, 255, 255, 255, true)

    exports['m-admins']:addLog('admins', fullMessage, {
        {'teleport', 'teleport-uid', playerUID}
    }) 
end)