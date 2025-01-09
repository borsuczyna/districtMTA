addEvent('onMissionVehicleEnter')

defineMissionEvent({
    name = 'onVehicleEnter',
    editorName = 'Gdy gracz wejdzie do pojazdu',
    arguments = {
        String('ID pojazdu'),
        Number('Siedzenie'),
    },
    generate = function(vehicle, seat)
        return {
            arguments = {'vehicle', 'seat'},
            header = ('if vehicle == %q and seat == %d then'):format(vehicle, seat),
            footer = 'end',
            tabs = 1,
        }
    end,
})

addEventHandler('onClientVehicleEnter', root, function(ped, seat)
    if ped ~= localPlayer then return end

    local specialId = getElementData(source, 'mission:element')
    if not specialId then return end
    
    triggerEvent('onMissionVehicleEnter', resourceRoot, specialId, seat)
end)

addEventHandler('onMissionVehicleEnter', resourceRoot, function(vehicle, seat)
    triggerMissionEvent('onVehicleEnter', vehicle, seat)
end)