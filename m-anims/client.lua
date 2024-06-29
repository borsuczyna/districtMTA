local playing = {}
local updates = {}
local animations = {
    ["handcuffs"] = {
        frame_time = 1000,
        frames = {
            {
                [22] = {rotation="30,50,-70"},
                [23] = {rotation="0,50,-5"},

                [32] = {rotation="-50,40,70"},
                [33] = {rotation="0,45,-5"},
            },
            {
                [22] = {rotation="30,50,-70"},
                [23] = {rotation="0,40,-5"},

                [32] = {rotation="-40,50,70"},
                [33] = {rotation="0,45,-5"},
            },
        },
    },
    ['scooter-carry'] = fromJSON('[ { "frame_time": 1000, "frames": [ { "22": { "rotation": "-33.502793710443,-17.170629573774,-45.168605369858" }, "23": { "rotation": "36.492159686511,-54.501254697389,10.82734622231" } } ] } ]'),
    ['rece2'] = fromJSON('[ { "frame_time": 1000, "frames": [ { "24": { "rotation": "202.14682431764,-26.503278901305,0" }, "32": { "rotation": "-110.49720628956,-26.503278901305,-0.83849325059333" }, "22": { "rotation": "0,-12.504304910008,13.160508554193" }, "34": { "rotation": "-140.82834441752,-61.500769506527,0" }, "23": { "rotation": "50.491133677809,-24.170116569422,29.492644877373" }, "33": { "rotation": "-0.83849325059333,-19.503791905657,31.825835022745" } } ] } ]'),
    ['rece'] = fromJSON('[ { "frame_time": 1000, "frames": [ { "23": { "rotation": "120.48608707476,0,92.48808346519" }, "33": { "rotation": "-129.16253275811,-0.83849325059333,-89.498745302611" }, "32": { "rotation": "3.8278592266614,-35.835956042326,-14.837467241891" }, "22": { "rotation": "1.4946968947785,-24.170116569422,22.493157881725" } } ] } ]'),
    ["pick_up"] = fromJSON('[ { "frame_time": 500, "frames": [ { "2": { "rotation": "0,20.159995549842,0" }, "32": { "rotation": "-21.83695423754,-10.171142578125,78.489109473892" }, "33": { "rotation": "-0.83849325059333,0,0" }, "3": { "rotation": "6.1610215585443,0,0" }, "23": { "rotation": "10.82734622231,0,0" }, "22": { "rotation": "0,0,-68.500256502176" } }, { "2": { "rotation": "0,34.158997354628,0" }, "32": { "rotation": "-33.502793710443,-80.16606816159,8.4941838904272" }, "22": { "rotation": "83.155434137658,-66.167094170293,-28.836469046677" }, "3": { "rotation": "1.4946968947785,41.158484350277,0" }, "23": { "rotation": "-75.499743497824,-110.49720628956,-56.834417029272" }, "33": { "rotation": "-0.83849325059333,-73.166581165941,0" } }, { "2": { "rotation": "1.4946968947785,-3.1716555824763,0" }, "32": { "rotation": "-10.171142578125,-49.834930033623,36.492159686511" }, "33": { "rotation": "-0.83849325059333,-77.832905829707,-14.837467241891" }, "22": { "rotation": "43.49164668216,-40.502280706092,-42.835443037975" }, "23": { "rotation": "13.160508554193,-56.834417029272,0" }, "3": { "rotation": "6.1610215585443,6.1610215585443,0" } } ] } ]'),
    ["carry"] = fromJSON('[ { "frame_time": 1000, "frames": [ { "33": { "rotation": "34.158997354628,-63.83393183841,22.493157881725" }, "22": { "rotation": "8.4941838904272,-54.501254697389,-45.168605369858" }, "32": { "rotation": "-54.501254697389,-54.501254697389,48.157971345926" }, "23": { "rotation": "-10.171142578125,-61.500769506527,27.159482545491" } } ] } ]'),
    ["carry2"] = fromJSON('[ \
        { \
           "frame_time":1000, \
           "frames":[ \
              { \
                 "33":{ \
                    "rotation":"34.158997354628,-63.83393183841,22.493157881725" \
                 }, \
                 "22":{ \
                    "rotation":"8.4941838904272,-54.501254697389,-20.168605369858" \
                 }, \
                 "32":{ \
                    "rotation":"-34.501254697389,-54.501254697389,20.157971345926" \
                 }, \
                 "23":{ \
                    "rotation":"-10.171142578125,-31.500769506527,27.159482545491" \
                 } \
              } \
           ] \
        } \
     ]'),
}

function replaceTempAnimation(data)
    animations["_temp"] = data
end

function playPedAnimation(ped, name, start, start_frame)
    playing[ped] = {name=name, start=(start or getTickCount()), frame=(start_frame or 1), update=getTickCount()}
end

