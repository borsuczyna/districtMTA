addEvent('weather:fetchWeather', true)

local weather = {}
local weathersData = {
    [1] = {
        cities = {'Los Santos', 'San Fierro', 'Red County', 'Flint County'},
        weathers = {
            {icon = 'sunny', name = 'Słonecznie', weathers = {0, 1, 11}, chance = 50},
            {icon = 'rain', name = 'Deszczowo', weathers = {8, 16}, chance = 2},
            {icon = 'partialyCloudy', name = 'Częściowe zachmurzenie', weathers = {4, 3}, chance = 35},
        },
    },
    [2] = {
        cities = {'Whetstone'},
        weathers = {
            {icon = 'snow', name = 'Opady śniegu', weathers = {9}, chance = 50},
            {icon = 'sunny', name = 'Słonecznie', weathers = {0}, chance = 50},
        },
    },
    [3] = {
        cities = {'Las Venturas', 'Bone County', 'Tierra Robada'},
        weathers = {
            {icon = 'sunny', name = 'Słonecznie', weathers = {0, 1}, chance = 100},
        }
    }
}

local function getRandomWeatherForCity(cityName)
    local availableWeathers = {}
    local totalChance = 0

    for _, weatherGroup in ipairs(weathersData) do
        if table.find(weatherGroup.cities, cityName) then
            for _, weatherData in ipairs(weatherGroup.weathers) do                
                totalChance = totalChance + weatherData.chance
                table.insert(availableWeathers, weatherData)
            end
        end
    end

    if #availableWeathers == 0 then
        return nil
    end

    local randomValue = math.random(1, totalChance)
    local accumulatedChance = 0

    for _, weatherData in ipairs(availableWeathers) do
        accumulatedChance = accumulatedChance + weatherData.chance

        if randomValue <= accumulatedChance then
            local randomIndex = math.random(1, #weatherData.weathers)
            local weatherId = weatherData.weathers[randomIndex]

            return {
                icon = weatherData.icon,
                name = weatherData.name,
                weather = weatherId
            }
        end
    end
end

local function rerollWeather(cityName)
    weather[cityName] = getRandomWeatherForCity(cityName)

    if weather[cityName] then
        triggerClientEvent(root, 'weather:receiveWeather', resourceRoot, cityName, weather[cityName])
    end
end

local function rerollAllWeather()
    for cityName, _ in pairs(weather) do
        rerollWeather(cityName)
    end
end

addEventHandler('weather:fetchWeather', resourceRoot, function(cityName)
    if not weather[cityName] then
        weather[cityName] = getRandomWeatherForCity(cityName)
    end

    if weather[cityName] then
        triggerClientEvent(client, 'weather:receiveWeather', resourceRoot, cityName, weather[cityName])
    end
end)

setTimer(rerollAllWeather, 1000 * 60 * 60, 0)

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end