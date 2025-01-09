removeWorldModel(3426, 5, 434, 1565, 12)
removeWorldModel(3428, 5, 434, 1565, 12)
removeWorldModel(3426, 5, 404, 1463, 8)
removeWorldModel(3426, 5, 404, 1463, 8)
removeWorldModel(3427, 155, 404, 1463, 8)
removeWorldModel(16277, 155, 404, 1463, 8)
removeWorldModel(16530, 55, 404, 1463, 8)
removeWorldModel(16531, 155, 404, 1500, 8)
removeWorldModel(16532, 155, 404, 1500, 8)
removeWorldModel(16533, 155, 454, 1500, 8)
removeWorldModel(16273, 55, 404, 1463, 8)
removeWorldModel(16745, 100, 434, 1565, 12)
removeWorldModel(16269, 1000, 434, 1565, 12)
removeWorldModel(1308, 60, 400, 1515, 12)
removeWorldModel(1308, 25, 493, 1496, 12)

local customMapObjects = {
    building = {
        object = createObject(16232, 445.22,1555.75,19.0859),
    },
    tube = {
        object = createObject(6928, 463.39999, 1528.2, 41.3),
        scale = 0.6,
    },
    missile = {
        object = createObject(2000, 463.20001, 1528.1, 46, 0, 0, 0),
        customModel = 'missile'
    },
    fire = {
        object = createObject(2000, 465.6, 1527.6, 46 - 295, 0, 0, 0),
        customModel = 'fire',
        scale = {1.5, 1.5, 3},
    },
}

for name, object in pairs(customMapObjects) do
    if object.scale then
        if type(object.scale) == 'table' then
            setObjectScale(object.object, unpack(object.scale))
        else
            setObjectScale(object.object, object.scale)
        end
    end
    if not object.noLod then
        assignLOD(object.object)
    end
    if object.customModel then
        setObjectCustomModel(object.object, object.customModel)
    end
end

function getCustomMapObject(name)
    return customMapObjects[name].object
end