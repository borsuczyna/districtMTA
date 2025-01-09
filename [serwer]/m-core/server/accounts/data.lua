addEvent('login:onPlayerLogin')

local function startsWith(str, start)
    return str:sub(1, #start) == start
end

local function assignPlayerInventory(player, data)
    local inventory = fromJSON(data)
    local itemsToEquip = {}

    -- unequip all items
    for i, item in ipairs(inventory) do
        -- if item.metadata and item.metadata.equipped then
        --     item.metadata.equipped = false
        -- end

        if item.metadata and item.metadata.equipped then
            item.metadata.equipped = false

            if not startsWith(item.item, 'fishingRod') then
                table.insert(itemsToEquip, item.hash)
            end
        end
    end

    setElementData(player, 'player:inventory', inventory, false)
    
    for i, item in ipairs(itemsToEquip) do
        exports['m-inventory']:useItem(player, item)
    end
end

function getPlayerTicketsCount(result, player)
    if not result then return end

    local data = dbPoll(result, 0)
    if not data then return end

    setElementData(player, 'player:tickets', data[1].count)
    setPlayerWantedLevel(player, math.min(data[1].count, 6))
end

function assignPlayerData(player, data)
    local settings = fromJSON(data.settings)
    
    setElementData(player, 'player:logged', true)
    setElementData(player, 'player:uid', data.uid)
    setElementData(player, 'player:skin', data.skin)
    setElementData(player, 'player:level', data.level)
    setElementData(player, 'player:exp', data.exp)
    setElementData(player, 'player:premium-end', data.premiumEnd)
    setElementData(player, 'player:time', data.time)
    setElementData(player, 'player:session', 0)
    setElementData(player, 'player:afkTime', data.afkTime)
    setElementData(player, 'player:dutyTime', data.dutyTime)
    setElementData(player, 'player:payDutyTime', data.payDutyTime)
    setElementData(player, 'player:dailyRewardDay', data.dailyRewardDay)
    setElementData(player, 'player:dailyRewardRedeem', data.dailyRewardRedeemDate)
    setElementData(player, 'player:loadMission', data.mission)
    setElementData(player, 'player:avatar', data.avatar)
    setElementData(player, 'player:collectibles', fromJSON(data.collectibles))
    setElementData(player, 'player:licenses', split(data.licenses, ','))
    setElementData(player, 'player:knownIntros', split(data.knownIntros, ','), false)
    setElementData(player, 'player:seasonPass:bought', data.seasonPassBought == 1)
    setElementData(player, 'player:seasonPass', fromJSON(data.seasonPassData))
    setElementData(player, 'player:boughtCars', tonumber(data.boughtCars) or 0)
    setElementData(player, 'player:catchedFishes', tonumber(data.catchedFishes) or 0)
    setElementData(player, 'player:lastActive', data.lastActiveUnix)
    triggerClientEvent(player, 'intro:setKnownIntros', root, split(data.knownIntros, ','))
    assignPlayerInventory(player, data.inventory)

    -- check if difference between now and dailyRewardRedeem is less than 24 hours, if so show notification that streak is lost
    local diff = getRealTime().timestamp - data.dailyRewardRedeemDate
    if diff > 86400 then
        setElementData(player, 'player:dailyRewardDay', 1)
        exports['m-notis']:addNotification(player, 'error', 'Dzienne nagrody', 'Straciłeś swoją serię dziennych nagród')
        exports['m-mysql']:execute('UPDATE `m-users` SET dailyRewardDay = 1 WHERE uid = ?', data.uid)
    end

    -- settings
    local settings = fromJSON(data.settings)

    setElementData(player, 'player:interfaceBlur', settings.interfaceBlur or 0.4)
    triggerClientEvent(player, 'interface:setInterfaceBlur', root, settings.interfaceBlur)

    setElementData(player, 'player:interfaceSize', settings.interfaceSize or 14)
    triggerClientEvent(player, 'interface:setRemSize', root, settings.interfaceSize)
    
    -- setElementData(player, 'player:controllerMode', settings.controllerMode or false)
    -- triggerClientEvent(player, 'interface:setControllerMode', root, settings.controllerMode)

    setPlayerName(player, data.username)
    setElementModel(player, data.skin)
    setPlayerMoney(player, data.money)
    setElementData(player, 'player:bankMoney', data.bankMoney or 0)
    
    updatePlayerMute(player)
    updatePlayerLicense(player)

    updatePlayerAchievements(player)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'UPDATE `m-users` SET lastActive = NOW() WHERE uid = ?', data.uid)
    dbQuery(getPlayerTicketsCount, { player }, connection, 'SELECT COUNT(*) as count FROM `m-sapd-tickets` WHERE `user` = ? AND `active` = 1', data.uid)

    triggerEvent('login:onPlayerLogin', root, player)
