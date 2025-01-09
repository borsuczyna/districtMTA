-- exports['m-ui']:setCursorAlpha(255)
-- local ax, ay, az = 0.3, 0.9, 0.4
-- local rx, ry, rz = 0, 0, 0
-- local veh = getPedOccupiedVehicle(localPlayer)
-- if not veh then return end

-- local sx, sy = guiGetScreenSize()
-- local object = createObject(1337, 0, 0, 0)
-- attachElements(object, veh, ax, ay, az)
-- local lookObject = createObject(1337, 0, 0, 0)
-- attachElements(lookObject, object, 0, 2, 0)
-- setElementCollisionsEnabled(object, false)
-- setElementCollisionsEnabled(lookObject, false)
-- setElementAlpha(object, 0)
-- setElementAlpha(lookObject, 0)
-- showCursor(true, false)

-- addEventHandler('onClientRender', root, function()
--     local cx, cy = getCursorPosition()
--     cx, cy = cx * sx, cy * sy
--     local dx, dy = cx - (sx / 2), cy - (sy / 2)
--     rx, rz = rx - dy / 10, rz - dx / 10
--     rx = math.max(-89, math.min(89, rx))
--     attachElements(object, veh, ax, ay, az, rx, ry, rz)
--     setCursorPosition(sx / 2, sy / 2)

--     local x, y, z = getElementPosition(object)
--     local lx, ly, lz = getElementPosition(lookObject)
--     setCameraMatrix(x, y, z, lx, ly, lz, 0, 120)

--     local verticalSize = sx * 9/25

--     dxDrawRectangle(0, 0, sx/2 - verticalSize/2, sy, tocolor(0, 0, 0, 200))
--     dxDrawRectangle(sx/2 + verticalSize/2, 0, sx/2 - verticalSize/2, sy, tocolor(0, 0, 0, 200))
-- end)

theTechnique = dxCreateShader("tex.fx")
explosionTexture = dxCreateTexture( "xd.png")

function replaceEffect()
	engineApplyShaderToWorldTexture(theTechnique, "*")
	dxSetShaderValue (theTechnique, "gTexture", explosionTexture)
end
addEventHandler("onClientResourceStart", resourceRoot, replaceEffect)