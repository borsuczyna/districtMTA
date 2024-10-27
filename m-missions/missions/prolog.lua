missions["prolog"] = {
	{
		name = "onStart",
		callback = async(function(context)
			showMissionName("Prolog")
			context:moveToMissionDimension()
			context:fadeCamera(true, 0.5, true)
			context:createPed("barry", 273, {x=0.0000, y=0.0000, z=0.0000}, 0.0000, 1)
			context:createServerSideVehicle("main-car", 422, {x=-136.5137, y=1055.1543, z=19.9326}, {x=0.5603, y=359.5496, z=199.3689}, {35, 33, 22, 255}, {15, 15, 15, 255}, 1)
			context:setElementFrozen("main-car", true)
			context:warpIntoVehicle("barry", "main-car", 1)
			context:setElementPosition("me", {x=-139.9385, y=1057.5791, z=19.9399})
			context:setElementRotation("me", {x=0.0000, y=0.0000, z=206.7686})
			context:sleep(100)
			context:resetCamera()
			context:fadeCamera(false, 0.5, false)
			context:setMissionTarget("Wsiądź do pojazdu")
			context:pedTellVoiceLine("barry", "prolog-1", "Ładuj sie do auta", false)
			exports['m-notis']:addNotification('info', 'Misje', 'Każda misja jest udźwiękowiona, zalecamy włączenie dźwięków MTA w ustawieniach gry', 15000)
		end),
	},

	{
		name = "onVehicleEnter",
		callback = async(function(context, vehicle, seat)
			if vehicle == "main-car" and seat == 0 then
				if getMissionData('prolog:goToCar') then
					context:disableVehicleEnter(true)
					context:disableVehicleExit(true)
					context:warpIntoVehicle("barry", "main-car", 1)
					context:pedTellVoiceLine("me", "prolog-38", "Masz ten pilot?", true)
					context:pedTellVoiceLine("barry", "prolog-39", "Gdzieś tu był... o tu jest", true)
					context:pedTellVoiceLine("me", "prolog-40", "Włączaj", true)
					context:pedTellVoiceLine("barry", "prolog-41", "Dobra, a ty odpal samochód i jedź do domu, posłuchamy po drodze", true)
					context:setMissionTarget("Wróć do domu")
					context:setElementFrozen("main-car", false)
					context:createBlip("target-7-blip", {x=-137.478, y=1055.550, z=19.984}, 41, 99999)	
					context:pedTellVoiceLine("me", "prolog-43", "Niezłą zabawe sobie wymyśliłeś", true)
					context:pedTellVoiceLine("barry", "prolog-44", "Czekaj, coś słyszę", true)
					context:pedTellVoiceLine("barry", "prolog-45", "(szum) (niezrozumiale) (szum)", true)
					context:pedTellVoiceLine("me", "prolog-46", "Co to jest?", true)
					context:pedTellVoiceLine("barry", "prolog-47", "(szum) we-ze mne-agz-ze le-proz-te", true)
					context:pedTellVoiceLine("barry", "prolog-48", "(szum) in-va-sion (szum) tar-get e-arth", true)
					context:pedTellVoiceLine("barry", "prolog-49", "Słyszysz to?!", true)
					context:pedTellVoiceLine("barry", "prolog-50", "(szum) pac-ka-ge (szum) de-se-rt (szum) re-lea-se - to-mor-row", true)
					context:pedTellVoiceLine("barry", "prolog-51", "Słyszałeś?", true)
					context:pedTellVoiceLine("me", "prolog-52", "No, to co robimy?", true)
					context:pedTellVoiceLine("barry", "prolog-53", "Wróćmy do domu, posłucham w międzyczasie sygnałów", true)
					context:pedTellVoiceLine("me", "prolog-54", "To jest jakiś żart?", true)
					context:pedTellVoiceLine("barry", "prolog-55", "Nie, mówie ci serio", true)
					context:createMarker("target-7", {x=-137.478, y=1055.550, z=18.984}, "cylinder", 3, {255, 0, 0, 255}, "Dom", "Cel misji", "work")
				elseif getMissionData('prolog:goToStation') then
					context:setMissionTarget("Udaj się do radiostacji")
					context:setElementFrozen("main-car", false)
					context:createBlip("target-3-blip", {x=-295.287, y=1456.097, z=74.056}, 41, 99999)
					context:warpIntoVehicle("barry", "main-car", 1)
					context:disableVehicleExit(true)
					context:pedTellVoiceLine("me", "prolog-22", "Ty masz nieźle pograne w głowie", true)
					context:pedTellVoiceLine("barry", "prolog-23", "Nie marudź, jedziemy", true)
					context:pedTellVoiceLine("me", "prolog-24", "Ty serio myślisz że ufoki wybrały by ciebie do kontaktu?", true)
					context:pedTellVoiceLine("barry", "prolog-25", "Nie wiem, ale zobaczymy", true)
					context:createMarker("target-3", {x=-295.287, y=1456.097, z=73.1}, "cylinder", 3, {255, 0, 0, 255}, "Radiostacja", "Cel misji", "work")
				else
					context:setElementFrozen("main-car", false)
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
				context:setElementFrozen("main-car", true)
				context:toggleAllControls(false)
				context:disableVehicleExit(false)
				context:disableVehicleEnter(true)
				context:makePedExitVehicle("barry")
				context:makePedExitVehicle("me")
				context:sleep(100)
				context:setMissionTarget("Podążaj za Barrym")
				context:sleep(2200)
				context:removeFromVehicle("me")
				context:removeFromVehicle("barry")
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
				-- context:destroy("main-car")
				-- context:createServerSideVehicle("main-car2", 422, {x=504.7373, y=1368.2725, z=4.9871}, {x=3.1146, y=0.9064, z=271.0437}, {35, 33, 22, 255}, {15, 15, 15, 255}, 2)
				context:toggleAllControls(false)
				context:playPlayback("barry", "prolog-2", false)
				context:setMissionTarget("Wróć do pojazdu")
				setMissionData('prolog:goToStation', true)
			elseif marker == "target-3" then
				context:setMissionTarget("")
				context:destroy("target-3")
				context:destroy("target-3-blip")
				context:pedTellVoiceLine("barry", "prolog-26", "Zaparkuj na parkingu żeby nie wzbudzać podejrzeń", true)
				context:createBlip("target-4-blip", {x=-287.430, y=1565.157, z=75.359}, 41, 99999)
				context:createMarker("target-4", {x=-287.430, y=1565.157, z=74.359}, "cylinder", 3, {255, 0, 0, 255}, "Parking", "Cel misji", "work")
				context:setMissionTarget("Zaparkuj na parkingu")
			elseif marker == "target-4" then
				context:destroy("target-4")
				context:destroy("target-4-blip")
				context:setElementFrozen("main-car", true)
				context:disableVehicleExit(false)
				context:disableVehicleEnter(true)
				context:makePedExitVehicle("barry")
				context:makePedExitVehicle("me")
				-- removePedFromVehicle(localPlayer)
				context:pedTellVoiceLine("barry", "prolog-27", "Dobra, idziemy", true)
				context:setMissionTarget("Podążaj za Barrym")
				context:sleep(2200)
				context:removeFromVehicle("me")
				context:removeFromVehicle("barry")
				context:playPlayback("barry", "prolog-3", true)
				context:createMarker("target-5", {x=-353.221, y=1584.001, z=75.529}, "cylinder", 1, {255, 0, 0, 255}, "Radiostacja", "Cel misji", "work")
			elseif marker == "target-5" then
				context:setMissionTarget("")
				context:destroy("target-5")
				context:pedTellVoiceLine("barry", "prolog-28", "Dobra, masz i kładź sprzęt", true)
				context:setMissionTarget("Rozstaw nadajniki")
				context:createMarker("target-6", {x=-345.892, y=1584.441, z=75.268}, "cylinder", 1, {255, 0, 0, 255}, "Radiostacja", "Cel misji", "work")
			elseif marker == "target-6" then
				context:setMissionTarget("")
				context:destroy("target-6")
				setPedAnimation(localPlayer, 'bomber', 'bom_plant', -1, false, false, false, false)
				context:sleep(2000)
				-- create ped
				context:createPed("security", 285, {x=-346.450, y=1544.947, z=75.562}, 168.72, 2)
				context:pedTellVoiceLine("barry", "prolog-29", "Dobra, sprzęt jest, teraz trzeba go uruchomić", true)
				context:pedTellVoiceLine("me", "prolog-30", "To na co czekasz?", true)
				context:pedTellVoiceLine("barry", "prolog-31", "Eee.. no.. tylko że to zdalnie się uruchamia", true)
				context:pedTellVoiceLine("me", "prolog-32", "Barry, nie mów że nie masz pilota", true)
				context:pedTellVoiceLine("barry", "prolog-33", "No.. no.. no.. jest gdzieś w aucie, chodźmy go poszukać", true)
				context:setMissionTarget("Znajdź pilota")
				context:playPlayback("barry", "prolog-4", true)
				context:pedTellVoiceLine("barry", "prolog-34", "Uważaj, ktoś jest w środku", true)
				context:pedTellVoiceLine("me", "prolog-35", "Co?!", true)
				context:pedTellVoiceLine("barry", "prolog-36", "Zakradniemy się i nas nie zauważy", true)
				context:playPlayback("barry", "prolog-5", true)
				setPedAnimation(getMissionElement("barry"), 'knife', 'kill_knife_player', -1, false, false, false, false)
				setPedAnimation(getMissionElement("security"), 'knife', 'kill_knife_ped_damage', -1, false, false, false, false)
				context:sleep(1500)
				setPedAnimation(getMissionElement("security"), 'knife', 'kill_knife_ped_die', -1, false, false, false, true)
				context:sleep(1000)
				context:pedTellVoiceLine("me", "prolog-37", "Barry co ty zrobiłeś?!", true)
				context:pedTellVoiceLine("barry", "prolog-38", "Nic, później się ocknie i będzie żył", true)
				context:playPlayback("barry", "prolog-6", true)
				context:disableVehicleEnter(false)
				context:disableVehicleExit(true)
				setMissionData('prolog:goToCar', true)
				context:destroy("security")
			elseif marker == "target-7" then
				context:destroy("target-7")
				context:destroy("target-7-blip")
				context:setElementFrozen("main-car", true)
				context:toggleAllControls(true)
				context:setMissionTarget("")
				context:pedTellVoiceLine("barry", "prolog-56", "Ide do domu, przyjdź później jak będziesz miał czas", true)
				context:pedTellVoiceLine("me", "prolog-57", "Dobra, do zobaczenia", true)
				context:fadeCamera(true, 0.5, true)
				context:sleep(4500)
				context:fadeCamera(false, 0.5, false)
				context:toggleAllControls(false)
				context:moveToNormalDimension()
				context:finishMission()
			end
		end),
	},

	allowedVehicles = {
		[1] = {  model = 422,  position = {    x = -136.5137,    y = 1055.1543,    z = 19.9326  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 0.5603,    y = 359.5496,    z = 199.3689  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car"},
	},
	allowedPeds = {
		[1] = {  model = 273,  position = {    x = 0,    y = 0,    z = 0  },  rotation = 0,  specialId = "barry"},
		[2] = {  model = 285,  position = {    x = -346.450,    y = 1544.947,    z = 75.562  },  rotation = 168.72,  specialId = "security"},
	}
}

if localPlayer then
	bindKey('c', 'down', function()
		forceExitVehicle(localPlayer)
	end)
end