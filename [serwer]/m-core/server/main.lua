local gameMode = 'RPG + Fabuła'
local fpsLimit = 100

function updateRealTime()
    local time = getRealTime()
    setTime(time.hour + 2 % 24, time.minute)
end

addEventHandler('onResourceStart', resourceRoot, function()
    setGameType(gameMode)

    setMinuteDuration(60000)
    setTimer(updateRealTime, 60000, 0)
    updateRealTime()

    setFPSLimit(fpsLimit)
    setOcclusionsEnabled(false)

    setMoonSize(1)
    setHeatHaze(0)

    setWorldSpecialPropertyEnabled('burnflippedcars', false)
end)