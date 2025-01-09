addCommandHandler('admins', function(player)
    local list = {}
    local ranksData = {}
    
    for i, rank in ipairs(ranks) do
        table.insert(ranksData, {name = rank.name, rank = i, color = rgbToHex(unpack(rank.color))})
    end

    table.sort(ranksData, function(a, b) return a.rank > b.rank end)

    for _, data in pairs(ranksData) do
        local admins = getActiveAdminsWithRank(data.rank)
        if #admins > 0 then
            table.insert(list, {name = data.name, admins = admins, color = data.color})
        end
    end

    local output = ''
    for i, data in ipairs(list) do
        output = output .. ('<b style="color: %s; font-size: 0.9rem; text-shadow: 2px 2px #00000055, 0 0 0.4rem %s;"><br>%s (%d)</b><br>'):format(data.color, data.color, data.name, #data.admins)

        for i, admin in ipairs(data.admins) do
            output = output .. ('%s<br>'):format(getPlayerName(admin))
        end

        output = output .. '<br>'
    end

    if output:sub(-4) == '<br>' then
        output = output:sub(1, -5)
    end

    if output == '' then
        output = 'Brak administracji online.'
    end

    exports['m-notis']:addNotification(player, 'info', 'Administracja online', output)
end)