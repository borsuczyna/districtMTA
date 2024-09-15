missions["test"] = {
	onStart = async(function(context)
		context:createMarker("zero", Vector3(2027.3994, -1898.9922, 13.2812), "cylinder", 1, {215, 9, 9, 255}, "Title", "opisek xd")
	end),

	onMarkerHit = async(function(context, marker)
		if marker == "zero" then
			context:outputChat("wszedles w marker", {255, 77, 77, 255})
		end
	end),
}