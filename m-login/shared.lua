spawns = {
    {
        name = 'Los Santos',
        spawns = {
            {'Spawn Pershing Square', 1479.608, -1675.643, 13.555, 180},
            {'Góra Galileo', 1147.351, -2037.077, 69.008, -90},
            {'Szkoła jazdy', 1109.498, -1835.956, 16.603, -90},
        }
    },
    {
        name = 'Wioski',
        spawns = {
            {'Blueberry', 280, -100, 0, 0},
            {'Fort Carson', -62, 1045, 0, 0},
            {'Dillimore', 713.52167, -522.02460, 16.32814, 0},
        }
    },
}

function getSpawnsByName(name)
    for i, v in ipairs(spawns) do
        if v.name == name then
            return v.spawns
        end
    end
    return {}
end

function getSpawn(name, index)
    local spawns = getSpawnsByName(name)
    if not spawns then
        return false
    end
    return spawns[index]
end