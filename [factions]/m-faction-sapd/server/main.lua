exports['m-factions']:createShelfMarker('SAPD', {2044.955, -1910.402, 13.703}, {
    {
        name = 'Ubrania',
        items = {
            {item = 'Test skin', permissions = {'manageFaction', 'defaultEquipment'}, skin = 283},
            {item = 'Ubranie cywilne', permissions = {'manageFaction', 'duty'}, skin = 'default'},
        }
    },
    {
        name = 'Bronie',
        items = {
            {item = 'Taser', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 23, ammo = 1000},
            {item = 'Deagle', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 24, ammo = 1000},
            {item = 'Baton', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 3, ammo = 1000},
            {item = 'Suszarka', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 22, ammo = 1000},
            {item = 'Beanbag', permissions = {'manageFaction', 'midEquipment'}, weapon = 25, ammo = 1000},
            {item = 'Combat', permissions = {'manageFaction', 'midEquipment'}, weapon = 27, ammo = 1000},
            {item = 'Myśliwski', permissions = {'manageFaction', 'highEquipment'}, weapon = 33, ammo = 1000},
            {item = 'Karabin snajperski', permissions = {'manageFaction', 'highEquipment'}, weapon = 34, ammo = 1000},
            {item = 'M4', permissions = {'manageFaction', 'highEquipment'}, weapon = 31, ammo = 1000},
        }
    },
})

exports['m-factions']:createManagePanel('SAPD', {2053.405, -1909.586, 13.703})
exports['m-factions']:createDutyMarker('SAPD', {2059.181, -1888.789, 13.703})

exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2049.736, -1883.550, 12.703, 0, 0, 90}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2049.1, -1888.920, 12.703, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2051.604, -1906.344, 12.703, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)