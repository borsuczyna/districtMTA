addEvent('missions:movedToMissionDimension', true)
addEvent('missions:movedOutOfMissionDimension', true)

defineMissionAction({
    name = 'moveToMissionDimension',
    editorName = 'Przenieś do wymiaru misji',
    arguments = {},
    callback = function(specialId)
        triggerServerEvent('missions:moveToMissionDimension', resourceRoot)
        await(waitForMissionDimensionChange())
    end
})

function waitForMissionDimensionChange()
    return Promise:new(function(resolve, _)
        addEventHandler('missions:movedToMissionDimension', resourceRoot, function()
            resolve()
        end)
    end)
end