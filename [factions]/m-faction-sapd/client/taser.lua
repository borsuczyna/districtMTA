local weaponSounds = {
    [23] = 'data/taser.mp3',
    [25] = 'data/chromegun.mp3'
}

addEventHandler('onClientPlayerDamage', root, function(attacker, weapon, bodypart, loss)
    if weapon == 23 or weapon == 25 then
        cancelEvent()
    end
end)

function fireSound(weapon, _, _, hitX, hitY, hitZ, element, startX, startY, startZ)
    if weapon == 23 then
        local sound = playSound3D(weaponSounds[weapon], hitX, hitY, hitZ)
        setSoundMaxDistance(sound, 25)

        for i = 1, 15, 1 do
            fxAddPunchImpact(hitX, hitY, hitZ, 0, 0, 0)
            fxAddSparks(hitX, hitY, hitZ, 0, 0, 0, 8, 1, 0, 0, 0, true, 3, 1)
        end

        fxAddPunchImpact(startX, startY, startZ, 0, 0, -3)
    elseif weapon == 25 then
        local sound = playSound3D(weaponSounds[weapon], startX, startY, startZ)
        setSoundMaxDistance(sound, 25)

        for i = 1, 15, 1 do
            fxAddPunchImpact(hitX, hitY, hitZ, 0, 0, 0)
            fxAddSparks(hitX, hitY, hitZ, 0, 0, 0, 8, 1, 0, 0, 0, true, 3, 1)
        end

        fxAddPunchImpact(startX, startY, startZ, 0, 0, -3)
    end
end

addEventHandler('onClientPlayerWeaponFire', root, fireSound)
