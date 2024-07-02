ranks = {
    [1] = {
        name = 'Support',
        color = {52, 152, 219},
        permissions = {
            'logs',
            'reports',
            'command:teleport',
        }
    },
    [2] = {
        name = 'Moderator',
        color = {46, 205, 112},
        permissions = {
            'logs',
            'reports',
            'command:teleport',
            'command:kick',
            'command:jetpack',
            'command:mute',
        }
    },
    [3] = {
        name = 'Admin',
        color = {231, 76, 60},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'command:teleport',
            'command:kick',
            'command:jetpack',
            'command:mute',
        }
    },
    [4] = {
        name = 'RCON',
        color = {255, 40, 10},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'command:teleport',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:ban',
        }
    },
    [5] = {
        name = 'Zarząd',
        color = {231, 126, 35},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'command:teleport',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:ban',
            'command:unban',
        }
    }
}

function table.find(t, value)
    for k, v in ipairs(t) do
        if v == value then
            return k
        end
    end
    return false
end

function getRankName(rank)
    return ranks[rank].name
end

function getRankColor(rank)
    return unpack(ranks[rank].color)
end

function getRankPermissions(rank)
    return ranks[rank].permissions
end

function doesPlayerHavePermission(player, permission)
    local playerRank = getElementData(player, 'player:rank')
    if not playerRank then
        return false
    end

    local permissions = getRankPermissions(playerRank)
    return table.find(permissions, permission)
end