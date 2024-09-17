local bunnyTimer

if localPlayer then
    local function onPlayerDamage(_, weapon)
        if weapon == 54 then
            cancelEvent()
        end
    end

    addEvent('inventory:onUsePotion', true)
    addEventHandler('inventory:onUsePotion', resourceRoot, function()
        setWorldSpecialPropertyEnabled('extrajump', true)
        addEventHandler('onClientPlayerDamage', localPlayer, onPlayerDamage)

        if bunnyTimer and isTimer(bunnyTimer) then
            killTimer(bunnyTimer)
        end
        
        bunnyTimer = setTimer(function()
            setWorldSpecialPropertyEnabled('extrajump', false)
            removeEventHandler('onClientPlayerDamage', localPlayer, onPlayerDamage)
        end, 60000, 1)
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