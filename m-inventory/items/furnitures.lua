furnitures = {
    {
        item = 'toilet1',
        category = 'toilet',
        name = 'Toaleta',
        description = 'Toaleta w kształcie klasycznej muszli klozetowej',
        icon = 'toilet-1',
        model = 2525,
    }
}

function getFurnitures()
    return furnitures
end

function getFurniture(item)
    for _, furniture in pairs(furnitures) do
        if furniture.item == item then
            return furniture
        end
    end
end