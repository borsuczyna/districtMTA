-- local canJoin = {}
-- local valid = {}
-- local canJoinTimer = {}

-- local function restoreSerialRestriction(serial)
--     canJoin[serial] = false
-- end

-- local function reconnectPlayer(player)
--     local serial = getPlayerSerial(player)

--     redirectPlayer(player, '', 0)
--     canJoin[serial] = true
--     setElementData(player, 'redirected', true)
-- end

-- addEventHandler('onPlayerJoin', root, function()
--     local serial = getPlayerSerial(source)
--     if not canJoin[serial] then
--         reconnectPlayer(source)
--         return
--     end
-- end)

-- addEventHandler('onPlayerQuit', root, function()
--     local serial = getPlayerSerial(source)
--     if getElementData(source, 'redirected') then
--         canJoinTimer[serial] = setTimer(restoreSerialRestriction, 15000, 1, serial)
--         return
--     end

--     local serial = getPlayerSerial(source)
--     canJoin[serial] = false

--     if canJoinTimer[serial] and isTimer(canJoinTimer[serial]) then
--         killTimer(canJoinTimer[serial])
--     end
-- end)