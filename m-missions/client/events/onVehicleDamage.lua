defineMissionEvent({
    name = 'onVehicleDamage',
    editorName = 'Gdy auto zostanie uszkodzone',
    arguments = {
        String('ID pojazdu'),
        Number('Minimalne uszkodzenie (0-1000)'),
    },
    generate = function(vehicle, damage)
        return {
            arguments = {'vehicle', 'damage'},
            header = ('if vehicle == %q and damage < %d then'):format(vehicle, damage),
            footer = 'end',
            tabs = 1,
        }
    end,
})

addEventHandler('onClientVehicleDamage', root, function(attacker, weapon, loss)
    local specialId = getElementData(source, 'mission:element')
    if not specialId then return end

    triggerMissionEvent('onVehicleDamage', specialId, getElementHealth(source))
end)