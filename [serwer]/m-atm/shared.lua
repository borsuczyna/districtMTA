local atms = {
    {224.142, 142.2, 1003.023, 0, 0, 90, 3},
    {1926.686, -1783.44, 13.545, -0.000, 0.000, 1}
}

local function createAtm(atm)
    local x, y, z, rx, ry, rz = unpack(atm)
    
    if localPlayer then
        local atmObject = createObject(2942, x, y, z - 0.35, rx, ry, rz + 180)
        setElementFrozen(atmObject, true)
        setObjectBreakable(atmObject, false)
        if atm[7] then
            setElementInterior(atmObject, atm[7])
        end

        local colShape = createColSphere(x, y, z, 1.5)
        attachElements(colShape, atmObject, 0, 0, 0)
        addEventHandler('onClientColShapeHit', colShape, onAtmHit)
        addEventHandler('onClientColShapeLeave', colShape, onAtmLeave)
    else
        local blip = createBlip(x, y, z, 53, 2, 255, 0, 0, 255, 0, 9999)
        setElementData(blip, 'blip:hoverText', 'Bankomat')
        if atm[7] then
            setElementInterior(blip, atm[7])
        end
    end
end

local function createAtms()
    for i, atm in ipairs(atms) do
        createAtm(atm)
    end
end

createAtms()