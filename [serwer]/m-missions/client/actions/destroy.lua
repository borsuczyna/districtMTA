addEvent('missions:destroyedMissionElement', true)

defineMissionAction({
    name = 'destroy',
    editorName = 'Zniszcz element',
    arguments = {
        String('ID elementu', '')
    },
    callback = function(specialId)
        local element = getMissionElement(specialId)

        if isElement(element) and not isElementLocal(element) then
            triggerServerEvent('missions:destroyMissionElement', resourceRoot, element, specialId)
            await(waitForElementDestroy(specialId))
            return
        end

        if isElement(element) then
            destroyElement(element)
        end
    end
})

function waitForElementDestroy(element)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:destroyedMissionElement', resourceRoot, function(destroyedElement)
            if destroyedElement == element then
                resolve()
            end
        end)
    end)
end