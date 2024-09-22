exports['m-factions']:createShelfMarker('SAPD', {2044.955, -1910.402, 13.703}, {
    {
        name = 'Ubrania',
        items = {
            {item = 'Test skin', permissions = {'manageFaction', 'defaultEquipment'}, callback = function(player)
                setElementModel(player, 283)
            end},
            {item = 'Ubranie cywilne', permissions = {'manageFaction', 'duty'}, callback = function(player)
                setElementModel(player, getElementData(player, 'player:skin'))
            end},
        }
    },
    {
        name = 'Bronie',
        items = {
            {item = 'Teaser', permissions = {'manageFaction', 'defaultEquipment'}, callback = function(player)
                giveWeapon(player, 23, 1000)
            end},
        }
    },
})

exports['m-factions']:createManagePanel('SAPD', {2053.405, -1909.586, 13.703})
exports['m-factions']:createDutyMarker('SAPD', {2059.181, -1888.789, 13.703})

exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2049.736, -1883.550, 12.703, 0, 0, 90}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2049.1, -1888.920, 12.703, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)
exports['m-factions']:createGate('SAPD', 'models/police_station_ls_door', {2051.604, -1906.344, 12.703, 0, 0, 0}, {0, 0, 0, 0, 0, 90}, 1.5, 700, true)