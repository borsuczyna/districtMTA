local encodeHash = 'jebactepierdolonepseudole321!@'
addEvent('models:getEncodeHashes', true)

function addFileToMeta(path)
    local meta = xmlLoadFile('meta.xml')
    local file = xmlCreateChild(meta, 'file')
    xmlNodeSetAttribute(file, 'src', path)
    xmlSaveFile(meta)
    xmlUnloadFile(meta)
end

function getFileHash(name)
    if not fileExists(name) then return false end
    
    local file = fileOpen(name)
    local size = fileGetSize(file)
    fileClose(file)

    return 'elo'
end

function encodeFile(name)
    encodeFileIn('data/decoded/' .. name, 'data/encoded/' .. name, getFileHash('data/decoded/' .. name))
    addFileToMeta('data/encoded/' .. name)

    return true
end

addCommandHandler('encode', function(player, cmd, name)
    local accountName = getAccountName(getPlayerAccount(player))
    if not isObjectInACLGroup('user.' .. accountName, aclGetGroup('Admin')) then return end
    if not name then return outputChatBox('Użycie: /encode <nazwa_pliku>', player) end

    local dff = encodeFile(name .. '.dff')
    local col = encodeFile(name .. '.col')
    local txd = encodeFile(name .. '.txd')

    if dff or col or txd then
        outputChatBox('Plik "' .. name .. '" został zakodowany', player, 0, 255, 0)
    else
        outputChatBox('Plik "' .. name .. '" nie istnieje', player, 255, 0, 0)
    end
end)

addEventHandler('models:getEncodeHashes', root, function(wanted)
    if getElementData(client, 'player:triggerLocked') then return end
    local hashes = {}
    for _, file in ipairs(wanted) do
        local hash = getFileHash('data/decoded/' .. file)
        hashes[file] = hash
    end

    triggerClientEvent(client, 'models:receiveEncodeHashes', resourceRoot, hashes)
end)