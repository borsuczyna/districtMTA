addEvent('missions:onVoiceLineFinish', true)

defineMissionAction({
    name = 'pedTellVoiceLine',
    editorName = 'Ped mówi dialog',
    arguments = {
        String('Ped', ''),
        String('Nazwa dźwięku', ''),
        String('Tekst', ''),
        Checkbox('Poczekać na zakończenie dialogu', false),
    },
    callback = function(ped, soundName, text, wait)
        local ped = getMissionElement(ped)
        pedTellVoiceLine(ped, soundName, text)

        if wait then
            await(waitForDialogFinish(soundName))
        end
    end,
})

function waitForDialogFinish(markerId)
    return Promise:new(function(resolve, _)
        addEventHandler('missions:onVoiceLineFinish', resourceRoot, function(soundName)
            if soundName == markerId then
                resolve()
            end
        end)
    end)
end

defineMissionAction({
    name = 'setMissionTarget',
    editorName = 'Ustaw cel misji',
    arguments = {
        String('Cel', ''),
    },
    callback = function(target)
        setMissionTarget(target)
    end,
})