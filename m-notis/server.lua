function addNotification(player, type, title, message, time)
    triggerClientEvent(player, 'notis:addNotification', resourceRoot, type, title, message, time)
end