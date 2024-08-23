addEvent('enter:interior', true)

local enters = {
    {
        marker = {2244.464, -1665.043, 15.477},
        interior = 0,
        target = {309.867, -530.913, 97.625},
        targetInterior = 1,
        name = 'Wejście',
        description = 'Przebieralnia',
        longDescrption = 'Tutaj zmienisz swoje ubrania',
    },
    {
        marker = {311.857, -531.112, 97.625},
        interior = 1,
        target = {2245.240, -1662.659, 15.469},
        targetInterior = 0,
        name = 'Wyjście',
        description = 'Przebieralnia',
        longDescrption = 'Wyście z przebieralni',
    },
    {
        marker = {1113.453, -1835.986, 16.600},
        interior = 0,
        target = {209.912, 142.263, 1003.023},
        targetInterior = 3,
        name = 'Wejście',
        description = 'Szkoła jazdy',
        longDescrption = 'Wejście do szkoły jazdy',
    },
    {
        marker = {208.447, 142.263, 1003.023},
        interior = 3,
        target = {1111.955, -1836.037, 16.601},
        targetInterior = 0,
        name = 'Wyjście',
        description = 'Szkoła jazdy',
        longDescrption = 'Wyście ze szkoły jazdy',
    },
}

addEventHandler('onResourceStart', resourceRoot, function()
    for i, enter in ipairs(enters) do
        local x, y, z = unpack(enter.marker)
        enter.marker = createMarker(x, y, z - 1, 'cylinder', 1, 255, 140, 0, 0)
        setElementInterior(enter.marker, enter.interior)
        setElementData(enter.marker, 'marker:title', enter.name)
        setElementData(enter.marker, 'marker:desc', enter.description)
        setElementData(enter.marker, 'marker:longDesc', enter.longDescrption)
        setElementData(enter.marker, 'marker:enter', i)
    end
end)

addEventHandler('enter:interior', resourceRoot, function(id)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `enter:interior` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local enter = enters[id]
    if not enter then return end

    local x, y, z = unpack(enter.target)
    setElementPosition(client, x, y, z)
    setElementInterior(client, enter.targetInterior)
end)