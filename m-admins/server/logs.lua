function addLog(category, message, icons)
    if not category or not message then return end

    for i, player in ipairs(getElementsByType('player')) do
        if doesPlayerHavePermission(player, 'logs') then
            triggerClientEvent(player, 'logs:addLog', resourceRoot, category, message, icons)
        end
    end
end