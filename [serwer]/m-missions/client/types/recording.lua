addEvent('missions:startRecording')

function Recording(name)
    return {
        name = name,
        type = 'recording',
        default = '',
        check = function(value)
            return type(value) == 'string'
        end,
        toCode = function(value)
            return string.format('%q', value)
        end
    }
end

addEventHandler('missions:startRecording', root, function(name)
    executeCommandHandler('record', name)
end)