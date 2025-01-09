local bloomTextures = {
    [1] = dxCreateTexture('data/textures/bloom-1.png', 'argb', true, 'clamp'),
    [2] = dxCreateTexture('data/textures/bloom-2.png', 'argb', true, 'clamp'),
    [3] = dxCreateTexture('data/textures/bloom-3.png', 'argb', true, 'clamp'),
    [4] = dxCreateTexture('data/textures/bloom-4.png', 'argb', true, 'clamp'),
}
local textureSizes = {}
for power, texture in pairs(bloomTextures) do
    textureSizes[power] = {dxGetMaterialSize(texture)}
end

function drawBloomLine(startX, startY, endX, endY, color, thickness, power)
    local tw, th = textureSizes[power][1], textureSizes[power][2]

    -- dxDrawLine(startX, startY, endX, endY, tocolor(255, 0, 0, 255), 2)

    local length = getDistanceBetweenPoints2D(startX, startY, endX, endY)
    local angle = math.atan2(endY - startY, endX - startX) * 180 / math.pi

    -- local centerX, centerY = (startX + endX) / 2, (startY + endY) / 2
    local cn = length / 14
    startX, startY = getPointFromDistanceRotation(startX, startY, cn * thickness, -angle + 180)
    dxDrawImage(startX, startY, length, length / 7 * thickness, bloomTextures[power], angle, -length/2, -cn * thickness, color)
end

function draw3DBloom(sx, sy, sz, ex, ey, ez, color, thickness, power)
    sx, sy = getScreenFromWorldPosition(sx, sy, sz, 100)
    if not sx then return end
    ex, ey = getScreenFromWorldPosition(ex, ey, ez, 100)
    if not ex then return end

    drawBloomLine(sx, sy, ex, ey, color or color, thickness or 1, power or 1)
end

function drawRealistic3DBloom(data)
    local startPos = data.startPos
    local endPos = data.endPos
    local startColor = data.startColor
    local endColor = data.endColor
    local startThickness = data.startThickness
    local endThickness = data.endThickness
    local steps = data.steps
    local startAlpha = data.startAlpha or 255
    local endAlpha = data.endAlpha or 255
    local midPosition = {interpolateBetween(
        startPos[1], startPos[2], startPos[3],
        endPos[1], endPos[2], endPos[3],
        0.5,
        'Linear'
    )}
    local cameraPosition = {getCameraMatrix()}

    if not isLineOfSightClear(cameraPosition[1], cameraPosition[2], cameraPosition[3], midPosition[1], midPosition[2], midPosition[3], true, true, true, true, true, true, true) then
        return
    end

    for step = steps, 1, -1 do
        local progress = step / steps
        local r, g, b = interpolateBetween(
            startColor[1], startColor[2], startColor[3],
            endColor[1], endColor[2], endColor[3],
            progress,
            'Linear'
        )
        local thickness, alpha = interpolateBetween(
            startThickness, startAlpha, 0,
            endThickness, endAlpha, 0,
            progress,
            'Linear'
        )
        local startPosEnd = {interpolateBetween(
            startPos[1], startPos[2], startPos[3],
            endPos[1], endPos[2], endPos[3],
            0.2*(1-progress),
            'Linear'
        )}

        local endPosEnd = {interpolateBetween(
            startPos[1], startPos[2], startPos[3],
            endPos[1], endPos[2], endPos[3],
            1 - 0.2*(1-progress),
            'Linear'
        )}
        draw3DBloom(
            startPosEnd[1], startPosEnd[2], startPosEnd[3],
            endPosEnd[1], endPosEnd[2], endPosEnd[3],
            tocolor(r, g, b, alpha),
            thickness,
            progress < 0.3 and 1 or (progress < 0.7 and 2 or 3)
        )
    end

    local startPosEnd = {interpolateBetween(
        startPos[1], startPos[2], startPos[3],
        endPos[1], endPos[2], endPos[3],
        0.2,
        'Linear'
    )}

    local endPosEnd = {interpolateBetween(
        startPos[1], startPos[2], startPos[3],
        endPos[1], endPos[2], endPos[3],
        0.8,
        'Linear'
    )}

    draw3DBloom(
        startPosEnd[1], startPosEnd[2], startPosEnd[3],
        endPosEnd[1], endPosEnd[2], endPosEnd[3],
        tocolor(255, 255, 255, startAlpha),
        startThickness,
        1
    )
end