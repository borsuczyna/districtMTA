function doesPlayerHaveLicense(player, license)
    local licenses = getElementData(player, 'player:licenses') or {}
    for i, v in ipairs(licenses) do
        if v == license then
            return true
        end
    end
    return false
end