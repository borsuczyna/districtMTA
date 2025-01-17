vehiclePrices = {
    -- [model] = {min, max, step}
    [600] = {900000, 935000, 500},
    [410] = {490000, 530000, 500},
    [478] = {400000, 450000, 500},
    [418] = {410000, 440000, 500},
    [404] = {470000, 510000, 500},
    [533] = {5500000, 6500000, 500},
    [613] = {980000, 110000, 500},
    [426] = {6250000, 7100000, 500},
    [602] = {7500000, 8300000, 500},
    [445] = {7800000, 8700000, 500},
    [589] = {9200000, 10000000, 500},
    [507] = {5800000, 620000, 500},
    [481] = {50000, 60000, 500},
    [462] = {50000, 60000, 500},
    [581] = {50000, 60000, 500},
    [579] = {11500000, 13000000, 500},
}
    
local cheapCarsExit = {1139.445, -2036.923, 68.738, 359.726, 360.000, 270.352}
local cheapCarsExit2 = {1895.972, -1878.888, 13.152, 358.759, 0.181, 180.304}
local defaultCarsExit = {1280.154, -1440.802, 13.367, 359.768, 359.999, 359.743}
    
vehicleShops = {
    CarsShop(1886.453, -1866.924, 13.270, {
        CheapCar({613}, {1886.367, -1873.479, 13.257, 359.792, 0.560, 266.332}, cheapCarsExit2),
        CheapCar({600}, {1894.389, -1854.841, 13.306, 359.223, 359.978, 181.490}, cheapCarsExit2),
        CheapCar({410}, {1872.362, -1872.447, 13.173, 359.529, 0.462, 276.047}, cheapCarsExit2),
        CheapCar({478}, {1883.909, -1847.957, 13.567, 359.240, 359.992, 153.111}, cheapCarsExit2),
        CheapCar({418}, {1865.887, -1850.869, 13.671, 0.042, 359.984, 264.279}, cheapCarsExit2),
        CheapCar({404}, {1886.087, -1859.183, 13.311, 359.746, 359.979, 209.613}, cheapCarsExit2),
    }),
    CarsShop(1324.208, -1427.177, 13.702, {
        GoodCar({533}, {1323.701, -1427.002, 13.405, 357.702, 359.692, 134.045}, defaultCarsExit),
        GoodCar({426}, {1323.614, -1435.594, 13.434, 357.703, 0.002, 45.055}, defaultCarsExit),
        GoodCar({602}, {1318.372, -1422.160, 13.377, 359.777, 0.001, 88.798}, defaultCarsExit),
        GoodCar({445}, {1310.408, -1422.002, 13.459, 359.994, 0.002, 89.478}, defaultCarsExit),
        GoodCar({589}, {1310.353, -1440.803, 13.219, 0.006, 359.999, 89.879}, defaultCarsExit),
        GoodCar({507}, {1318.472, -1440.947, 13.384, 359.744, 0.000, 87.705}, defaultCarsExit),
        GoodCar({481}, {1309.422, -1431.366, 13.086, 358.772, 0.001, 132.765}, defaultCarsExit),
        GoodCar({462}, {1312.433, -1431.474, 13.169, 359.472, 0.001, 134.865}, defaultCarsExit),
        GoodCar({581}, {1315.403, -1431.367, 13.173, 359.367, 0.003, 134.840}, defaultCarsExit),
        GoodCar({579}, {1287.559, -1419.747, 14.729, 354.488, 359.839, 44.069}, defaultCarsExit),
    })
}