end

function buildSavePlayerQuery(player)
    local uid = getElementData(player, 'player:uid')

    local skin = getElementData(player, 'player:skin')
    local money = getPlayerMoney(player)
    local bankMoney = getElementData(player, 'player:bankMoney')
    local time = getElementData(player, 'player:time')
    local afkTime = getElementData(player, 'player:afkTime')
    local dutyTime = getElementData(player, 'player:dutyTime')
    local payDutyTime = getElementData(player, 'player:payDutyTime')
    local inventory = getElementData(player, 'player:inventory') or {}
    local collectibles = getElementData(player, 'player:collectibles') or {}
    local licenses = table.concat(getElementData(player, 'player:licenses') or {}, ',')
    local knownIntros = table.concat(getElementData(player, 'player:knownIntros') or {}, ',')
    local seasonPassBought = getElementData(player, 'player:seasonPass:bought') or false
    local seasonPassData = getElementData(player, 'player:seasonPass') or {}
    local boughtCars = getElementData(player, 'player:boughtCars') or 0
    local catchedFishes = getElementData(player, 'player:catchedFishes') or 0
    local mission = exports['m-missions']:getPlayerMission(player) or getElementData(player, 'player:loadMission')
    local settings = {
        interfaceBlur = getElementData(player, 'player:interfaceBlur') or 0,
        interfaceSize = getElementData(player, 'player:interfaceSize') or 8,
        -- controllerMode = getElementData(player, 'player:controllerMode') or false
    }

    local saveData = {
        skin = skin,
        money = money,
        bankMoney = bankMoney,
        level = getElementData(player, 'player:level'),
        exp = getElementData(player, 'player:exp'),
        time = time,
        afkTime = afkTime,
        dutyTime = dutyTime,
        payDutyTime = payDutyTime,
        settings = toJSON(settings),
        inventory = toJSON(inventory),
        collectibles = toJSON(collectibles),
        licenses = licenses,
        knownIntros = knownIntros,
        seasonPassBought = seasonPassBought and 1 or 0,
        seasonPassData = toJSON(seasonPassData),
        boughtCars = boughtCars,
        catchedFishes = catchedFishes,
        mission = mission,
    }

    local query = 'UPDATE `m-users` SET ' .. table.concat(mapk(saveData, function(value, key)
        return '`' .. key .. '` = ?'
    end), ', ') .. ' WHERE `uid` = ?'
    local values = mapk(saveData, function(value)
        return value
    end)
    table.insert(values, uid)

    return query, values, uid
end

function updatePlayerMoney(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local money = getPlayerMoney(player)
    local bankMoney = getElementData(player, 'player:bankMoney')

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'UPDATE `m-users` SET money = ?, bankMoney = ? WHERE uid = ?', money, bankMoney, uid)
end

function givePlayerBankMoney(uid, amount, log, logDesc)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'UPDATE `m-users` SET bankMoney = bankMoney + ? WHERE uid = ?', amount, uid)

    if log then
        addMoneyLogByUid(uid, log, logDesc, amount)
    end
end

function savePlayerData(player, noLogs)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query, values, uid = buildSavePlayerQuery(player)
    dbExec(connection, query, unpack(values))
end

function saveAllPlayers()
    local startTime = getTickCount()
    for i, player in ipairs(getElementsByType('player')) do
        savePlayerData(player, true)
    end

    exports['m-logs']:sendLog('accounts', 'info', 'Zapisano dane wszystkich graczy (' .. getTickCount() - startTime .. 'ms)')
end

addEventHandler('onPlayerQuit', root, function()
    savePlayerData(source)
    updatePlayerDailyTaskProgress(source)

    exports['m-core']:addUserLog(source, 'ACCOUNT', 'Wylogowano z konta', ('Serial: ||%s||\nIP: ||%s||'):format(getPlayerSerial(source), getPlayerIP(source)))
end)

setTimer(saveAllPlayers, 300000, 0) -- 5 minutes