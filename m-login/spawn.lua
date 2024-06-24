local spawns = {
    -- nazwa, spawn x, y, z
    ['Główne'] = {
        {'Urząd', 1284, -1405, 0, camera={1275.88806, -1406.38342, 25.22648, 1313.18005, -1374.37402, 17.30728}},
        {'Szkoła jazdy', 1049, -1657, 0, camera={1061.06055, -1758.87781, 26.04539, 1100.50415, -1792.82593, 19.58187}},
    },
    ['Wioski'] = {
        {'Blueberry', 280, -100, 0, camera={280.00000, -100.00000, 9.73867, 253.56168, -67.30295, 7.1392}},
        {'Fort Carson', -62, 1045, 0, camera={-62.00000, 1045.00000, 26.65475, -87.59967, 1097.10535, 25.14151}},
        {'Dillimore', 713.52167, -522.02460, 16.32814, camera={749.93439, -611.90558, 46.03849, 702.89777, -564.89679, 26.00567}},
    },
}

addEvent('login-spawn:spawn', true)
addEventHandler('login-spawn:spawn', root, function(data)
    data = fromJSON(data)
    setTimer(function()
        exports['m-ui']:destroyInterfaceElement('login-spawn')
        hideInterface()
        triggerServerEvent('login:spawn', resourceRoot, data)
    end, 1000, 1)
end)

function setSpawnsData()
    exports['m-ui']:setInterfaceData('login-spawn', 'spawns', spawns)
end

addEventHandler('interface:load', root, function(name)
    if name == 'login-spawn' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setSpawnsData()
    end
end)

function showSpawnSelect()
    exports['m-ui']:loadInterfaceElementFromFile('login-spawn', 'm-login/data/spawn.html')
end