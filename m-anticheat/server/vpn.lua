-- function checkPlayerUsingVPN(player)
--     local ip = getPlayerIP(player)
    
--     fetchRemote('http://proxy.mind-media.com/block/proxycheck.php?ip='..ip, function(data, err)
--         if err == 0 then
--             if data == 'Y' then
--                 ban(player, 'VPN', 'VPN')
--             end
--         end
--     end)
-- end

-- addEventHandler('onPlayerJoin', root, function()
--     checkPlayerUsingVPN(source)
-- end)