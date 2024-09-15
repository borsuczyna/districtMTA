defineMissionAction({
    name = 'warpIntoVehicle',
    editorName = 'Przenieś peda do pojazdu',
    arguments = {
        String('Ped', ''),
        String('Pojazd', ''),
        Number('Siedzenie', 0),
    },
    callback = function(ped, vehicle, seat)
        local ped = getMissionElement(ped)
        local vehicle = getMissionElement(vehicle)
        
        return warpPedIntoVehicle(ped, vehicle, seat)
    end
})