local camera

function getModelBoundingBox(element)
	local type = getElementType(element)
	local model = getElementModel(element)
	local element;

	if type == "vehicle" then
		element = createVehicle(model, 0, 0, 0)
	elseif type == "object" then
		element = createObject(model, 0, 0, 0)
	else
		return false
	end

	local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(element)
	destroyElement(element)

	return x1, y1, z1, x2, y2, z2
end

function getElementSize(element)
	local x1, y1, z1, x2, y2, z2 = getModelBoundingBox(element)
	if not x1 then return end

	return x2 - x1, y2 - y1, z2 - z1
end

function zoomToComponent(vehicle, component)
	local sx, sy, sz = getElementSize(vehicle)
	local wx, wy, wz = getPositionFromElementOffset(vehicle, component[1] * sx, component[2] * sy, component[3] * sz)
	local wlx, wly, wlz = getPositionFromElementOffset(vehicle, component[4] * sx, component[5] * sy, component[6] * sz)
	if not wx then return end

	moveCamera(wx, wy, wz, wlx, wly, wlz, 1000)
end

function restoreCamera()
	if not camera then return end

	local cx, cy, cz, lx, ly, lz = unpack(camera.from)
	setCameraMatrix(cx, cy, cz, lx, ly, lz)
	camera = nil
end

function applyInverseRotation ( x,y,z, rx,ry,rz )
    -- Degress to radians
    local DEG2RAD = (math.pi * 2) / 360
    rx = rx * DEG2RAD
    ry = ry * DEG2RAD
    rz = rz * DEG2RAD

    -- unrotate each axis
    local tempY = y
    y =  math.cos ( rx ) * tempY + math.sin ( rx ) * z
    z = -math.sin ( rx ) * tempY + math.cos ( rx ) * z

    local tempX = x
    x =  math.cos ( ry ) * tempX - math.sin ( ry ) * z
    z =  math.sin ( ry ) * tempX + math.cos ( ry ) * z

    tempX = x
    x =  math.cos ( rz ) * tempX + math.sin ( rz ) * y
    y = -math.sin ( rz ) * tempX + math.cos ( rz ) * y

    return x, y, z
end

function moveCamera(x, y, z, tlx, tly, tlz, duration)
	local cx, cy, cz, lx, ly, lz = getCameraMatrix()
	camera = {
		from = {cx, cy, cz, lx, ly, lz},
		to = {x, y, z, tlx, tly, tlz},
		start = getTickCount(),
		duration = duration,
	}
end

function updateCamera()
	if not camera then return end

	local now = getTickCount()
	local progress = (now - camera.start) / camera.duration
	if progress >= 1 then
		camera = nil
		return
	end

	local x, y, z = interpolateBetween(
		camera.from[1], camera.from[2], camera.from[3],
		camera.to[1], camera.to[2], camera.to[3],
		progress, 'InOutQuad'
	)

	local lx, ly, lz = interpolateBetween(
		camera.from[4], camera.from[5], camera.from[6],
		camera.to[4], camera.to[5], camera.to[6],
		progress, 'InOutQuad'
	)

	setCameraMatrix(x, y, z, lx, ly, lz)
end

addEventHandler('onClientRender', root, updateCamera)

