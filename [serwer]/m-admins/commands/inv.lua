addCommandHandler('inv', function(player)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:inv') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local alpha = (getElementAlpha(player) == 255) and 0 or 255
    setElementAlpha(player, alpha)
    setElementData(player, 'player:inv', (getElementAlpha(player) == 255 and false or true))

    triggerClientEvent(root, 'inv:elementCollision', resourceRoot, player, alpha == 0)

    local message = (alpha == 0) and 'niewidzialny' or 'widzialny'
    exports['m-notis']:addNotification(player, 'success', 'Niewidzialność', ('Jesteś teraz %s'):format(message))
end)