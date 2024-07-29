local shader = dxCreateShader('data/circle.fx')
local imageCache = {}

function getImage(imagePath)
    if not imageCache[imagePath] then
        imageCache[imagePath] = {
            image = dxCreateTexture(imagePath),
            lastUsed = getTickCount()
        }
    end

    imageCache[imagePath].lastUsed = getTickCount()
    return imageCache[imagePath].image
end

function drawCircleImage(x, y, w, h, image, start, stop, color)
    local image = getImage(image)
    dxSetShaderValue(shader, 'DrawTexture', image)
    dxSetShaderValue(shader, 'Angles', {math.rad(start) - math.pi, math.rad(stop) - math.pi})

    dxDrawImage(x, y, w, h, shader, 0, 0, 0, color)
end

function updateCache()
    for path, data in pairs(imageCache) do
        if getTickCount() - data.lastUsed > 3000 then
            destroyElement(data.image)
            imageCache[path] = nil
        end
    end
end

setTimer(updateCache, 5000, 0)