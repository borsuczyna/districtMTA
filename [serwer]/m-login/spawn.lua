addEvent('login-spawn:spawn', true)

addEventHandler('login-spawn:spawn', root, function(category, index)
    setTimer(function()
        exports['m-ui']:destroyInterfaceElement('login-spawn')
        exports['m-hud']:setHudVisible(true)
        hideInterface()
        triggerServerEvent('login:spawn', resourceRoot, category, index)
    end, 1000, 1)
end)

function setSpawnsData()
    exports['m-ui']:setInterfaceData('login-spawn', 'spawns', spawns)
end

addEventHandler('interface:load', root, function(name)
    if name == 'login-spawn' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setSpawnsData()
    end
end)

function showSpawnSelect()
    triggerServerEvent('login-spawn:getPlayerHouses', resourceRoot)
    exports['m-ui']:loadInterfaceElementFromFile('login-spawn', 'm-login/data/spawn.html')
end