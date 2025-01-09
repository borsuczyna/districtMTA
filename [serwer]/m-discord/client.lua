local applicationID = '1256281764041854977'

function updateDiscordPresence()
    local state, color, max = exports['m-status']:getPlayerStatus(localPlayer)
    
    setDiscordRichPresenceState('Gra jako '..getPlayerName(localPlayer))
    setDiscordRichPresenceDetails(state .. ' (1 z '.. max ..')')
    setDiscordRichPresenceAsset('logo', 'districtMTA')
    setDiscordRichPresenceButton(1, 'Dołącz do gry', 'mtasa://46.105.237.84:22003')

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
    setElementData(localPlayer, 'player:discordID', getDiscordRichPresenceUserID())
    updateDiscordPresence()

    setTimer(updateDiscordPresence, 10000, 0)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    initDiscordPresence()
end)

addCommandHandler("getmyuserid",
    function ()
        if isDiscordRichPresenceConnected() then
            local id = getDiscordRichPresenceUserID() 
            if id == "" then 
                outputChatBox("You didn't allow consent to share Discord data! Grant permission in the settings!")
            else 
                outputChatBox("Your Discord userid: "..id)
            end 
        end 
    end
)