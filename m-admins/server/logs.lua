addEvent('logs:requestLogsList', true)

local logs = {}

function addLog(category, message, icons)
    if not category or not message then return end

    table.insert(logs, {
        category = category,
        message = message,
        icons = icons,
    })

    while #logs > 100 do
        table.remove(logs, 1)
    end

    local admins = {}
    for i, player in ipairs(getElementsByType('player')) do
        if doesPlayerHavePermission(player, 'logs') then
            table.insert(admins, player)
        end
    end

    triggerClientEvent(admins, 'logs:addLog', resourceRoot, category, message, icons)
end

addEventHandler('logs:requestLogsList', resourceRoot, function()
    if not doesPlayerHavePermission(client, 'logs') then return end
    
    triggerClientEvent(client, 'logs:addLogs', resourceRoot, logs)
end)