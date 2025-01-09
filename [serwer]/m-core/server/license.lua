function addPlayerLicense(player, license)
    local licenses = getElementData(player, 'player:licenses') or {}
    table.insert(licenses, license)
    setElementData(player, 'player:licenses', licenses)
end

function removePlayerLicense(player, license)
    local licenses = getElementData(player, 'player:licenses') or {}
    for i, v in ipairs(licenses) do
        if v == license then
            table.remove(licenses, i)
            break
        end
    end
    setElementData(player, 'player:licenses', licenses)
end