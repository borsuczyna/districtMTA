addEvent('intro:setIntroAsKnown')
addEvent('intro:fetchKnownIntros', true)

addEventHandler('intro:setIntroAsKnown', root, function(hash, player, id)
    if #id > 20 then return end

    local knownIntros = getElementData(player, 'player:knownIntros') or {}
    if table.includes(knownIntros, id) then return end
    table.insert(knownIntros, id)

    if #knownIntros > 100 then
        table.remove(knownIntros, 1)
    end

    setElementData(player, 'player:knownIntros', knownIntros)
end)

addEventHandler('intro:fetchKnownIntros', resourceRoot, function()
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `intro:fetchKnownIntros` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    local knownIntros = getElementData(client, 'player:knownIntros') or {}
    triggerClientEvent(client, 'intro:setKnownIntros', root, knownIntros)
end)

function table.includes(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end

    return false
end