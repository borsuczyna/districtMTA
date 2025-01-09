local modelSizeCache = {}

function getModelBoundingBox(element)
	local type = getElementType(element)
	local model = getElementModel(element)
	local element;

	if type == "vehicle" then
		element = createVehicle(model, 0, 0, 0)
	elseif type == "object" then
		element = createObject(model, 0, 0, 0)
	else
		return false
	end

	local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(element)
	destroyElement(element)

	return x1, y1, z1, x2, y2, z2
end

function getElementSize(element)
	if modelSizeCache[element] then
		return unpack(modelSizeCache[element])
	end

	local x1, y1, z1, x2, y2, z2 = getModelBoundingBox(element)
	if not x1 then return end

	modelSizeCache[element] = {x2 - x1, y2 - y1, z2 - z1}
	return unpack(modelSizeCache[element])
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

function getVehicleTuning(vehicle)
    local tuning = {}
    local upgrades = exports['m-upgrades']:getVehicleUpgrades(vehicle)

    for i, value in pairs(upgrades) do
        table.insert(tuning, exports['m-upgrades']:getUpgradeName(value))
    end

    return tuning
end

function rgbToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

function formatNumber(number)
    local formatted = number
    while true do  
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end