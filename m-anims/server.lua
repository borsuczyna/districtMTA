function removeCustomAnimation(ped)
    setElementData(ped, "player:animation", nil)
    setElementData(ped, "player:animation:start", false)
    setElementData(ped, "player:animation:frame", false)
end

function playCustomAnimation(ped, name, frame)
    setElementData(ped, "player:animation", name)
    setElementData(ped, "player:animation:start", getTickCount())
    setElementData(ped, "player:animation:frame", (frame or 1))
end