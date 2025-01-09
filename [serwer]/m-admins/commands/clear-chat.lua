addCommandHandler('cc', function(player, cmd, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:clearchat') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end
    
    for i = 1, 1500 do
        outputChatBox(' ')
    end

    local color = getPlayerColor(player)
    local playerID = getElementData(player, 'player:id')
    local playerName = getPlayerName(player)

    local fullMessage = ('#ddddddCzat został wyczyszczony przez %s(#ffffff%d%s) #dddddd%s'):format(color, playerID, color, playerName)
    outputChatBox(fullMessage, root, 255, 255, 255, true)
end)