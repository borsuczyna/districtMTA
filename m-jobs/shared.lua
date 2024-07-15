jobs = {
    burger = {
        name = 'Burgerownia',
        background = 'forest',
        description = 'Praca burgerowni polega na przygotowywaniu i sprzedawaniu burgerów dla klientów.',
        coop = true,
        minLobbySize = 1,
        lobbySize = 4,
        minLevel = 1,
        upgrades = {
            {
                name = 'Sprinter',
                description = 'Zwiększa prędkość poruszania się o 10%',
                points = 15
            },
            {
                name = 'Kucharz',
                description = 'Zwiększa szybkość przygotowywania burgerów o 10%',
                points = 20
            },
            {
                name = 'Natłok',
                description = 'Zwiększa ilość klientów o 10%',
                points = 25
            },
        }
    },
    trash = {
        name = 'Wywóz śmieci',
        background = 'trash',
        description = 'Praca wywożenia śmieci polega na zbieraniu i wywożeniu śmieci z miasta.',
        coop = true,
        minLobbySize = 1,
        lobbySize = 4,
        minLevel = 1,
        upgrades = {
            {
                name = 'Sprinter',
                description = 'Zwiększa prędkość poruszania się o 10%',
                points = 15
            },
            {
                name = 'Kierowca',
                description = 'Zwiększa pojemność samochodu o 10%',
                points = 20
            },
            {
                name = 'Recykling',
                description = 'Zwiększa ilość punktów za wywóz śmieci o 10%',
                points = 25
            },
        }
    }
}

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function generateHash(length)
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local hash = ''
    for i = 1, (length or 16) do
        local pos = math.random(1, #chars)
        hash = hash .. chars:sub(pos, pos)
    end

    return hash
end

function htmlEscape(s)
    return s:gsub('[<>&"]', function(c)
        return c == '<' and '&lt;' or c == '>' and '&gt;' or c == '&' and '&amp;' or '&quot;'
    end)
end