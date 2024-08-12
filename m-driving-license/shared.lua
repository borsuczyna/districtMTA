local examElements = {}
local defaultRoute = {
    spawn = {1420.913, -1682.169, 13.271, 0.001, 0.000, 269.637},
    finish = {
        interior = 3,
        dimension = 0,
        position = {210.098, 142.230, 1003.023},
    },
    checkpoints = {
        -- {text, x, y, z, distance, angle, possible angle difference}
        {'Wyjedź z placu', 1431.459, -1670.396, 13.116, 4},
        {'Jedź prosto', 1431.604, -1652.124, 13.107, 4},
        {'Zaparkuj równolegle między dwoma pojazdami', 1436.138, -1625.743, 13.271, 1, 0, 3},
    },
    callbacks = {
        [1] = function()
            destroyExamElement('vehicle1')
            destroyExamElement('vehicle2')
            
            examElements['vehicle1'] = createVehicle(401, 1436.277, -1619.992, 13.265, 0, 0, 0)
            examElements['vehicle2'] = createVehicle(401, 1436.203, -1631.510, 13.271, 0, 0, 0)

            setElementFrozen(examElements['vehicle1'], true)
            setElementFrozen(examElements['vehicle2'], true)
        end
    }
}

local examMarkers = {
    {221.137, 147.822, 1003.023, 3},
    {215.873, 147.662, 1003.023, 3},
    {210.601, 148.936, 1003.023, 3},
}

examsData = {
    A = defaultRoute,
    B = defaultRoute,
    C = defaultRoute,
}

function destroyAllExamElements()
    for k, v in pairs(examElements) do
        if isElement(v) then
            destroyElement(v)
        end
    end
    examElements = {}
end

function destroyExamElement(name)
    if examElements[name] and isElement(examElements[name]) then
        destroyElement(examElements[name])
        examElements[name] = nil
    end
end

function angleDifference(a, b)
    local diff = b - a
    if diff > 180 then
        diff = diff - 360
    elseif diff < -180 then
        diff = diff + 360
    end
    return diff
end

local function onClientMarkerHit(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
    
    setDrivingLicenseUIVisible(true)
end

local function onClientMarkerLeave(leaveElement, matchingDimension)
    if leaveElement ~= localPlayer or not matchingDimension then return end
    
    setDrivingLicenseUIVisible(false)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    for k, v in pairs(examMarkers) do
        local marker = createMarker(v[1], v[2], v[3] - 1, 'cylinder', 1, 0, 0, 255, 100)
        setElementInterior(marker, v[4])
        setElementData(marker, 'marker:title', 'Egzamin')
        setElementData(marker, 'marker:desc', 'Egzamin na prawo jazdy')
        addEventHandler('onClientMarkerHit', marker, onClientMarkerHit)
        addEventHandler('onClientMarkerLeave', marker, onClientMarkerLeave)
    end
end)