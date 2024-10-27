local encodeHash = 'jebactepierdolonepseudole321!@'
addEvent('models:getEncodeHashes', true)
addEventHandler('models:getEncodeHashes', root, function(wanted)
    if getElementData(client, 'player:triggerLocked') then return end
    local hashes = {}
    for _, file in ipairs(wanted) do
        local hash = getFileHash('data/decoded/' .. file)
        hashes[file] = hash
    end

    triggerClientEvent(client, 'models:receiveEncodeHashes', resourceRoot, hashes)
end)

function getFileHash(name)
    if not fileExists(name) then return false end
    
    local file = fileOpen(name)
    local size = fileGetSize(file)
    fileClose(file)

    return md5(name .. size .. encodeHash)
end

function encodeFile(name)
    encodeFileIn(name, name:gsub('data/decoded/', 'data/encoded/'), getFileHash(name))
    return true
end

function scanDirectory(path)
    local entries = pathListDir(path)
    for _, fileOrFolder in ipairs(entries) do
        local path = path .. '/' .. fileOrFolder
        if pathIsFile(path) then
            local encoded = encodeFile(path)
            if encoded then
                outputDebugString('Encoded: ' .. path, 3)
            else
                outputDebugString('Failed to encode: ' .. path, 1)
            end
        else
            scanDirectory(path)
        end
    end
end

addCommandHandler('encode', function(player, cmd)
    local accountName = getAccountName(getPlayerAccount(player))
    if not isObjectInACLGroup('user.' .. accountName, aclGetGroup('Admin')) then return end

    -- local entries = pathListDir('data/decoded')
    -- for _, fileOrFolder in ipairs(entries) do
    --     local path = 'data/decoded/' .. fileOrFolder
    --     if pathIsFile(path) then

    --     else
    --         print('Folder: ' .. path)
    --     end
    -- end

    scanDirectory('data/decoded')
    exports['m-notis']:addNotification(player, 'success', 'Kodowanie', 'Wszystkie pliki zostały zakodowane')
end)