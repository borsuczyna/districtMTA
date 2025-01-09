addEvent('onPlaybackFinished')

defineMissionAction({
    name = 'playPlayback',
    editorName = 'Uruchom nagranie',
    arguments = {
        String('Ped', ''),
        Recording('Nazwa'),
        Checkbox('Poczekaj na zakończenie')
    },
    callback = function(ped, name, wait)
        local ped = getMissionElement(ped)
        exports['m-record']:startPlayback(name, ped)
        table.insert(playedPlaybacks, name)

        if wait then
            await(waitForPlaybackFinish(name))
        end
    end,
})

function waitForPlaybackFinish(playbackName)
    return Promise:new(function(resolve, _)
        addEventHandler('onPlaybackFinished', resourceRoot, function(name)
            if name == playbackName then
                resolve()
            end
        end)
    end)
end