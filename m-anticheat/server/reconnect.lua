local players = {}
local timers = {}

local function reconnectPlayer(player)
    if isElement(player) then
        local serial = getPlayerSerial(player)

        if players[serial] then 
            players[serial] = false
        else 
            redirectPlayer(player, '', 0)
            removeEventHandler('onPlayerQuit', player, onQuit)

            setTimer(function(newSerial)
                players[newSerial] = true
            end, 3000, 1, serial)
        end 
    end 
end

function onJoin()
    addEventHandler('onPlayerQuit', source, onQuit)
    timers[source] = setTimer(reconnectPlayer, 10000, 1, source)
end 

addEventHandler('onPlayerJoin', root, onJoin)

function onQuit()
    local serial = getPlayerSerial(source)

    if players[serial] then 
        players[serial] = false

        if isTimer(timers[source]) then 
            killTimer(timers[source])
        end 
    end 
end 