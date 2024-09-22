addEventHandler("onClientResourceStart", getRootElement(), function()
    txd = engineLoadTXD("models/taser.txd")
    engineImportTXD(txd, 347)
    dff = engineLoadDFF("models/taser.dff")
    engineReplaceModel(dff, 347)
end)
local posX, posY, posZ = getElementPosition(localPlayer)
local dim = getElementDimension(localPlayer) 
local int = getElementInterior(localPlayer)
local weaponsSound = {
	[23] = "sounds/taser.mp3"
}
function checkPlayerDamage(_, weapon)
    if (weapon == 23) then 
        setPedAnimation(source, "SWEET", "Sweet_injuredloop", 15000, true, false, false, false)
        cancelEvent()
    end
end 
function fireSound(weaponID)
if (weapon == 23) then
    setAmbientSoundEnabled("gunfire", false)
	sound = playSound3D(weaponsSound[weaponID], posX, posY, posZ)
    setSoundMaxDistance(sound, 80)
    setElementDimension(sound, dim)
    setElementInterior(sound, int)
    setSoundVolume(sound, 1)
    end 
end

addEventHandler("onClientPlayerDamage", root, checkPlayerDamage)
addEventHandler("onClientPlayerWeaponFire", root, fireSound)