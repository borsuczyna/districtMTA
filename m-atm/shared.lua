local atms = {
    {1105.074, -1827.607, 33.629, -0.000, 0.000, 353.770},
}

local function createAtm(atm)
    local x, y, z, rx, ry, rz = unpack(atm)
    
    if localPlayer then
        local atmObject = createObject(2942, x, y, z - 0.35, rx, ry, rz + 180)
        setElementFrozen(atmObject, true)
        setObjectBreakable(atmObject, false)

        local colShape = createColSphere(x, y, z, 1.5)
        attachElements(colShape, atmObject, 0, 0, 0)
        addEventHandler('onClientColShapeHit', colShape, onAtmHit)
        addEventHandler('onClientColShapeLeave', colShape, onAtmLeave)
    else
        local blip = createBlip(x, y, z, 53, 2, 255, 0, 0, 255, 0, 9999)
    end
end

local function createAtms()
    for i, atm in ipairs(atms) do
        createAtm(atm)
    end
end

createAtms()