function visualUpgrades(vehicle, id, zoomTo)
	local upgrades = getVehicleCompatibleUpgrades(vehicle, id)
	local outUpgrades = {}
	local vehicleUpgrades = getVehicleUpgrades(vehicle)

	for i, upgrade in ipairs(upgrades) do
		local installed = not not table.find(vehicleUpgrades, upgrade)
		local price = getUpgradePrice(upgrade)

		table.insert(outUpgrades, {
			name = ('(%d) %s'):format(upgrade, getUpgradeName(upgrade)),
			upgrade = upgrade,
			installed = installed,
			price = installed and math.floor(price * 0.6) or price,
			preview = function(vehicle)
				local current = getVehicleUpgradeOnSlot(vehicle, id)
				if current then
					removeVehicleUpgrade(vehicle, current)
				end

				addVehicleUpgrade(vehicle, upgrade)
				zoomToComponent(vehicle, zoomTo)
			end,
			install = function(player, vehicle)
				addVehicleUpgrade(vehicle, upgrade)
			end,
			uninstall = function(player, vehicle)
				removeVehicleUpgrade(vehicle, upgrade)
			end,
			canInstall = function(vehicle)
				local current = getVehicleUpgradeOnSlot(vehicle, id)
				return current == 0 or not current, 'Posiadasz już inny tuning tego typu, pierw go zdemontuj.'
			end,
		})
	end

	return outUpgrades
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

