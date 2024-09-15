defineMissionAction({
    name = 'destroyPlaybackElements',
    editorName = 'Zniszcz elementy nagrania',
    arguments = {
        Recording('Nazwa'),
    },
    callback = function(name)
        exports['m-record']:destroyPlaybackElements(name)
    end
})