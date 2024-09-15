addEvent('missions:toggleAnimationEditor')

function Animation(name)
    return {
        name = name,
        type = 'animation',
        default = '',
        check = function(value)
            return type(value) == 'string'
        end,
        toCode = function(value)
            return string.format('%q', value)
        end
    }
end

addEventHandler('missions:toggleAnimationEditor', root, function()
    exports['m-anim']:toggleAnimUI()
end)