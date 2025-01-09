local scoreboardLoaded, scoreboardVisible, scoreboardTimer = false, false, false
local statuses = {}

function getPlayerStatus(player)
    if statuses[player] and statuses[player].time > getTickCount() then
        return statuses[player].status, statuses[player].statusColor
    end

    local status, statusColor = exports['m-status']:getPlayerStatus(player)
    statuses[player] = {status = status, statusColor = statusColor, time = getTickCount() + 5000}

    return status, statusColor
end

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

function toggleMouse(button, down)
    if button ~= 'mouse2' or not down then return end
    showCursor(not isCursorShowing(), false)
    toggleControl('chatbox', not isCursorShowing())
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
        local level = getElementData(player, 'player:level') or 0
        local status, statusColor = getPlayerStatus(player)
        local rank = getElementData(player, 'player:rank') or false
        local duty = getElementData(player, 'player:duty') or false

        table.insert(data, {
            uid = uid,
            id = id,
            name = name,
            ping = ping,
            organization = organization,
            status = status,
            statusColor = statusColor,
            level = level,
            category = rank and 'administration' or duty and 'duty' or 'players',
            me = player == localPlayer
        })
    end

    exports['m-ui']:setInterfaceData('scoreboard', 'players', data)
end

function updateAvatar(player, avatar)
    if not scoreboardLoaded or not scoreboardVisible then return end
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

addEventHandler('avatars:onPlayerAvatarChange', root, function(uid, avatar)
    if not scoreboardLoaded or not scoreboardVisible then return end

    if type(uid) == 'number' then
        local player = exports['m-core']:getPlayerByUid(uid)
        if not player then return end
        updateAvatar(player, avatar)
    else
        updateAvatar(uid, avatar)
    end
end)

addEventHandler('interface:load', root, function(name)
    if name == 'scoreboard' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('scoreboard', 990)
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

function setScoreboardVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('scoreboard')

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
        toggleControl('chatbox', true)
    end

    if not scoreboardLoaded and visible then
        showScoreboardInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('scoreboard', 'play-animation', false)
            scoreboardHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('scoreboard')
                scoreboardLoaded = false
            end, 300, 1)
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

function controllerButtonPressed(button)
    if (button == 15 and not scoreboardVisible and not isCursorShowing()) or (button == 2 and scoreboardVisible) then
        toggleScoreboard()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('tab', 'down', toggleScoreboard)
    addEventHandler('controller:buttonPressed', root, controllerButtonPressed)

    addEventHandler('interfaceLoaded', root, function()
        scoreboardLoaded = false
        setScoreboardVisible(scoreboardVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('scoreboard')
end)