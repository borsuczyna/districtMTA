houseInteriors = {
    [1] = {
        description = 'Małe jednopokojowe mieszkanie z kuchnią i łazienką. Pokój i kuchnie rozgradza długi blat kuchenny.',
        bedrooms = 1,
        maxTenants = 2,

        model = 'int-1',
        enter = {2, -1, 0.95, 0},

        defaultFurniture = {
            {model = 2525, position = {3.5, 12.3, 0, 0, 0, 0}},
        },

        textureNames = {
            {name = 'Kuchnia', texture = 'wall123', type = 'wall'},
            {name = 'Podłoga w kuchni', texture = '139', type = 'floor'},
            {name = 'Mieszkanie', texture = 'motelwall', type = 'wall'},
            {name = 'Podłoga mieszkania', texture = '5', type = 'floor'},
            {name = 'Ściany łazienki', texture = 'Bow_sub_walltiles', type = 'wall'},
            {name = 'Podłoga w łazience', texture = '78ce2bb2', type = 'floor'},
        }
    },
    [2] = {
        description = 'Małe trzypokojowe mieszkanie z łazienką i garderobą. Idealne dla singla lub pary.',
        bedrooms = 1,
        maxTenants = 2,

        model = 'int-2',
        enter = {1, 1, -1, 90},

        defaultFurniture = {},

        textureNames = {
            {name = 'Ściany mieszkania', texture = 'sciana1', type = 'wall'},
            {name = 'Podłoga mieszkania', texture = 'podloga2', type = 'floor'},
            {name = 'Ściany garderoby', texture = 'sciana4', type = 'wall'},
            {name = 'Ściany kuchni', texture = 'sciana2', type = 'wall'},
            {name = 'Kafelki', texture = 'podloga1', type = 'floor'},
            {name = 'Ściany sypialni', texture = 'sciana5', type = 'wall'},
            {name = 'Podłoga w sypialni', texture = 'podloga3', type = 'floor'},
        }
    },
    [3] = {
        description = 'Średnich rozmiarów mieszkanie z dwoma pokojami, i łazienką. Ogromne okna z widokiem na miasto.',
        bedrooms = 1,
        maxTenants = 2,

        model = 'int-3',
        enter = {-5.34, 4.60, -1.73, -90},

        defaultFurniture = {},

        textureNames = {
            {name = 'Podłoga mieszkania', texture = 'podloga2', type = 'floor'},
            {name = 'Ściany mieszkania', texture = 'sciana4', type = 'wall'},
            {name = 'Ściany korytarzu', texture = 'sciana1', type = 'wall'},
            {name = 'Podłoga na piętrze', texture = 'podloga3', type = 'floor'},
            {name = 'Ściany na piętrze', texture = 'sciana5', type = 'wall'},
            {name = 'Sufit', texture = 'sufit', type = 'floor'},
        }
    },
    [4] = {
        description = 'Średnich rozmiarów mieszkanie z dwoma pokojami, kuchnią i łazienką. Idealne dla pary lub singla.',
        bedrooms = 1,
        maxTenants = 2,

        model = 'int-4',
        enter = {1.66, -7.12, -0.70, 0},

        defaultFurniture = {},

        textureNames = {
            {name = 'Ściany pokoju 1', texture = 'INT_2_SCIANA_POKOJ_1', type = 'wall'},
            {name = 'Podłoga w pokoju 1', texture = 'INT_2_PODLOGA_POKOJ_1', type = 'floor'},
            {name = 'Sufit pokoju 1', texture = 'INT_2_SUFIT_POKOJ_1', type = 'floor'},
            {name = 'Ściany pokoju 2', texture = 'INT_2_SCIANA_POKOJ_2', type = 'wall'},
            {name = 'Sufit pokoju 2', texture = 'INT_2_SUFIT_POKOJ_2', type = 'floor'},
            {name = 'Podłoga w pokoju 2', texture = 'INT_2_PODLOGA_POKOJ_2', type = 'floor'},
            {name = 'Ściany łazienki', texture = 'INT_2_SCIANA_LAZIENKA', type = 'wall'},
            {name = 'Podłoga w łazience', texture = 'INT_2_PODLOGA_LAZIENKA', type = 'floor'},
            {name = 'Sufit łazienki', texture = 'INT_2_SUFIT_LAZIENKA', type = 'floor'},
            {name = 'Ściany przedpokoju', texture = 'INT_2_SCIANA_PRZEDPOKOJ', type = 'wall'},
            {name = 'Podłoga w przedpokoju', texture = 'INT_2_PODLOGA_PRZEDPOKOJ', type = 'floor'},
            {name = 'Sufit przedpokoju', texture = 'INT_2_SUFIT_PRZEDPOKOJ', type = 'floor'},
            {name = 'Ściany kuchni', texture = 'INT_2_SCIANA_KUCHNIA', type = 'wall'},
            {name = 'Podłoga w kuchni', texture = 'INT_2_PODLOGA_KUCHNIA', type = 'floor'},
            {name = 'Sufit kuchni', texture = 'INT_2_SUFIT_KUCHNIA', type = 'floor'},
        }
    },
    [5] = {
        description = 'Średnich rozmiarów mieszkanie z dwoma pokojami, kuchnią i dużą łazienką. Idealne dla pary lub singla.',
        bedrooms = 1,
        maxTenants = 3,

        model = 'int-5',
        enter = {14.80, 1.44, -1.50, 90},

        defaultFurniture = {},

        textureNames = {
            {name = 'Ściany dużego pokoju', texture = 'INT_1_SCIANA_POKOJ_DUZY', type = 'wall'},
            {name = 'Podłoga w dużym pokoju', texture = 'INT_1_PODLOGA_DUZY_POKOJ', type = 'floor'},
            {name = 'Sufit dużego pokoju', texture = 'INT_1_SUFIT_DUZY_POKOJ', type = 'floor'},
            {name = 'Ściany małego pokoju', texture = 'INT_1_SCIANA_POKOJ_MALY', type = 'wall'},
            {name = 'Sufit małego pokoju', texture = 'INT_1_SUFIT_MALY_POKOJ', type = 'floor'},
            {name = 'Podłoga w małym pokoju', texture = 'INT_1_PODLOGA_MALY_POKOJ', type = 'floor'},
            {name = 'Ściany łazienki', texture = 'INT_1_SCIANA_LAZIENKA', type = 'wall'},
            {name = 'Podłoga w łazience', texture = 'INT_1_PODLOGA_LAZIENKA', type = 'floor'},
            {name = 'Sufit łazienki', texture = 'INT_1_SUFIT_LAZIENKA', type = 'floor'},
            {name = 'Ściany przedpokoju', texture = 'INT_1_SCIANA_PRZEDPOKOJ', type = 'wall'},
            {name = 'Podłoga w przedpokoju', texture = 'INT_1_PODLOGA_PRZEDPOKOJ', type = 'floor'},
            {name = 'Sufit przedpokoju', texture = 'INT_1_SUFIT_PRZEDPOKOJ', type = 'floor'},
            {name = 'Ściany kuchni', texture = 'INT_1_SCIANA_KUCHNIA', type = 'wall'},
            {name = 'Podłoga w kuchni', texture = 'INT_1_PODLOGA_KUCHNIA', type = 'floor'},
            {name = 'Sufit kuchni', texture = 'INT_1_SUFIT_KUCHNIA', type = 'floor'},
        }
    },
    [6] = {
        description = 'Duże mieszkanie z basenem i dużą sypialnią z widokiem na miasto oraz łazienką.',
        bedrooms = 1,
        maxTenants = 4,

        model = 'int-6',
        enter = {-6.93, -1.42, -0.66, -90},

        defaultFurniture = {},

        textureNames = {
            {name = 'Ściany sypalni', texture = 'sciana1', type = 'wall'},
            {name = 'Podłoga w sypialni', texture = 'podloga3', type = 'floor'},
            {name = 'Ściany toalety', texture = 'sciana2', type = 'wall'},
            {name = 'Ściany salonu 1', texture = 'sciana4', type = 'wall'},
            {name = 'Ściany salonu 2', texture = 'sciana5', type = 'wall'},
            {name = 'Podłoga salonu 1', texture = 'podloga2', type = 'floor'},
            {name = 'Podłoga salonu 2', texture = 'podloga1', type = 'floor'},
            {name = 'Sufit', texture = 'sufit', type = 'floor'},
        }
    },
}

interiorTextures = {
    {name = 'Murowana', texture = 'wall-1', type = 'wall'},
    {name = 'Mieszanka', texture = 'wall-2', type = 'wall'},
    {name = 'Hotelowa', texture = 'wall-3', type = 'wall'},
    {name = 'Przyjemna', texture = 'wall-4', type = 'wall'},
    {name = 'Panele', texture = 'floor-1', type = 'floor'},
    {name = 'Dywan', texture = 'floor-2', type = 'floor'},
    {name = 'Szary dywan', texture = 'floor-3', type = 'floor'},
    {name = 'Panele', texture = 'floor-4', type = 'floor'},
    {name = 'Deski', texture = 'floor-5', type = 'floor'},
}

function getInteriors()
    return houseInteriors
end