addEvent('missions:changedLightsState', true)

defineMissionAction({
    name = 'setLightsState',
    editorName = 'Ustaw stan świateł pojazdu',
    arguments = {
        String('ID elementu', ''),
        Checkbox('Włączone'),
    },
    callback = function(specialId, lightsState)
        local element = getMissionElement(specialId)

        if not isElementLocal(element) then
            triggerServerEvent('missions:setLightsState', resourceRoot, element, lightsState)
            await(waitForElementLightsStateChange(element))
            return
        end

        if isElement(element) then
            setVehicleOverrideLights(element, lightsState and 2 or 1)
        end
    end
})

function waitForElementLightsStateChange(element)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:changedLightsState', resourceRoot, function(vehicle)
            if vehicle == element then
                resolve()
            end
        end)
    end)
end