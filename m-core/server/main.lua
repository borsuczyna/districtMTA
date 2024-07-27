local gameMode = 'RPG + Prace'
local fpsLimit = 75

function updateRealTime()
    local time = getRealTime()
    setTime(time.hour, time.minute)
end

addEventHandler('onResourceStart', resourceRoot, function()
    setGameType(gameMode)

    setMinuteDuration(60000)
    setTimer(updateRealTime, 60000, 0)
    updateRealTime()

    setFPSLimit(fpsLimit)
    setOcclusionsEnabled(false)
    setWeather(18)

    setWorldSpecialPropertyEnabled('burnflippedcars', false)
end)