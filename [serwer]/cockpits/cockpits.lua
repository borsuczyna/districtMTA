local root = getRootElement()
local localPlayer = localPlayer
local PI = math.pi

local isEnabled = false
local wasInVehicle = isPedInVehicle(localPlayer)

local mouseSensitivity = 0.1
local rotX, rotY = 0,0
local mouseFrameDelay = 0
local idleTime = 2500
local fadeBack = false
local fadeBackFrames = 50
local executeCounter = 0
local recentlyMoved = false
local Xdiff,Ydiff
local FPSactive = false
local isAiming = false
local checking = 0
local isInWall = false
local isForced = false

function setFirspersonEnabled(state, force, force2)
	--exports.TR_dashboard:setDashboardResponseShader()

	if isForced and (not force or not force2) then return end
	if state then
		firstPersonEnable()
		if force2 then
			isForced = nil
		else
			isForced = force
		end

	elseif not state then
		firstPersonDisable()
		isForced = nil
	end
end

function firstPersonEnable()
	if isEnabled then return end
	isEnabled = true
	addEventHandler ("onClientPreRender", root, updateCamera)
	addEventHandler ("onClientCursorMove",root, freecamMouse)
	bindKey ("aim_weapon", "both", aimCheck )
	bindKey ("jump", "down", climbcheck )

	setElementAlpha(localPlayer, 0)

	addEventHandler ("onClientRender", root, noWallXRay)
	markerWallCheck = createMarker ( 2, 2, 2, "cylinder", 0.7, 255, 0, 0, 0, 0 )
	attachElements(markerWallCheck, localPlayer,0,0.5,0)
	setElementAlpha(markerWallCheck, 0)
end

function firstPersonDisable()
	if not isEnabled then return end
	isEnabled = false
	setCameraTarget (localPlayer, localPlayer)
	removeEventHandler ("onClientPreRender", root, updateCamera)
	removeEventHandler ("onClientCursorMove", root, freecamMouse)
	unbindKey ("aim_weapon", "both", aimCheck )
	unbindKey ("jump", "down", climbcheck )

	if isElement(getElementData (localPlayer, "firstPersonCameraShooter")) then destroyElement(getElementData (localPlayer, "firstPersonCameraShooter")) end

	setElementAlpha(localPlayer, 255)

	removeEventHandler ("onClientRender", root, noWallXRay)
	destroyElement(markerWallCheck)
end

function noWallXRay ()
	local camPosXr, camPosYr, camPosZr = getPedBonePosition (localPlayer, 6)
	local camPosXl, camPosYl, camPosZl = getPedBonePosition (localPlayer, 7)
	local camPosX, camPosY, camPosZ = (camPosXr + camPosXl) / 2, (camPosYr + camPosYl) / 2, (camPosZr + camPosZl) / 2

	local camPosZ = camPosZ + 1

	local intTargetX, intTargetY, intTargetZ = getElementPosition(markerWallCheck)
	if isLineOfSightClear (camPosX, camPosY, camPosZ, intTargetX, intTargetY, intTargetZ, true, false, false, true) == false then
		setTimer(function() isInWall = true end, 100,1)
		setElementAlpha(localPlayer, 0)
	elseif isLineOfSightClear (camPosX, camPosY, camPosZ, intTargetX, intTargetY, intTargetZ, true, false, false, true) and isInWall then
		isInWall = false
		setElementAlpha(localPlayer, 255)
	end
end

function FPSStart ()
	if FPSactive then return end
		local x,y,z = getElementPosition( localPlayer )
		Body = createObject (983, x, y, z )
		attachElements ( Body, localPlayer, 0, -0.2, 0, 90, 0, 90)
		setTimer(function() setCameraTarget (localPlayer)end, 100,1)
		setElementAlpha( Body, 0)
		setElementData (localPlayer, "firstPersonCameraShooter", Body, false)
		FPSactive = true
end

