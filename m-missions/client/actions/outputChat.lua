defineMissionAction({
    name = 'outputChat',
    editorName = 'Wiadomość na chacie',
    arguments = {
        String('Wiadomość', 'Hello World'),
        Color('Kolor', {255, 255, 255, 255})
    },
    callback = function(message, color)
        local r, g, b = unpack(color)
        outputChatBox(message, r, g, b, true)
    end
})