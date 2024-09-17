missions["prolog"] = {
	{
		name = "onStart",
		callback = async(function(context)
			context:moveToMissionDimension()
			context:fadeCamera(true, 0.5, true)
			context:createPed("barry", 273, {x=0.0000, y=0.0000, z=0.0000}, 0.0000, 1)
			context:createServerSideVehicle("main-car", 422, {x=-136.5137, y=1055.1543, z=19.9326}, {x=0.5603, y=359.5496, z=199.3689}, {35, 33, 22, 255}, {15, 15, 15, 255}, 1)
			context:warpIntoVehicle("barry", "main-car", 1)
			context:setElementPosition("me", {x=-139.9385, y=1057.5791, z=19.9399})
			context:setElementRotation("me", {x=0.0000, y=0.0000, z=206.7686})
			context:sleep(100)
			context:resetCamera()
			context:fadeCamera(false, 0.5, false)
			context:setMissionTarget("Wsiądź do pojazdu")
			context:pedTellVoiceLine("barry", "prolog-1", "Ładuj sie do auta", false)
		end),
	},

	{
		name = "onVehicleEnter",
		callback = async(function(context, vehicle, seat)
			if vehicle == "main-car" and seat == 0 then
				context:setMissionTarget("Udaj się na pustkowie")
				context:createBlip("target-1-blip", {x=501.1367, y=1368.6357, z=4.7480}, 41, 99999)
				context:disableVehicleExit(true)
				context:pedTellVoiceLine("barry", "prolog-2", "Pal go i jedziemy", true)
				context:pedTellVoiceLine("me", "prolog-3", "Kupiłbyś jakieś normalne auto a nie takiego grata", true)
				context:pedTellVoiceLine("barry", "prolog-4", "O co ci się znowu rozchodzi, samochód jak samochód, ważne że jeździ", true)
				context:pedTellVoiceLine("me", "prolog-5", "Samochód? Przecież to jakiś odpad a nie samochód, nie zdziwie się jak wysadzi nas podczas jazdy", true)
				context:pedTellVoiceLine("barry", "prolog-6", "Znalazła sie księżniczka na ziarnku grochu", true)
				context:pedTellVoiceLine("me", "prolog-7", "Po co my w ogóle tam jedziemy?", true)
				context:pedTellVoiceLine("barry", "prolog-8", "Musimy roztawić nowe nadajniki, jestem pewien że teraz będą działać", true)
				context:pedTellVoiceLine("me", "prolog-9", "Jezu Barry mówiłem ci że masz przestać z tym szaleństwem", true)
				context:pedTellVoiceLine("barry", "prolog-10", "Mówie ci że to coś dużego", true)
				context:pedTellVoiceLine("me", "prolog-11", "Oj tak szczególnie jak ostatnio złapałeś sygnał TVP z tej popapranej anteny", true)
				context:pedTellVoiceLine("barry", "prolog-12", "Dlatego teraz użyjemy czegoś większego, z resztą zobaczysz, kieruj", true)
				context:createMarker("target-1", {x=502.0117, y=1368.2363, z=3.7853}, "cylinder", 3, {255, 0, 0, 255}, "Pustkowie", "Cel misji", "work")
			end
		end),
	},

	{
		name = "onVehicleDamage",
		callback = async(function(context, vehicle, damage)
			if vehicle == "main-car" and damage < 900 then
				context:failMission("Pojazd Barry'ego został uszkodzony!")
			end
		end),
	},

	{
		name = "onMarkerHit",
		callback = async(function(context, marker)
			if marker == "target-1" then
				context:destroy("target-1")
				context:destroy("target-1-blip")
				context:setVelocity("main-car", {x=0.0000, y=0.0000, z=0.0000})
				context:setElementFrozen("main-car", true)
				context:setMissionTarget("")
				context:toggleAllControls(true)
				context:fadeCamera(true, 0.5, true)
				context:sleep(100)
				context:fadeCamera(false, 0.5, false)
				context:setElementPosition("main-car", {x=499.1094, y=1368.1758, z=4.6066})
				context:setElementRotation("main-car", {x=4.1034, y=2.2522, z=268.4235})
				context:interpolateCamera({x=521.5811, y=1362.1133, z=8.6362}, {x=500.4912, y=1368.0596, z=4.8710}, {x=480.1016, y=1365.8545, z=9.1362}, {x=500.4912, y=1368.0596, z=4.8710}, 20000, 0, 0, 80, 70, "InOutQuad", true, false)
				context:pedTellVoiceLine("barry", "prolog-13", "Dobra bierz sprzęt i go rozstaw", true)
				context:pedTellVoiceLine("me", "prolog-14", "A ty co będziesz tu sobie czekać?", true)
				context:pedTellVoiceLine("barry", "prolog-15", "No też ide rozstawiać", true)
				context:fadeCamera(true, 0.5, true)
				context:sleep(100)
				context:resetCamera()
				context:fadeCamera(false, 0.5, false)
				context:makePedExitVehicle("barry")
				context:setElementFrozen("main-car", true)
				context:toggleAllControls(false)
				context:disableVehicleExit(false)
				context:disableVehicleEnter(true)
				context:setMissionTarget("Podążaj za Barrym")
				context:makePedExitVehicle("me")
				context:sleep(2200)
				context:createBlip("target-2-blip", {x=553.0039, y=1383.2959, z=12.6349}, 41, 99999)
				context:playPlayback("barry", "prolog-1", true)
				context:createMarker("target-2", {x=553.0039, y=1383.2959, z=12.6349}, "cylinder", 1, {255, 123, 0, 255}, "Misja", "Rozstaw nadajniki", "work")
			end
		end),
	},

	{
		name = "onMarkerHit",
		callback = async(function(context, marker)
			if marker == "target-2" then
				context:setMissionTarget("")
				context:destroy("target-2")
				context:destroy("target-2-blip")
				context:toggleAllControls(true)
				context:fadeCamera(true, 0.5, true)
				context:setElementPosition("me", {x=554.6328, y=1382.8818, z=13.6064})
				context:setElementRotation("me", {x=0.0000, y=0.0000, z=78.3255})
				context:interpolateCamera({x=567.3320, y=1379.8271, z=19.6329}, {x=552.7676, y=1383.5156, z=13.6329}, {x=556.5078, y=1376.8643, z=16.1329}, {x=552.7676, y=1383.5156, z=13.6329}, 25000, 0, 0, 40, 80, "Linear", false, false)
				context:fadeCamera(false, 0.5, true)
				context:pedTellVoiceLine("me", "prolog-16", "To są te niby mocne nadajniki?", true)
				context:pedTellVoiceLine("barry", "prolog-17", "Nie, miałem na myśli coś innego, wiesz gdzie jest ta ogromna satelita na górze?", true)
				context:pedTellVoiceLine("me", "prolog-18", "Dobra Barry chyba nieźle cie już pogrzało, przecież to jest strzeżone", true)
				context:pedTellVoiceLine("barry", "prolog-19", "Wszystko mam przemyślane, spokojnie, nikt nas nie złapie", true)
				context:pedTellVoiceLine("me", "prolog-20", "To ostatni raz jak ci z czymkolwiek pomagam", true)
				context:pedTellVoiceLine("barry", "prolog-21", "Nie marudź, kładź sprzęt i się zwijamy", true)
				context:fadeCamera(true, 0.5, true)
				context:resetCamera()
				context:fadeCamera(false, 0.5, false)
				context:disableVehicleEnter(false)
				context:destroy("main-car")
				context:createServerSideVehicle("main-car2", 422, {x=504.7373, y=1368.2725, z=4.9871}, {x=3.1146, y=0.9064, z=271.0437}, {35, 33, 22, 255}, {15, 15, 15, 255}, 2)
				context:toggleAllControls(false)
				context:playPlayback("barry", "prolog-2", false)
				context:setMissionTarget("Wróć do pojazdu")
			end
		end),
	},

	allowedVehicles = {
		[1] = {  model = 422,  position = {    x = -136.5137,    y = 1055.1543,    z = 19.9326  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 0.5603,    y = 359.5496,    z = 199.3689  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car"},
		[2] = {  model = 422,  position = {    x = 504.7373,    y = 1368.2725,    z = 4.9871  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 3.1146,    y = 0.9064,    z = 271.0437  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car2"},
	},
	allowedPeds = {
		[1] = {  model = 273,  position = {    x = 0,    y = 0,    z = 0  },  rotation = 0,  specialId = "barry"},
	}
}