function FPSStop ()
	if FPSactive then
		destroyElement(getElementData (localPlayer, "firstPersonCameraShooter"))
		FPSactive = false
	end
end

function updateCamera ()
	if (isEnabled) then
	if isAiming then
		local aimX,aimY,aimZ,aimTX,aimTY,aimTZ =  getCameraMatrix()
		newangle = (( 360 - math.deg ( math.atan2 ( ( aimX - aimTX ), ( aimY - aimTY ) ) ) ) % 360)-180
		setPedRotation( localPlayer, newangle )
	else

		local nowTick = getTickCount()

		-- check if the last mouse movement was more than idleTime ms ago
		if wasInVehicle and recentlyMoved and not fadeBack and startTick and nowTick - startTick > idleTime then
			recentlyMoved = false
			fadeBack = true
			if rotX > 0 then
				Xdiff = rotX / fadeBackFrames
			elseif rotX < 0 then
				Xdiff = rotX / -fadeBackFrames
			end
			if rotY > 0 then
				Ydiff = rotY / fadeBackFrames
			elseif rotY < 0 then
				Ydiff = rotY / -fadeBackFrames
			end
		end

		if fadeBack then

			executeCounter = executeCounter + 1

			if rotX > 0 then
				rotX = rotX - Xdiff
			elseif rotX < 0 then
				rotX = rotX + Xdiff
			end

			if rotY > 0 then
				rotY = rotY - Ydiff
			elseif rotY < 0 then
				rotY = rotY + Ydiff
			end

			if executeCounter >= fadeBackFrames then
				fadeBack = false
				executeCounter = 0
			end

		end

		local camPosXr, camPosYr, camPosZr = getPedBonePosition (localPlayer, 6)
		local camPosXl, camPosYl, camPosZl = getPedBonePosition (localPlayer, 7)

		local camPosX, camPosY, camPosZ = (camPosXr + camPosXl) / 2, (camPosYr + camPosYl) / 2, (camPosZr + camPosZl) / 2 - 0.02
		local roll = 0
		local rot = getPedRotation (localPlayer)
		radRot = math.rad ( rot )
		local radius = 0.12
		if isInWall == true then radius = 0.3 end
		local camPosX = camPosX + radius * math.sin(radRot)
		local camPosY = camPosY + -(radius) * math.cos(radRot)
		local camPosZ = camPosZ

		inVehicle = isPedInVehicle(localPlayer)

		-- note the vehicle rotation
		if inVehicle then
			local rx,ry,rz = getElementRotation(getPedOccupiedVehicle(localPlayer))

			roll = -ry
			if rx > 90 and rx < 270 then
				roll = ry - 180
			end

			if not wasInVehicle then
				rotX = rotX + math.rad(rz) --prevent camera from rotation when entering a vehicle
				if rotY > -PI/15 then --force camera down if needed
					rotY = -PI/15
				end
			end

			cameraAngleX = rotX - math.rad(rz)
			cameraAngleY = rotY + math.rad(rx)

			if getControlState("vehicle_look_behind") or ( getControlState("vehicle_look_right") and getControlState("vehicle_look_left") ) then
				cameraAngleX = cameraAngleX + math.rad(180)
				--cameraAngleY = cameraAngleY + math.rad(180)
			elseif getControlState("vehicle_look_left") then
				cameraAngleX = cameraAngleX - math.rad(90)
				--roll = rx doesn't work out well
			elseif getControlState("vehicle_look_right") then
				cameraAngleX = cameraAngleX + math.rad(90)
				--roll = -rx
			end
		else
			local rx, ry, rz = getElementRotation(localPlayer)

			if wasInVehicle then
				rotX = rotX - math.rad(rz) --prevent camera from rotating when exiting a vehicle
			end
			cameraAngleX = rotX
			cameraAngleY = rotY
		end

		wasInVehicle = inVehicle

		--Taken from the freecam resource made by eAi

		-- work out an angle in radians based on the number of pixels the cursor has moved (ever)

		local freeModeAngleZ = math.sin(cameraAngleY)
		local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
		local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)

		-- calculate a target based on the current position and an offset based on the angle
		local camTargetX = camPosX + freeModeAngleX * 100
		local camTargetY = camPosY + freeModeAngleY * 100
		local camTargetZ = camPosZ + freeModeAngleZ * 100

		-- Work out the distance between the target and the camera (should be 100 units)
		local camAngleX = camPosX - camTargetX
		local camAngleY = camPosY - camTargetY
		local camAngleZ = 0 -- we ignore this otherwise our vertical angle affects how fast you can strafe

		-- Calulcate the length of the vector
		local angleLength = math.sqrt(camAngleX*camAngleX+camAngleY*camAngleY+camAngleZ*camAngleZ)

		-- Normalize the vector, ignoring the Z axis, as the camera is stuck to the XY plane (it can't roll)
		local camNormalizedAngleX = camAngleX / angleLength
		local camNormalizedAngleY = camAngleY / angleLength
		local camNormalizedAngleZ = 0

		-- We use this as our rotation vector
		local normalAngleX = 0
		local normalAngleY = 0
		local normalAngleZ = 1

		-- Perform a cross product with the rotation vector and the normalzied angle
		local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
		local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
		local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)

		-- Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
		camTargetX = camPosX + freeModeAngleX * 100
		camTargetY = camPosY + freeModeAngleY * 100
		camTargetZ = camPosZ + freeModeAngleZ * 100

		-- Set the new camera position and target
		if checking == 0 then
			setCameraMatrix (camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ, roll)
		end

		--[[
		dxDrawText("fadeBack = "..tostring(fadeBack),400,200)
		dxDrawText("recentlyMoved = "..tostring(recentlyMoved),400,220)
		if executeCounter then dxDrawText("executeCounter = "..tostring(executeCounter),400,240) end
		dxDrawText("rotX = "..tostring(rotX),400,260)
		dxDrawText("rotY = "..tostring(rotY),400,280)
		if Xdiff then dxDrawText("Xdiff = "..tostring(Xdiff),400,300) end
		if Ydiff then dxDrawText("Ydiff = "..tostring(Ydiff),400,320) end
		if startTick then dxDrawText("startTick = "..tostring(startTick),400,340) end
		dxDrawText("nowTick = "..tostring(nowTick),400,360)
		]]
	end
	end
