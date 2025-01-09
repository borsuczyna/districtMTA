local fishingRods = {}
local objectsTable = {
    ['common'] = 'fishing-rod',
    ['uncommon'] = 'fishing-rod-u',
    ['rare'] = 'fishing-rod-r',
    ['epic'] = 'fishing-rod-e',
    ['legendary'] = 'fishing-rod-l',
    ['mythic'] = 'fishing-rod-m',
    ['exotic'] = 'fishing-rod-x',
    ['divine'] = 'fishing-rod-d',
}

local function getFishingRodModel(rarity)
    return objectsTable[rarity] or objectsTable['common']
end

local function destroyPlayerFishingRod(player)
    if fishingRods[player] and isElement(fishingRods[player]) then
        destroyElement(fishingRods[player])
        fishingRods[player] = nil
    end
end

local function toggleFishingRod(player, model, visible)
    destroyPlayerFishingRod(player)
    if not visible then return end

    local fishingRod = createObject(1337, 0, 0, 0)
    setElementData(fishingRod, 'element:model', model)
    exports['m-pattach']:attach(fishingRod, player, 25, 0, 0.02, 0.02, 0, 180, 0)

    fishingRods[player] = fishingRod
end

function onFishingRodUse(player, itemHash)
    if getElementData(player, 'player:fishing') or getElementData(player, 'player:job') then
        exports['m-notis']:addNotification(player, 'error', 'Wędka', 'Nie możesz teraz tego zrobić.')
        return 0
    end

    local item = getPlayerItem(player, itemHash)
    local itemData = getItemData(item)

    local equipped = item.metadata and item.metadata.equipped or false
    local equippedOtherRod = doesPlayerHaveAnyItemByRegexEquipped(player, 'fishingRod%w+')
    if not equipped and equippedOtherRod then
        exports['m-notis']:addNotification(player, 'error', 'Wędka', 'Posiadasz już założoną wędkę.')
        return 0
    end

    setItemMetadata(player, itemHash, 'equipped', not equipped)
    exports['m-notis']:addNotification(player, 'info', 'Wędka', 'Wędka została ' .. (equipped and 'zdjęta.' or 'założona.<br>Aby zacząć łowić ryby, kliknij <kbd class="keycap keycap-sm">LPM</kbd> nieopodal wody.'))
    setElementData(player, 'player:equippedFishingRod', not equipped and itemHash or nil)

    local model = getFishingRodModel(itemData.rarity)
    toggleFishingRod(player, model, not equipped)

    return 0
end