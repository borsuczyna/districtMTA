cancelLoadingModels = false
models = {
    ['int-1'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['spawn-ls'] = {
        custom = false,
        type = 'object',
        model = 4825,
    },
    ['spawn-road'] = {
        custom = false,
        type = 'object',
        model = 4823,
    },
    ['spawn-garage'] = {
        custom = false,
        type = 'object',
        model = 4824,
        txd = 'spawn-ls',
    },
    ['building-fix'] = {
        custom = false,
        type = 'object',
        model = 4101,
    },
    ['building-barrier'] = {
        custom = false,
        type = 'object',
        model = 6103,
    },
    ['spawn-road2'] = {
        custom = false,
        type = 'object',
        model = 6126,
    },
    ['spawn-road3'] = {
        custom = false,
        type = 'object',
        model = 6128,
    },
    ['cable-station'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'spawn-ls',
    },
    ['cable-station-fix'] = {
        custom = false,
        type = 'object',
        model = 6102,
        txd = 'spawn-ls',
    },
    ['cablecar'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'cablecar',
    },
    ['cablecar-door'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'cablecar',
    },
    ['cablecar-rail'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'cablecar',
    },
    ['railway-station'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },
    ['burger-interior'] = {
        custom = true,
        type = 'object',
        model = 1337,
    },

    ['burger/board'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/bun'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/burger-in-packaging'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/burger'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/cola-dispenser'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/cola-glass'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/cola-glass-full'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/cola-liquid'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fries-cooked'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fries-burned'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fries'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fries-box'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fries-box-burned'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fryer-grid'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/fryer'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/glass'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/grill'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/meat-cooked'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/meat-overcooked'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/meat'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/packaging'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/salad-box'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/salad'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/trash'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/door'] = {
        custom = true,
        type = 'object',
        model = 1337,
        txd = 'burger/textures'
    },
    ['burger/building'] = {
        custom = false,
        type = 'object',
        model = 5741,
    },
    ['gas-station/gas-station-ls1'] = {
        custom = false,
        type = 'object',
        model = 5489,
        txd = 'gas-station/gas-station-ls',
    },
    ['gas-station/gas-station-ls2'] = {
        custom = false,
        type = 'object',
        model = 5409,
        txd = 'gas-station/gas-station-ls',
    },
    ['gas-station/gas-station-ls3'] = {
        custom = false,
        type = 'object',
        model = 14581,
        txd = 'gas-station/gas-station-ls',
    },
    ['gas-station/door'] = {
        custom = false,
        type = 'object',
        model = 1492,
        txd = 'gas-station/gas-station-ls',
    },
    ['gas-station/glass'] = {
        custom = false,
        type = 'object',
        model = 16251,
        txd = 'gas-station/gas-station-ls',
    },
    ['clothing-interior'] = {
	    custom = false,
	    type = 'object',
	    model = 2324,
    },
}

function getModelsCount()
    local count = 0
    for _, model in pairs(models) do
        count = count + 1
    end
    return count
end

function encodeFileIn(path, pathOut, hash)
    if not fileExists(path) then return end

    local file = fileOpen(path)
    if not file then return end
    local data = fileRead(file, fileGetSize(file))
    fileClose(file)
    
    if fileExists(pathOut) then
        fileDelete(pathOut)
    end
    
    local newData = teaEncode(data, hash)
    local newFile = fileCreate(pathOut)
    fileWrite(newFile, newData)
    fileClose(newFile)
end
    
function decodeFileIn(path, hash)
    if not fileExists(path) then return end

    local file = fileOpen(path)
    local size = fileGetSize(file)
    local data = fileRead(file, size)
    fileClose(file)
    
    return data
    -- return teaDecode(data, hash)
end

function createCustomObject(model, x, y, z, rx, ry, rz)
    local original = models[model]
    if not original then return end

    local object = createObject(original.model, x, y, z, rx, ry, rz)
    setElementData(object, 'element:model', model)

    return object
end

createCustomObject('railway-station', 1177.474, -1993.162, 67.508)