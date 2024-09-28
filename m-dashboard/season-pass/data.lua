seasonPass = {
    {
        {
            name = 'Testowy skin',
            image = '2.png?v4',
            size = {1, 1},
            stars = 3,
            rarity = 'epickie',
            free = true,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {3, 2},
            rarity = 'epickie',
            stars = 9,
        },
        {
            name = 'Szlamiasty szum',
            image = '9.png',
            size = {2, 1},
            rarity = 'niepospolite',
            stars = 5,
            onRedeem = function(player)
                exports['m-inventory']:addPlayerItem(player, 'trace2', 1)
            end
        },
        {
            name = '100 distów',
            image = '4.png',
            size = {1, 1},
            rarity = 'egzotyczne',
            stars = 5,
            onRedeem = function(player)
                addPlayerSeasonMoney(player, 100)
            end
        },
        {
            name = 'Testowy skin',
            image = '6.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            stars = 3,
        },
        {
            name = '100 distów',
            image = '4.png',
            size = {1, 1},
            rarity = 'egzotyczne',
            stars = 5,
            onRedeem = function(player)
                addPlayerSeasonMoney(player, 100)
            end
        },
        {
            name = 'UFO lampka nocna',
            image = '3.png?v4',
            size = {2, 2},
            rarity = 'epickie',
            free = true,
            stars = 5,
        },
        {
            name = '100 distów',
            image = '4.png',
            size = {1, 1},
            rarity = 'egzotyczne',
            stars = 5,
            onRedeem = function(player)
                addPlayerSeasonMoney(player, 100)
            end
        },
        {
            name = 'Testowy skin',
            image = '5.png?v7',
            size = {2, 1},
            rarity = 'epickie',
            stars = 5,
        },
        {
            name = 'Szum UFO',
            image = '8.png',
            size = {2, 1},
            rarity = 'epickie',
            stars = 5,
            onRedeem = function(player)
                exports['m-inventory']:addPlayerItem(player, 'trace1', 1)
            end
        },
    },
    {
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            stars = 3,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {3, 2},
            rarity = 'epickie',
            stars = 9,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {2, 1},
            rarity = 'epickie',
            stars = 5,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            free = true,
            stars = 3,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            stars = 3,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            stars = 3,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {2, 2},
            rarity = 'epickie',
            stars = 5,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {1, 1},
            rarity = 'epickie',
            stars = 3,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {2, 1},
            rarity = 'epickie',
            stars = 5,
        },
        {
            name = 'Testowy skin',
            image = '1.png?v4',
            size = {2, 1},
            rarity = 'epickie',
            stars = 5,
        },
    }
}