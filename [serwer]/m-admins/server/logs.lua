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
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `logs:requestLogsList` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not doesPlayerHavePermission(client, 'logs') then return end
    
    triggerClientEvent(client, 'logs:addLogs', resourceRoot, logs)
end)