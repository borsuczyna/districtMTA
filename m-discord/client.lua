local applicationID = '1256281764041854977'

function updateDiscordPresence()
    local state, color, max = exports['m-status']:getPlayerStatus(localPlayer)
    
    setDiscordRichPresenceState('Gra jako '..getPlayerName(localPlayer))
    setDiscordRichPresenceDetails(state .. ' (1 z '.. max ..')')
    setDiscordRichPresenceAsset('logo', 'districtMTA')
    
    if max == #getElementsByType('player') then
        setDiscordRichPresencePartySize(0, 0)
    else
        setDiscordRichPresencePartySize(1, #getElementsByType('player'))
    end
end

function initDiscordPresence()
    local isEnabled = isDiscordRichPresenceConnected()
    if not isEnabled then return end

    setDiscordApplicationID(applicationID)
    updateDiscordPresence()
    setTimer(updateDiscordPresence, 10000, 0)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    initDiscordPresence()
end)