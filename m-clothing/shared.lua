clothes = {
    -- nie powtarzajace sie nazwy, nie moze byc koszula 1, koszula 2 etc.
    {name = 'CJ', model = 0},
    {name = 'Szarak', model = 7},
    {name = 'Koszula', model = 8},
    {name = 'Koszula z krawatem', model = 9},
    {name = 'Koszula z krawatem', model = 10},
    {name = 'Koszula z krawatem', model = 11},
    {name = 'Koszula z krawatem', model = 12},
    {name = 'Koszula z krawatem', model = 13},
    {name = 'Koszula z krawatem', model = 14},
    {name = 'Koszula z krawatem', model = 15},
    {name = 'Koszula z krawatem', model = 16},
    {name = 'Koszula z krawatem', model = 17},
    {name = 'Koszula z krawatem', model = 18},
    {name = 'Koszula z krawatem', model = 19},
    {name = 'Koszula z krawatem', model = 20},
    {name = 'Koszula z krawatem', model = 21},
    {name = 'Koszula z krawatem', model = 22},
    {name = 'Koszula z krawatem', model = 23},
    {name = 'Koszula z krawatem', model = 24},
    {name = 'Koszula z krawatem', model = 25},
    {name = 'Koszula z krawatem', model = 26},
    {name = 'Koszula z krawatem', model = 27},
    {name = 'Koszula z krawatem', model = 28},
    {name = 'Koszula z krawatem', model = 29},
    {name = 'Koszula z krawatem', model = 30},
    {name = 'Koszula z krawatem', model = 31},
    {name = 'Koszula z krawatem', model = 32},
    {name = 'Koszula z krawatem', model = 33},
    {name = 'Koszula z krawatem', model = 34},
}

clothingShops = {
    {305.712, -550.558, 97.851, 1},
    {298.290, -550.167, 97.851, 1},
    {301.050, -510.442, 97.844, 1},
    {308.528, -510.919, 97.848, 1}
}

local blips = {
    {2245.213, -1663.606, 15.477},
}

if localPlayer then
    for i, v in ipairs(clothingShops) do
        local x, y, z = v[1], v[2], v[3]
        local marker = createMarker(x, y, z - 1, 'cylinder', 1, 255, 255, 0, 150)
        setElementInterior(marker, v[4])
        setElementData(marker, 'marker:title', 'Przebieralnia')
        setElementData(marker, 'marker:desc', 'Zmiana ubrania')
        addEventHandler('onClientMarkerHit', marker, clothingMarkerHit)
        addEventHandler('onClientMarkerLeave', marker, clothingMarkerLeave)
    end
else
    for i, v in ipairs(blips) do
        local blip = createBlip(v[1], v[2], v[3], 45, 2, 255, 255, 255, 255, 0, 9999.0)
    end
end