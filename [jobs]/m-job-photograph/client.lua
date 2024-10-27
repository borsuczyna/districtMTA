local function onWeaponFire(weapon)
    if weapon == 43 then
        local playersOnPhoto = {}
        local players = getElementsByType('player', root, true)

        for i, player in ipairs(players) do
            if isElementInPhotoArea(player) then
                table.insert(playersOnPhoto, player)
            end
        end

        triggerServerEvent('photograph:onPlayerPhoto', resourceRoot, playersOnPhoto)
	end
end

addEventHandler('onClientPlayerWeaponFire', root, onWeaponFire)