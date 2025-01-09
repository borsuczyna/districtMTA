local function findShopDataItem(shopData, item, type)
    for i, shopItem in ipairs(shopData.items) do
        if shopItem.item == item and shopItem.type == type then
            return shopItem
        end
    end
end

addEvent('inventory:buyItems')
addEventHandler('inventory:buyItems', root, function(hash, player, data)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local shopData = shopList[data.shopId]
    if not shopData then return end

    local inventory = getPlayerInventory(player)
    local totalPrice = 0
    local items = {
        buy = {},
        sell = {}
    }

    -- declare functions
    for i, item in ipairs(data.items) do
        local shopItem = findShopDataItem(shopData, item.item, item.type)
        if not shopItem then
            exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono przedmiotu w sklepie'})
            return
        end

        if type(shopItem.price) == 'number' then
            local price = shopItem.price * item.count

            if item.type == 'buy' then
                totalPrice = totalPrice + price
                table.insert(items.buy, {item = item.item, count = item.count, onBuy = shopItem.onBuy})
            elseif item.type == 'sell' then
                if not doesPlayerHaveItem(player, item.item, item.count) then
                    exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczająco przedmiotów ('..getItemName(item)..')'})
                    return
                end
    
                totalPrice = totalPrice - price
                table.insert(items.sell, {item = item.item, count = item.count, price = price})
            end
        else
            for i, inventoryItem in ipairs(inventory) do
                if not (inventoryItem.metadata and inventoryItem.metadata.equipped) then
                    local addPrice = shopItem.priceCallback(inventoryItem)
                    if addPrice then
                        local price = addPrice * inventoryItem.amount
                        
                        totalPrice = totalPrice - price
                        table.insert(items.sell, {item = inventoryItem.item, count = inventoryItem.amount, price = price})
                    end
                end
            end
        end
    end

    if getPlayerMoney(player) < totalPrice then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz wystarczająco pieniędzy'})
        return
    end

    if totalPrice == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie wybrano żadnych przedmiotów'})
        return
    end

    for i, item in ipairs(items.sell) do
        if not doesPlayerHaveItem(player, item.item, item.count) then
            -- exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczająco przedmiotów ('..getItemName(item)..')'})
            totalPrice = totalPrice + item.price
        else
            removePlayerItem(player, item.item, item.count)
        end
    end

    for i, item in ipairs(items.buy) do
        if item.onBuy then
            item.onBuy(player, item.count)
        else
            addPlayerItem(player, item.item, item.count)
        end
    end

    local details = (totalPrice > 0 and 'Zakup' or 'Sprzedaż') .. ' przedmiotów w sklepie '.. shopData.name .. ', ' .. shopData.description
    exports['m-core']:givePlayerMoney(player, 'shop', details, -totalPrice)

    exports['m-ui']:respondToRequest(hash, {
        status = 'success',
        inventory = getPlayerInventory(player),
        message = totalPrice > 0 and 'Zakupiono przedmioty pomyślnie' or 'Sprzedano przedmioty pomyślnie'
    })
end)