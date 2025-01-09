local car = dxCreateTexture("data/car.png", "argb", true, "clamp")
local lights = dxCreateTexture("data/lights.png", "argb", true, "clamp")
local sx, sy = guiGetScreenSize()
local zoom = 1 
if sx < 2048 then
	zoom = math.min(2.2, 2048/sx)
end 
local font = dxCreateFont("data/font.ttf", 13/zoom)

addEventHandler("onClientRender", root, function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local modes = getVehicleModes(veh)
    if not modes then return end

    dxDrawRectangle(50/zoom, sy/2 - 75/zoom, 370/zoom, 150/zoom, tocolor(0,0,0,180))
    -- draw border with color 25,25,25 around it, 2 pixels thick
    dxDrawRectangle(48/zoom, sy/2 - 75/zoom, 370/zoom, 2, tocolor(25,25,25,180))
    dxDrawRectangle(48/zoom, sy/2 - 73/zoom, 2, 150/zoom, tocolor(25,25,25,180))
    dxDrawRectangle(48/zoom, sy/2 + 73/zoom, 370/zoom, 2, tocolor(25,25,25,180))
    dxDrawRectangle(313/zoom, sy/2 - 75/zoom, 2, 150/zoom, tocolor(25,25,25,180))
    dxDrawRectangle(418/zoom, sy/2 - 75/zoom, 2, 150/zoom, tocolor(25,25,25,180))
    
    dxDrawImage(100/zoom, sy/2 - 20/zoom, 160/zoom, 55/zoom, car)

    local activeModes = getElementData(veh, "vehicle:els:modes") or {}

    local function isModeActive(name)
        local t = (modes.draw and modes.draw[name])
        if t then
            for k,v in pairs(t) do
                if activeModes[v] then
                    return true
                end
            end
        end
    end

    local on = isModeActive("top")
    local color = on and tocolor(255,255,255,255) or tocolor(65,65,65,255)
    dxDrawImage(160/zoom, sy/2 - 57/zoom, 55/zoom, 28/zoom, lights, 0, 0, 0, color)

    local on = isModeActive("back")
    local color = on and tocolor(255,255,255,255) or tocolor(65,65,65,255)
    dxDrawImage(260/zoom, sy/2 - 2/zoom, 55/zoom*0.7, 28/zoom*0.9, lights, 90, 0, 0, color)

    local on = isModeActive("front")
    local color = on and tocolor(255,255,255,255) or tocolor(65,65,65,255)
    dxDrawImage(60/zoom, sy/2 + 2/zoom, 55/zoom*0.7, 28/zoom*0.9, lights, -90, 0, 0, color)

    local on = {}

    for i = 1, 8 do
        for k,v in pairs(activeModes) do
            if v then
                local mode = modes[k]
                if mode[mode.index] and mode[mode.index][i + 10] and v then
                    on[i] = true
                end
            end
        end
    end

    for i = 1, 8 do
        local color = on[i] and tocolor(151,151,151,255) or tocolor(35,35,35,255)
        dxDrawRectangle(36/zoom + 29/zoom*i, sy/2 + 50/zoom, 25/zoom, 8/zoom, color)
    end

    local h = 0
    for k,v in ipairs(modes) do
        if v.name then
            h = h + 20/zoom
        end
    end

    local y = sy/2 - h/2
    for k,v in ipairs(modes) do
        if v.name then
            dxDrawText(v.name, 325/zoom, y, 410/zoom, sy, activeModes[k] and tocolor(255,255,255) or tocolor(100,100,100,255), 1, font, "center")
            y = y + 20/zoom
        end
    end
end)

function switchLights(key)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local driver = getVehicleOccupant(veh, 0)
    if driver ~= localPlayer then return end
    local modes = getVehicleModes(veh)
    if not modes or not modes[tonumber(key)] then return end
    local mode = getElementData(veh, "vehicle:els:modes") or {}
    local found = false
    for e,d in pairs(modes) do
        for k,v in pairs(d.collidable or {}) do
            if v == tonumber(key) and mode[e] then
                found = true
                break
            end
        end
    end
    if not found then
        playSound("data/sounds/click.wav")
        mode[tonumber(key)] = not mode[tonumber(key)]
    end
    setElementData(veh, "vehicle:els:modes", mode)
end

function switchPreset(key)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local driver = getVehicleOccupant(veh, 0)
    if driver ~= localPlayer then return end
    local modes = getVehicleModes(veh)
    if not modes or not modes.presets then return end
    local presets = modes.presets
    if not presets[key] then return end
    for k,v in pairs(presets[key]) do
        switchLights(v)
    end
end

addEventHandler("onClientKey", root, function(key, state)
    if not state then return end
    -- if key:sub(1,4) == "num_" then
    --     switchLights(key:sub(5))
    -- end
    -- no numpad version
    if tonumber(key) then
        switchLights(key)
    end

    if #key == 1 then
        switchPreset(key)
    end
end)