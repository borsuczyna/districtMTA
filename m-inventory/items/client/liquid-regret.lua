local usages = {}

addEvent('item:applyDrunkEffect', true)
addEventHandler('item:applyDrunkEffect', resourceRoot, function()
    local player = source

    if not usages[player] then
        usages[player] = {count = 0, strength = 0.02}
    end

    local data = usages[player]
    data.count = data.count + 1
    data.strength = data.strength + 0.02

    local effectDuration = data.count * 10
    exports['m-screen-effects']:addDrunkEffect(true, data.strength, effectDuration)

    setTimer(function()
        data.count = 0
        data.strength = 0.02
    end, effectDuration * 1000, 1)
end)