categories = {
	{
		name = 'Koła',
		icon = 'wheel',
		key = 'wheels',
		items = function(vehicle) 
			return visualUpgrades(vehicle, 12, {-2, 0.6, 0.5, -1, 0.4, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 12)
		end,
	},
	{
		name = 'Maska',
		icon = 'hood',
		key = 'hood',
		items = function(vehicle)
			return visualUpgrades(vehicle, 0, {-0.4, 1, 1.3, -0.15, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 0)
		end,
	},
		{
		name = 'Wloty',
		icon = 'vent',
		key = 'vent',
		items = function(vehicle)
			return visualUpgrades(vehicle, 1, {-0.4, 1, 1.3, -0.15, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 1)
		end,
	},
	{
		name = 'Spoilery',
		icon = 'spoiler',
		key = 'spoiler',
		items = function(vehicle)
			return visualUpgrades(vehicle, 2, {-0.7, -1, 0.9, -0.15, -0.5, 0.3})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 2)
		end,
	},
	{
		name = 'Progi',
		icon = 'sideskirt',
		key = 'sideskirt',
		items = function(vehicle)
			return visualUpgrades(vehicle, 3, {-1.5, -0.1, 0.3, 0.9, -0.23, -0.1})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 3)
		end,
	},
	{
		name = 'Lampy',
		icon = 'lights',
		key = 'lights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 4, {0, 1.5, 0.5, 0, 0.5, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 4)
		end,
	},
	{
		name = 'Przednie lampy',
		icon = 'lights',
		key = 'frontlights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 6, {0, 1.1, 0.5, 0, 0.5, 0.2})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 6)
		end,
	},
	{
		name = 'Tylne lampy',
		icon = 'lights',
		key = 'rearlights',
		items = function(vehicle)
			return visualUpgrades(vehicle, 5, {0, -1.1, 0.5, 0, -0.5, 0.2})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 5)
		end,
	},
	{
		name = 'Dach',
		icon = 'roof',
		key = 'roof',
		items = function(vehicle)
			return visualUpgrades(vehicle, 7, {-0.3, 0.4, 1.5, 0, 0, 0.5})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 7)
		end,
	},
	{
		name = 'Wydechy',
		icon = 'exhaust',
		key = 'exhaust',
		items = function(vehicle)
			return visualUpgrades(vehicle, 13, {-0.7, -1.1, 0.5, -0.2, -0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 13)
		end,
	},
	{
		name = 'Przedni zderzak',
		icon = 'bumper',
		key = 'frontbumper',
		items = function(vehicle)
			return visualUpgrades(vehicle, 14, {-0.6, 1.1, 0.5, -0.1, 0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 14)
		end,
	},
	{
		name = 'Tylny zderzak',
		icon = 'bumper',
		key = 'rearbumper',
		items = function(vehicle)
			return visualUpgrades(vehicle, 15, {-0.6, -1.1, 0.5, -0.1, -0.5, 0})
		end,
		remove = function(vehicle)
			restoreVehicleUpgrade(vehicle, 15)
		end,
	},
}

function getUpgradeName(upgradeID)
	return partNames[upgradeID] or 'Nieznany'
end

function getUpgradePrice(upgradeID)
	return partPrices[upgradeID] or 6969
end

function getVehicleUpgradeCategories(vehicle)
	local outCategories = {}

	for i, category in ipairs(categories) do
		local items = category.items(vehicle)
		if #items > 0 then
			table.insert(outCategories, {
				name = category.name,
				icon = category.icon,
				key = category.key,
				items = items,
				remove = category.remove,
			})
		end
	end

	return outCategories
end

function getVehicleOriginalUpgrades(vehicle)
	local data = {
		upgrades = {}
	}

	for i = 0, 16 do
		local upgrade = getVehicleUpgradeOnSlot(vehicle, i)
		if upgrade then
			data.upgrades[i] = upgrade
		end
	end

	return data
end

function restoreVehicleUpgrade(vehicle, slot)
	if not originalTuning then return end

	local upgrade = originalTuning.upgrades[slot]
	local currentUpgrade = getVehicleUpgradeOnSlot(vehicle, slot)
	if currentUpgrade then
		removeVehicleUpgrade(vehicle, currentUpgrade)
	end

	if upgrade then
		addVehicleUpgrade(vehicle, upgrade)
	end

	return upgrade
end

function table.find(t, value)
	for i, v in ipairs(t) do
		if v == value then
			return v, i
		end
	end
	return false
end

function table.findCallback(t, callback)
	for i, v in ipairs(t) do
		if callback(v) then
			return v, i
		end
	end
	return false
end

partNames = {
	[1000] = "Pro",
	[1001] = "Win",
	[1002] = "Drag",
	[1003] = "Alpha",
	[1004] = "Champ Scoop",
	[1005] = "Fury Scoop",
	[1006] = "Roof Scoop",
	[1007] = "Right Sideskirt",
	[1008] = "5 times",
	[1009] = "2 times",
	[1010] = "10 times",
	[1011] = "Race Scoop",
	[1012] = "Worx Scoop",
	[1013] = "Round Fog",
	[1014] = "Champ",
	[1015] = "Race",
	[1016] = "Worx",
	[1017] = "Left Sideskirt",
	[1018] = "Upswept",
	[1019] = "Twin",
	[1020] = "Large",
	[1021] = "Medium",
	[1022] = "Small",
	[1023] = "Fury",
	[1024] = "Square Fog",
	[1025] = "Offroad",
	[1026] = "Right Alien Sideskirt",
	[1027] = "Left Alien Sideskirt",
	[1028] = "Alien",
	[1029] = "X-Flow",
	[1030] = "Left X-Flow Sideskirt",
	[1031] = "Right X-Flow Sideskirt",
	[1032] = "Alien Roof Vent",
	[1033] = "X-Flow Roof Vent",
	[1034] = "Alien",
	[1035] = "X-Flow Roof Vent",
	[1036] = "Right Alien Sideskirt",
	[1037] = "X-Flow",
	[1038] = "Alien Roof Vent",
	[1039] = "Left X-Flow Sideskirt",
	[1040] = "Left Alien Sideskirt",
	[1041] = "Right X-Flow Sideskirt",
	[1042] = "Right Chrome Sideskirt",
	[1043] = "Slamin",
	[1044] = "Chrome",
	[1045] = "X-Flow",
	[1046] = "Alien",
	[1047] = "Right Alien Sideskirt",
	[1048] = "Right X-Flow Sideskirt",
	[1049] = "Alien",
	[1050] = "X-Flow",
	[1051] = "Left Alien Sideskirt",
	[1052] = "Left X-Flow Sideskirt",
	[1053] = "X-Flow",
	[1054] = "Alien",
	[1055] = "Alien",
	[1056] = "Right Alien Sideskirt",
	[1057] = "Right X-Flow Sideskirt",
	[1058] = "Alien",
	[1059] = "X-Flow",
	[1060] = "X-Flow",
	[1061] = "X-Flow",
	[1062] = "Left Alien Sideskirt",
	[1063] = "Left X-Flow Sideskirt",
	[1064] = "Alien",
	[1065] = "Alien",
	[1066] = "X-Flow",
	[1067] = "Alien",
	[1068] = "X-Flow",
	[1069] = "Right Alien Sideskirt",
	[1070] = "Right X-Flow Sideskirt",
	[1071] = "Left Alien Sideskirt",
	[1072] = "Left X-Flow Sideskirt",
	[1073] = "Shadow",
	[1074] = "Mega",
	[1075] = "Rimshine",
	[1076] = "Wires",
	[1077] = "Classic",
	[1078] = "Twist",
	[1079] = "Cutter",
	[1080] = "Switch",
	[1081] = "Grove",
	[1082] = "Import",
	[1083] = "Dollar",
	[1084] = "Trance",
	[1085] = "Atomic",
	[1086] = "Stereo",
	[1087] = "Hydraulics",
	[1088] = "Alien",
	[1089] = "X-Flow",
	[1090] = "Right Alien Sideskirt",
	[1091] = "X-Flow",
	[1092] = "Alien",
	[1093] = "Right X-Flow Sideskirt",
	[1094] = "Left Alien Sideskirt",
	[1095] = "Right X-Flow Sideskirt",
	[1096] = "Ahab",
	[1097] = "Virtual",
	[1098] = "Access",
	[1099] = "Left Chrome Sideskirt",
	[1100] = "Chrome Grill",
	[1101] = "Left `Chrome Flames` Sideskirt",
	[1102] = "Left `Chrome Strip` Sideskirt",
	[1103] = "Covertible",
	[1104] = "Chrome",
	[1105] = "Slamin",
	[1106] = "Right `Chrome Arches`",
	[1107] = "Left `Chrome Strip` Sideskirt",
	[1108] = "Right `Chrome Strip` Sideskirt",
	[1109] = "Chrome",
	[1110] = "Slamin",
	[1111] = "Little Sign?",
	[1112] = "Little Sign?",
	[1113] = "Chrome",
	[1114] = "Slamin",
	[1115] = "Chrome",
	[1116] = "Slamin",
	[1117] = "Chrome",
	[1118] = "Right `Chrome Trim` Sideskirt",
	[1119] = "Right `Wheelcovers` Sideskirt",
	[1120] = "Left `Chrome Trim` Sideskirt",
	[1121] = "Left `Wheelcovers` Sideskirt",
	[1122] = "Right `Chrome Flames` Sideskirt",
	[1123] = "Bullbar Chrome Bars",
	[1124] = "Left `Chrome Arches` Sideskirt",
	[1125] = "Bullbar Chrome Lights",
	[1126] = "Chrome Exhaust",
	[1127] = "Slamin Exhaust",
	[1128] = "Vinyl Hardtop",
	[1129] = "Chrome",
	[1130] = "Hardtop",
	[1131] = "Softtop",
	[1132] = "Slamin",
	[1133] = "Right `Chrome Strip` Sideskirt",
	[1134] = "Right `Chrome Strip` Sideskirt",
	[1135] = "Slamin",
	[1136] = "Chrome",
	[1137] = "Left `Chrome Strip` Sideskirt",
	[1138] = "Alien",
	[1139] = "X-Flow",
	[1140] = "X-Flow",
	[1141] = "Alien",
	[1142] = "Left Oval Hoods",
	[1143] = "Right Oval Hoods",
	[1144] = "Left Square Hoods",
	[1145] = "Right Square Hoods",
	[1146] = "X-Flow",
	[1147] = "Alien",
	[1148] = "X-Flow",
	[1149] = "Alien",
	[1150] = "Alien",
	[1151] = "X-Flow",
	[1152] = "X-Flow",
	[1153] = "Alien",
	[1154] = "Alien",
	[1155] = "Alien",
	[1156] = "X-Flow",
	[1157] = "X-Flow",
	[1158] = "X-Flow",
	[1159] = "Alien",
	[1160] = "Alien",
	[1161] = "X-Flow",
	[1162] = "Alien",
	[1163] = "X-Flow",
	[1164] = "Alien",
	[1165] = "X-Flow",
	[1166] = "Alien",
	[1167] = "X-Flow",
	[1168] = "Alien",
	[1169] = "Alien",
	[1170] = "X-Flow",
	[1171] = "Alien",
	[1172] = "X-Flow",
	[1173] = "X-Flow",
	[1174] = "Chrome",
	[1175] = "Slamin",
	[1176] = "Chrome",
	[1177] = "Slamin",
	[1178] = "Slamin",
	[1179] = "Chrome",
	[1180] = "Chrome",
	[1181] = "Slamin",
	[1182] = "Chrome",
	[1183] = "Slamin",
	[1184] = "Chrome",
	[1185] = "Slamin",
	[1186] = "Slamin",
	[1187] = "Chrome",
	[1188] = "Slamin",
	[1189] = "Chrome",
	[1190] = "Slamin",
	[1191] = "Chrome",
	[1192] = "Chrome",
	[1193] = "Slamin",
}

partPrices = {
	[1025]=1250,
	[1073]=920,
	[1074]=980,
	[1075]=520,
	[1076]=720,
	[1077]=710,
	[1078]=1250,
	[1079]=420,
	[1080]=760,
	[1081]=1020,
	[1082]=400,
	[1083]=570,
	[1084]=800,
	[1085]=1100,
	[1096]=1500,
	[1097]=870,
	[1098]=1000,
--  Stereo
	[1086]=300,
--  Spoilery
	[1000]=2000,
	[1001]=2500,
	[1002]=2000,
	[1003]=2500,
	[1014]=1400,
	[1015]=2000,
	[1016]=2100,
	[1023]=2400,
	[1049]=1540,
	[1050]=1300,
	[1058]=1300,
	[1060]=1750,
	[1138]=3900,
	[1139]=3400,
	[1146]=3000,
	[1147]=3550,
	[1158]=4100,
	[1162]=2900,
	[1163]=2000,
	[1164]=4500, 
--	Progi
	[1036]=1500,
	[1039]=2000,
	[1040]=1870,
	[1041]=2300,
	[1007]=1000,
	[1017]=1000,
	[1026]=1500,
	[1027]=2000,
	[1030]=1500,
	[1031]=2300,
	[1042]=1000,
	[1047]=1890,
	[1048]=1730,
	[1051]=2000,
	[1052]=1800,
	[1056]=1000,
	[1057]=1000,
	[1062]=1000,
	[1063]=1250,
	[1069]=1800,
	[1070]=1500,
	[1071]=1650,
	[1072]=1750,
	[1090]=1750,
	[1093]=1700,
	[1094]=1500,
	[1095]=1000,
	[1099]=1000,
	[1101]=1000,
	[1102]=700,
	[1106]=1000,
	[1107]=1000,
	[1108]=1000,
	[1118]=700,
	[1119]=700,
	[1120]=700,
	[1121]=700,
	[1122]=700,
	[1124]=700,
	[1133]=1000,
	[1134]=1000,
	[1137]=1000,
	
--  Bullbar . . ? [przod]
	[1100]=750,
	[1115]=750,
	[1116]=750,
	[1123]=750,
	[1125]=1000,
--  Bullbar . . ? [tył]
	[1109]=900,
	[1110]=300,
--	Front Sign [figurka itd z przodu]
	[1111]=650,
	[1112]=650,
--	Hydraulika
	[1087]=15100,
--  Wydechy
	[1034]=1900,
	[1037]=2000,
	[1044]=1800,
	[1046]=2000,
	[1018]=1700,
	[1019]=1900,
	[1020]=2000,
	[1021]=1800,
	[1022]=1800,
	[1028]=1900,
	[1029]=2000,
	[1043]=1500,
}