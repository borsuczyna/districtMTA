function getPlayerStatus(player)
    local uid = getElementData(player, 'player:uid') or 0

    local status = 'W grze'
    local statusColor = '#3AF36D'
    local maxPlayers = #getElementsByType('player')

    if uid == 0 then
        status = 'Loguje się'
        statusColor = '#cccccc'
    end

    return status, statusColor, maxPlayers
end