local actions = {}

local function checkArguments(argumentsDefinitions, arguments, codeGeneration)
    local result = {}

    for index, definition in ipairs(argumentsDefinitions) do
        local value = arguments[index]

        if not value then
            if definition.default ~= nil then
                value = definition.default
            else
                error(('Argument %s (%d) is required'):format(definition.name, index))
            end
        end

        if definition.check then
            if not definition.check(value) then
                error(('Argument %s (%d) is invalid, got %s'):format(definition.name, index, inspect(value)))
            end
        end

        table.insert(result, value)
    end

    if codeGeneration then
        local lastArgument = arguments[#arguments]
        table.insert(result, lastArgument)
    end

    return result
end

function defineMissionAction(data)
    local action = {
        data = data
    }

    setmetatable(action, {
        __call = function(self, _, specialId, ...)
            local arguments = data.specialId and {...} or {specialId, ...}

            arguments = checkArguments(data.arguments, arguments, data.codeGeneration)
            local element = data.callback(unpack(arguments))

            if element then
                if data.specialId then
                    addSpecialMissionElement(specialId, element)
                else
                    addMissionElement(element)
                end
            end
        end
    })

    actions[data.name] = action
end

function getActions()
    return actions
end

function getAction(name)
    return actions[name]
end