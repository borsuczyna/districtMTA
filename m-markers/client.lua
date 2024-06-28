local markersData = {}
local markerTexture = dxCreateTexture('data/texture.png')
local markerGlowTexture = dxCreateTexture('data/glow.png')
local markerGroundTexture = dxCreateTexture('data/ground.png')

local id = engineRequestModel('object', 1649)
local idSquare = engineRequestModel('object', 1649)
engineSetModelFlag(id, 'draw_last', true)
engineSetModelFlag(id, 'additive', true)
engineSetModelFlag(id, 'no_zbuffer_write', true)
engineSetModelFlag(idSquare, 'draw_last', true)
engineSetModelFlag(idSquare, 'additive', true)
engineSetModelFlag(idSquare, 'no_zbuffer_write', true)
local txd = engineLoadTXD('data/marker.txd')
engineImportTXD(txd, id)
engineReplaceModel(engineLoadDFF('data/marker.dff'), id, true)
engineImportTXD(txd, idSquare)
engineReplaceModel(engineLoadDFF('data/square-marker.dff'), idSquare, true)

function updateRenderTarget(marker, rt)
    dxSetRenderTarget(rt, true)

    local r, g, b = getMarkerColor(marker)
    local title = getElementData(marker, "marker:title") or "Przechowalnia"
    local icon = getElementData(marker, "marker:icon") or "entrance"
    local desc = getElementData(marker, "marker:desc") or "Odbiór pojazdów"

    -- dxDrawImage(100, 0, 200, 200, 'data/background.png')
    dxSetBlendMode('modulate_add')
    -- dxDrawImage(100, 0, 200, 200, 'data/overlay.png', 0, 0, 0, tocolor(r, g, b, 255))
    -- dxDrawImage(100, 0, 200, 200, 'data/overlay.png', 0, 0, 0, tocolor(r, g, b, 100))
    dxSetBlendMode('blend')
    dxDrawImage(100, 0, 200, 200, 'data/icons/' .. icon .. '.png')
    -- dxDrawImage(150, 50, 200, 100, 'data/icons/' .. icon .. '.png')

    dxDrawText(title, 200, 255, nil, nil, white, 1, getFont('Inter-Bold', 25), 'center', 'bottom')
    dxDrawText(desc, 200, 255, nil, nil, 0xFFCCCCCC, 1, getFont('Inter-Medium', 23), 'center', 'top')

    dxSetRenderTarget()
end

function updateMarker(marker)
    local r, g, b = getMarkerColor(marker)

    if not markersData[marker] then
        local x, y, z = getElementPosition(marker)
        local size = getMarkerSize(marker)
        local squareSize = getElementData(marker, 'marker:square')
        local r, g, b = getMarkerColor(marker)
        local h, s, l = rgbToHsl(r, g, b)
        local h2, s2, l2 = rgbToHsl(r, g, b)
        r, g, b = hslToRgb(h, s, l + 0.1, 1)
        local r2, g2, b2 = hslToRgb(h, s, l + 0.2, 1)

        markersData[marker] = {
            object = createObject(squareSize and idSquare or id, x, y, z+0.4),
            shader = dxCreateShader('data/shader.fx', 0, 0, false, 'all'),
            rt = dxCreateRenderTarget(400, 290, true),
            r = r, g = g, b = b,
            r2 = r2, g2 = g2, b2 = b2
        }

        setObjectScale(markersData[marker].object, squareSize and squareSize[1] or size, squareSize and squareSize[2] or size, 1)
        updateRenderTarget(marker, markersData[marker].rt)
        setElementDoubleSided(markersData[marker].object, true)
        dxSetShaderValue(markersData[marker].shader, 'Texture', markerTexture)
        dxSetShaderValue(markersData[marker].shader, 'GlowTexture', markerGlowTexture)
        dxSetShaderValue(markersData[marker].shader, 'markerColor', r/255, g/255, b/255)
        dxSetShaderValue(markersData[marker].shader, 'markerSize', squareSize and squareSize[1] or size, squareSize and squareSize[2] or size)
        dxSetShaderValue(markersData[marker].shader, 'isSquare', not not squareSize)
        setElementCollisionsEnabled(markersData[marker].object, false)
        engineApplyShaderToWorldTexture(markersData[marker].shader, '*', markersData[marker].object)
    end

    setMarkerColor(marker, r, g, b, 0)
end

function unloadMarker(marker)
    if markersData[marker] then
        destroyElement(markersData[marker].object)
        destroyElement(markersData[marker].shader)
        destroyElement(markersData[marker].rt)
        markersData[marker] = nil
    end
end

function updateMarkers()
    for _,marker in pairs(getElementsByType('marker', root)) do
        updateMarker(marker)
    end
end

function renderMarkers()
    local a = (math.sin(getTickCount()/500)+1)*0.5*255
    local floatZ = math.sin(getTickCount()/700)*0.05
    local cx, cy, cz = getCameraMatrix()
    for k,v in pairs(markersData) do
        if not isElement(k) then
            unloadMarker(k)
        else
            local x, y, z = getElementPosition(k)
            local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)

            if distance < 40 then
                local model = getElementModel(v.object)
                local isSquare = model == idSquare

                local groundZ = getGroundPosition(x, y, z+0.5)
                groundZ = groundZ + 0.01
                if not isSquare then
                    local _, _, rz = getElementRotation(v.object)
                    setElementRotation(v.object, 0, 0, rz+0.5)
                end

                dxDrawMaterialLine3D(x, y, z + 1.45 + floatZ, x, y, z + 0.8 + floatZ, v.rt, 0.9, tocolor(255, 255, 255))
                
                if math.abs(groundZ-z) < 2 then
                    local squareSize = getElementData(k, 'marker:square')
                    local size = getMarkerSize(k)
                    if not squareSize then
                        squareSize = {size, size}
                    end

                    local r, g, b = v.r, v.g, v.b
                    dxDrawMaterialLine3D(x+0.8*squareSize[1], y, groundZ, x-0.8*squareSize[1], y, groundZ, markerGroundTexture, 1.6*squareSize[2], tocolor(r, g, b), x, y, groundZ + 0.5)
                    
                    groundZ = groundZ + 0.01
                    local r, g, b = v.r2, v.g2, v.b2
                    dxDrawMaterialLine3D(x+0.5*squareSize[1], y, groundZ, x-0.5*squareSize[1], y, groundZ, markerGroundTexture, squareSize[2], tocolor(r, g, b, a), x, y, groundZ + 0.5)
                end
            end
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, updateMarkers)
addEventHandler('onClientRender', root, renderMarkers)

addEventHandler('onClientElementStreamIn', root, function()
    if getElementType(source) == 'marker' then
        updateMarker(source)
    end
end)

addEventHandler('onClientElementStreamOut', root, function()
    if getElementType(source) == 'marker' then
        unloadMarker(source)
    end
end)