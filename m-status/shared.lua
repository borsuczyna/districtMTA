local ranksData = {}
local jobNames = {}

local function getJobName(key)
    if jobNames[key] then
        return jobNames[key]
    end

    local job = exports['m-jobs']:getJobName(key)
    jobNames[key] = job

    return job
end

function rgbToHex(r, g, b)
    return string.format("#%02x%02x%02x", r, g, b)
end

function getPlayerStatus(player)
    local uid = getElementData(player, 'player:uid') or 0
    local rank = getElementData(player, 'player:rank') or 0
    local premium = getElementData(player, 'player:premium-end')
    local afk = getElementData(player, 'player:afk')
    local job = getElementData(player, 'player:job')
    local duty = getElementData(player, 'player:duty')

    local status = 'W grze'
    local statusColor = '#3AF36D'
    local maxPlayers = #getElementsByType('player')

    if uid == 0 then
        status = 'Loguje się'
        statusColor = '#cccccc'
    end

    if afk then
        status = 'AFK'
        statusColor = '#ff0000'
    end

    if premium then
        statusColor = '#ffcc00'
    end

    if duty then
        status = 'Służba ' .. duty
        statusColor = '#00FF00'
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

    if duty == 'SAPD' then
        statusColor = '#0099FF'
    elseif duty == 'SAFD' then
        statusColor = '#FF0000'
    elseif duty == 'SAMC' then
        statusColor = '#00FFFF'
    end

    if job then
        status = getJobName(job)
        statusColor = '#9E00FF'
        maxPlayers = #(getElementData(player, 'player:job-players') or {}) or 0
    end

    return status, statusColor, maxPlayers
end