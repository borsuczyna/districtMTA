ranks = {
    [1] = {
        name = 'Support',
        color = {52, 152, 219},
        permissions = {
            'logs',
            'reports',
            'dryer',
            'teleports',
            'command:jetpack',
            'command:teleport',
            'command:license',
            'command:spec',
            'command:warn',
            'command:fix',
            'command:heal',
            'command:admin',
            'command:dim',
            'command:int',
        }
    },
    [2] = {
        name = 'Moderator',
        color = {46, 205, 112},
        permissions = {
            'logs',
            'reports',
            'dryer',
            'teleports',
            'command:clearchat',
            'command:teleport',
            'command:license',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:inv',
            'command:spec',
            'command:warn',
            'command:fix',
            'command:heal',
            'command:admin',
            'command:dim',
            'command:int',
        }
    },
    [3] = {
        name = 'Admin',
        color = {231, 76, 60},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'dryer',
            'teleports',
            'command:clearchat',
            'command:teleport',
            'command:license',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:inv',
            'command:spec',
            'command:warn',
            'command:cv',
            'command:fix',
            'command:heal',
            'command:admin',
            'command:dim',
            'command:int',
        }
    },
    [4] = {
        name = 'RCON',
        color = {255, 40, 10},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'dryer',
            'teleports',
            'command:clearchat',
            'command:teleport',
            'command:license',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:ban',
            'command:inv',
            'command:spec',
            'command:warn',
            'command:cv',
            'command:fix',
            'command:heal',
            'command:admin',
            'command:dim',
            'command:int',
        }
    },
    [5] = {
        name = 'Zarząd',
        color = {231, 126, 35},
        permissions = {
            'logs',
            'reports',
            'noclip',
            'dryer',
            'teleports',
            'command:clearchat',
            'command:dev',
            'command:teleport',
            'command:license',
            'command:kick',
            'command:jetpack',
            'command:mute',
            'command:ban',
            'command:unban',
            'command:inv',
            'command:spec',
            'command:warn',
            'command:cv',
            'command:cv.bypass',
            'command:rank',
            'command:fix',
            'command:heal',
            'command:admin',
            'command:dim',
            'command:int',
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

function rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
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

function htmlEscape(s)
    return s:gsub('[<>&"]', function(c)
        return c == '<' and '&lt;' or c == '>' and '&gt;' or c == '&' and '&amp;' or '&quot;'
    end)
end

function isPedAiming (thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end