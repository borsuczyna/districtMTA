addEvent('inventory:getInventory')
addEvent('inventory:useItem')

function getPlayerInventory(player)
    return getElementData(player, 'player:inventory') or {}
end

local function checkIfPlayerHaveItem(inventory, player, item, count)
    for i, v in ipairs(inventory) do
        if v.item == item and v.amount >= count then
            return true, v
        end
    end
    return false
end

function doesPlayerHaveItem(player, item, count)
    count = count or 1
    local inventory = getPlayerInventory(player)

    return checkIfPlayerHaveItem(inventory, player, item, count)
end

function getPlayerItemCount(player, item)
    local inventory = getPlayerInventory(player)
    local count = 0
    for i, v in ipairs(inventory) do
        if v.item == item then
            count = count + v.amount
        end
    end

    return count
end

function doesPlayerHaveItems(player, items)
    local inventory = getPlayerInventory(player)
    for item, count in pairs(items) do
        local have = checkIfPlayerHaveItem(inventory, player, item, count)
        if not have then
            return false, item
        end
    end

    return true
end

function doesPlayerHaveItemsUnequipped(player, items)
    local inventory = getPlayerInventory(player)
    for item, count in pairs(items) do
        local have, itemData = checkIfPlayerHaveItem(inventory, player, item, count)
        if not have then
            return false, item
        end

        if itemData.metadata and itemData.metadata.equipped then
            return false, item
        end
    end

    return true
end

function getPlayerItemAmount(player, item)
    local have, item = doesPlayerHaveItem(player, item)
    if not have then return 0 end

    return item.amount
end

function clone(t)
    if not t then return end
    return fromJSON(toJSON(t))
end

function addInventoryItem(inventory, item, amount, metadata)
    local itemData = itemsData[item]
    if not itemData then return end

    if not itemData.metadata then
        for i, v in ipairs(inventory) do
            if v.item == item then
                v.amount = math.max(0, v.amount + amount)
                if v.amount == 0 then
                    table.remove(inventory, i)
                end

                return inventory
            end
        end
    elseif amount <= 0 then
        local removeAmount = amount
        for i, v in ipairs(inventory) do
            if v.item == item then
                local toRemove = math.min(v.amount, math.abs(removeAmount))
                v.amount = v.amount - toRemove
                removeAmount = removeAmount + toRemove

                if v.amount == 0 then
                    table.remove(inventory, i)
                end
            end
        end

        return inventory
    end

    if amount <= 0 then return inventory end

    if not itemData.metadata then
        table.insert(inventory, {item = item, amount = amount, metadata = clone(metadata or itemData.metadata), hash = generateHash()})
    else
        for i = 1, amount do
            table.insert(inventory, {item = item, amount = 1, metadata = clone(metadata or itemData.metadata), hash = generateHash()})
        end
    end

    return inventory
end

function addPlayerItem(player, item, amount, metadata)
    local inventory = getPlayerInventory(player)
    inventory = addInventoryItem(inventory, item, amount, metadata)
    setElementData(player, 'player:inventory', inventory, false)
end

function getPlayerItemsOffline(uid)
    local data = exports['m-mysql']:query('SELECT `inventory` FROM `m-users` WHERE `uid` = ?', uid)
    if not data or not data[1] then return {} end

    return fromJSON(data[1].inventory)
end

function setPlayerItemsOffline(uid, items)
    exports['m-mysql']:query('UPDATE `m-users` SET `inventory` = ? WHERE `uid` = ?', toJSON(items), uid)
end

function addPlayerItemsOffline(uid, items)
    local player = exports['m-core']:getPlayerByUid(uid)
    if player then
        local playerItems = getPlayerInventory(player)

        for _, item in pairs(items) do
            if type(item) == 'table' then
                playerItems = addInventoryItem(playerItems, item[1], item[2])
            else
                playerItems = addInventoryItem(playerItems, item, 1)
            end
        end

        setElementData(player, 'player:inventory', playerItems, false)
        return
    end

    local playerItems = getPlayerItemsOffline(uid)

    for _, item in pairs(items) do
        if type(item) == 'table' then
            playerItems = addInventoryItem(playerItems, item[1], item[2])
        else
            playerItems = addInventoryItem(playerItems, item, 1)
        end
    end

    setPlayerItemsOffline(uid, playerItems)