end

function freecamMouse (cX,cY,aX,aY)

	--ignore mouse movement if the cursor or MTA window is on
	--and do not resume it until at least 5 frames after it is toggled off
	--(prevents cursor mousemove data from reaching this handler)
	if isCursorShowing() or isMTAWindowActive() then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end

	startTick = getTickCount()
	recentlyMoved = true

	-- check if the mouse is moved while fading back, if so abort the fading
	if fadeBack then
		fadeBack = false
		executeCounter = 0
	end

	-- how far have we moved the mouse from the screen center?
	local width, height = guiGetScreenSize()
	aX = aX - width / 2
	aY = aY - height / 2

	rotX = rotX + aX * mouseSensitivity * 0.01745
	rotY = rotY - aY * mouseSensitivity * 0.01745

	local pRotX, pRotY, pRotZ = getElementRotation (localPlayer)
	pRotZ = math.rad(pRotZ)

	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end

	-- limit the camera to stop it going too far up or down
	if isPedInVehicle(localPlayer) then
		if rotY < -PI / 10 then
			rotY = -PI / 10
		elseif rotY > -PI/70 then
			rotY = -PI/70
		end
	else
		if rotY < -PI / 2.2 then
			rotY = -PI / 2.2
		elseif rotY > PI / 2.1 then
			rotY = PI / 2.1
		end
	end
end

