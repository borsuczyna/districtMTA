boneIDs = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 21,
    22, 23, 24, 25, 26, 31, 32, 33,
    34, 35, 36, 41, 42, 43, 44, 51,
    52, 53, 54, 201, 301, 302
}

function isMouseInPosition(x, y, width, height)
    if isCursorShowing() then
        local mx, my = getCursorPosition()
        local sx, sy = guiGetScreenSize()
        mx, my = mx * sx, my * sy

        return mx >= x and mx <= x + width and my >= y and my <= y + height
    end
    return false
end

function table.find(tbl, callback)
    for i, v in ipairs(tbl) do
        if callback(v, i) then
            return v, i
        end
    end
    return false
end

function table.size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end