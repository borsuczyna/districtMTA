local sides = 12
local anglesPositions = {}
local fade = 0
local px, py, pz = 0, 0, 0
local pDimension = 0
local pInterior = 0
local targets = {}

for i = 1, sides do
    local angle = math.rad(i / sides * -360)
    anglesPositions[i] = {math.cos(angle), math.sin(angle)}
end

local shader = dxCreateShader('data/shader.fx')
local textures = {
    glow = dxCreateTexture('data/glow.png', 'argb', true, 'wrap'),
    ground = dxCreateTexture('data/ground.png', 'argb', true, 'clamp'),
    texture = dxCreateTexture('data/texture.png', 'argb', true, 'wrap')
}

dxSetShaderValue(shader, 'defaultTexture', textures.texture)
dxSetShaderValue(shader, 'glowTexture', textures.glow)

local requiredResource = getResourceFromName('m-ui')

if not requiredResource or getResourceState(requiredResource) ~= "running" then
    exportedFonts = {
        dev_default = 'default-bold',
        original = {
            ["title"] = 'default',
            ["description"] = 'default-bold'
        }
    }
else
    exportedFonts = {
        dev_default = 'default-bold',
        original = {
            ["title"] = exports['m-ui']:getFont('Inter-Black', 28) or 'default-bold',
            ["description"] = exports['m-ui']:getFont('Inter-Bold', 25) or 'default-bold'
        }
    }
end

local function handleMarkerFont(font)
    if exportedFonts.original[font] then
        return exportedFonts.original[font]
    else
        return exportedFonts.dev_default
    end
end

local updatedMarkersTextColor = {title = tocolor(255, 255, 255), desc = tocolor(200, 200, 200)}

local function updateMarkerTarget(marker, rt)
    dxSetRenderTarget(rt, false)

    local r, g, b, a = getMarkerColor(marker)
    if a ~= 0 then
        setMarkerColor(marker, r, g, b, 0)
    end
    
    local title = getElementData(marker, "marker:title") or "Przechowalnia"
    local icon = getElementData(marker, "marker:icon") or "entrance"
    local desc = getElementData(marker, "marker:desc") or "Odbiór pojazdów"

    if icon ~= 'none' then
        dxDrawImage(100, 0, 200, 200, 'data/icons/' .. icon .. '.png')
    end

    dxDrawText(title, 200, 265, nil, nil, updatedMarkersTextColor.title, 1, handleMarkerFont('title'), 'center', 'bottom')
    dxDrawText(desc, 200, 265, nil, nil, updatedMarkersTextColor.desc, 2.4, handleMarkerFont('desc'), 'center', 'top')

    dxSetRenderTarget()
end

local function createMarkerTarget(marker)
    local target = dxCreateRenderTarget(400, 305, true)
    updateMarkerTarget(marker, target)

    targets[marker] = {
        target = target,
        lastUsed = getTickCount()
    }

    return target
end

local function getMarkerTarget(marker)
    if not targets[marker] then
        createMarkerTarget(marker)
    end

    local target = targets[marker]
    target.lastUsed = getTickCount()

    return target.target
end

local function handleExpiredTargets()
    for marker, target in pairs(targets) do
        if getTickCount() - target.lastUsed > 5000 then
            destroyElement(target.target)
            targets[marker] = nil
        end
    end
end

local function isMarkerOnScreen(x, y, z, size)
    local screenX, screenY = getScreenFromWorldPosition(x, y, z, 40 * size)
    return screenX and screenY
end

local GLOBAL_TEXTURE_SIZE = 4000

local function renderRoundedMarker(marker)
    local x, y, z = getElementPosition(marker)
    z = z + 0.4

    if getDistanceBetweenPoints3D(x, y, z, px, py, pz) > 200 then return end
    if not isMarkerOnScreen(x, y, z, 1) then return end

    local title = getElementData(marker, 'marker:title') or '-'
    local desc = getElementData(marker, 'marker:desc') or '-'
    local r, g, b = getMarkerColor(marker)
    local size = getMarkerSize(marker) or 1
    
    local h, s, l = rgbToHsl(r, g, b)
    r, g, b = hslToRgb(h, s, l + 0.1, 1)
    local r2, g2, b2 = hslToRgb(h, s, l + 0.2, 1)

    local radius = size / 2
    local oneSideSize = 1 / sides
    local textureSide = GLOBAL_TEXTURE_SIZE / sides

    dxSetShaderValue(shader, 'markerSize', size)
    dxSetShaderValue(shader, 'markerColor', r / 255, g / 255, b / 255, 1)

    for side = 0, sides - 1 do
        local angle = math.rad(side / sides * -360)
        local nextAngle = math.rad((side + 1) / sides * -360)

        local anglePosition = anglesPositions[side + 1]
        local nextAnglePosition = anglesPositions[side + 2] or anglesPositions[1]
        local x1, y1 = x + anglePosition[1] * radius, y + anglePosition[2] * radius
        local x2, y2 = x + nextAnglePosition[1] * radius, y + nextAnglePosition[2] * radius
       
        dxDrawMaterialSectionLine3D(x1, y1, z, x2, y2, z, textureSide * side * size + getTickCount() / 3, 0, textureSide * size, 512, true, textures.texture, 0.4, tocolor(r, g, b, 100), 'prefx', x, y, z)
    end
    
    local groundZ = getGroundPosition(x, y, z)
    dxDrawMaterialLine3D(x, y + size * 0.8, groundZ + 0.01, x, y - size * 0.8, groundZ + 0.01, textures.ground, size * 1.6, tocolor(r, g, b, 0), 'prefx', x, y, groundZ)
    dxDrawMaterialLine3D(x, y + size * 0.8, groundZ + 0.01, x, y - size * 0.8, groundZ + 0.01, textures.ground, size * 1.6, tocolor(r2, g2, b2, fade / 1.7), 'prefx', x, y, groundZ)

    local target = getMarkerTarget(marker)
    local floatZ = fade / 255 * 0.1
    dxDrawMaterialLine3D(x, y, z + 0.85 + floatZ, x, y, z + 0.2 + floatZ, target, 0.9, tocolor(255, 255, 255), 'postfx')
