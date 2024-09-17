addEvent('missions:receiveServerSidePed', true)

defineMissionAction({
    name = 'createPed',
    editorName = 'Stwórz peda',
    specialId = true,
    arguments = {
        Number('Model'),
        Position('Pozycja'),
        Rotation('Rotacja')
    },
    codeGeneration = function(specialId, model, position, rotation)
        local index = #allowedMissionPeds + 1
        allowedMissionPeds[index] = {
            specialId = specialId,
            model = model,
            position = position,
            rotation = rotation
        }

        return index
    end,
    callback = function(model, position, rotation, index)
        triggerServerEvent('missions:requestServerSidePed', resourceRoot, getCurrentMission(), index)
        local ped = await(waitForPedCreation(index))
        return ped
    end,
})

function waitForPedCreation(index)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:receiveServerSidePed', resourceRoot, function(mission, pedIndex, ped)
            if pedIndex == index then
                resolve(ped)
            end
        end)
    end)
end