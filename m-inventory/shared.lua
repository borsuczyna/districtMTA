itemsData = {
    m4 = {
        title = 'M4',
        description = 'Karabin szturmowy, który jest używany przez wiele jednostek specjalnych na całym świecie.',
        category = 'weapon',
        icon = '../../m-inventory/data/icons/m4.png',
        rarity = 'divine',
        onUse = function(player)
            giveWeapon(player, 'm4', 30)
            return -1
        end,

        metadata = {
            ammo = 30,
        },

        render = [[{description}<br><br>
            <div class="label">Amunicja: 30</div>
        ]],
    },
    hotDog = {
        title = 'Hotdog',
        description = 'Parówka w bułce z ketchupem i musztardą.',
        category = 'food',
        icon = '../../m-inventory/data/icons/hot-dog.png',
        rarity = 'common',
        onUse = function(player)
            local health = getElementHealth(player)
            setElementHealth(player, health + 20)
            setPedAnimation(player, "FOOD", "EAT_Burger", nil, false, false, nil, false)
            return -1
        end,
    },
    potion = {
        title = 'Sok z gumijagód',
        description = 'Lśniący sok z gumijagód, który dodaje energii.',
        category = 'food',
        icon = '../../m-inventory/data/icons/potion.png',
        rarity = 'epic',
        onUse = function(player)
            setPedAnimation(player, "FOOD", "EAT_Burger", nil, false, false, nil, false)
            triggerClientEvent(player, 'inventory:onUsePotion', resourceRoot)
            return -1
        end,
    },
    bait = {
        title = 'Przynęta',
        description = 'Obślizgłe robaki, które przyciągają ryby.',
        category = 'fish',
        icon = '../../m-inventory/data/icons/worm.png',
        rarity = 'common',
        onUse = false
    },
    wire = {
        title = 'Metalowa linka',
        description = 'Skręcona metalowa linka.',
        category = 'fish',
        icon = '../../m-inventory/data/icons/wire.png',
        rarity = 'common',
        onUse = false
    },
    fishingRod = {
        title = 'Wędka',
        description = 'Przydałby się sprzęt do wędkowania.',
        category = 'fish',
        icon = '../../m-inventory/data/icons/fishing-rod.png',
        rarity = 'legendary',
        onUse = function(player, itemHash)
            local equipped = getItemMetadata(player, itemHash, 'equipped')
            setItemMetadata(player, itemHash, 'equipped', not equipped)
            return 0
        end,

        metadata = {
            progress = 0,
            equipped = false,
        },

        render = [[{description}<br>
            <div class="progress">
                <div class="progress-bar" style="width: {metadata.progress}%;"></div>
            </div>
            <div class="label">Postęp: {metadata.progress}%</div>
            <div class="label">Założona: {metadata.equipped}</div>
        ]],
    },
}

function getItemName(item)
    return itemsData[item].title
end

function generateHash()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 16
    local hash = ''

    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        hash = hash .. chars:sub(randomIndex, randomIndex)
    end

    return hash
end