addEvent('missions:onVoiceLineFinish', true)

local playingVoiceLines = {}
local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local font = exports['m-ui']:getFont('Inter-Medium', 25)
local fontBold = exports['m-ui']:getFont('Inter-Bold', 25)
local fontHeight = dxGetFontHeight(1, font)
local missionTarget = false
local DEBUG_SKIP_VOICE = false

-- bindKey('r', 'down', function()
--     if DEBUG_SKIP_VOICE then
--         DEBUG_SKIP_VOICE = false
--         outputChatBox('Debugowanie głosu wyłączone')
--     else
--         DEBUG_SKIP_VOICE = true
--         outputChatBox('Debugowanie głosu włączone')
--     end
-- end)

local function urlEncode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function (c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function playTTS(text, lang)
    local URL = ('http://translate.google.com/translate_tts?tl=%s&q=%s&client=tw-ob'):format(lang, urlEncode(text))
    return URL
end

local function updatePedVoice(ped, fft)
    -- local openMouthValue = math.sqrt(fft[15]) * 256
    -- local boneId = 8
    -- local x, y, z = getElementBonePosition(ped, boneId)
    -- if not x or not y or not z or not openMouthValue or openMouthValue ~= openMouthValue then
    --     return
    -- end
    
    -- local rx, ry, rz = getElementBoneRotation(ped, boneId)
    -- setElementBoneRotation(ped, boneId, rx, ry + openMouthValue / 3, rz)
    -- updateElementRpHAnim(ped)
end

function renderVoiceLines()
    if (#playingVoiceLines + (missionTarget and 1 or 0)) == 0 then
        removeEventHandler('onClientPedsProcessed', root, renderVoiceLines)
        return
    end

    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    local zoom = zoomOriginal * (25 / interfaceSize)
    local y = sy - 145/zoom

    local lineColors = {
        tocolor(255, 255, 255, 255),
        tocolor(200, 255, 200, 255),
        tocolor(255, 200, 200, 255),
        tocolor(200, 200, 255, 255),
        tocolor(255, 255, 200, 255),
        tocolor(200, 255, 255, 255),
        tocolor(255, 200, 255, 255),
    }

    if (#playingVoiceLines + (missionTarget and 1 or 0)) > 1 then
        y = y - #playingVoiceLines * (fontHeight / zoom + 44/zoom)
    end

    for i, line in ipairs(playingVoiceLines) do
        if not isElement(line.ped) or not isElement(line.sound) then
            table.remove(playingVoiceLines, i)
            triggerEvent('missions:onVoiceLineFinish', resourceRoot, line.line)
        end

        if isElement(line.sound) then
            local fft = getSoundFFTData(line.sound, 2048, 256)
            if fft then
                updatePedVoice(line.ped, fft)
            end

            local color = lineColors[i % #lineColors]
            dxDrawText(line.text, 2, y + 2, sx + 2, sy + 2, tocolor(0, 0, 0, 155), 1/zoom, font, 'center', 'center', false, false, false, true)
            dxDrawText(line.text, 0, y, sx, sy, color, 1/zoom, font, 'center', 'center', false, false, false, true)
            y = y + fontHeight / zoom + 44/zoom
        end
    end

    if missionTarget then
        dxDrawText(missionTarget, 2, y + 2, sx + 2, sy + 2, tocolor(0, 0, 0, 155), 1/zoom, fontBold, 'center', 'center', false, false, false, true)
        dxDrawText(missionTarget, 0, y, sx, sy, tocolor(255, 170, 85, 255), 1/zoom, fontBold, 'center', 'center', false, false, false, true)
    end
end

function pedTellVoiceLine(ped, line, text)
    if DEBUG_SKIP_VOICE then
        setTimer(triggerEvent, 10, 1, 'missions:onVoiceLineFinish', resourceRoot, line)
        return
    end

    local sound;

    local path = ('data/voice/%s.mp3'):format(line)
    if line ~= '' and fileExists(path) then
        sound = playSound(path)
    else
        print('Playing TTS for', path)
        local url = playTTS(text, 'pl')
        -- sound = playSound3D(url, 0, 0, 0, false)
        sound = playSound(url)
        setSoundSpeed(sound, (ped == localPlayer and 1.2 or 1.5) * 1)
    end

    -- setSoundMaxDistance(sound, 35)
    -- setSoundMinDistance(sound, 10)
    -- attachElements(sound, ped, 0, 0, 1)
    -- setElementDimension(sound, getElementDimension(localPlayer))
    -- setElementInterior(sound, getElementInterior(localPlayer))

    table.insert(playingVoiceLines, {
        ped = ped,
        sound = sound,
        text = text,
        path = path,
        line = line
    })

    if not isEventHandlerAdded('onClientPedsProcessed', root, renderVoiceLines) then
        addEventHandler('onClientPedsProcessed', root, renderVoiceLines)
    end
end

function clearAllVoiceLines()
    for i, line in ipairs(playingVoiceLines) do
        if isElement(line.sound) then
            destroyElement(line.sound)
        end
    end

    playingVoiceLines = {}
end

function setMissionTarget(text)
    if #text == 0 then
        missionTarget = nil
        return
    end

    missionTarget = text

    if not isEventHandlerAdded('onClientPedsProcessed', root, renderVoiceLines) then
        addEventHandler('onClientPedsProcessed', root, renderVoiceLines)
    end
end

-- local ped = createPed(291, 992.570, -1440.423, 13.586, 61)
-- local menelica = createPed(38, 992.893, -1439.800, 13.586, 85)
-- local beer = createObject(1544, 0, 0, 0)
-- setObjectScale(beer, 0.8)
-- exports['m-anim']:setPedAnimation(ped, 'ciolek')
-- exports['m-anim']:setPedAnimation(menelica, 'menelica')
-- exports['m-pattach']:attach(beer, menelica, 25, 0.05, 0.05, -0.1, 0, 0, 0)
-- pedTellVoiceLine(menelica, 'menelica', '')
-- pedTellVoiceLine(ped, 'ciolek', '')
-- setMissionTarget('Wsiądź do pojazdu')