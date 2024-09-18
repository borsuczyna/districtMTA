local allowedIPs = {
    '89.107.156.244', '31.0.43.202'
}

local function isIPAllowed(ip)
    for _, allowedIP in ipairs(allowedIPs) do
        if ip == allowedIP then
            return true
        end
    end
    return false
end

function checkPlayerUsingVPN(player, ip)    
    if not isIPAllowed(ip) then
        fetchRemote('https://www.rayzs.de/provpn/api/proxy.php/?a='..ip, function(data, err)
            if err == 0 then
                if data == 'true' then
                    kick(player, 'VPN', 'VPN')
                end
            end
        end)
    end
end

addEventHandler('onPlayerConnect', root, function(playerNick, playerIP)
    local player = getPlayerFromName(playerNick)
    checkPlayerUsingVPN(player, playerIP)
end)
