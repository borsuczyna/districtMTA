exports['m-factions']:createShelfMarker('ERS', {1777.939, -1751.825, 13.539}, {
    {
        name = 'Ubrania',
        items = {
            {item = 'Test skin', permissions = {'manageFaction', 'defaultEquipment'}, skin = 283},
            {item = 'Ubranie cywilne', permissions = {'manageFaction', 'duty'}, skin = 'default'},
        }
    },
    {
        name = 'Sprzet',
        items = {
            {item = 'Gasnica', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 42, ammo = 9999},
            {item = 'Pila spalinowa', permissions = {'manageFaction', 'defaultEquipment'}, weapon = 9, ammo = 1000},
        }
    },
})

exports['m-factions']:createManagePanel('ERS', {1790.112, -1753.899, 13.539})
exports['m-factions']:createDutyMarker('ERS', {1781.921, -1751.811, 13.539})

exports['m-factions']:createGate('ERS', 'models/police_station_ls_door', {1786.1, -1755.803, 12.539, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('ERS', 'models/police_station_ls_door', {1786.1, -1759, 12.539, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('ERS', 'models/police_station_ls_door', {1790.9, -1755.803, 12.539, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)

exports['m-factions']:createVirtualParking('ERS', {1764.022, -1792.688, 13.383}, {1775.587, -1785.105, 13.614, 0, 0, 270}, {
    {name = 'Straż', model = 407, permissions = {'manageFaction', 'defaultEquipment'}, handling = {
        engineAcceleration = 8,
    }},
    {name = 'Ambulans', model = 416, permissions = {'manageFaction', 'defaultEquipment'}, handling = {
        engineAcceleration = 8,
    }},
})

exports['m-factions']:createVehicleStorage(416, 'Ambulans', {0, -4.5, -1}, 'ERS', {
    {
        name = 'Podstawowe',
        items = {
            {item = 'Nosze', permissions = {'manageFaction', 'defaultEquipment'}, callback = 'useStretcher'},
            {item = 'Deska', permissions = {'manageFaction', 'defaultEquipment'}, callback = 'usePlank'},
            {item = 'Torba R1', permissions = {'manageFaction', 'defaultEquipment'}, callback = 'useR1Bag'},
        }
    },
})

local blip = createBlip(1786.661, -1777.150, 14.656, 12, 2, 255, 0, 0, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Emergency Rescue Service')