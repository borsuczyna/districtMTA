vehiclePrices = {
-- [model] = {min, max, step}
    [401] = {3000, 4950, 50},
    [404] = {3400, 4950, 50},
    [546] = {3600, 5150, 50},
    [533] = {70000, 80000, 500},
    [613] = {50000, 60000, 500},
}

local cheapCarsExit = {1139.445, -2036.923, 68.738, 359.726, 360.000, 270.352}
local cheapCarsExit2 = {1896.904, -1874.694, 13.228, 358.639, 0.129, 181.427}
local defaultCarsExit = {1280.154, -1440.802, 13.367, 359.768, 359.999, 359.743}

vehicleShops = {
    CarsShop(1174.670, -2027.381, 69.008, {
        CheapCar({401, 404, 546}, {1158.368, -2034.601, 68.742, 359.673, 359.849, 278.429}, cheapCarsExit),
        CheapCar({401, 404, 546}, {1164.700, -2043.088, 68.742, 359.689, 0.107, 322.234}, cheapCarsExit),
        CheapCar({401, 404, 546}, {1172.630, -2043.980, 68.746, 359.936, 359.870, 7.356}, cheapCarsExit),
    }),
    CarsShop(1886.453, -1866.924, 13.270, {
        CheapCar({613}, {1897.075, -1867.179, 13.297, 359.025, 359.782, 128.715}, cheapCarsExit2),
    }),
    CarsShop(1324.208, -1427.177, 13.702, {
        GoodCar({533}, {1323.701, -1427.002, 13.405, 357.702, 359.692, 134.045}, defaultCarsExit),
    })
}