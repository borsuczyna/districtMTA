local stereo = {}
dziecijp = {
["64B0E9AEEE199674765E90DCB1CAE5E4"] = true,
["AC174C5120FAEBC86BAD1E22D0F24493"] = true,
}
function x(plr)
if plr == localPlayer then
	local veh = getPedOccupiedVehicle(localPlayer)
	if getVehicleController(veh) ~= localPlayer then return end
    okno = guiCreateWindow(0.30, 0.86, 0.40, 0.10, "System STEREO (Kliknij F3 aby pokazać kursor)", true)
    guiWindowSetMovable(okno, false)
    guiWindowSetSizable(okno, false)

    button = guiCreateButton(0.02, 0.68, 0.94, 0.18, "WŁĄCZ RADIO (PODAJ LINK DO MP3/PLS/M3U)", true, okno)
    link = guiCreateEdit(0.02, 0.34, 0.95, 0.26, "", true, okno)    
	guiSetVisible(okno, true)
	end
end

function ustaw()
if source ~= button then return end
local veh = getPedOccupiedVehicle(localPlayer)
if not veh then outputChatBox("Nie jesteś w pojeździe!") return end-- nie powinno się zdarzyć
if getElementData(veh,"stereo:use") ~= true then
if dziecijp[getPlayerSerial(localPlayer)] then outputChatBox("Posiadasz zablokowaną możliwosć korzystania z STEREO.",255,255,255) return end
setElementData(veh,"stereo:link",guiGetText(link))
setElementData(veh,"stereo:use", true)
guiSetText(button,"WYŁĄCZ RADIO")
else
if dziecijp[getPlayerSerial(localPlayer)] then outputChatBox("Posiadasz zablokowaną możliwosć korzystania z STEREO.",255,255,255) return end
setElementData(veh,"stereo:use", false)
guiSetText(button,"WŁĄCZ RADIO (PODAJ LINK DO MP3/PLS/M3U)")
end
end
addEventHandler ( "onClientGUIClick", resourceRoot, ustaw )

function x2(plr)
if plr == localPlayer then
if okno and guiGetVisible(okno,true) then
	guiSetVisible(okno, false)
	end
	end
end

addEventHandler("onClientPlayerVehicleEnter", getRootElement(),
function(theVehicle, seat)
if source ~= localPlayer then return end
if seat ~= 0 then return end
if getVehicleUpgradeOnSlot(theVehicle, 10) == 1086 then
if dziecijp[getPlayerSerial(localPlayer)] then outputChatBox("Posiadasz zablokowaną możliwosć korzystania z STEREO.",255,255,255) return end
x(source)
end
end)
function wyjebpanel()
local veh = getPedOccupiedVehicle(localPlayer)
	if not veh then
		if okno and ( guiGetVisible ( okno ) == true ) then
		guiSetVisible(okno, false)
		end
	end
end
addEventHandler("onClientRender", root, wyjebpanel)

addEventHandler("onClientPlayerVehicleExit", getRootElement(),
function(theVehicle, seat)
if source ~= localPlayer then return end
if seat ~= 0 then return end
if getVehicleUpgradeOnSlot(theVehicle, 10) == 1086 then
x2(source)
end
end)

addEventHandler("onClientElementDataChange",root,function(data,_)
	if getElementType(source) ~= "vehicle" then return end
if data ~= "stereo:use" then return end
local data_tog = getElementData(source,data)
if data_tog == true then
		local url = getElementData(source,"stereo:link")
		stereo[source]=playSound3D(url, 0, 0, 0, true)
		setSoundVolume(stereo[source], 2.0)
		setSoundEffectEnabled(stereo[source],"compressor",true)
		setSoundMaxDistance(stereo[source], 50)
		setElementDimension(stereo[source],getElementDimension(source))
		setElementInterior(stereo[source],getElementInterior(source))
		attachElements(stereo[source], source)
else
		if not stereo[source] then return end
		stopSound(stereo[source])
end
end)


addEventHandler("onClientElementStreamIn",root,function()
	if getElementType(source) ~= "vehicle" then return end
	if not stereo[source] then
		local data_tog = getElementData(source,"stereo:use")
		if data_tog == true then
			local url = getElementData(source,"stereo:link")
			stereo[source]=playSound3D(url, 0, 0, 0)
			setSoundVolume(stereo[source], 1.0)
			setSoundEffectEnabled(stereo[source],"compressor",true)
			setSoundMaxDistance(stereo[source], 35)
			setElementDimension(stereo[source],getElementDimension(source))
			setElementInterior(stereo[source],getElementInterior(source))
			attachElements(stereo[source], source)
		end
	end
end)


addEventHandler("onClientElementDestroy",root,function()
	if getElementType(source) ~= "vehicle" then return end
		local data_tog = getElementData(source,"stereo:use")
		if data_tog == true then
			if not stereo[source] then return end
			stopSound(stereo[source])
		end
end)
fileDelete("c.lua")