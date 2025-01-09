function giveJetPack(player)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:jetpack') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not isPedInVehicle(player) then
        local jetpack = isPedWearingJetpack(player)
        if jetpack then
            setPedWearingJetpack(player, false)
            exports['m-notis']:addNotification(player, 'info', 'Jetpack', 'Usunięto jetpacka')
        else
            setPedWearingJetpack(player, true)
            exports['m-notis']:addNotification(player, 'info', 'Jetpack', 'Dodano jetpacka')
        end
    else
        exports['m-notis']:addNotification(player, 'error', 'Jetpack', 'Nie możesz używać jetpacka w pojeździe')
    end
end

addCommandHandler('jp', giveJetPack)

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        bindKey(player, 'j', 'down', 'jp')
    end
end)

addEventHandler('onPlayerJoin', root, function()
    bindKey(source, 'j', 'down', 'jp')
end)