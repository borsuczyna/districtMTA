local examElements = {}
local defaultRoute = {
    vehicle = 546,
    spawn = {1098.851, -1763.798, 13.074, 0.135, 359.976, 89.709},
    finish = {
        interior = 3,
        dimension = 0,
        position = {210.098, 142.230, 1003.023},
    },
    checkpoints = {
        -- {text, x, y, z, distance, angle, possible angle difference}
        {'Przygotuj się do jazdy i wyjedź z placu', 1109.877, -1743.222, 13.123, 4},
        {'Na skrzyżowaniu skręć w prawo', 1160.351, -1743.208, 13.123, 4},
        {false, 1173.066, -1790.062, 13.123, 4},
        {'Na następnym skrzyżowaniu w lewo', 1173.006, -1837.625, 13.146, 4},
        {'Jedź prosto a następnie w lewo', 1270.426, -1854.593, 13.107, 4},
        {false, 1314.794, -1825.143, 13.107, 4},
        {'Skręć w prawo do centrum', 1314.908, -1748.946, 13.107, 4},
        {false, 1331.386, -1734.564, 13.109, 4},
        {'Zaparkuj tyłem między dwoma pojazdami', 1349.470, -1752.868, 13.106, 1, 0, 3},
        {'Wyjedź z parkingu', 1375.920, -1734.648, 13.107, 4},
        {'Skręć w lewo', 1405.589, -1734.507, 13.115, 4},
        {false, 1432.009, -1717.959, 13.105, 4},
        {'Jedź cały czas prosto', 1436.677, -1545.793, 13.094, 4},
        {false, 1456.704, -1461.117, 13.095, 4},
        {'Skręć w prawo', 1513.038, -1443.213, 13.105, 4},
        {'Zjedź do garażu podziemnego', 1530.776, -1475.571, 9.222, 4},
        {'Zaparkuj równolegle między dwoma pojazdami', 1511.490, -1468.608, 9.211, 1, 0, 3},
        {'Wyjedź z garażu i skręć w lewo', 1500.180, -1438.398, 13.107, 4},
        {'Na skrzyżowaniu jedź prosto', 1471.379, -1438.451, 13.107, 4},
        {false, 1374.523, -1392.915, 13.211, 4},
        {false, 1282.934, -1393.108, 12.948, 4},
        {'Przepuść pieszego', 1220.097, -1392.852, 12.972, 4},
        {'Poczekaj aż pieszy przekroczy jezdnię', 1181.904, -1392.746, 12.973, 4},
        {'Rozpędź pojazd i zatrzymaj się na poziomie sklepu z kasetami', 820.502, -1391.823, 13.186, 1, 90, 4},
        {'Skręć w lewo', 792.757, -1467.501, 13.110, 4},
        {'Na następnym skrzyżowaniu skręć w lewo', 770.106, -1570.638, 13.111, 4},
        {false, 804.499, -1592.876, 13.115, 4},
        {'Skręć w lewo', 900.257, -1574.501, 13.107, 4},
        {'Jedź prosto', 1006.859, -1574.771, 13.118, 4},
        {'Skręć w prawo', 1035.010, -1679.167, 13.107, 4},
        {'Skręć w lewo', 1156.180, -1714.457, 13.410, 4},
        {'Zaparkuj na parkingu', 1062.926, -1743.212, 13.186, 1, 90, 3},
    },
    callbacks = {
        [1] = function()
            examElements['vehicle1'] = createVehicle(546, 1346.561, -1752.832, 13.084, 0, 0, 180)
            examElements['vehicle2'] = createVehicle(401, 1352.307, -1753.024, 13.139, 0, 0, 0)
            examElements['vehicle3'] = createVehicle(478, 1511.502, -1462.269, 9.486, 0, 0, 0)
            examElements['vehicle4'] = createVehicle(418, 1511.627, -1474.852, 9.593, 0, 0, 0)

            setElementFrozen(examElements['vehicle1'], true)
            setElementFrozen(examElements['vehicle2'], true)
            setElementFrozen(examElements['vehicle3'], true)
            setElementFrozen(examElements['vehicle4'], true)
        end,
        [22] = function() -- zmienic na 22
            destroyExamElement('vehicle1')
            destroyExamElement('vehicle2')
            destroyExamElement('vehicle3')
            destroyExamElement('vehicle4')

            examElements['ped'] = createPed(7, 1213.806, -1385.974, 13.380, 180)
            setPedControlState(examElements['ped'], 'walk', true)
            setPedControlState(examElements['ped'], 'forwards', true)
        end,
    }
}

local defaultRouteL = {
    vehicle = 593,
    spawn = {1970.507, -2438.260, 14.006, 0, 0, 180},
    finish = {
        interior = 3,
        dimension = 0,
        position = {210.098, 142.230, 1003.023},
    },
    checkpoints = {
        -- {text, x, y, z, distance, angle, possible angle difference}
        {'Odpal silnik w samolocie oraz udaj się na pas startowy', 1955.427, -2493.914, 13.539, 10},
        {false, 1667.261, -2494.010, 55.039, 10},
        {false, 1392.415, -2487.119, 81.039, 10},
        {false, 1138.243, -2246.134, 161.404, 10},
        {false, 1111.413, -1890.712, 150.904, 10},
        {false, 1108.390, -1395.642, 269.949, 10},
        {false, 1397.462, -1114.169, 319.449, 10},
        {false, 1647.793, -561.311, 281.994, 10},
        {false, 1919.084, 7.290, 372.994, 10},
        {false, 2655.085, 123.579, 372.994, 10},
        {false, 2745.409, -1102.703, 252.994, 10},
        {false, 2738.339, -1695.359, 252.994, 10},
        {false, 2268.796, -2175.185, 252.994, 10},
        {false, 1819.590, -2493.337, 51.994, 10},
        {'Kończymy egzamin, udaj się do ostatniego punktu', 1474.139, -2491.310, 50.055, 10},
    },
    callbacks = {}
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
    L1 = defaultRouteL,
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
    if hitElement ~= localPlayer or not matchingDimension or getPedOccupiedVehicle(localPlayer) then return end
    
    setDrivingLicenseUIVisible(true)
end

local function onClientMarkerLeave(leaveElement, matchingDimension)
    if leaveElement ~= localPlayer or not matchingDimension or getPedOccupiedVehicle(localPlayer) then return end
    
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

if not localPlayer then
    local blip = createBlip(1153.985, -1771.820, 16.599, 52, 2, 255, 0, 0, 255, 0, 9999)
    setElementData(blip, 'blip:hoverText', 'Ośrodek szkolenia kierowców')
end