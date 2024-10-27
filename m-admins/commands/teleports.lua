local teleports = {
    sapd = {2067.367, -1895.553, 13.703},
    ers = {1808.638, -1757.527, 13.555},
    sara = {1804.089, -1725.469, 13.539},
    gielda = {1479.568, -1721.564, 13.383},
    przecho = {1949.319, -1861.231, 13.562},
    przecho2 = {1368.361, -1665.336, 13.494},
    cygan = {1900.271, -1879.948, 13.484},
    salon = {1289.960, -1440.628, 13.195},
    przebieralnia = {2245.815, -1663.143, 15.477},
    urzad = {1481.240, -1770.278, 18.734},
    osk = {1108.175, -1836.147, 16.604},
    meble = {2032.305, -1312.922, 23.984},
    burgerownia = {1206.939, -908.822, 43.211},
    kurier = {2142.269, -2266.172, 13.294},
    magazynier = {2311.632, -2338.766, 13.547},
    smieciarz = {2182.242, -1964.203, 14.047},
    molo = {2906.501, -1970.949, 11.109},
    spawn = {990.178, -1450.632, 13.883},
    spawn2 = {1185.417, -2036.631, 69.007},
    bb = {112.635, -156.311, 1.578},
    montgomery = {1245.177, 333.361, 19.555},
    fc = {-88.529, 1214.451, 19.742},
    ls = {2012.888, -1839.012, 17.328},
}

addCommandHandler('tp', function(player, cmd, name)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'teleports') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not name then 
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /tp (nazwa np. przecho)')
        return
    end

    local teleport = teleports[name]
    if not teleport then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawna nazwa teleportu')
        return
    end

    local veh = getPedOccupiedVehicle(player)

    if veh then
        setElementInterior(veh, 0)
        setElementDimension(veh, 0)

        setElementInterior(player, 0)
        setElementDimension(player, 0)

        setElementPosition(veh, teleport[1], teleport[2], teleport[3])
        exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Zostałeś teleportowany do ' .. name)
        return
    end

    setElementInterior(player, 0)
    setElementDimension(player, 0)
    setElementPosition(player, teleport[1], teleport[2], teleport[3])
    exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Zostałeś teleportowany do ' .. name)
end)