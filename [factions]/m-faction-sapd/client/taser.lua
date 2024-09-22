function fireSound(weapon, _, _, hitX, hitY, hitZ, element, startX, startY, startZ)
    if weapon == 23 and element and getElementType(element) == 'player' then
        local sound = playSound3D('data/taser.mp3', hitX, hitY, hitZ)
        setSoundMaxDistance(sound, 25)

        for i = 1, 5, 1 do
            fxAddPunchImpact(hitX, hitY, hitZ, 0, 0, 0)
            fxAddSparks(hitX, hitY, hitZ, 0, 0, 0, 8, 1, 0, 0, 0, true, 3, 1)
        end

        fxAddPunchImpact(startX, startY, startZ, 0, 0, -3)
    end
end

addEventHandler('onClientPlayerWeaponFire', root, fireSound)