addEvent('onPlaybackFinished')

defineMissionAction({
    name = 'playPlayback',
    editorName = 'Uruchom nagranie',
    arguments = {
        String('Ped', ''),
        Recording('Nazwa'),
    },
    callback = function(ped, name)
        local ped = getMissionElement(ped)
        exports['m-record']:startPlayback(name, ped)
        table.insert(playedPlaybacks, name)
    end,
    promise = {
        name = 'Poczekaj aż nagranie się zakończy',
        toCode = function(args)
            return ('waitForPlaybackFinish(%q)'):format(args['2'])
        end
    }
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