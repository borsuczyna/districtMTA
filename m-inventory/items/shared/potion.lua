local bunnyTimer

if localPlayer then
    addEvent('inventory:onUsePotion', true)
    addEventHandler('inventory:onUsePotion', resourceRoot, function()
        setWorldSpecialPropertyEnabled('extrajump', true)
        if bunnyTimer and isTimer(bunnyTimer) then
            killTimer(bunnyTimer)
        end

        bunnyTimer = setTimer(setWorldSpecialPropertyEnabled, 60000, 1, 'extrajump', false)
    end)
end

function createPotionItem()
    return {
        title = 'Sok z gumijagód',
        description = 'Lśniący sok z gumijagód, który dodaje energii',
        category = 'food',
        icon = '/m-inventory/data/icons/potion.png',
        rarity = 'epic',
        onUse = onPotionUse,
    }
end