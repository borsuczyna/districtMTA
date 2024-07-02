local ranksData = {}

function rgbToHex(r, g, b)
    return string.format("#%02x%02x%02x", r, g, b)
end

function getPlayerStatus(player)
    local uid = getElementData(player, 'player:uid') or 0
    local rank = getElementData(player, 'player:rank') or 0

    local status = 'W grze'
    local statusColor = '#3AF36D'
    local maxPlayers = #getElementsByType('player')

    if uid == 0 then
        status = 'Loguje się'
        statusColor = '#cccccc'
    end

    if rank and rank > 0 then
        if not ranksData[rank] then
            ranksData[rank] = {
                name = exports['m-admins']:getRankName(rank),
                color = rgbToHex(exports['m-admins']:getRankColor(rank))
            }
        end

        status = status .. ' (' .. ranksData[rank].name .. ')'
        statusColor = ranksData[rank].color
    end

    return status, statusColor, maxPlayers
end