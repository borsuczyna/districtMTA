missions["test"] = {
	{
		name = "onStart",
		callback = async(function(context)
			context:interpolateCamera({x=487.4365, y=1343.3496, z=10.0380}, {x=494.9355, y=1368.7910, z=5.2380}, {x=519.7441, y=1354.5791, z=12.8380}, {x=494.9355, y=1368.7910, z=5.2380}, 1000, 0, 0, 80, 80, "", false)
		end),
	},

	allowedVehicles = {
	},
	allowedPeds = {
	}
}