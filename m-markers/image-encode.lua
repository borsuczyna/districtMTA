local textures = {}

function decodeFile(file)
    local file = fileOpen(file .. '.brsk')
    local data = fileRead(file, fileGetSize(file))
    fileClose(file)

    return teaDecode(data, 'jebachuciarzacwelapierdolonego')
end

function createDecodedTexture(path)
    local data = decodeFile(path)
    local temp = fileCreate('temp.png')
    fileWrite(temp, data)
    fileClose(temp)
    local texture = dxCreateTexture('temp.png')
    fileDelete('temp.png')
    return texture
end

local _dxDrawImage = dxDrawImage
function dxDrawImage(x, y, w, h, path, ...)
    if not textures[path] then
        textures[path] = {
            texture = createDecodedTexture(path)
        }
    end

    textures[path].lastUsed = getTickCount()
    return _dxDrawImage(x, y, w, h, textures[path].texture, ...)
end

setTimer(function()
    for path, data in pairs(textures) do
        if data.lastUsed and getTickCount() - data.lastUsed > 10000 then
            destroyElement(data.texture)
            textures[path] = nil
        end
    end
end, 1000, 0)