--[[
local boneNumbers = {1,2,3,4,5,6,7,8,21,22,23,24,25,26,31,32,33,34,35,36,41,42,43,44,51,52,53,54}
local boneColors = {}
for _,i in ipairs(boneNumbers) do
 boneColors[i] = tocolor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end
addEventHandler ("onClientRender", getRootElement(),
 function ()
  for _,i in ipairs(boneNumbers) do
   local x,y = getScreenFromWorldPosition(getPedBonePosition(localPlayer,i))
   if x then
	dxDrawText(tostring(i),x,y,"center","center",boneColors[i])
   end
  end
 end
)
]]


function autoAimMode( key, keystate)
	if isAiming then return end
	if keystate == "down" then
		setControlState("aim_weapon", true)
	else
		setControlState("aim_weapon", false)
	end
end

local weapons = {24,22,23,26,25,27,29,32,28,30,31,33,34,38}

function aimCheck( key, keystate)
	if getPedOccupiedVehicle(localPlayer) then return end
	local weaponAimCheck = false

	for i,v in ipairs(weapons) do
		if v == getPlayerWeapon(localPlayer) then
			weaponAimCheck = true
		end
	end

	if weaponAimCheck == false then return end
	if keystate == "down" then
		isAiming = true
		FPSStart()
		setElementAlpha(localPlayer, 0)
		setElementData(localPlayer, "inv", true, false)
	else
		isAiming = false
		FPSStop()
		setElementAlpha(localPlayer, 255)
		setElementData(localPlayer, "inv", false, false)
	end
end

local onJump = false
function climbcheck()
	if isPlayerDead(localPlayer)== false and getControlState("aim_weapon") == false then
		if checking == 0 and not onJump then
			stopclimbcheck = setTimer ( stopCcheck, 1200, 1 )
			addEventHandler ("onClientPreRender", getRootElement(), areyouclimbing)
			onJump = true
		elseif checking == 1 then
			if isTimer(stopclimbcheck) then
				killTimer(stopclimbcheck)
			end
			stopclimbcheck = setTimer ( stopCcheck, 1200, 1 )
			onJump = false
		end
	end
end


function stopCcheck()
	removeEventHandler("onClientPreRender", getRootElement(), areyouclimbing)
	setCameraTarget (localPlayer)
	checking = 0
	setTimer(function() setElementAlpha(localPlayer, 255) end, 300,1)
	onJump = false
end

function areyouclimbing()
	if ( isPedDoingTask ( localPlayer, "TASK_SIMPLE_CLIMB" ) ) then
		checking = 1
		setElementAlpha(localPlayer, 0)
		hx,hy,hz = getPedBonePosition ( localPlayer, 8 )
		local rot = getPedRotation (localPlayer)
		radRot = math.rad ( rot )
		local radius = .2
		local tx = hx + radius * math.sin(radRot)
		local ty = hy + -(radius) * math.cos(radRot)
		local tz = hz
		setCameraMatrix(tx,ty,tz,hx,hy,hz)
		if isTimer(stopclimbcheck) then
			killTimer(stopclimbcheck)
			doneclimbyet = setTimer ( finishCcheck, 400, 1 )
		end
	end
end

function finishCcheck()
	if ( isPedDoingTask ( localPlayer, "TASK_SIMPLE_CLIMB" ) ) then
		doneclimbyet = setTimer ( finishCcheck, 400, 1 )
	else
		finishedclimbing()
	end
end

function finishedclimbing()
	checking = 0
	removeEventHandler("onClientPreRender", getRootElement(), areyouclimbing)
	setCameraTarget (localPlayer)
	setTimer(function() setElementAlpha(localPlayer, 255) end, 300,1)
	onJump = false
end
--[[function updateLookAt()
    local tx, ty, tz = getWorldFromScreenPosition(sx / 2, sy / 2, 10)
    setPedLookAt(localPlayer, tx, ty, tz, -1, 0)
end
addEventHandler("onClientPreRender", root, updateLookAt)]]

setFirspersonEnabled(true, true, true)