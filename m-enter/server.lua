addEvent('enter:interior', true)

local enters = {
    {
        marker = {1922.031, -1795.087, 13.383},
        interior = 0,
        target = {1944.677, -1788.690, 13.383},
        targetInterior = 0,
        name = 'Wejście',
        description = 'Przechowalnia pojazdów',
        longDescrption = 'Tutaj schowasz i wyciągniesz swój pojazd prywatny, organizacyjny lub pożyczony od znajomego',
    },
    {
        marker = {1946.033, -1789.626, 13.383},
        interior = 0,
        target = {1920.972, -1796.491, 13.383},
        targetInterior = 1,
        name = 'Wyjście',
        description = 'Przechowalnia pojazdów',
        longDescrption = 'Wyjście z przechowalni pojazdów',
    }
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
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local enter = enters[id]
    if not enter then return end

    local x, y, z = unpack(enter.target)
    setElementPosition(client, x, y, z)
    setElementInterior(client, enter.targetInterior)
end)