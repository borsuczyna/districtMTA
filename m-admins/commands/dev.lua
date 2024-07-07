addCommandHandler('alldata', function(player)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:dev') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local data = getAllElementData(player)
    for k, v in pairs(data) do
        outputConsole(k..': '..tostring(v), player)
    end
end)