end

local function renderSquareMarker(marker, size)
    local x, y, z = getElementPosition(marker)
    z = z + 0.4

    if getDistanceBetweenPoints3D(x, y, z, px, py, pz) > 200 then return end
    if not isMarkerOnScreen(x, y, z, size[1]) then return end

    local title = getElementData(marker, 'marker:title') or '-'
    local desc = getElementData(marker, 'marker:desc') or '-'
    local r, g, b = getMarkerColor(marker)

    local h, s, l = rgbToHsl(r, g, b)
    r, g, b = hslToRgb(h, s, l + 0.1, 1)
    local r2, g2, b2 = hslToRgb(h, s, l + 0.2, 1)

    local textureSize = GLOBAL_TEXTURE_SIZE
    local textureSizeX = textureSize / size[1]
    local textureSizeY = textureSize / size[2]

    dxSetShaderValue(shader, 'markerSize', (size[1] + size[2]) * 2)
    dxSetShaderValue(shader, 'markerColor', r / 255, g / 255, b / 255, 0.5)

    local width = GLOBAL_TEXTURE_SIZE * size[1] / 3
    local length = GLOBAL_TEXTURE_SIZE * size[2] / 3

    dxDrawMaterialSectionLine3D(x - size[1] / 2, y - size[2] / 2, z, x + size[1] / 2, y - size[2] / 2, z, 0 + getTickCount() / 3, 0, width, 512, true, textures.texture, 0.4, tocolor(r, g, b, 100), 'prefx', x, y, z)
    dxDrawMaterialSectionLine3D(x + size[1] / 2, y - size[2] / 2, z, x + size[1] / 2, y + size[2] / 2, z, width + getTickCount() / 3, 0, length, 512, true, textures.texture, 0.4, tocolor(r, g, b, 100), 'prefx', x, y, z)
    dxDrawMaterialSectionLine3D(x + size[1] / 2, y + size[2] / 2, z, x - size[1] / 2, y + size[2] / 2, z, width + length + getTickCount() / 3, 0, width, 512, true, textures.texture, 0.4, tocolor(r, g, b, 100), 'prefx', x, y, z)
    dxDrawMaterialSectionLine3D(x - size[1] / 2, y + size[2] / 2, z, x - size[1] / 2, y - size[2] / 2, z, width*2 + length + getTickCount() / 3, 0, length, 512, true, textures.texture, 0.4, tocolor(r, g, b, 100), 'prefx', x, y, z)

    local groundZ = getGroundPosition(x, y, z)
    local maxSize = math.max(size[1], size[2])
    dxDrawMaterialLine3D(x, y + maxSize / 2, groundZ + 0.01, x, y - maxSize / 2, groundZ + 0.01, textures.ground, maxSize, tocolor(r, g, b, 255), 'prefx', x, y, groundZ)
    dxDrawMaterialLine3D(x, y + maxSize / 2, groundZ + 0.01, x, y - maxSize / 2, groundZ + 0.01, textures.ground, maxSize, tocolor(r2, g2, b2, fade / 2), 'prefx', x, y, groundZ)

    local target = getMarkerTarget(marker)
    local floatZ = fade / 255 * 0.1
    dxDrawMaterialLine3D(x, y, z + 0.85 + floatZ, x, y, z + 0.2 + floatZ, target, 0.9, tocolor(255, 255, 255), 'postfx')
end

local function renderMarkers()
    fade = (math.sin(getTickCount()/500)+1)*0.5*255
    px, py, pz = getCameraMatrix()
    pDimension = getElementDimension(localPlayer)
    pInterior = getElementInterior(localPlayer)

    for _, marker in ipairs(getElementsByType('marker')) do
        local markerDimension = getElementDimension(marker)
        local markerInterior = getElementInterior(marker)

        if markerDimension == pDimension and markerInterior == pInterior and getMarkerType(marker) == 'cylinder' then
            local squareSize = getElementData(marker, 'marker:square')

            if squareSize then
                renderSquareMarker(marker, type(squareSize) == 'number' and {squareSize, squareSize} or squareSize)
            else
                renderRoundedMarker(marker)
            end
        end
    end

    handleExpiredTargets()
end
addEventHandler('onClientPreRender', root, renderMarkers)

-- rerender all markers targets on restore
addEventHandler('onClientRestore', root, function()
    for marker, target in pairs(targets) do
        updateMarkerTarget(marker, target.target)
    end
end)