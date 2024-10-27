missions["investigation"] = {
    {
		name = "onStart",
		callback = async(function(context)
            -- context:sleep(60000 * 2)
            context:createMarker("target-1", {x=1891.582, y=-1775.386, z=12.573}, "cylinder", 1, {255, 0, 0, 255}, "Misja", "Dochodzenie", "work")
            context:createBlip("target-1-blip", {x=1891.582, y=-1775.386, z=12.573}, 13, 99999)

            local blip = getMissionElement("target-1-blip")
            setElementData(blip, "blip:hoverText", "Misja - Barry")
            exports['m-notis']:addNotification('info', 'Barry', 'Barry znajduje się w hotelu w Idlewood, odwiedź go w wolnej chwili')
        end)
    },

    {
		name = "onMarkerHit",
		callback = async(function(context, marker)
			if marker == "target-1" and not getPedOccupiedVehicle(localPlayer) then
                showMissionName("Dochodzenie")
                context:destroy("target-1")
				context:destroy("target-1-blip")

                context:toggleAllControls(true)
                context:fadeCamera(true, 0.5, true)

                context:moveToMissionDimension()
                context:createServerSideVehicle("main-car", 422, {x=0, y=0, z=0}, {x=0, y=0, z=0}, {35, 33, 22, 255}, {15, 15, 15, 255}, 1)
                context:createPed("barry", 273, {x = -135.735, y = 1056.714, z = 19.958}, 110.0000, 1)
                context:createPed("weirdo", 273, {x = -135.735, y = 1056.714, z = 19.958}, 110.0000, 2)
                setElementPosition(localPlayer, 1890.034, -1771.192, 13.594)
                setElementRotation(localPlayer, 0, 0, 28, "default", true)
                setPedAnimation(localPlayer, 'GHANDS', 'gsign4', -1, true, false, false, false)
                setPedAnimation(getMissionElement("barry"), 'GHANDS', 'gsign3', -1, true, false, false, false)
                context:playPlayback("weirdo", "investigation-1", false)
                
                context:sleep(800)
                context:fadeCamera(false, 0.5, false)

                context:interpolateCamera(
                    {x=1871.622, y=-1779.431, z=17.722},
                    {x=1890.172, y=-1770.720, z=13.822},
                    {x=1879.794, y=-1765.323, z=13.622},
                    {x=1890.172, y=-1770.720, z=13.822},
                    30000, 0, 0, 80, 70, "OutQuad", false, false
                )

                context:pedTellVoiceLine("barry", "investigation-1", "Rozejrzałem się trochę po mieście, ten gościu ze wzgórz jest podejrzany", true)
                context:pedTellVoiceLine("me", "investigation-2", "Co masz na myśli?", true)
                context:pedTellVoiceLine("barry", "investigation-3", "Podsłuchiwałem go przez całą noc, mówił coś o jakimś spotkaniu", true)
                context:pedTellVoiceLine("barry", "investigation-4", "Mają się spotkać w Downtown, powinniśmy tam pojechać", true)
                context:pedTellVoiceLine("me", "investigation-5", "No dobra a jakieś konkretne informacje?", true)
                context:pedTellVoiceLine("barry", "investigation-6", "Mówili coś o starcie rakiety, nie wiem o co chodzi", true)
                context:destroy("weirdo")

                context:fadeCamera(true, 0.5, true)
                context:toggleAllControls(false)
                context:warpIntoVehicle("me", "main-car", 0)
                context:warpIntoVehicle("barry", "main-car", 1)
                context:resetCamera()
                context:sleep(500)
                context:fadeCamera(false, 0.5, false)
                context:disableVehicleExit(true)

                context:setMissionTarget("Udaj się na most w Downtown")
                context:createBlip("target-2-blip", {x=1612.701, y=-1383.501, z=27.570}, 41, 99999)
                context:createMarker("target-2", {x=1612.701, y=-1383.501, z=27.570}, "cylinder", 3, {255, 0, 0, 255}, "Most", "Cel misji", "work")

                context:pedTellVoiceLine("barry", "investigation-7", "Jedź na most w Downtown, tam powinniśmy mieć dobry widok", true)
            elseif marker == "target-2" then
                context:destroy("target-2")
                context:destroy("target-2-blip")
                context:setMissionTarget("Zatrzymaj się po drugiej stronie mostu")

                context:pedTellVoiceLine("barry", "investigation-8", "Zatrzymaj się po drugiej stronie mostu", true)

                context:createBlip("target-3-blip", {x=1586.751, y=-1376.547, z=27.649}, 41, 99999)
                context:createMarker("target-3", {x=1586.751, y=-1376.547, z=27.649}, "cylinder", 3, {255, 0, 0, 255}, "Most", "Cel misji", "work")
            elseif marker == "target-3" then
                context:destroy("target-3")
                context:destroy("target-3-blip")
                context:setMissionTarget("")
                context:setElementFrozen("main-car", true)
                context:toggleAllControls(true)
                context:pedTellVoiceLine("barry", "investigation-9", "Dobra, tu będzie dobrze, trzymaj aparat, ma funkcję zbierania dźwięku", true)
                context:toggleAllControls(false)
                context:giveWeapon("me", 1)
                
                context:disableVehicleExit(false)
                context:disableVehicleEnter(true)
				context:makePedExitVehicle("me")
				context:makePedExitVehicle("barry")
                context:sleep(2200)
				context:removeFromVehicle("me")
				context:removeFromVehicle("barry")

                context:playPlayback("barry", "investigation-2", false)
                context:sleep(2000)
                context:createBlip("target-4-blip", {x=1579.917, y=-1395.168, z=28.578}, 41, 99999)
                context:createMarker("target-4", {x=1579.917, y=-1395.168, z=27.578}, "cylinder", 1, {255, 0, 0, 255}, "Punkt widokowy", "Cel misji", "work")
            elseif marker == "target-4" then
                context:destroy("target-4")
                context:destroy("target-4-blip")
                context:setElementFrozen("me", true)
                context:fadeCamera(true, 0.5, true)
                setElementPosition(localPlayer, 1579.938, -1394.661, 28.577)
                setElementRotation(localPlayer, 0, 0, 70, "default", true)
                context:sleep(200)
                context:fadeCamera(false, 0.5, false)

                context:pedTellVoiceLine("barry", "investigation-10", "Musimy trochę poczekać, jeszcze ich nie ma", true)
                context:createServerSideVehicle("premier", 422, {x=0, y=0, z=0}, {x=0, y=0, z=0}, {35, 33, 22, 255}, {15, 15, 15, 255}, 2)
                context:createServerSideVehicle("stafford", 422, {x=0, y=0, z=0}, {x=0, y=0, z=0}, {35, 33, 22, 255}, {15, 15, 15, 255}, 3)
                context:createPed("premier-driver", 241, {x = 1579.917, y = -1395.168, z = 27.578}, 0.0000, 3)
                context:createPed("stafford-driver", 255, {x = 1579.917, y = -1395.168, z = 27.578}, 0.0000, 4)
                context:warpIntoVehicle("premier-driver", "premier", 0)
                context:warpIntoVehicle("stafford-driver", "stafford", 0)
                context:playPlayback("premier-driver", "investigation-3", false)
                context:playPlayback("stafford-driver", "investigation-4", false)
                
                context:sleep(4000)
                context:pedTellVoiceLine("barry", "investigation-11", "Patrz są! Ten w Staffordzie to ten ze wzgórz", false)

                context:sleep(2000)
                context:makePedExitVehicle("premier-driver")
                context:sleep(1500)
                context:makePedExitVehicle("stafford-driver")

                context:sleep(300)
				context:removeFromVehicle("premier-driver")
                context:playPlayback("premier-driver", "investigation-6a", false)
                context:sleep(1800)
				context:removeFromVehicle("stafford-driver")
                context:playPlayback("stafford-driver", "investigation-5", false)

                context:sleep(6200)
                
                context:setMissionTarget("Nagraj rozmowę")
                context:pedTellVoiceLine("barry", "investigation-12", "Odpal dźwięk, coś tam mówią", true)
                context:pedTellVoiceLine("premier-driver", "investigation-13", "Wszystko gotowe, rakieta gotowa do startu", true)
                context:pedTellVoiceLine("stafford-driver", "investigation-14", "Kiedy startujemy?", true)
                context:pedTellVoiceLine("premier-driver", "investigation-15", "Za 2 dni (4 listopada 2024) o 20:00", true)
                context:pedTellVoiceLine("stafford-driver", "investigation-16", "Dobra, będę gotowy", true)
                context:pedTellVoiceLine("barry", "investigation-17", "Dobra to nam wystarczy, musimy się zmywać zanim nas zauważą", true)

                context:fadeCamera(true, 0.5, true)
                context:toggleAllControls(true)
                
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                context:setMissionTarget("Wróć do pojazdu")
                context:setElementFrozen("me", false)

                context:playPlayback("barry", "investigation-6", false)
                context:disableVehicleExit(true)
                context:disableVehicleEnter(false)
				setMissionData('investigation:goToCar', true)
            elseif marker == "target-5" then
                context:destroy("target-5")
                context:destroy("target-5-blip")
                
                context:fadeCamera(true, 0.5, true)
                context:toggleAllControls(true)
                
                context:interpolateCamera(
                    {x=1871.622, y=-1779.431, z=17.722},
                    {x=1890.172, y=-1770.720, z=13.822},
                    {x=1879.794, y=-1765.323, z=13.622},
                    {x=1890.172, y=-1770.720, z=13.822},
                    30000, 0, 0, 80, 70, "OutQuad", false, false
                )

                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)

                context:pedTellVoiceLine("barry", "investigation-22", "Zobaczymy się za parę dni, będziemy gotowi", true)
                context:pedTellVoiceLine("me", "investigation-23", "Dobra, do zobaczenia", true)

                context:fadeCamera(true, 0.5, true)
                context:sleep(2500)
                context:resetCamera()
                context:moveToNormalDimension()
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                exports['m-notis']:addNotification('info', 'Event na żywo', 'Event na żywo odbędzie się 4 listopada 2024 o godzinie 20:00, nie może Cię tam zabraknąć! Liczymy na Ciebie!')
                context:finishMission()
            end
        end)
    },

    {
		name = "onVehicleEnter",
		callback = async(function(context, vehicle, seat)
			if vehicle == "main-car" and seat == 0 then
				if getMissionData('investigation:goToCar') then
                    context:fadeCamera(true, 0.5, true)
                    context:toggleAllControls(true)
                    context:warpIntoVehicle("barry", "main-car", 1)
                    context:fadeCamera(false, 0.5, false)

                    context:destroy("premier-driver")
                    context:destroy("stafford-driver")
                    context:destroy("premier")
                    context:destroy("stafford")
                    
                    context:setMissionTarget("Wróć do hotelu")
                    context:createBlip("target-5-blip", {x=1878.693, y=-1773.671, z=13.427}, 41, 99999)
                    context:setElementFrozen("main-car", false)
                    context:toggleAllControls(false)
                    context:pedTellVoiceLine("barry", "investigation-18", "Dobra, wracamy do hotelu", true)
                    context:pedTellVoiceLine("me", "investigation-19", "Słyszałeś? Będą startować rakietę", true)
                    context:pedTellVoiceLine("barry", "investigation-20", "Tak, zorganizuję sprzęt, będziemy gotowi", true)
                    context:pedTellVoiceLine("me", "investigation-21", "Spoko, spotkamy się na miejscu", true)
                    
                    context:createMarker("target-5", {x=1878.693, y=-1773.671, z=12.427}, "cylinder", 3, {255, 0, 0, 255}, "Hotel", "Cel misji", "work")
                end
            end
        end)
    },

    allowedVehicles = {
		[1] = {  model = 422,  position = {    x = 1883.008, y=-1773.466, z=13.416  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 0,    y = 0,    z = 0  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car"},
		[2] = {  model = 426,  position = {    x = 1883.008, y=-1773.466, z=13.416  },  primaryColor = { 0, 0, 0, 255 },  rotation = {    x = 0,    y = 0,    z = 0  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "premier"},
		[3] = {  model = 580,  position = {    x = 1883.008, y=-1773.466, z=13.416  },  primaryColor = { 0, 0, 0, 255 },  rotation = {    x = 0,    y = 0,    z = 0  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "stafford"},
	},
    allowedPeds = {
		[1] = {  model = 273,  position = {x=1889.571, y=-1770.317, z=13.620},  rotation = 205,  specialId = "barry"},
		[2] = {  model = 73,  position = {x=1889.571, y=-1770.317, z=13.620},  rotation = 205,  specialId = "weirdo"},
		[3] = {  model = 241,  position = {x=1889.571, y=-1770.317, z=13.620},  rotation = 205,  specialId = "premier-driver"},
		[4] = {  model = 255,  position = {x=1889.571, y=-1770.317, z=13.620},  rotation = 205,  specialId = "stafford-driver"},
	},
    allowedWeapons = {
        [1] = { id = 43, ammo = 1000 },
    },
}