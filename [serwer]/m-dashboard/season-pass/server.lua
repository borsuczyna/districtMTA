addEvent('dashboard:fetchSeasonPassData')
addEvent('dashboard:redeemSeasonItem')
addEvent('dashboard:buySeasonPass')
addEvent('dashboard:useSeasonPassPromoCode')
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

function getPlayerSeasonPassStars(player)
    local passData = getPlayerSeasonPassData(player)
    return passData.stars or 0
end

function addPlayerSeasonPassStars(player, stars)
    local passData = getPlayerSeasonPassData(player)
    passData.stars = (passData.stars or 0) + stars
    setElementData(player, 'player:seasonPass', passData)
end

function getPlayerSeasonMoney(player)
    return exports['m-inventory']:getPlayerItemCount(player, 'dist')
end

function addPlayerSeasonMoney(player, amount)
    exports['m-inventory']:addPlayerItem(player, 'dist', amount)
end

function didPlayerRedeemSeasonPassItem(player, page, index)
    local passData = getPlayerSeasonPassData(player)
    return passData.redeemedItems and passData.redeemedItems[tostring(page)] and passData.redeemedItems[tostring(page)][tostring(index)]
end

function getPlayerActualSeasonPassData(player)
    local passData = getPlayerSeasonPassData(player)
    local pages = {}

    for page, items in pairs(seasonPass) do
        local pageData = {}

        for index, item in ipairs(items) do
            local redeemed = passData.redeemedItems and passData.redeemedItems[tostring(page)] and passData.redeemedItems[tostring(page)][tostring(index)]
            table.insert(pageData, {
                name = item.name,
                image = item.image,
                size = item.size,
                stars = item.stars,
                free = item.free,
                rarity = item.rarity,
                onRedeem = item.onRedeem,
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
        stars = getPlayerSeasonPassStars(player),
        dists = getPlayerSeasonMoney(player)
    }
end

addEventHandler('dashboard:fetchSeasonPassData', root, function(hash, player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', data = getPlayerActualSeasonPassData(player)})
end)

addEventHandler('dashboard:redeemSeasonItem', root, function(hash, player, page, index)
    local passData = getPlayerActualSeasonPassData(player)
    page, index = tonumber(page) + 1, tonumber(index) + 1

    local pageData = passData.pages[page]
    if not pageData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono strony'})
        return
    end

    local previousPageData = passData.pages[page - 1] or {}
    local previousPageRedeemed = true
    for _, item in ipairs(previousPageData) do
        -- if not item.redeemed then
        --     previousPageRedeemed = false
        --     break
        -- end

        if not item.free and not item.redeemed then
            previousPageRedeemed = false
            break
        end
    end

    if not previousPageRedeemed then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Poprzednia strona nie została jeszcze ukończona'})
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

    if itemData.stars > getPlayerSeasonPassStars(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczającej ilości gwiazdek'})
        return
    end

    -- redeem item
    local passData = getPlayerSeasonPassData(player)
    if not passData.redeemedItems then
        passData.redeemedItems = {}
    end

    if not passData.redeemedItems[tostring(page)] then
        passData.redeemedItems[tostring(page)] = {}
    end

    passData.redeemedItems[tostring(page)][tostring(index)] = true
    setElementData(player, 'player:seasonPass', passData)

    -- call callback
    itemData.onRedeem(player)
    addPlayerSeasonPassStars(player, -itemData.stars)
    
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
        exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Pomyślnie zakupiono 1000 distów')
    end

    exports['m-inventory']:addPlayerItemsOffline(tonumber(uid), {{'dist', 1000}})
end)

function buySeasonPass(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local distCoins = getPlayerSeasonMoney(player)
    if distCoins < 1000 then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz wystarczającej ilości distów')
        return false
    end

    if doesPlayerHaveBoughtSeasonPass(player) then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Posiadasz już przepustkę sezonową')
        return false
    end

    exports['m-inventory']:addPlayerItem(player, 'dist', -1000)
    setPlayerBoughtSeasonPass(player, true)
    exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Pomyślnie zakupiono przepustkę sezonową')
    triggerClientEvent(player, 'dashboard:boughtSeasonPass', resourceRoot)

    return true
end

function isValidSeasonPassCode(code)
    local codes = exports['m-mysql']:query('SELECT * FROM `m-season-pass-codes` WHERE `code` = ? AND `leftUses` > 0', code)
    return codes and #codes > 0
end

function useSeasonPassCode(player, code)
    if not isValidSeasonPassCode(code) then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nieprawidłowy kod promocyjny')
        return false
    end

    if doesPlayerHaveBoughtSeasonPass(player) then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Posiadasz już przepustkę sezonową')
        return false
    end

    exports['m-mysql']:query('UPDATE `m-season-pass-codes` SET `leftUses` = `leftUses` - 1 WHERE `code` = ?', code)
    setPlayerBoughtSeasonPass(player, true)
    exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Pomyślnie użyto kodu promocyjnego')
    triggerClientEvent(player, 'dashboard:boughtSeasonPass', resourceRoot)

    return true
end

addEventHandler('dashboard:buySeasonPass', root, function(hash, player)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wysyłasz zbyt wiele zapytań'})
        return
    end

    if buySeasonPass(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'success'})
    else
        exports['m-ui']:respondToRequest(hash, {status = 'error'})
    end
end)

addEventHandler('dashboard:useSeasonPassPromoCode', root, function(hash, player, code)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wysyłasz zbyt wiele zapytań'})
        return
    end

    if useSeasonPassCode(player, code) then
        exports['m-ui']:respondToRequest(hash, {status = 'success'})
    else
        exports['m-ui']:respondToRequest(hash, {status = 'error'})
    end
end)

addEventHandler('onResourceStart', resourceRoot, function()
    for k, v in ipairs(getElementsByType('player')) do
        -- setPlayerBoughtSeasonPass(v, false)
        -- setElementData(v, 'player:seasonPass', {})
        bindKey(v, 'j', 'down', function(v)
            exports['m-notis']:addNotification(v, 'success', 'Sukces', 'Pomyślnie zakupiono 1000 distów')
            local uid = getElementData(v, 'player:uid')
            exports['m-inventory']:addPlayerItemsOffline(tonumber(uid), {{'dist', 1000}})
        end)

        bindKey(v, 'k', 'down', function(v)
            exports['m-notis']:addNotification(v, 'success', 'Sukces', 'Dodano 400 gwiazdek')
            addPlayerSeasonPassStars(v, 400)
        end)
    end
end)