addEvent('missions:warpedIntoMissionVehicle', true)

defineMissionAction({
    name = 'warpIntoVehicle',
    editorName = 'Przenieś peda do pojazdu',
    arguments = {
        String('Ped', ''),
        String('Pojazd', ''),
        Number('Siedzenie', 0),
    },
    callback = function(ped, vehicle, seat, primaryColor, secondaryColor)
        local ped = getMissionElement(ped)
        local vehicle = getMissionElement(vehicle)

        if not isElementLocal(ped) and not isElementLocal(vehicle) then
            triggerServerEvent('missions:warpIntoMissionVehicle', resourceRoot, ped, vehicle, seat)
            await(waitForWarpToVehicle(ped, vehicle))
            return
        end
        
        return warpPedIntoVehicle(ped, vehicle, seat)
    end
})

function waitForWarpToVehicle(ped, vehicle)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:warpedIntoMissionVehicle', resourceRoot, function(warpedPed, warpedTo)
            if ped == warpedPed and warpedTo == vehicle then
                resolve()
            end
        end)
    end)
end