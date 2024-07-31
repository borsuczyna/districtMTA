jobs = {
    burger = {
        name = 'Pracownik burgerowni',
        background = 'burger',
        description = 'Praca w burgerowni polega na przygotowywaniu i sprzedawaniu burgerów dla klientów.',
        coop = true,
        minLobbySize = 1,
        lobbySize = 8,
        minLevel = 1,
        upgrades = {
            {
                name = 'Sprinter',
                key = 'sprinter',
                description = 'Zwiększa prędkość poruszania się o 10%',
                points = 15
            },
            {
                name = 'Kucharz',
                key = 'kucharz',
                description = 'Zwiększa szybkość przygotowywania burgerów o 10%',
                points = 20
            },
            {
                name = 'Natłok',
                key = 'natlok',
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
                key = 'sprinter',
                description = 'Zwiększa prędkość poruszania się o 10%',
                points = 15
            },
            {
                name = 'Kierowca',
                key = 'kierowca',
                description = 'Zwiększa prędkość samochodu o 15%',
                points = 20
            },
            {
                name = 'Recykling',
                key = 'recykling',
                description = 'Zwiększa ilość wyrzucanych śmieci o 10%',
                points = 25
            },
        }
    }
}

function setJobMultiplier(job, multiplier)
    local jobMultipliersManager = getElementsByType('jobMultipliersManager')[1]
    setElementData(jobMultipliersManager, job, multiplier)
    outputChatBox(('Multiplier for job `%s` has been set to %s'):format(job, multiplier))
end

function getJobMultiplier(job)
    local jobMultipliersManager = getElementsByType('jobMultipliersManager')[1]
    return getElementData(jobMultipliersManager, job) or 1
end

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