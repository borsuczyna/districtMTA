houseInteriors = {
    [1] = {
        description = 'Mały mieszkanie lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        bedrooms = 1,
        maxTenants = 2,
        defaultFurniture = {
            -- @TODO
        },

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
    }
}

interiorTextures = {
    {name = 'A test', texture = 'a', type = 'wall'},
    {name = 'B test', texture = 'b', type = 'floor'},
    {name = 'C test', texture = 'c', type = 'wall'},
}