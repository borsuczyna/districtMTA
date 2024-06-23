local frozen = false

addEventHandler('onClientPlayerNetworkStatus', root, function(status)
	if status == 0 then
        if not isElementFrozen(localPlayer) then
		    setElementFrozen(localPlayer, true)
            frozen = true
        end
	elseif status == 1 then
        if frozen then
		    setElementFrozen(localPlayer, false)
            frozen = false
        end
	end
end)