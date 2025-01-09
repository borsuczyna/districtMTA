clothes = {
    -- nie powtarzajace sie nazwy, nie moze byc koszula 1, koszula 2 etc.
    {name = 'CJ', model = 0},
    {name = 'Hipis', model = 1},
    {name = 'Szarak', model = 7},
    {name = 'Taksówkarz', model = 8},
    {name = 'Starsza kobieta', model = 9},
    {name = 'Babcia', model = 10},
    {name = 'Kelnerka', model = 11},
    {name = 'Modelka', model = 12},
    {name = 'Sąsiadka', model = 13},
    {name = 'Dziadek mróz', model = 14},
    {name = 'Pasiasty', model = 15},
    {name = 'Biznesman', model = 17},
    {name = 'Plażowicz', model = 18},
    {name = 'Członek gangu', model = 19},
    {name = 'Żółtek', model = 20},
    {name = 'Gangster', model = 21},
    {name = 'Luzak', model = 22},
    {name = 'Luzak', model = 23},
    {name = 'Tuner', model = 24},
    {name = 'George', model = 25},
    {name = 'Turysta', model = 26},
    {name = 'Robotnik', model = 27},
    {name = 'Diler', model = 28},
    {name = 'Rockstar', model = 29},
    {name = 'Koszula z krawatem', model = 30},
    {name = 'Kobieta z wioski', model = 31},
    {name = 'Pirat', model = 32},
    {name = 'Hitman', model = 33},
    {name = 'Wieśniak', model = 34},
    {name = 'Golfista', model = 36},
    {name = 'Klubowiczka', model = 40},
    {name = 'Nieznajomy', model = 42},
    {name = 'Chinczyk', model = 49},
    {name = 'Skater', model = 51},
    {name = 'Pracownik korporacji', model = 57},
    {name = 'Członek kartelu', model = 59},
    {name = 'Prostytutka', model = 64},
    {name = 'Bezdomny', model = 78},
    {name = 'Bezdomny', model = 79},
    {name = 'Bokser', model = 80},
    {name = 'Elvis', model = 82},
    {name = 'Blondynek', model = 97},
    {name = 'Hipis w kurtce', model = 101},
    {name = 'Ballas z bandana', model = 102},
    {name = 'Gruby ballas', model = 103},
    {name = 'Ballas w czapce', model = 104},
    {name = 'Gruby członek grove', model = 105},
    {name = 'Członek grove', model = 106},
    {name = 'Członek grove', model = 107},
    {name = 'Vagos', model = 108},
    {name = 'Vagos', model = 109},
    {name = 'Vagos', model = 110},
    {name = 'Rosyjski mafioza', model = 111},
    {name = 'Palacz', model = 134},
    {name = 'Rastafarianin', model = 136},
    {name = 'Człowiek pudło', model = 137},
    {name = 'Pracownik pizzeri', model = 155},
    {name = 'Farmer', model = 158},
    {name = 'Kuzyn', model = 162},
    {name = 'Ochroniarz', model = 163},
    {name = 'Ochroniarz', model = 164},
    {name = 'Agent', model = 165},
    {name = 'Agent', model = 166},
    {name = 'Szef kuchni', model = 168},
    {name = 'Punk', model = 181},
    {name = 'Nauczyciel', model = 186},
    {name = 'Wysportowana kobieta', model = 190},
    {name = 'Ninja', model = 204},
    {name = 'Foliarz', model = 212},
    {name = 'Brodacz', model = 221},
    {name = 'Bezdomny', model = 230},
    {name = 'Elegant', model = 240},
    {name = 'Stylowy', model = 249},
    {name = 'Ratowniczka', model = 251},
    {name = 'Golas', model = 252},
    {name = 'Kierowca autobusu', model = 253},
    {name = 'Kierowca limuzyny', model = 255},
    {name = 'Big Smoke', model = 269},
    {name = 'Sweet', model = 270},
    {name = 'Ryder', model = 271},
    {name = 'Żołnierz', model = 287},
    {name = 'Madd Dogg', model = 297},
    {name = 'Psychopata', model = 312},
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