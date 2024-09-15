missions["ped"] = {
	onStart = async(function(context)
		context:createMarker("zero", Vector3(1469.3145, -1647.3525, 12.5469), "cylinder", 1, {215, 9, 9, 255}, "Cel", "Dobiegnij tutaj")
		context:createPed("pedzior", 7, Vector3(1489.6689, -1647.7422, 13.5469), 85.0107)
		context:playPlayback("pedzior", "pedzior-biegnie")
	end),

	onPlaybackFinished = async(function(context, name)
		if name == "pedzior-biegnie" then
			context:outputChat("Ped wygrał", {236, 19, 19, 255})
		end
	end),
}