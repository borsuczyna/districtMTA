addEvent('weather:receiveWeather', true)

local lastCityName = nil
local currentWeather = nil

local function updateWeather()
    if not getElementData(localPlayer, 'player:spawn') then 
        setWeather(0)
        return 
    end

    if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then 
        setWeather(0)
        return
    end

    local x, y, z = getElementPosition(localPlayer)
    local cityName = getZoneName(x, y, z, true)
    if cityName == lastCityName then return end

    triggerServerEvent('weather:fetchWeather', resourceRoot, cityName)
end

addEventHandler('weather:receiveWeather', resourceRoot, function(cityName, weather)    
    local x, y, z = getElementPosition(localPlayer)
    local city = getZoneName(x, y, z, true)
    if city ~= cityName then return end
    
    weather.city = cityName
    lastCityName = cityName

    setWeather(weather.weather)
    exports['m-timecyc']:setWeather(weather.weather)

    showWeatherData(weather)
end)

setTimer(updateWeather, 5000, 0)
addEventHandler('onClientResourceStart', resourceRoot, updateWeather)