--
-- dxCreateRoundedTexture
-- https://github.com/Pioruniasty/MTA_rounded_rectangle
-- https://forum.mtasa.com/viewtopic.php?f=108&t=96096
-- Author: Piorun
-- All credits of this function to him
--

function dxCreateRoundedTexture(text_width,text_height,radius)
	assert(text_width,"Missing argument 'text_width' at dxCreateRoundedTexture")
	assert(text_height,"Missing argument 'height' at dxCreateRoundedTexture")
	assert(radius,"Missing argument 'radius' at dxCreateRoundedTexture")
	if type(text_width) ~= "number" then outputDebugString("Bad argument @ 'dxCreateRoundedTexture' [Excepted number at argument 1, got " .. type(text_width) .. "]",2) return false end
	if type(text_height) ~= "number" then outputDebugString("Bad argument @ 'dxCreateRoundedTexture' [Excepted number at argument 2, got " .. type(text_height) .. "]",2) return false end
	if type(radius) ~= "number" then outputDebugString("Bad argument @ 'dxCreateRoundedTexture' [Excepted number at argument 3, got " .. type(radius) .. "]",2) return false end
	if text_width < 0 then outputDebugString("text_width can't be less than 0",1) return false end
	if text_height < 0 then outputDebugString("text_height can't be less than 0",1) return false end
	if radius < 0 or radius > 100 then outputDebugString("Parameter 'radius' can't be between 0 and 100",1) return false end

	local texture = DxTexture(text_width,text_height)
	local pix = texture:getPixels()

	radius = (radius * (text_height / 2)) / 100

	for x=0,text_width do
		for y=0,text_height do
			if x >= radius and x <= text_width - radius then
				dxSetPixelColor(pix,x,y,255,255,255,255)
			end
			if y >= radius and y <= text_height - radius then
				dxSetPixelColor(pix,x,y,255,255,255,255)
			end
			if math.sqrt((x - radius)^2 + (y - radius)^2) < radius then
				dxSetPixelColor(pix,x,y,255,255,255,255) -- lewy gorny rog
			end
			if math.sqrt((x - (text_width - radius))^2 + (y - radius)^2) < radius then
				dxSetPixelColor(pix,x,y,255,255,255,255) -- prawy gorny rog
			end
			if math.sqrt((x - radius)^2 + (y - (text_height - radius))^2) < radius then
				dxSetPixelColor(pix,x,y,255,255,255,255) -- lewy dolny rog
			end
			if math.sqrt((x - (text_width - radius))^2 + (y - (text_height - radius))^2) < radius then
				dxSetPixelColor(pix,x,y,255,255,255,255) -- prawy dolny rog
			end
		end
	end
	texture:setPixels(pix)
	return texture
end