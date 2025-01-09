local pos, camerapos, count, AFK = false, false, 0, false

local function isAFK()
    if pos and camerapos then
        local cx, cy, cz, lx, ly, lz = getCameraMatrix(localPlayer)
        local x, y, z = getElementPosition(localPlayer)

        if (x == pos[1] and y == pos[2] and z == pos[3] and cx == camerapos[1] and cy == camerapos[2] and cz == camerapos[3] and lx == camerapos[4] and ly == camerapos[5] and lz == camerapos[6]) then
            count = count + 1
            if (count >= 60 and not AFK) then
                AFK = true
                setElementData(localPlayer, 'player:afk', true)
                outputChatBox('✈ #FFFFFFPrzechodzisz w tryb AFK, od tego momentu wszelkie bonusy nie będą naliczane.', 255, 55, 55, true)
            end
        else
            if AFK then
                AFK = false
                setElementData(localPlayer, 'player:afk', false)
                outputChatBox('✈ #FFFFFFGra została wznowiona, od teraz bonusy będą naliczane.', 255, 55, 55, true)
            end
            pos, camerapos, count = false, false, 0
        end
    else
        local cx, cy, cz, lx, ly, lz = getCameraMatrix(localPlayer)
        local x, y, z = getElementPosition(localPlayer)
        pos, camerapos = {x, y, z}, {cx, cy, cz, lx, ly, lz}
    end
end
setTimer(isAFK, 1000, 0)