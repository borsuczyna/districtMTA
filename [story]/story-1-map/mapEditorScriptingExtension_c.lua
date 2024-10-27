-- FILE: mapEditorScriptingExtension_c.lua
-- PURPOSE: Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION: RemoveWorldObjects (v1) AutoLOD (v2) BreakableObjects (v1)

function setLODsClient(lodTbl)
	for model in pairs(lodTbl) do
		engineSetModelLODDistance(model, 3000)
	end
	engineSetModelLODDistance(3790, 3000)
	engineSetModelLODDistance(6928, 3000)
	engineSetModelLODDistance(6933, 3000)
	engineSetModelLODDistance(16232, 3000)
end
addEvent("setLODsClient", true)
addEventHandler("setLODsClient", resourceRoot, setLODsClient)
