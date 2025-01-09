local function loadFurnitureShop(data, index)
    local object = createObject(1337, data[1], data[2], data[3] + 100)
    setElementData(object, 'element:model', 'furniture-shop')
    setElementInterior(object, 1)

    local blip = createBlip(data[1], data[2], data[3], 17, 2, 255, 0, 0, 255, 0, 9999.0)
    setElementData(blip, 'blip:hoverText', 'Sklep z meblami')

    exports['m-enter']:createEntrance({
        marker = data,
        target = {data[1] + 8.5, data[2] + 4.3, data[3] + 101},
        interior = 0,
        targetInterior = 1,
        name = 'Wejście',
        description = 'Sklep z meblami',
        longDescrption = 'Wejście do sklepu z meblami',
    }, 5000 + index)

    exports['m-enter']:createEntrance({
        marker = {data[1] + 8.5, data[2] + 4.3, data[3] + 101},
        target = data,
        interior = 1,
        targetInterior = 0,
        name = 'Wyjście',
        description = 'Sklep z meblami',
        longDescrption = 'Wyjście ze sklepu z meblami',
    }, 6000 + index)

    local cashier1 = createPed(141, data[1] + 7, data[2] + 1.55, data[3] + 101, 90)
    local cashier2 = createPed(142, data[1] + 7, data[2] - 2.8, data[3] + 101, 90)
    local cashier3 = createPed(143, data[1] + 7, data[2] - 7.1, data[3] + 101, 90)
    setElementFrozen(cashier1, true)
    setElementFrozen(cashier2, true)
    setElementFrozen(cashier3, true)
    setElementInterior(cashier1, 1)
    setElementInterior(cashier2, 1)
    setElementInterior(cashier3, 1)
end

local function loadFurnitureShops()
    for i, shop in ipairs(shops) do
        loadFurnitureShop(shop, i)
    end
end

addEventHandler('onResourceStart', resourceRoot, loadFurnitureShops)