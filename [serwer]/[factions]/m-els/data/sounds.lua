sounds = {
    [597] = {
        -- key = {"sound", volume, minimal distance, max distance},
        [1] = {"1.wav", 1, 10, 40},
        [2] = {"2.wav", 1, 20, 40},
    }
}

function getVehicleSounds(veh)
    if type(veh) == "number" then
        return sounds[veh]
    end

    local veh = getElementModel(veh)
    return sounds[veh]
end