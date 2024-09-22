local loaded = false

function loadCustom()
    if loaded then return end
    loaded = true

    local txd = engineLoadTXD('data/snow.txd')

    for _, v in ipairs(customLoad) do
        removeWorldModel(v.lod, 0.1, v.pos.x, v.pos.y, v.pos.z)
    end

    setTimer(function()
        for _, v in ipairs(customLoad) do
            engineImportTXD(txd, v.model)
        end
    end, 1000, 1)
end

function unloadCustom()
    if not loaded then return end
    loaded = nil

    local txd = engineLoadTXD('data/grass.txd')
    for _, v in ipairs(customLoad) do
        engineImportTXD(txd, v.model)
    end
end

function loadTXD(pos, tutorial)
    local txd = engineLoadTXD('data/snow.txd')

    for _, v in ipairs(models) do
        engineImportTXD(txd, v.model)
    end

    loadCustom()
end

loadTXD()