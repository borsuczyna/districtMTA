local scoreboardLoaded, scoreboardVisible, scoreboardTimer = false, false, false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function toggleMouse(button, down)
    if button ~= 'mouse2' or not down then return end
    showCursor(not isCursorShowing(), false)
end

function updateScoreboardData()
    local data = {}
    local players = getElementsByType('player')

    for i, player in ipairs(players) do
        local uid = getElementData(player, 'player:uid') or 0
        local id = getElementData(player, 'player:id') or 0
        local name = getPlayerName(player)
        local ping = getPlayerPing(player)
        local organization = getElementData(player, 'player:organization') or ''
        local status = getElementData(player, 'player:status') or 'W grze'
        local level = getElementData(player, 'player:level') or 0

        table.insert(data, {
            uid = uid,
            id = id,
            name = name,
            ping = ping,
            organization = organization,
            status = status,
            level = level,
            category = 'players',
            me = player == localPlayer
        })
    end

    exports['m-ui']:setInterfaceData('scoreboard', 'players', data)
end

function updateAvatar(player, avatar)
    local uid = getElementData(player, 'player:uid') or 0
    exports['m-ui']:executeJavascript(string.format('scoreboard_setAvatar(%d, %q)', uid, avatar or ''))
end

addEventHandler('onPlayerQuit', root, function()
    local uid = getElementData(source, 'player:uid') or 0
    exports['m-ui']:executeJavascript(string.format('scoreboard_removeAvatar(%d)', uid))
end)

function updateAllAvatars()
    local players = getElementsByType('player')
    
    for i, player in ipairs(players) do
        local avatar = exports['m-avatars']:getPlayerAvatar(player)
        updateAvatar(player, avatar)
    end
end

addEventHandler('avatars:onPlayerAvatarChange', root, function(player, avatar)
    updateAvatar(player, avatar)
end)

addEventHandler('interface:load', root, function(name)
    if name == 'scoreboard' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('scoreboard', 998)
        exports['m-ui']:triggerInterfaceEvent('scoreboard', 'play-animation', true)
        scoreboardLoaded = true
        updateScoreboardData()
        updateAllAvatars()
        scoreboardTimer = setTimer(updateScoreboardData, 1000, 0)
    end
end)

function showScoreboardInterface()
    exports['m-ui']:loadInterfaceElementFromFile('scoreboard', 'm-scoreboard/data/interface.html')
end

function setScoreboardText(text)
    scoreboardData.text = text
    updateScoreboardData()
end

function setScoreboardProgress(progress, time)
    scoreboardData.progress = progress
    scoreboardData.time = time or 0
    updateScoreboardData()
end

function setScoreboardVisible(visible)
    if scoreboardHideTimer and isTimer(scoreboardHideTimer) then
        killTimer(scoreboardHideTimer)
    end

    scoreboardVisible = visible

    if not visible and isTimer(scoreboardTimer) then
        killTimer(scoreboardTimer)
    end

    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientKey', root, toggleMouse)
    if not visible then
        showCursor(false)
    end

    if not scoreboardLoaded and visible then
        showScoreboardInterface()
    else
        if not visible then
            -- exports['m-ui']:destroyInterfaceElement('scoreboard')
            -- scoreboardLoaded = false
            exports['m-ui']:triggerInterfaceEvent('scoreboard', 'play-animation', false)
            scoreboardHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('scoreboard')
                scoreboardLoaded = false
            end, 500, 1)
        else
            exports['m-ui']:setInterfaceVisible('scoreboard', true)
            exports['m-ui']:triggerInterfaceEvent('scoreboard', 'play-animation', true)
            scoreboardVisible = true
        end
    end
end

function toggleScoreboard()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setScoreboardVisible(not scoreboardVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('tab', 'down', toggleScoreboard)

    addEventHandler('interfaceLoaded', root, function()
        scoreboardLoaded = false
        setScoreboardVisible(scoreboardVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('scoreboard')
end)