missions["long-road"] = {
    {
		name = "onStart",
		callback = async(function(context)
            showMissionName("Długa droga")
			context:fadeCamera(true, 0.5, true)
			context:sleep(100)
			context:fadeCamera(false, 0.5, false)
            context:moveToMissionDimension()
            context:toggleAllControls(true)
			context:createPed("barry", 273, {x = -135.735, y = 1056.714, z = 19.958}, 110.0000, 1)
			context:createServerSideVehicle("main-car", 422, {x=-136.5137, y=1055.1543, z=19.9326}, {x=0.5603, y=359.5496, z=199.3689}, {35, 33, 22, 255}, {15, 15, 15, 255}, 1)
			context:createServerSideVehicle("bmx", 422, {x=0, y=0, z=0}, {x=0.5603, y=359.5496, z=199.3689}, {255, 255, 22, 255}, {15, 15, 15, 255}, 2)
            setPedAnimation(getMissionElement('barry'), 'casino', 'cards_loop', -1, true, false, false, false)
            context:setElementFrozen("main-car", true)
            context:warpIntoVehicle("me", "bmx", 0)
            
            context:createObject('package', 2969, {x=-130.818, y=1059.519, z=19.10}, {x=0.0000, y=0.0000, z=0.0000})
            setObjectScale(getMissionElement('package'), 1.5)

            context:interpolateCamera(
                {x=-172.557, y=1046.691, z=19.032},
                {x=-136.922, y=1055.744, z=20.232},
                {x=-123.300, y=1048.530, z=20.832},
                {x=-136.922, y=1055.744, z=20.232},
                30000, 0, 0, 80, 70, "OutQuad", false, false
            )

            context:playPlayback("me", "long-road-1", true)
            context:makePedExitVehicle("me")
            context:pedTellVoiceLine("barry", "long-road-1", "O w końcu jesteś! Czekałem na ciebie", false)
            context:sleep(800)
            -- context:removeFromVehicle("me")
            context:playPlayback("me", "long-road-2", true)
            setPedAnimation(localPlayer, 'casino', 'cards_loop', -1, true, false, false, false)

            context:pedTellVoiceLine("me", "long-road-2", "Co się stało? Znalazłeś coś ciekawego w torbie?", true)
            context:pedTellVoiceLine("barry", "long-road-3", "Tak, znalazłem, mam tu mape i koordynaty, wychodzi na to że gość który kontaktuje się z kosmitami mieszka w Los Santos", true)
            context:pedTellVoiceLine("me", "long-road-4", "Wiesz co on planuje?", true)
            context:pedTellVoiceLine("barry", "long-road-5", "Nie, ale chcę się dowiedzieć", true)
            context:pedTellVoiceLine("me", "long-road-6", "I pewnie ja mam ci w tym pomóc", true)

            context:interpolateCamera(
                {x=-123.300, y=1053.530, z=24.832},
                {x=-136.922, y=1055.744, z=20.232},
                {x=-147.557, y=1049.691, z=23.032},
                {x=-136.922, y=1055.744, z=20.232},
                20000, 0, 0, 80, 70, "InOutQuad", false, false
            )

            context:pedTellVoiceLine("barry", "long-road-7", "Dokładnie, zaczniemy od tego, żeby zdobyć jak najwięcej informacji o tym gościu", true)
            context:pedTellVoiceLine("barry", "long-road-8", "Popytamy ludzi w okolicy, założymy podsłuch, zobaczymy co się da zrobić", true)
            context:pedTellVoiceLine("me", "long-road-9", "Przecież ten gość pewnie ma całą prywatną armię", true)
            context:pedTellVoiceLine("barry", "long-road-10", "Nie martw się, zawsze znajdzie się jakiś sposób", true)
            context:pedTellVoiceLine("barry", "long-road-11", "Weź tą paczke i załaduj ją do samochodu, tam jest cały sprzęt który będziemy potrzebować", true)
            
            context:fadeCamera(true, 0.5, true)
            context:warpIntoVehicle("barry", "main-car", 1)
			context:sleep(100)
			context:fadeCamera(false, 0.5, false)
            context:toggleAllControls(false)
            context:resetCamera()
            context:disableVehicleEnter(true)
            context:setMissionTarget("Podnieś skrzynię")
            setPedAnimation(localPlayer)
            
            -- context:sleep(1000)
            context:pedTellVoiceLine("me", "long-road-12", "Może ty powinieneś mi pomóc?", true)
            context:pedTellVoiceLine("barry", "long-road-13", "Przecież wiesz że mam chore stawy", true)
            context:pedTellVoiceLine("me", "long-road-14", "No, paluszek i główka, standard", true)

            context:createMarker("target-1", {x=-131.070, y=1058.725, z=18.920}, "cylinder", 1, {255, 0, 0, 255}, "Skrzynia", "Cel misji", "work")
            context:createBlip("target-1-blip", {x=-131.070, y=1058.725, z=19.920}, 41, 99999)
        end),
	},

    {
		name = "onMarkerHit",
		callback = async(function(context, marker)
			if marker == "target-1" then
                context:destroy("target-1")
				context:destroy("target-1-blip")
                context:setMissionTarget("")
                
                context:toggleAllControls(true)
                setPedAnimation(localPlayer, 'carry', 'liftup', -1, false, false, false, false)
                context:sleep(500)
                exports['m-pattach']:attach(getMissionElement('package'), localPlayer, 24, 0.32, 0.15, -0.2, -15 - 95, -3, 0)
                context:sleep(800)
                setPedAnimation(localPlayer, 'carry', 'crry_prtial', 1, true)
                context:toggleAllControls(false)

                context:pedTellVoiceLine("me", "long-road-15", "O cholera, co ty tam nakładłeś, kamienie?", true)
                context:pedTellVoiceLine("barry", "long-road-16", "Masa drobiazgów, wiesz o co chodzi", true)

                context:createMarker("target-2", {x=-137.688, y=1057.912, z=18.933}, "cylinder", 1, {255, 0, 0, 255}, "Bagażnik", "Cel misji", "work")
                context:createBlip("target-2-blip", {x=-137.688, y=1057.912, z=19.933}, 41, 99999)
                context:setMissionTarget("Załaduj skrzynię do bagażnika")
            elseif marker == "target-2" then
                context:destroy("target-2")
                context:destroy("target-2-blip")
                context:setMissionTarget("")
                
                context:toggleAllControls(true)
                setPedAnimation(localPlayer, 'carry', 'putdwn', -1, false, false, false, false)
                context:sleep(500)
                exports['m-pattach']:detach(getMissionElement('package'))
                attachElements(getMissionElement('package'), getMissionElement('main-car'), 0, -1.5, -0.15)
                context:sleep(800)

                context:toggleAllControls(false)
                context:disableVehicleEnter(false)

                context:pedTellVoiceLine("barry", "long-road-17", "Dobra, wszystko gotowe, jedziemy", true)
                context:setMissionTarget("Wsiądź do samochodu")
            elseif marker == "target-3" then
                context:destroy("target-3")
                context:destroy("target-3-blip")
                context:setMissionTarget("")
                context:setElementFrozen("main-car", true)

                context:fadeCamera(true, 0.5, true)
                context:fadeCamera(false, 0.5, false)
                context:moveToMissionDimension()
                context:toggleAllControls(true)

                context:interpolateCamera(
                    {x=631.283, y=1687.050, z=9.592},
                    {x=620.868, y=1686.250, z=7.292},
                    {x=626.081, y=1694.984, z=8.592},
                    {x=620.868, y=1686.250, z=7.292},
                    15000, 0, 0, 80, 70, "InOutQuad", false, false
                )

                context:sleep(100)

                context:pedTellVoiceLine("barry", "long-road-27", "Dobra, ja zatankuję, a ty idź zapłacisz i weź mi hot-doga", true)
                context:pedTellVoiceLine("me", "long-road-28", "Hot-doga? Ty chyba żartujesz", true)
                context:pedTellVoiceLine("barry", "long-road-29", "Głodny jestem nie przesadzaj", true)

                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                context:disableVehicleExit(false)
                context:disableVehicleEnter(true)
                context:setMissionTarget("Zapłać za paliwo")
                context:resetCamera()
				context:makePedExitVehicle("me")
				context:sleep(2200)
				context:removeFromVehicle("me")

                context:createMarker("target-4", {x=638.777, y=1683.643, z=6.188}, "cylinder", 1, {255, 0, 0, 255}, "Stacja benzynowa", "Cel misji", "work")
                context:createBlip("target-4-blip", {x=638.777, y=1683.643, z=7.188}, 41, 99999)
            elseif marker == "target-4" then
                context:destroy("target-4")
                context:destroy("target-4-blip")
                context:setMissionTarget("")

                context:toggleAllControls(true)
                context:fadeCamera(true, 0.5, true)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)
                
				setMissionData('long-road:goToCar', true)
                context:setMissionTarget("Wróć do samochodu")
                context:disableVehicleEnter(false)
                context:toggleAllControls(false)
            elseif marker == "target-5" then
                context:destroy("target-5")
                context:destroy("target-5-blip")
                context:setMissionTarget("Znajdź dom naukowca")
                context:createBlip("target-6-blip", {x=1022.653, y=-791.065, z=101.364}, 41, 99999)

                context:pedTellVoiceLine("me", "long-road-49", "Dobra, gdzie teraz?", true)
                context:pedTellVoiceLine("barry", "long-road-50", "Czekaj daj mi spojrzeć na tą mapę", true)
                context:pedTellVoiceLine("barry", "long-road-51", "Dobra mam, jedź na górę, zobaczysz taki dom w kształcie UFO", true)
                context:pedTellVoiceLine("me", "long-road-52", "Ich pogrzało? Nawet się z tym nie kryją", true)

                context:createMarker("target-6", {x=1022.653, y=-791.065, z=101.364}, "cylinder", 3, {255, 0, 0, 255}, "Góra Vinewood", "Cel misji", "work")
            elseif marker == "target-6" then
                context:destroy("target-6")
                context:destroy("target-6-blip")
                context:setMissionTarget("Zaparkuj po drugiej stronie ulicy")
                context:createBlip("target-7-blip", {x=1082.201, y=-749.591, z=105.929}, 41, 99999)

                context:pedTellVoiceLine("barry", "long-road-53", "Dobra, zaparkuj po drugiej stronie ulicy w alejce, ja pójdę zobaczyć co tam jest", true)
                context:pedTellVoiceLine("me", "long-road-54", "A ja?", true)
                context:pedTellVoiceLine("barry", "long-road-55", "Zostań w samochodzie, jak coś to dzwoń", true)

                context:createMarker("target-7", {x=1082.201, y=-749.591, z=104.929}, "cylinder", 3, {255, 0, 0, 255}, "Alejka", "Cel misji", "work")
            elseif marker == "target-7" then
                context:destroy("target-7")
                context:destroy("target-7-blip")
                context:setMissionTarget("Zaczekaj na Barry'ego")
                context:setElementFrozen("main-car", true)
                context:toggleAllControls(true)
                context:pedTellVoiceLine("barry", "long-road-56", "Dobra, czekaj tu, zaraz wracam", true)
                
                context:makePedExitVehicle("barry")
                context:sleep(1500)
                context:removeFromVehicle("barry")
                
                context:playPlayback("barry", "long-road-3", true)
                setPedAnimation(getMissionElement('barry'), 'carry', 'liftup', -1, false, false, false, false)
                context:sleep(500)
                detachElements(getMissionElement('package'), getMissionElement('main-car'))
                exports['m-pattach']:attach(getMissionElement('package'), getMissionElement('barry'), 24, 0.32, 0.15, -0.2, -15 - 95, -3, 0)
                context:sleep(800)
                setPedAnimation(getMissionElement('barry'), 'carry', 'crry_prtial', 1, true)
                context:playPlayback("barry", "long-road-4", true)

                context:sleep(15000)
                context:playPlayback("barry", "long-road-5", true)
                setPedAnimation(getMissionElement('barry'), 'carry', 'liftup', -1, false, false, false, false)
                context:sleep(500)
                exports['m-pattach']:detach(getMissionElement('package'))
                attachElements(getMissionElement('package'), getMissionElement('main-car'), 0, -1.5, -0.15)
                context:sleep(800)
                setPedAnimation(getMissionElement('barry'))

                context:fadeCamera(true, 0.5, true)
                context:warpIntoVehicle("barry", "main-car", 1)
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
                context:setMissionTarget("Jedź do hotelu")
                context:setElementFrozen("main-car", false)
                context:createBlip("target-8-blip", {x=998.492, y=-1293.172, z=13.373}, 41, 99999)

                context:pedTellVoiceLine("barry", "long-road-57", "Dobra, podłożyłem podsłuch", true)
                context:pedTellVoiceLine("me", "long-road-58", "Zostawili coś ciekawego?", true)
                context:pedTellVoiceLine("barry", "long-road-59", "Nie wiem, nie wchodziłem do środka, podłożyłem tylko pluskwy pod okna", true)
                context:pedTellVoiceLine("me", "long-road-60", "Wysadzę cię w centrum miasta", true)
                context:pedTellVoiceLine("barry", "long-road-61", "Dobra pasuje mi to, a ty zdobądź trochę gotówki, przyda ci się, dam ci znać jak czegoś się dowiem", true)
                context:pedTellVoiceLine("me", "long-road-62", "Jasne, teraz musimy wymyśleć nazwę naszej dwójki", true)
                context:pedTellVoiceLine("barry", "long-road-63", "Niech będzie \"Barry i jego pomocnik\"", true)
                context:pedTellVoiceLine("me", "long-road-64", "Chyba cię coś boli, może \"Mistrz i debil\"?", true)
                context:pedTellVoiceLine("barry", "long-road-65", "Ej ej, uważaj co mówisz", true)
                context:pedTellVoiceLine("me", "long-road-66", "Dobra, dobra, \"Jastrzębi wzrok\"", true)
                context:pedTellVoiceLine("barry", "long-road-67", "Nieźle, może być", true)

                context:createMarker("target-8", {x=998.492, y=-1293.172, z=12.373}, "cylinder", 3, {255, 0, 0, 255}, "Centrum", "Cel misji", "work")
            elseif marker == "target-8" then
                context:destroy("target-8")
                context:destroy("target-8-blip")
                context:setMissionTarget("")
                context:setElementFrozen("main-car", true)
                context:toggleAllControls(true)

                context:fadeCamera(true, 0.5, true)
                context:interpolateCamera(
                    {x=985.621, y=-1310.753, z=13.9},
                    {x=998.429, y=-1294.316, z=13.596},
                    {x=999.108, y=-1310.897, z=13.9},
                    {x=998.429, y=-1294.316, z=13.596},
                    15000, 0, 0, 80, 70, "InOutQuad", false, false
                )
                context:sleep(100)
                context:fadeCamera(false, 0.5, false)

                context:pedTellVoiceLine("barry", "long-road-68", "Dobra, przeleje ci $100, idź do jakiegoś bankomatu i kup sobie coś do jedzenia", true)
                context:pedTellVoiceLine("me", "long-road-69", "Dzięki, do zobaczenia", true)
                context:pedTellVoiceLine("barry", "long-road-70", "Do zobaczenia", true)

                context:fadeCamera(true, 0.5, true)
                context:sleep(4500)
                context:resetCamera()
                context:moveToNormalDimension()
                context:fadeCamera(false, 0.5, false)
                context:toggleAllControls(false)
				context:finishMission()
            end
        end),
    },

    {
		name = "onVehicleEnter",
		callback = async(function(context, vehicle, seat)
			if vehicle == "main-car" and seat == 0 then
				if getMissionData('long-road:goToCar') then
                    context:disableVehicleExit(true)
                    context:setMissionTarget("Jedź do Los Santos")
                    context:createBlip("target-5-blip", {x=598.513, y=-699.418, z=10.902}, 41, 99999)
                    context:setElementFrozen("main-car", false)

                    context:pedTellVoiceLine("me", "long-road-31", "Masz i jedz", true)
                    context:pedTellVoiceLine("barry", "long-road-32", "Dzięki, jedziemy teraz na góry Vinewood, tam się rozejrzymy", true)
                    local sound = playSound('data/voice/intro-soundtrack.mp3')
                    addMissionElement(sound)
                    setSoundVolume(sound, 0.15)

                    context:sleep(1500)
                    context:pedTellVoiceLine("me", "long-road-33", "Ty się nigdy nie badałeś na głowę?", true)
                    context:pedTellVoiceLine("barry", "long-road-34", "Nie zdarzyło mi się", true)
                    context:pedTellVoiceLine("me", "long-road-35", "To może teraz?", true)
                    context:pedTellVoiceLine("barry", "long-road-36", "Daj mi spokój", true)
                    context:pedTellVoiceLine("me", "long-road-37", "Dobra, jak chcesz", true)

                    context:sleep(2500)
                    context:pedTellVoiceLine("me", "long-road-38", "Widać że rozum to masz po matce", true)
                    context:pedTellVoiceLine("barry", "long-road-39", "Nie zaczynaj", true)
                    context:pedTellVoiceLine("me", "long-road-40", "Wiesz dobrze co sądze o tym wszystkim", true)
                    context:pedTellVoiceLine("barry", "long-road-41", "Kiedyś mi podziękujesz", true)
                    context:pedTellVoiceLine("me", "long-road-42", "Jak nie będę wtedy w więzieniu, albo martwy", true)
                    context:pedTellVoiceLine("barry", "long-road-43", "Wiesz co mi zawsze mawiał ojciec?", true)
                    context:pedTellVoiceLine("me", "long-road-44", "No co mawiał?", true)
                    context:pedTellVoiceLine("barry", "long-road-45", "\"Ignoruj inne głosy, słuchaj tylko swojego\"", true)
                    context:pedTellVoiceLine("me", "long-road-46", "I co to ma z tym wspólnego?", true)
                    context:pedTellVoiceLine("barry", "long-road-47", "Nic, po prostu mi się przypomniało", true)
                    context:pedTellVoiceLine("me", "long-road-48", "Nieźle", true)

                    context:createMarker("target-5", {x=598.513, y=-699.418, z=9.902}, "cylinder", 3, {255, 0, 0, 255}, "Los Santos", "Cel misji", "work")
                else
                    context:disableVehicleExit(true)
                    context:setMissionTarget("Udaj się na stacje benzynową")

                    context:createBlip("target-3-blip", {x=618.804, y=1685.063, z=6.977}, 41, 99999)
                    context:setElementFrozen("main-car", false)
                    context:pedTellVoiceLine("me", "long-road-18", "Gdzie jedziemy?", true)
                    context:pedTellVoiceLine("barry", "long-road-19", "Na stacje benzynową, musimy zatankować", true)
                    context:pedTellVoiceLine("me", "long-road-20", "A potem?", true)
                    context:pedTellVoiceLine("barry", "long-road-21a", "Pierw podłożymy podsłuch, musimy mieć jak najwięcej informacji", true)
                    context:pedTellVoiceLine("barry", "long-road-21b", "Potem zatrzymamy się w hotelu, posłuchamy co mówią ludzie", true)
                    context:pedTellVoiceLine("me", "long-road-22", "I co dalej?", true)
                    context:pedTellVoiceLine("barry", "long-road-23", "Nie wiem, zobaczymy co się wydarzy", true)
                    context:pedTellVoiceLine("me", "long-road-24", "A co jeśli nas złapią?", true)
                    context:pedTellVoiceLine("barry", "long-road-25", "Nie sraj żarem, nigdy nas nie złapią", true)
                    context:pedTellVoiceLine("me", "long-road-26", "Mam nadzieję", true)

                    context:createMarker("target-3", {x=618.804, y=1685.063, z=5.977}, "cylinder", 3, {255, 0, 0, 255}, "Stacja benzynowa", "Cel misji", "work")
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

    allowedVehicles = {
		[1] = {  model = 422,  position = {    x = -136.5137,    y = 1055.1543,    z = 19.9326  },  primaryColor = { 35, 33, 22, 255 },  rotation = {    x = 0.5603,    y = 359.5496,    z = 199.3689  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "main-car"},
		[2] = {  model = 481,  position = {    x = 0, y = 0, z = 0  },  primaryColor = { 255, 255, 22, 255 },  rotation = {    x = 0.5603,    y = 359.5496,    z = 199.3689  },  secondaryColor = { 15, 15, 15, 255 },  specialId = "bmx"},
	},
    allowedPeds = {
		[1] = {  model = 273,  position = {    x = -135.735,    y = 1056.714,    z = 19.958  },  rotation = 110,  specialId = "barry"},
	}
}