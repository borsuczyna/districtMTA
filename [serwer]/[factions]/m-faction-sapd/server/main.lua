exports['m-factions']:createShelfMarker('SAPD', {2044.955, -1910.402, 13.703}, {
    {
        name = 'Ubrania',
        items = {
            {item = 'Cadet', permissions = {'manageFaction', 'defaultEquipment'}, skin = 265},
            {item = 'Police Officer I', permissions = {'manageFaction', 'defaultEquipment'}, skin = 280},
            {item = 'Police Officer II', permissions = {'manageFaction', 'defaultEquipment'}, skin = 281},
            {item = 'Police Officer III+1', permissions = {'manageFaction', 'defaultEquipment'}, skin = 282},
            {item = 'Sergeant I', permissions = {'manageFaction', 'defaultEquipment'}, skin = 283},
            {item = 'Sergeant II', permissions = {'manageFaction', 'defaultEquipment'}, skin = 284},
            {item = 'Sergeant I', permissions = {'manageFaction', 'defaultEquipment'}, skin = 285},
            {item = 'Corporal I', permissions = {'manageFaction', 'defaultEquipment'}, skin = 266},
            {item = 'Corporal II', permissions = {'manageFaction', 'defaultEquipment'}, skin = 267},
            {item = 'Command', permissions = {'manageFaction', 'highEquipment'}, skin = 286},
            {item = 'Unmarked #1', permissions = {'manageFaction', 'midEquipment'}, skin = 23},
            {item = 'Unmarked #2', permissions = {'manageFaction', 'midEquipment'}, skin = 29},
            {item = 'Unmarked #3', permissions = {'manageFaction', 'midEquipment'}, skin = 221},
            {item = 'Unmarked #4', permissions = {'manageFaction', 'midEquipment'}, skin = 217},
            {item = 'Unmarked #5', permissions = {'manageFaction', 'midEquipment'}, skin = 250},
            {item = 'Unmarked #6', permissions = {'manageFaction', 'midEquipment'}, skin = 170},
            {item = 'Unmarked #7', permissions = {'manageFaction', 'midEquipment'}, skin = 93},
            {item = 'Unmarked #8', permissions = {'manageFaction', 'midEquipment'}, skin = 60},
            {item = 'Unmarked #9', permissions = {'manageFaction', 'midEquipment'}, skin = 306},
            {item = 'Unmarked #9', permissions = {'manageFaction', 'midEquipment'}, skin = 190},
            {item = 'Ubranie cywilne', permissions = {'manageFaction', 'duty'}, skin = 'default'},
        }
    },
    {
        name = 'Bronie',
        items = {
            {item = 'Taser', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 23, ammo = 1000},
            {item = 'Deagle', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 24, ammo = 1000},
            {item = 'Suszarka', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 22, ammo = 1000},
            {item = 'Beanbag', permissions = {'manageFaction', 'midEquipment'}, weapon = 25, ammo = 1000},
            {item = 'Combat', permissions = {'manageFaction', 'midEquipment'}, weapon = 27, ammo = 1000},
            {item = 'MP5', permissions = {'manageFaction', 'midEquipment'}, weapon = 29, ammo = 1000},
            {item = 'Spadochron', permissions = {'manageFaction', 'midEquipment'}, weapon = 46, ammo = 1000},
            {item = 'Gaz łzawiący', permissions = {'manageFaction', 'midEquipment'}, weapon = 17, ammo = 1000},
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

exports['m-factions']:createVirtualParking('SAPD', {2014.147, -1874.453, 13.281}, {2011.387, -1868.699, 13.3, 359.692, 360.000, 89.392}, {
    {name = 'Pojazd patrolowy', model = 596, permissions = {'manageFaction', 'defaultEquipment'}, handling = {
        engineAcceleration = 40,
    }},
})

local blip = createBlip(2065.934, -1907.856, 13.547, 8, 2, 255, 0, 0, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'San Andreas Police Department')