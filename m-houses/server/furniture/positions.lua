local inFront = {
    [1] = {23, 0.6, 0.03, 0.45, 0, 220, 90},
}

furnitureHoldPositions = {
    toilet1 = inFront[1],
}

function getFurnitureHoldPosition(furniture)
    return furnitureHoldPositions[furniture] or inFront[1]
end