local applicationID = '1256281764041854977'
local isLoaded = false

function showDiscordPresence()
    local id = getElementData(localPlayer, 'player:id') or 0

    setDiscordRichPresenceAsset('logo', 'districtMTA')
    setDiscordRichPresenceSmallAsset('user', 'ID: '..id)
    setDiscordRichPresenceDetails('Loguje się')
end 

function loadDiscordPresence()
    local isEnabled = isDiscordRichPresenceConnected()
    if not isEnabled then return end

    isLoaded = setDiscordApplicationID(applicationID)
    showDiscordPresence()
end

function setDiscordPresenceDetails(details)
    if not isLoaded then return end
    setDiscordRichPresenceDetails(details)
end

function setDiscordPresenceState(state)
    if not isLoaded then return end
    setDiscordRichPresenceState(state)
end

addEventHandler('onClientResourceStart', root, function()
    loadDiscordPresence()
end)