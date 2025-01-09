addEvent('missions:changedEngineState', true)

defineMissionAction({
    name = 'setEngineState',
    editorName = 'Ustaw stan silnika pojazdu',
    arguments = {
        String('ID elementu', ''),
        Checkbox('Uruchomiony'),
    },
    callback = function(specialId, engineState)
        local element = getMissionElement(specialId)

        if not isElementLocal(element) then
            triggerServerEvent('missions:setEngineState', resourceRoot, element, engineState)
            await(waitForElementEngineStateChange(element))
            return
        end

        if isElement(element) then
            setVehicleEngineState(element, engineState)
        end
    end
})

function waitForElementEngineStateChange(element)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:changedEngineState', resourceRoot, function(vehicle)
            if vehicle == element then
                resolve()
            end
        end)
    end)
end