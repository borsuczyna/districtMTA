local weatherUILoaded, boilerplateUIVisible, weatherHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('weather', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'weather' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showWeatherInterface()
    exports['m-ui']:loadInterfaceElementFromFile('weather', 'm-weather/data/interface.html')
end

function setWeatherUIVisible(visible)
    if weatherHideTimer and isTimer(weatherHideTimer) then
        killTimer(weatherHideTimer)
    end

    weatherUIVisible = visible

    if not visible and isTimer(weatherTimer) then
        killTimer(weatherTimer)
    end

    if not weatherUILoaded and visible then
        showWeatherInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('weather', 'play-animation', false)
            weatherHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('weather')
                weatherUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('weather', true)
            setInterfaceData()
            weatherUIVisible = true
        end
    end
end

function toggleWeatherUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setWeatherUIVisible(not weatherUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    toggleWeatherUI()
    
    addEventHandler('interfaceLoaded', root, function()
        weatherUILoaded = false
        setWeatherUIVisible(weatherUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('weather')
end)