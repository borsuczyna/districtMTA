local objects = {}

local function loadPlayerCosmetics(player)
    local cosmetics = getElementData(player, 'player:cosmetics') or {}

    for _, cosmeticItem in pairs(cosmetics) do
        local cosmetic = getCosmetic(cosmeticItem.item)

        if cosmetic then
            if not objects[player] then
                objects[player] = {}
            end

            if not objects[player][cosmeticItem.item] then
                objects[player][cosmeticItem.item] = createObject(1337, 0, 0, 0)
                setElementDoubleSided(objects[player][cosmeticItem.item], true)
                setElementData(objects[player][cosmeticItem.item], 'element:model', cosmetic.model)

                exports['m-pattach']:attach(objects[player][cosmeticItem.item], player, cosmetic.bone, cosmetic.position.x, cosmetic.position.y, cosmetic.position.z, cosmetic.rotation.x, cosmetic.rotation.y, cosmetic.rotation.z)
            end
        end
    end
end

local function unloadPlayerCosmetics(player)
    if objects[player] then
        for _, object in pairs(objects[player]) do
            destroyElement(object)
        end
        
        objects[player] = nil
    end
end

function onCosmeticUse(player, itemHash, autoUse)
    local item = getPlayerItem(player, itemHash)
    local cosmetic = getCosmetic(item.item)

    if not item or not cosmetic then return end

    local equipped = item.metadata and item.metadata.equipped or false
    local equippedOtherCosmetic = doesPlayerHaveEquippedCosmetic(player, cosmetic.type)

    if not equipped and equippedOtherCosmetic then
        exports['m-notis']:addNotification(player, 'error', 'Kosmetyki', 'Nie możesz założyć dwóch kosmetyków tego samego typu na raz.')
        return 0
    end

    setItemMetadata(player, itemHash, 'equipped', not equipped)

    if not autoUse then
        exports['m-notis']:addNotification(player, 'info', 'Kosmetyki', 'Kosmetyk został ' .. (equipped and 'zdjęty.' or 'założony.'))
    end

    if not objects[player] then
        objects[player] = {}
    end

    if not equipped then
        objects[player][item.item] = createObject(1337, 0, 0, 0)
        setElementDoubleSided(objects[player][item.item], true)
        setElementData(objects[player][item.item], 'element:model', cosmetic.model)

        exports['m-pattach']:attach(objects[player][item.item], player, cosmetic.bone, cosmetic.position.x, cosmetic.position.y, cosmetic.position.z, cosmetic.rotation.x, cosmetic.rotation.y, cosmetic.rotation.z)
        setCosmeticEquipped(player, cosmetic.type, cosmetic.item, true)
    else
        if objects[player][item.item] then
            destroyElement(objects[player][item.item])
            objects[player][item.item] = nil
        end

        setCosmeticEquipped(player, cosmetic.type, cosmetic.item, false)
    end
end

addEventHandler('onPlayerQuit', root, function()
    unloadPlayerCosmetics(source)
end)

addEventHandler('onPlayerResourceStart', root, function()
    loadPlayerCosmetics(source)
end)