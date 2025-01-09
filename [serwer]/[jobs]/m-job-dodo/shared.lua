settings = {
    jobStart = Vector3(1953.009, -2179.168, 13.547),
    blipPosition = Vector3(1953.009, -2179.168, 13.547),
    vehiclePosition = {1993.350, -2382.331, 14.007, 0, 0, 90},
    moneyPerPackage = {1070, 1160}, -- w groszach, 1$ = 100
    upgradePointsPerPackage = {-5, 1},

    points = {

        {2257.420, -210.820, 96.182},

    }
}

function getRandomPoint()
    return settings.points[math.random(1, #settings.points)]
end

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end