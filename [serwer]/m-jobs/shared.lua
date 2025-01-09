jobs = {
    burger = {
        name = 'Pracownik burgerowni',
        background = 'burger',
        description = 'Praca w burgerowni polega na przygotowywaniu i sprzedawaniu burgerów dla klientów.',
        coop = true,
        minLobbySize = 1,
        lobbySize = 8,
        minLevel = 1,
        canEndWithGui = true,
        upgrades = {
            {
                name = 'Sprinter',
                key = 'sprinter',
                description = 'Pozwala biegać sprintem',
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
        description = 'Praca wywożenia śmieci polega na zbieraniu i wywożeniu śmieci z miasta.<br><br>Wymagana kategoria C',
        coop = true,
        minLobbySize = 1,
        lobbySize = 4,
        minLevel = 1,
        upgrades = {
            {
                name = 'Sprinter',
                key = 'sprinter',
                description = 'Pozwala biegać sprintem',
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
    },
    courier = {
        name = 'Kurier',
        background = 'trash',
        description = 'Praca kuriera polega na dostarczaniu przesyłek do klientów.<br><br>Wymagana kategoria C',
        coop = true,
        minLobbySize = 1,
        lobbySize = 2,
        minLevel = 1,
        upgrades = {
            {
                name = 'Kierowca',
                key = 'kierowca',
                description = 'Zwiększa prędkość samochodu o 15%',
                points = 20
            },
            {
                name = 'Pojemność',
                key = 'pojemnosc',
                description = 'Zwiększa ilość dostarczanych przesyłek o 20%',
                points = 25
            },
            {
                name = 'Sprinter',
                key = 'sprinter',
                description = 'Pozwala biegać sprintem',
                points = 15
            },
        }
    },
    wheelsupplier = {
        name = 'Dostawca opon',
        background = 'trash',
        description = 'Praca dostawcy opon polega na rozwożeniu opon do klienta.',
        coop = false,
        minLobbySize = 1,
        lobbySize = 1,
        minLevel = 1,
        upgrades = {},
    },
    warehouse = {
        name = 'Magazynier',
        background = 'warehouse',
        description = 'Praca magazyniera polega na przenoszeniu przesyłek z ciężarówki na półki magazynu.',
        coop = false,
        minLobbySize = 1,
        lobbySize = 1,
        minLevel = 1,
        upgrades = {
            {
                name = 'Sprinter',
                key = 'sprinter',
                description = 'Pozwala biegać sprintem',
                points = 25
            },
            {
                name = 'Biznesmen',
                key = 'biznesmen',
                description = 'Zwiększa zarobki o 5%',
                points = 15
            },
            {
                name = 'Fachowiec',
                key = 'fachowiec',
                description = 'Zwiększa zarobki o 10%',
                points = 30
            },
        }
    },

    pilotl1 = {
        name = 'Pilot L1',
        background = 'warehouse',
        description = 'Praca pilota L1 polega na dostarczaniu paczek po miastach Los Santos, San Fierro i Las Venturas.',
        coop = false,
        minLobbySize = 1,
        lobbySize = 1,
        minLevel = 1,
        upgrades = {
            
            {
                name = 'Biznesmen',
                key = 'biznesmen',
                description = 'Zwiększa zarobki o 5%',
                points = 15
            },

        }
    },
}

function getJobName(job)
    return jobs[job].name
end

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