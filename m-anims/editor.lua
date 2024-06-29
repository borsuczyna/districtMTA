addCommandHandler("aeditor", function()
    local sx, sy = guiGetScreenSize()
    local zoom = 1 
    if sx < 2048 then
        zoom = math.min(2.2, 2048/sx)
    end 

    local guiFont = "default"
    local circle = dxCreateTexture("data/circle.png")

    local editor = {
        open = true,
        bone = 32,
        rx = 0,
        ry = 0,
        rz = 0,
        prev_frame = 1,
        frame = 1,
        data = {
            frame_time = 1000,
            frames = {},
        },
    }

    addCommandHandler("next", function()
        editor.prev_frame = editor.frame
        editor.frame = editor.frame + 1
        refreshEditor()
    end)

    addCommandHandler("prev", function()
        editor.prev_frame = editor.frame
        editor.frame = math.max(editor.frame - 1, 1)
        refreshEditor()
    end)

    addCommandHandler("bone", function(_, id)
        editor.bone = tonumber(id)
        refreshEditor()
    end)

    addCommandHandler("copy", function(_, id)
        setClipboard(toJSON(editor.data))
    end)

    addCommandHandler("removebone", function(_, id)
        for k,v in pairs(editor.data.frames) do
            for d,c in pairs(v) do
                if d == tonumber(id) then
                    v[d] = nil
                end
            end
        end
    end)

    function refreshEditor()
        if not editor.data.frames[editor.frame] or not editor.data.frames[editor.frame][editor.bone] or not editor.data.frames[editor.frame][editor.bone].rotation then
            if editor.data.frames[editor.prev_frame] and editor.data.frames[editor.prev_frame][editor.bone] then
                local rx, ry, rz = loadstring("return " .. editor.data.frames[editor.prev_frame][editor.bone].rotation)()
                editor.rx = rx
                editor.ry = ry
                editor.rz = rz
            else
                editor.rx = 0
                editor.ry = 0
                editor.rz = 0
            end
            return
        end
        local rx, ry, rz = loadstring("return " .. editor.data.frames[editor.frame][editor.bone].rotation)()
        editor.rx = rx
        editor.ry = ry
        editor.rz = rz
    end

    function updateTempBone()
        if not editor.data.frames[editor.frame] then
            editor.data.frames[editor.frame] = {}
        end

        for e,v in pairs(editor.data.frames) do
            for k,l in pairs(v) do
                for d,c in pairs(editor.data.frames) do
                    if not c[k] then
                        c[k] = l
                    end
                end
            end
        end

        editor.data.frames[editor.frame][editor.bone] = {rotation=(editor.rx..","..editor.ry..","..editor.rz)}

        replaceTempAnimation(editor.data)

        playPedAnimation(localPlayer, "_temp", false, editor.frame)
    end

    updateTempBone()

    addEventHandler("onClientRender", root, function()
        if not editor.open then return end

        showCursor(not getKeyState("mouse2"))

        dxDrawRectangle(0, sy - 260/zoom, sx, 260/zoom, tocolor(0, 0, 0, 155))
        dxDrawText("Editing bone: " .. editor.bone .. "\nCurrent frame: " .. editor.frame .. "\nRotation: " .. math.floor(editor.rx) .. ", " .. math.floor(editor.ry) .. ", " .. math.floor(editor.rz), 15/zoom, sy - 250/zoom, sx, sy, white, 1.9/zoom, guiFont)

        local y = 10/zoom
        dxDrawRectangle(15/zoom, sy - 170/zoom + y, 400/zoom, 35/zoom, tocolor(0, 0, 0, 155))
        dxDrawRectangle(18/zoom, sy - 167/zoom + y, 395/zoom * (editor.rx+360)/720, 29/zoom, tocolor(255, 0, 0, 155))

        dxDrawRectangle(15/zoom, sy - 120/zoom + y, 400/zoom, 35/zoom, tocolor(0, 0, 0, 155))
        dxDrawRectangle(18/zoom, sy - 117/zoom + y, 395/zoom * (editor.ry+360)/720, 29/zoom, tocolor(0, 255, 0, 155))

        dxDrawRectangle(15/zoom, sy - 70/zoom + y, 400/zoom, 35/zoom, tocolor(0, 0, 0, 155))
        dxDrawRectangle(18/zoom, sy - 67/zoom + y, 395/zoom * (editor.rz+360)/720, 29/zoom, tocolor(0, 0, 255, 155))

        if getKeyState("mouse1") then
            local cx, cy = getCursorPosition()
            cx, cy = cx * sx, cy * sy
            if isMouseInPosition(18/zoom, sy - 167/zoom + y, 395/zoom, 29/zoom) then
                editor.rx = ((cx - 18/zoom)/(395/zoom))*720-360

                updateTempBone()
            elseif isMouseInPosition(18/zoom, sy - 117/zoom + y, 395/zoom, 29/zoom) then
                editor.ry = ((cx - 18/zoom)/(395/zoom))*720-360

                updateTempBone()
            elseif isMouseInPosition(18/zoom, sy - 67/zoom + y, 395/zoom, 29/zoom) then
                editor.rz = ((cx - 18/zoom)/(395/zoom))*720-360

                updateTempBone()
            end
        end
    end)

    function isMouseInPosition ( x, y, width, height )
        if ( not isCursorShowing( ) ) then
            return false
        end
        local sx, sy = guiGetScreenSize ( )
        local cx, cy = getCursorPosition ( )
        local cx, cy = ( cx * sx ), ( cy * sy )
        
        return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
    end
end)