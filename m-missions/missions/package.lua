missions["package"] = {
    {
		name = "onStart",
		callback = async(function(context)
            showMissionName("Przechwyt")
			context:fadeCamera(true, 0.5, true)
			context:sleep(100)
			context:fadeCamera(false, 0.5, false)
            context:moveToMissionDimension()
            context:toggleAllControls(true)
			context:createPed("barry", 273, {x=0.0000, y=0.0000, z=0.0000}, 0.0000, 1)
			context:createServerSideVehicle("main-car", 422, {x=-136.5137, y=1055.1543, z=19.9326}, {x=0.5603, y=359.5496, z=199.3689}, {35, 33, 22, 255}, {15, 15, 15, 255}, 1)
            
            context:interpolateCamera(
                {x=-127.032, y=1051.752, z=22.291},
                {x=-128.532, y=1057.890, z=20.000},
                {x=-132.973, y=1057.109, z=21.491},
                {x=-128.532, y=1057.890, z=20.000},
                10000, 0, 0, 80, 70, "InOutQuad", false, false
            )
			
            context:playPlayback("me", "package-1", true)
            context:pedTellVoiceLine("me", "package-1", "Barry? Jesteś tam?", true)
            context:playPlayback("me", "package-2", true)
            setPedAnimation(localPlayer, 'kissing', 'gfwave2', -1, false, false, false, false)
            context:pedTellVoiceLine("me", "package-2", "Barry..?", true)
            context:pedTellVoiceLine("barry", "package-3", "Jestem jestem, czekaj zaraz wychodzę!", true)
            context:pedTellVoiceLine("me", "package-4", "Dobra, ale się pospiesz!", true)

            context:fadeCamera(true, 0.5, true)
            
            context:warpIntoVehicle("me", "main-car", 0)
			context:warpIntoVehicle("barry", "main-car", 1)
            context:sleep(100)
            
            context:fadeCamera(false, 0.5, false)
			context:resetCamera()
            context:toggleAllControls(false)
            context:disableVehicleExit(true)

            context:createBlip("target-1-blip", {x=497.756, y=2387.640, z=29.629}, 41, 99999)
            context:pedTellVoiceLine("barry", "package-5", "Słuchałem sygnału całą noc, z tego co zrozumiałem to będą zrzucać paczkę w okolicach starego lotniska", true)
            context:pedTellVoiceLine("me", "package-6", "A od kiedy ty gadasz po kosmicku?", true)
            context:pedTellVoiceLine("barry", "package-7", "Oni nie mówią po kosmicku, kontaktują się z kimś na ziemi i używają tłumacza", true)
            context:pedTellVoiceLine("barry", "package-8", "Zresztą, nie ważne, musimy się tam dostać zanim zabiorą paczkę", true)
            context:pedTellVoiceLine("me", "package-9", "A co to za paczka?", true)
            context:pedTellVoiceLine("barry", "package-10", "Nie wiem, ale z tego co zrozumiałem to jest bardzo ważna", true)
            context:pedTellVoiceLine("me", "package-11", "To jakiś koszmar, wciąż nie wierzę że biorę udział w takich akcjach", true)
            context:pedTellVoiceLine("me", "package-12", "Ty lepiej sie tym nie chwal na prawo i lewo, bo jeszcze cię zamkną do czubków", true)
            context:pedTellVoiceLine("me", "package-12a", "Ojciec miał racje, jesteś tak głupi jak matka", true)
            context:pedTellVoiceLine("barry", "package-13", "Nie bój sie, ojciec też mówił że siki są dobre na raka", true)
            context:pedTellVoiceLine("me", "package-13a", "Oboje jesteście idiotami", true)

            context:createMarker("target-1", {x=497.756, y=2387.640, z=28.629}, "cylinder", 3, {255, 0, 0, 255}, "Stare lotnisko", "Cel misji", "work")
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
                
                context:interpolateCamera(
                    {x=512.420, y=2393.335, z=33.732},
                    {x=497.738, y=2387.974, z=30.032},
                    {x=497.637, y=2400.763, z=33.932},
                    {x=497.738, y=2387.974, z=30.032},
                    10000, 0, 0, 80, 70, "InOutQuad", false, false
                )

                context:pedTellVoiceLine("me", "package-14", "I co teraz?", true)
                context:pedTellVoiceLine("barry", "package-15", "Jeszcze chyba nie zrzucili paczki, musimy poczekać", true)
                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)

                context:createObject('package', 2903, {x=262.745, y=2602.356, z=71.729}, {x=0.0000, y=0.0000, z=0.0000})
                moveObject(getMissionElement("package"), 35000, 163.651, 2612.596, 22.478, 0, 0, 0, "InOutQuad")
                setElementCollisionsEnabled(getMissionElement("package"), false)

                context:interpolateCamera(
                    {x=301.687, y=2533.058, z=61.477},
                    {x=264.024, y=2601.489, z=68.877},
                    {x=333.990, y=2564.713, z=49.977},
                    {x=250.522, y=2598.157, z=62.177},
                    5000, 0, 0, 80, 70, "InOutQuad", false, false
                )

                -- blip
                context:createBlip("target-2-blip", {x=163.651, y=2612.596, z=22.478}, 41, 99999)
                attachElements(getMissionElement("target-2-blip"), getMissionElement("package"), 0, 0, 1)

                context:pedTellVoiceLine("me", "package-16", "O kurde, zobacz to!", true)
                context:pedTellVoiceLine("barry", "package-17", "Jest paczka, goń ją!", true)
                
                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                context:resetCamera()
                context:setElementFrozen("main-car", false)

                context:createMarker("target-2", {x=172.347, y=2613.064, z=15.463}, "cylinder", 3, {255, 0, 0, 255}, "Paczka", "Cel misji", "work")
                
                context:sleep(4000)
                context:pedTellVoiceLine("barry", "package-18a", "Pośpiesz się bo nam ucieknie!", true)
                context:pedTellVoiceLine("me", "package-19a", "Nie widzisz że jadę?", true)
            elseif marker == "target-2" then
                context:destroy("target-2")
                context:destroy("target-2-blip")

                context:setElementFrozen("main-car", true)
				context:toggleAllControls(false)
				context:disableVehicleExit(false)
				context:disableVehicleEnter(true)
				context:makePedExitVehicle("barry")
				context:makePedExitVehicle("me")

                context:sleep(100)
				context:setMissionTarget("Podejdź do paczki")
				context:sleep(2200)
				context:removeFromVehicle("me")
				context:removeFromVehicle("barry")

                context:playPlayback("barry", "package-3", true)
                context:createMarker("target-3", {x=165.436, y=2611.295, z=15.477}, "cylinder", 1, {255, 0, 0, 255}, "Paczka", "Cel misji", "work")
            elseif marker == "target-3" then
				context:setMissionTarget("")
                context:destroy("target-3")
                context:toggleAllControls(true)
                setPedAnimation(getMissionElement("barry"), 'bomber', 'bom_plant', -1, true, false, false, false)
                
                context:pedTellVoiceLine("me", "package-18", "Co to jest?", true)
                context:pedTellVoiceLine("barry", "package-19", "Nie wiem, ale musimy się stąd wynieść", true)
                context:pedTellVoiceLine("me", "package-20", "Dlaczego?", true)
                context:pedTellVoiceLine("barry", "package-21", "Bo zaraz tu będą", true)
                context:pedTellVoiceLine("me", "package-22", "Kto?", true)
                context:pedTellVoiceLine("barry", "package-23", "Nie mam pojęcia stary, bierz paczkę i zabierajmy się stąd", true)
                context:pedTellVoiceLine("me", "package-24", "Dobra, to co robimy?", true)
                context:pedTellVoiceLine("barry", "package-25", "Wracamy do domu, tam to sprawdzimy", true)
                
                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                setPedAnimation(getMissionElement("barry"))

                context:disableVehicleExit(true)
                context:disableVehicleEnter(false)

                context:setMissionTarget("Wsiądź do samochodu")
				setMissionData('package:goToCar', true)
				-- context:destroy("package")
                setObjectScale(getMissionElement("package"), 0.5)
                attachElements(getMissionElement("package"), getMissionElement("main-car"), 0, -1.5, 3.5)
            elseif marker == "target-4" then
				context:destroy("target-4")
				context:destroy("target-4-blip")
				context:setElementFrozen("main-car", true)
				context:toggleAllControls(true)
				context:setMissionTarget("")
				
                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)

                context:interpolateCamera(
                    {x=-150.782, y=1042.419, z=23.575},
                    {x=-139.941, y=1054.814, z=20.000},
                    {x=-132.327, y=1044.997, z=24.875},
                    {x=-139.941, y=1054.814, z=20.000},
                    10000, 0, 0, 80, 70, "InOutQuad", false, false
                )

                context:pedTellVoiceLine("me", "package-33", "Dobra ja muszę jeszcze załatwić parę spraw, zobacz co jest w tej paczce i potem się zgadamy", true)
                context:pedTellVoiceLine("barry", "package-34", "Dobra, do zobaczenia", true)
                
                context:fadeCamera(true, 0.5, true)
                context:sleep(4500)
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                context:resetCamera()
                context:moveToNormalDimension()
				context:finishMission()
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
		name = "onVehicleEnter",
		callback = async(function(context, vehicle, seat)
			if vehicle == "main-car" and seat == 0 then
				if getMissionData('package:goToCar') then
					context:warpIntoVehicle("barry", "main-car", 1)
                    context:disableVehicleEnter(true)
					context:disableVehicleExit(true)
                    context:setMissionTarget("Wróć do domu")
                    context:setElementFrozen("main-car", false)
                    context:createBlip("target-4-blip", {x=-137.478, y=1055.550, z=19.984}, 41, 99999)

                    context:pedTellVoiceLine("me", "package-26", "Myślisz że co jest w tej paczce?", true)
                    context:pedTellVoiceLine("barry", "package-27", "Nie wiem, ale musimy to sprawdzić", true)
                    context:pedTellVoiceLine("me", "package-28", "Mówię ci to jeszcze nas wszystkich pozabija", true)
                    context:pedTellVoiceLine("barry", "package-29", "Nic nam nie będzie, musimy to sprawdzić, to dla dobra ludzkości", true)
                    context:pedTellVoiceLine("me", "package-30", "Pewnie już mamy armię na karku", true)
                    context:pedTellVoiceLine("barry", "package-31", "Nawet jeśli, to musimy to sprawdzić", true)
                    context:pedTellVoiceLine("me", "package-32", "To jest szaleństwo", true)

                    context:createMarker("target-4", {x=-137.478, y=1055.550, z=18.984}, "cylinder", 3, {255, 0, 0, 255}, "Dom", "Cel misji", "work")
                end
            end
        end),
    },

    allowedVehicles = {
		[1] = {  model = 422,  position = {    x = -136.5137,    y = 1055.1543,    z = 19.9326  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 0.5603,    y = 359.5496,    z = 199.3689  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car"},
	},
    allowedPeds = {
		[1] = {  model = 273,  position = {    x = 0,    y = 0,    z = 0  },  rotation = 0,  specialId = "barry"},
	}
}