end

function transferItem(playerA, playerB, itemHash, amount)
    local item = getPlayerItemByHash(playerA, itemHash)
    if not item then return end

    local itemData = itemsData[item.item]
    if not itemData then return end

    if item.amount < amount then return end

    addPlayerItem(playerB, item.item, amount, item.metadata)
    removePlayerItemByHash(playerA, itemHash, amount)
end

function removePlayerItem(player, item, amount)
    addPlayerItem(player, item, -amount)
end

function removePlayerItemByHash(player, hash, amount)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.hash == hash then
            v.amount = v.amount - amount
            if v.amount <= 0 then
                table.remove(inventory, i)
            end

            setElementData(player, 'player:inventory', inventory, false)
            return
        end
    end
end

function getPlayerItemByHash(player, hash)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.hash == hash then
            return v
        end
    end

    return false
end

function getPlayerItemRarityByHash(player, hash)
    local item = getPlayerItemByHash(player, hash)
    if not item then return end

    local itemData = itemsData[item.item]
    if not itemData then return end

    return itemData.rarity
end

function getPlayerItemsByRegex(player, regex)
    local inventory = getPlayerInventory(player)
    local items = {}
    for i, v in ipairs(inventory) do
        if v.item:match(regex) then
            table.insert(items, v)
        end
    end

    return items
end

function matchItems(player, callback)
    local inventory = getPlayerInventory(player)
    local items = {}
    for i, v in ipairs(inventory) do
        if callback(v) then
            table.insert(items, v)
        end
    end

    return items
end

function doesPlayerHaveAnyItemByRegexEquipped(player, regex)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.item:match(regex) and v.metadata and v.metadata.equipped then
            return true, v
        end
    end

    return false
end

function getPlayerItem(player, itemHash)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.hash == itemHash then
            return v
        end
    end
end

function getItemMetadata(player, itemHash, key)
    local item = getPlayerItemByHash(player, itemHash)
    if not item then return end

    return item.metadata[key]
end

function setItemMetadata(player, itemHash, key, value)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.hash == itemHash then
            if not v.metadata then v.metadata = {} end
            v.metadata[key] = value
            setElementData(player, 'player:inventory', inventory, false)
            return
        end
    end
end

function addItemProgress(player, itemHash, progress)
    local inventory = getPlayerInventory(player)
    for i, v in ipairs(inventory) do
        if v.hash == itemHash then
            if not v.metadata then return end
            v.metadata.progress = math.min(v.metadata.progress + progress, 100)
            setElementData(player, 'player:inventory', inventory, false)
            return
        end
    end
end

addEventHandler('inventory:getInventory', root, function(hash, player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    exports['m-ui']:respondToRequest(hash, {status = 'success', inventory = getPlayerInventory(player)})
end)

addEventHandler('inventory:useItem', root, function(hash, player, itemHash)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local item = getPlayerItemByHash(player, itemHash)
    if not item then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tego przedmiotu'})
        return
    end
    
    if item.amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tego przedmiotu'})
        return
    end
    
    local itemData = itemsData[item.item]
    if not itemData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono przedmiotu'})
        return
    end
    
    local takeAmount = itemData.onUse(player, itemHash)
    if takeAmount then
        removePlayerItemByHash(player, itemHash, -takeAmount)
    end
    
    exports['m-ui']:respondToRequest(hash, {status = 'success', inventory = getPlayerInventory(player)})
    
    local itemName = exports['m-inventory']:getItemName(item)
    exports['m-logs']:sendLog('items', 'info', ('Gracz `%s` użył przedmiotu %s (`%s`)'):format(getPlayerName(player), itemName, itemHash))
end)

function useItem(player, itemHash)
    local item = getPlayerItemByHash(player, itemHash)
    if not item then return end

    local itemData = itemsData[item.item]
    if not itemData then return end

    local takeAmount = itemData.onUse(player, itemHash, true)
    if takeAmount then
        removePlayerItemByHash(player, itemHash, -takeAmount)
    end
end

-- TODO: remove
addCommandHandler('testitem', function(player, cmd, name, count)
    addPlayerItem(player, name or 'hotDog', tonumber(count) or 1)
    exports['m-notis']:addNotification(player, 'success', 'xd', 'masz kurwo')
end)