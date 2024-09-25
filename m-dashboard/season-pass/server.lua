addEvent('dashboard:fetchSeasonPassData')
addEvent('dashboard:redeemSeasonItem')
addEvent('payment:onPaymentCreated')
addEvent('payment:onPaymentFinished')

local timeouts = {}
local paymentRequests = {}

local function isPlayerTimedOut(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 1000 then
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

function getPlayerSeasonPassData(player)
    local passData = getElementData(player, 'player:seasonPass') or {}
    return passData
end

function doesPlayerHaveBoughtSeasonPass(player)
    return getElementData(player, 'player:seasonPass:bought') or false
end

function setPlayerBoughtSeasonPass(player, bought)
    setElementData(player, 'player:seasonPass:bought', bought)
end

function getPlayerSeasonMoney(player)
    return getElementData(player, 'player:seasonMoney') or 0
end

function addPlayerSeasonMoney(player, amount)
    local currentMoney = getPlayerSeasonMoney(player)
    setElementData(player, 'player:seasonMoney', currentMoney + amount)
end

function didPlayerRedeemSeasonPassItem(player, page, index)
    local passData = getPlayerSeasonPassData(player)
    return passData.redeemedItems and passData.redeemedItems[page] and passData.redeemedItems[page][index]
end

function getPlayerActualSeasonPassData(player)
    local passData = getPlayerSeasonPassData(player)
    local pages = {}

    for page, items in pairs(seasonPass) do
        local pageData = {}

        for index, item in ipairs(items) do
            local redeemed = passData.redeemedItems and passData.redeemedItems[page] and passData.redeemedItems[page][index]
            table.insert(pageData, {
                name = item.name,
                image = item.image,
                size = item.size,
                stars = item.stars,
                free = item.free,
                rarity = item.rarity,
                redeemed = redeemed
            })
        end

        table.insert(pages, pageData)
    end

    return {
        pages = pages,
        season = 1,
        seasonName = 'Rozdarcie',
        bought = doesPlayerHaveBoughtSeasonPass(player),
        stars = 7,
    }
end

addEventHandler('dashboard:fetchSeasonPassData', root, function(hash, player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', data = getPlayerActualSeasonPassData(player)})
end)

addEventHandler('dashboard:redeemSeasonItem', root, function(hash, player, page, index)
    local passData = getPlayerActualSeasonPassData(player)
    page, index = tonumber(page) + 1, tonumber(index) + 1

    print('redeeming', page, index)
    local pageData = passData.pages[page]
    if not pageData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono strony'})
        return
    end

    local itemData = pageData[index]
    if not itemData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono przedmiotu'})
        return
    end

    if itemData.redeemed then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Przedmiot został już odebrany'})
        return
    end

    if not itemData.free and not doesPlayerHaveBoughtSeasonPass(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten przedmiot wymaga zakupienia przepustki sezonowej'})
        return
    end

    -- redeem item
    local passData = getPlayerSeasonPassData(player)
    if not passData.redeemedItems then
        passData.redeemedItems = {}
    end

    if not passData.redeemedItems[page] then
        passData.redeemedItems[page] = {}
    end

    passData.redeemedItems[page][index] = true
    setElementData(player, 'player:seasonPass', passData)

    exports['m-ui']:respondToRequest(hash, {
        status = 'success',
        message = 'Przedmiot został pomyślnie odebrany',
        data = getPlayerActualSeasonPassData(player)
    })
end)

function resetPlayerRedeedmedItems(player)
    local passData = getPlayerSeasonPassData(player)
    passData.redeemedItems = {}
    setElementData(player, 'player:seasonPass', passData)
end

addEventHandler('payment:onPaymentCreated', root, function(uid, item, url)
    local hash = paymentRequests[tonumber(uid)]
    if not hash then return end

    fetchRemote(('https://api.qrserver.com/v1/create-qr-code/?size=256x256&data=%s'):format(url), function(data, err, hash)
        if err ~= 0 then
            exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie udało się wygenerować kodu QR'})
            return
        end

        exports['m-ui']:respondToRequest(hash, {status = 'success', url = url, qr = base64Encode(data)})
    end, '', false, hash)
end)

addEventHandler('dashboard:fetchPaymentUrl', resourceRoot, function(hash, player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    exports['m-sockets']:createPayment(player, 'seasonPass')
    paymentRequests[uid] = hash
end)

addEventHandler('payment:onPaymentFinished', root, function(uid, player, item)
    if item ~= 'seasonPass' then return end

    if player then
        setPlayerBoughtSeasonPass(player, true)
        exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Pomyślnie zakupiono przepustkę sezonową')
        triggerClientEvent(player, 'dashboard:boughtSeasonPass', resourceRoot)
    else 
        -- TODO: add to database
    end
end)

-- resetPlayerRedeedmedItems(getRandomPlayer())
-- setPlayerBoughtSeasonPass(getRandomPlayer(), false)
addEventHandler('onResourceStart', resourceRoot, function()
    for k, v in ipairs(getElementsByType('player')) do
        setPlayerBoughtSeasonPass(v, false)
        bindKey(v, 'j', 'down', function(v)
            setPlayerBoughtSeasonPass(v, true)
            exports['m-notis']:addNotification(v, 'success', 'Sukces', 'Pomyślnie zakupiono przepustkę sezonową')
            triggerClientEvent(v, 'dashboard:boughtSeasonPass', resourceRoot)
        end)
    end
end)