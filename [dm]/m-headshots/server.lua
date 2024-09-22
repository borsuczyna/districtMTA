addEvent('onPlayerHeadshot', false)

function checkForHeadshot(attacker, weapon, bodypart, loss)
	if bodypart == 9 then
		local forceDeath = triggerEvent('onPlayerHeadshot', source, attacker, weapon, loss)

		if forceDeath then
			killPed(source, attacker, weapon, bodypart)
			setPedHeadless(source, true)
		end
	end
end

addEventHandler('onPlayerDamage', root, checkForHeadshot)

function restorePlayerHead()
	if isPedHeadless(source) then
		setPedHeadless(source, false)
	end
end

addEventHandler('onPlayerSpawn', root, restorePlayerHead)