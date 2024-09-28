local coronas = {}
local coronaTxt = dxCreateTexture("data/blast.png")
local cameraPosition = Vector3(getCameraMatrix())
local shader = dxCreateShader("data/corona.fx")
dxSetShaderValue(shader, "gCoronaTexture", coronaTxt)

function queueCorona(x, y, z, size, color, type)
    table.insert(coronas,{
		x,y,z,
		color[1],color[2],color[3],color[4],
		size=size,
		type=type,
	})
end

function nightTime()
	if true then return 1 end
    local h, m = getTime()
    if h == 5 then
        return 1 - (m / 60)
    elseif h > 5 and h < 21 then
        return 0
    elseif h <= 4 then
        return 1
    elseif h > 21 then
        return 1
    elseif h == 21 then
        return m / 60
    end
end

local getScreenFromWorldPosition = getScreenFromWorldPosition
local dxDrawMaterialLine3D = dxDrawMaterialLine3D
local dxSetShaderValue = dxSetShaderValue
local getDistanceBetweenPoints3D = getDistanceBetweenPoints3D
local alphaType = {[0]=255,255,255,255,255,255}
--[[
function drawCorona(x, y, z, size, color, type)
	if true then return false end
    local night = nightTime()
	if night == 0 then return end
    local dist = getDistanceBetweenPoints3D(cameraPosition, x, y, z)   
	local distRatio = dist/400
	local alpha = distRatio < 1 and distRatio or 1
    if getScreenFromWorldPosition(x, y, z) and dist < 900 then
		alpha = alpha*alphaType[type]*night
        dxSetShaderValue(shader, "fCoronaPosition", x, y, z)
        dxDrawMaterialLine3D(
			0,0,-size*2,
			0,0,size*2,
			shader, size*4, 0xFFFFFFFF,
			0,1,0
		)
    end
end]]

local frames = 0
local renderPos = {
	[0] = {},
	[1] = {},
	[2] = {},
}
local renderColor = {
	[0] = {},
	[1] = {},
	[2] = {},
}

function drawCoronas()
	local tick = getTickCount()
    local night = 255
    alphaType[2] = interpolateBetween(0, 0, 0, night, 0, 0, (tick%1500)/1500, "CosineCurve")
    alphaType[3] = interpolateBetween(0, 0, 0, night, 0, 0, (tick%3500)/3500, "CosineCurve")
    alphaType[4] = alphaType[3]
    alphaType[6] = alphaType[3]
    local cx,cy,cz = getCameraMatrix()
	local materials = 0
	local index,line,corona,pos,listIndex
	local x,y,z
	if #coronas == 0 and isElement(shader) then
		dxSetShaderValue(shader,"drawPos",cx,cy,cz)
		dxSetShaderValue(shader,"farClip",0)
	end

	if not shader then
		shader = dxCreateShader("data/corona.fx")
		dxSetShaderValue(shader, "gCoronaTexture", coronaTxt)
	end

	local renderCount = #coronas
	local renderIndex = 0
	local rendered = 0
	local isRendered = false
	local rPos,rColor
	local vectorStart,vectorEnd = Vector3(cx,cy,cz+50),Vector3(cx,cy,cz-50)
	local vectorFace = Vector3(cx,cy+1,cz)
	local farClip = getFarClipDistance()
	renderPos = {
		[0] = {
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
		},
		[1] = {
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
		},
		[2] = {
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
		},
	}
	renderColor = {
		[0] = {},
		[1] = {},
		[2] = {},
	}
	dxSetShaderValue(shader,"drawPos",cx,cy,cz)
	dxSetShaderValue(shader,"farClip",farClip)
    for i=1,renderCount do
		corona = coronas[i]
		if corona then
			x,y,z = corona[1],corona[2],corona[3]
			if getScreenFromWorldPosition(x,y,z,0.1) then
				if getDistanceBetweenPoints3D(x,y,z,cx,cy,cz) <= farClip then
					index = (renderIndex%4)*4+1
					line = (renderIndex/4)%3
					line = line-line%1
					rPos = renderPos[line]
					rColor = renderColor[line]
					rPos[index] = x
					rPos[index+1] = y
					rPos[index+2] = z
					rPos[index+3] = corona.size
					rColor[index] = corona[4]
					rColor[index+1] = corona[5]
					rColor[index+2] = corona[6]
					rColor[index+3] = corona[7]
					renderIndex = renderIndex+1
					rendered = rendered+1
					isRendered = false
				end
			end
		end
		if ((renderIndex > 0 and renderIndex%12 == 0) or i == renderCount) and not isRendered then
			if renderIndex%12 ~= 0 then
				for ind=1,12-renderIndex%12 do
					index = (renderIndex%4)*4+1
					line = (renderIndex/4)%3
					line = line-line%1
					rPos = renderPos[line]
					rColor = renderColor[line]
					rPos[index] = 0
					rPos[index+1] = 0
					rPos[index+2] = 0
					rPos[index+3] = 0
					rColor[index] = 0
					rColor[index+1] = 0
					rColor[index+2] = 0
					rColor[index+3] = 0
					renderIndex = renderIndex+1
				end
			end
			dxSetShaderValue(shader,"coronaPos0",renderPos[0])
			dxSetShaderValue(shader,"coronaColor0",renderColor[0])
			dxSetShaderValue(shader,"coronaPos1",renderPos[1])
			dxSetShaderValue(shader,"coronaColor1",renderColor[1])
			dxSetShaderValue(shader,"coronaPos2",renderPos[2])
			dxSetShaderValue(shader,"coronaColor2",renderColor[2])
			materials = materials+1
			dxDrawMaterialLine3D(vectorStart,vectorEnd,shader,100,0xFFFFFFFF,vectorFace)
			isRendered = true
		end
    end
	--print(getTickCount()-tick,materials,rendered)
	--frames = frames+1 
	--dxDrawText("dxDrawMaterialLine3D Calls: "..materials,20,300)
	--dxDrawText("rendered coronas: "..rendered,20,320)
	
	coronas = {}
end