function processPosition(position, ped, bone)
    if position:sub(1, 1) == "+" then
        local bx, by, bz = getPedBonePosition(ped, bone)
        local px, py, pz = getElementPosition(ped)
        local x, y, z = loadstring("return " .. position:sub(2, #position))()
        x, y, z = getPositionFromElementOffset(ped, x, y, z)
        x, y, z = x - px, y - py, z - pz
        x, y, z = x + bx, y + by, z + bz
        return x, y, z
    elseif position:sub(1, 1) == "o" then
        local x, y, z = loadstring("return " .. position:sub(2, #position))()
        x, y, z = getPositionFromElementOffset(ped, x, y, z)
        return x, y, z
    else
        local x, y, z = loadstring("return " .. position)()
        return x, y, z
    end
end

function processRotation(rotation, ped, bone)
    if rotation:sub(1, 1) == "+" then
        local bx, by, bz = getElementBoneRotation(ped, bone)
        local x, y, z = loadstring("return " .. rotation:sub(2, #rotation))()
        x, y, z = x + bx, y + by, z + bz
        return x, y, z
    else
        local x, y, z = loadstring("return " .. rotation)()
        return x, y, z
    end
end

function processAnimation(ped, data, fdata)
    local frame = fdata.frame

    for k,v in pairs(data.frames[frame]) do
        if not updates[ped] then updates[ped] = getTickCount() end
        local t = (getTickCount() - updates[ped])/data.frame_time
        
        local next_frame = nextFrame(fdata, data)
        if next_frame < frame and next_frame == 1 then
            triggerEvent("onAnimationEnd", ped, fdata.name)
        end

        if v.rotation then
            local x1, y1, z1 = processRotation(v.rotation, ped, k)
            local x2, y2, z2 = processRotation(data.frames[next_frame][k].rotation, ped, k)

            local x, y, z = x1 + (x2 - x1)*t, y1 + (y2 - y1)*t, z1 + (z2 - z1)*t
            
            setElementBoneRotation(ped, k, x, y, z)
            updateElementRpHAnim(ped)
        end

        if v.position then
            local x1, y1, z1 = processPosition(v.position, ped, k)
            local x2, y2, z2 = processPosition(data.frames[next_frame][k].position, ped, k)

            local x, y, z = x1 + (x2 - x1)*t, y1 + (y2 - y1)*t, z1 + (z2 - z1)*t

            setElementBonePosition(ped, k, x, y, z)
        end        
    end
end

function nextFrame(v, data)
    local frame = v.frame
    frame = frame + 1
    if frame > #data.frames then
        frame = 1
    end
    return frame
end

addEvent("onAnimationRestart", true)
addEvent("onAnimationEnd", true)

addEventHandler("onClientPedsProcessed", root, function()
    for k,v in pairs(playing) do
        if k and isElement(k) then
            local data = animations[v.name]
            if data then
                if not updates[k] then updates[k] = getTickCount() end
                if updates[k] + data.frame_time < getTickCount() then
                    updates[k] = getTickCount()
                    local prev = tonumber(v.frame)
                    v.frame = nextFrame(v, data)
                    if prev > v.frame and v.frame == 1 then
                        triggerEvent("onAnimationRestart", k, v.name)
                    end
                end

                processAnimation(k, data, v)
            end
        end
    end
end, true, "high+999")

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

-- synchronization

function updatePlayerSync(player)
    local anim = getElementData(player, "player:animation")
    local frame = getElementData(player, "player:animation:frame")
    local start = getElementData(player, "player:animation:start")
    updates[player] = start
    if not anim then
        playing[player] = nil
        return
    end
    
    playPedAnimation(player, anim, start, 1)
end

addEventHandler("onClientElementDataChange", root, function(key, old, new)
    if key == "player:animation" then
        updatePlayerSync(source)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    for k,v in pairs(getElementsByType("player")) do
        updatePlayerSync(v)
    end
    for k,v in pairs(getElementsByType("ped")) do
        updatePlayerSync(v)
    end
end)

function removeCustomAnimation()
    setElementData(localPlayer, "player:animation", nil)
    setElementData(localPlayer, "player:animation:start", false)
    setElementData(localPlayer, "player:animation:frame", false)
end

function playCustomAnimation(name, frame)
    setElementData(localPlayer, "player:animation", name)
    setElementData(localPlayer, "player:animation:start", getTickCount())
    setElementData(localPlayer, "player:animation:frame", (frame or 1))
end

--[[
addCommandHandler("hands", function()
    playCustomAnimation("pick_up")
end)

addCommandHandler("off", function()
    removeCustomAnimation()
end)

addEventHandler("onAnimationRestart", root, function(name)
    print(name)
end)]]

bindKey("1", "down", function()
    if getElementData(localPlayer, "player:animation") ~= "rece" then
        setElementData(localPlayer, "player:animation", "rece")
    elseif getElementData(localPlayer, "player:animation") == "rece" then
        setElementData(localPlayer, "player:animation", nil)
    else
        setElementData(localPlayer, "player:animation", "rece")
    end
end)

bindKey("2", "down", function()
    if getElementData(localPlayer, "player:animation") ~= "rece2" then
        setElementData(localPlayer, "player:animation", "rece2")
    elseif getElementData(localPlayer, "player:animation") == "rece2" then
        setElementData(localPlayer, "player:animation", nil)
    else
        setElementData(localPlayer, "player:animation", "rece2")
    end
end)