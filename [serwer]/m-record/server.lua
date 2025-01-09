addEvent('onClientUploadRecording', true)

local function addFileToMeta(name)
    local path = ('recordings/%s.json'):format(name)
    if not fileExists(path) then return end

    local meta = xmlLoadFile('meta.xml')
    if not meta then return end

    local file = xmlCreateChild(meta, 'file')
    xmlNodeSetAttribute(file, 'src', path)
    xmlSaveFile(meta)
    xmlUnloadFile(meta)
end

addEventHandler('onClientUploadRecording', resourceRoot, function(name, data)
    local path = ('recordings/%s.json'):format(name)
    if fileExists(path) then
        fileDelete(path)
    end

    local file = fileCreate(path)
    if not file then return end

    fileWrite(file, data)
    fileClose(file)

    addFileToMeta(name)
end)