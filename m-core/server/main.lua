local gameMode = 'RPG + Prace'
local fpsLimit = 75

addEventHandler('onResourceStart', resourceRoot, function()
    setGameType(gameMode)

    setMinuteDuration(60000)
    setTime(getRealTime().hour, getRealTime().minute)

    setFPSLimit(fpsLimit)
    setOcclusionsEnabled(false)
    setWeather(18)
end)