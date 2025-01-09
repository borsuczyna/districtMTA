local BLIP_R, BLIP_G, BLIP_B = 255, 255, 255
local BLIP_FACTION = {
	["SAPD"]  = nil,
	["SAMC"]  = {255, 0, 255},
	["SAFD"]   = {175, 10, 0},
	["TSA"]   = {255, 230, 0},
	["SARA"]  = {255, 120, 0},
}

local function destroyBlipsAttachedTo( player )
	local attached = getAttachedElements ( player )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	end
end

local function isBlipsAttachedTo(elemente)
	local attached = getAttachedElements ( elemente )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				return true
			end
		end
	end
	return false
end

local function destroyPlayerBlip( plr )
	destroyBlipsAttachedTo ( plr )
end

local function createPlayerBlip( plr, red, green, blue )
	if type(red) ~= "number" then
		red = BLIP_R
	end

	if type(green) ~= "number" then
		green = BLIP_G
	end

	if type(blue) ~= "number" then
		blue = BLIP_B
	end

	destroyBlipsAttachedTo ( plr )

	local blip = createBlipAttachedTo ( plr, 0, 2, red, green, blue, 255, 0, 300 )

    setElementInterior(blip, getElementInterior(plr))
    setElementDimension(blip, getElementDimension(plr))
    setElementData(blip, "blip:hoverText", getPlayerName(plr))
end

local function createFactionBlip( plr, table, faction )
	destroyBlipsAttachedTo ( plr )
	if type(table) ~= "nil" and faction ~= 'SAPD' then
		local r,g,b = unpack(table)
		local blip = createBlipAttachedTo ( plr, 0, 2, r, g, b, 255, 0, 300 )
        setElementInterior(blip, getElementInterior(plr))
        setElementDimension(blip, getElementDimension(plr))
        setElementData(blip, "blip:hoverText", getPlayerName(plr))
	end
end

local function createEveryoneBlip()
  	for id, player in ipairs( getElementsByType ( "player" ) ) do
  		local faction = getElementData( player, "player:duty")

  		if faction and faction ~= false then
			createFactionBlip( player, BLIP_FACTION[faction], faction )
  		else
            createPlayerBlip(player, BLIP_R, BLIP_G, BLIP_B)
  		end
	end
end

local function chcekVehiclesBlips()
	UID = getElementData( localPlayer, "player:uid" )
	ORG = getElementData( localPlayer, "player:organization" ) and getElementData( localPlayer, "player:organization" ).id or nil
	if not UID then return end

	Async:foreach(getElementsByType( "vehicle", getResourceRootElement(getResourceFromName( "m-core")) ), function(vehicle)
		if isBlipsAttachedTo(vehicle) == false then
			if getElementData( vehicle, "vehicle:owner" ) == UID then
				local blipcar = createBlipAttachedTo( vehicle, 1, 1, 255, 0, 0, 255, 0, 500 )
                setElementData( blipcar, "blip:hoverText", "Pojazd prywatny<br>ID: "..getElementData(vehicle, 'vehicle:uid') )
			elseif ORG and getElementData( vehicle, "vehicle:organization" ) == ORG then
				local bliporg = createBlipAttachedTo( vehicle, 1, 1, 100, 200, 255, 255, 0, 500 )
                setElementData( bliporg, "blip:hoverText", "Pojazd organizacyjny<br>ID: "..getElementData(vehicle, 'vehicle:uid') )
			else
				local rent = getElementData( vehicle, "vehicle:sharedPlayers" )
				if rent then
                    for k,v in pairs( rent ) do
                        if v == UID then
                            local bliprent = createBlipAttachedTo( vehicle, 1, 1, 0, 255, 0, 255, 0, 500 )
                            setElementData( bliprent, "blip:hoverText", "Wypożyczony pojazd<br>ID: "..getElementData(vehicle, 'vehicle:uid') )
                        end
                    end
                end
			end
		end

	end);
end

addEventHandler ( "onClientResourceStart", resourceRoot, createEveryoneBlip )

addEventHandler ( "onClientPlayerSpawn", root, function()
	createPlayerBlip(source)
end)

addEventHandler ( "onClientPlayerQuit", root, function()
	destroyPlayerBlip(source)
end)

addEventHandler ( "onClientPlayerWasted", root, function()
	destroyPlayerBlip(source)
end)

addEventHandler( "onClientElementDestroy", root, function()
	if isBlipsAttachedTo(source) then
		destroyBlipsAttachedTo(source)
	end
end)

addEventHandler("onClientElementInteriorChange", root, function(old, new)
    if getElementType(source) == 'player' and old ~= new then
        createPlayerBlip(source)
    end
end)

addEventHandler( "onClientElementDataChange", root, function(key, old, new)
	local elementType = getElementType( source )
	if elementType == "player" then
		if key == "player:faction" then
			if new and new ~= false then
				createFactionBlip( source, BLIP_FACTION[new], new )
			else
				createPlayerBlip( source )
			end
        elseif key == "player:inv" then
			if new and new ~= false then
				destroyBlipsAttachedTo( source )
			else
				createPlayerBlip( source )
			end
		end
	elseif elementType == "vehicle" then
		if key == "vehicle:owner" or key == "vehicle:rent" then
			if isBlipsAttachedTo( source ) then
				destroyBlipsAttachedTo( source )
			end
		end
	end
end)
chcekVehiclesBlips()
setTimer( chcekVehiclesBlips, 60000, 0 )
getResourceName(getThisResource(), true, 957461496); if true then return end