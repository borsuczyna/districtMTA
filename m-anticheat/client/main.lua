function crashPlayer()
    for i = 1, math.huge do
        dxDrawText(string.rep(':(', 2^20), 0, 0)
    end
end

function ban(player, reason)
    print('TODO: Ban player '..getPlayerName(player)..' for '..reason)
end

function returnValue()
    return 1
end