addCommandHandler('texturesencode', function(plr)
    local account = getPlayerAccount(plr)
    if not account or not isObjectInACLGroup('user.' .. getAccountName(account), aclGetGroup('Admin')) then return end

    local filesToEncode = {
        'shader.fx', 'texture.png', 'marker.dff', 'square-marker.dff', 'marker.txd', 'glow.png', 'background.png', 'overlay.png', 'mta-helper.fx', 'ground.png',
        'enter.png', 'cheese.png', 'clothing.png', 'default.png', 'entrance.png', 'gielda.png', 'house.png', 'icecream.png', 'pack.png', 'parking.png', 'prawojazdy.png', 'repair.png', 'salon.png', 'skin.png', 'snacks.png', 'treasure.png', 'tshirt.png', 'vegetables.png'
    }
    
    for k,v in pairs(filesToEncode) do
        local file = fileOpen('data/' .. v)
        local data = fileRead(file, fileGetSize(file))
        fileClose(file)

        data = teaEncode(data, 'jebachuciarzacwelapierdolonego')
        file = fileCreate('data/' .. v .. '.brsk')
        fileWrite(file, data)
        fileClose(file)
    end
end)