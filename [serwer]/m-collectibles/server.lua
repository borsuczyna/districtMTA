local collectibles = {
    {969.607, -1421.054, 13.522, 0, 10000},
    {706.611, -1473.952, 5.469, 0, 10000},
    {811.170, -1098.213, 25.906, 0, 10000},
    {1932.737, -1201.777, 20.312, 0, 10000},
    {2537.791, -1669.950, 15.167, 0, 10000},
    {1916.753, -1773.595, 13.570, 0, 10000},
    {1918.696, -1704.746, 13.547, 0, 10000},
    {1898.672, -1849.820, 13.568, 0, 10000},
    {2003.703, -1305.425, 18.320, 0, 10000},
    {1714.842, -1912.213, 13.567, 0, 10000},
    {1637.979, -1636.948, 22.516, 0, 10000},
    {1481.451, -1612.419, 13.539, 0, 10000},
    {1464.833, -1905.523, 22.354, 0, 10000},
    {2474.766, -1760.676, 18.550, 0, 10000},
    {2142.952, -1802.946, 16.147, 0, 10000},
    {1935.157, -2139.530, 23.859, 0, 10000},
    {1874.520, -1956.843, 20.070, 0, 10000},
    {2775.075, -1964.886, 16.938, 0, 10000},
    {2882.276, -1971.516, 6.708, 0, 10000},
    {1341.901, -1624.417, 17.734, 0, 10000},
    {604.056, -580.065, 16.634, 0, 10000},
    {113.492, -188.282, 1.500, 0, 10000},
    {183.247, -107.407, 2.023, 0, 10000},
    {258.940, -303.077, 4.063, 0, 10000},
    {1183.336, -1691.958, 14.496, 0, 10000},
    {2201.997, -1152.124, 29.804, 0, 10000},
    {715.608, -1691.872, 2.430, 0, 10000},
    {1227.512, -867.899, 42.875, 0, 10000},
    {1307.631, -873.241, 39.578, 0, 10000},
    {1740.075, -1609.625, 20.216, 0, 10000},
    {2505.800, -1882.298, 25.550, 0, 10000},
    {2333.477, -1882.799, 15.000, 0, 10000},
    {2331.144, -2003.060, 16.029, 0, 10000},
    {2371.311, -2114.760, 27.180, 0, 10000},
    {2202.715, -2034.072, 27.322, 0, 10000},
    {1020.922, -1923.044, 12.651, 0, 10000},
    {671.616, -1869.682, 5.461, 0, 10000},
    {388.967, -2074.340, 7.836, 0, 10000},
    {154.646, -1963.780, 3.773, 0, 10000},
    {53.125, -1531.512, 11.957, 0, 10000},
    {2448.146, -2194.932, 21.563, 0, 10000},
    {2212.215, -2274.135, 14.765, 0, 10000},
    {2043.195, -2146.637, 19.918, 0, 10000},
    {733.312, -1357.769, 23.579, 0, 10000},
    {647.965, -1384.431, 22.723, 0, 10000},
    {2415.885, -1575.370, 23.854, 0, 10000},
    {2454.426, -1460.915, 24.000, 0, 10000},
    {-50.248, -270.225, 6.633, 0, 10000},
    {-47.379, 30.338, 6.484, 0, 10000},
    {275.770, 25.053, 3.098, 0, 10000},
}

for i, v in pairs(collectibles) do
    local pickup = createPickup(v[1], v[2], v[3], 3, 1254, 500)
    setElementData(pickup, 'data', {v, i})
end

function getCollectibleIndex(pickup)
    local pickupData = getElementData(pickup, 'data')
    return ('i%d'):format(pickupData[2])
end

addEventHandler('onPickupHit', resourceRoot, function(hit)
    if getElementType(hit) ~= 'player' then return end
    if isPedInVehicle(hit) then return end

    local playerCollectibles = getElementData(hit, 'player:collectibles') or {}
    local pickupData = getElementData(source, 'data')
    local index = getCollectibleIndex(source)
    local collected = playerCollectibles[index]

    if collected then
        exports['m-notis']:addNotification(hit, 'warning', 'Znajdźka', 'Ta znajdźka została już przez ciebie odnaleziona.')
    else    
        givePlayerMoney(hit, tonumber(pickupData[1][5])) 
        exports['m-core']:givePlayerExp(hit, 5)
        
        playerCollectibles[index] = true
        setElementData(hit, 'player:collectibles', playerCollectibles)
        
        exports['m-notis']:addNotification(hit, 'info', 'Znajdźka', ('Odnalazłeś znajdźkę nr. %d i otrzymujesz %d$ + 5 EXP<br>Posiadane znajdźki: %d/%d'):format(index:gsub('i', ''), pickupData[1][5]/100, countTable(playerCollectibles), #collectibles))
    end
end)

function countTable(table)
    local count = 0
    for i, v in pairs(table) do
        count = count + 1
    end
    return count
end