--
-- c_light_disable.lua
--

local lightDissShader

addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		-- Create shader
		lightDissShader, tec = dxCreateShader ( "light_disable.fx", 0, 0, false, "object" )
		if lightDissShader then
			-- Apply to world texture
			engineApplyShaderToWorldTexture ( lightDissShader, "*" )
		end
	end
)
