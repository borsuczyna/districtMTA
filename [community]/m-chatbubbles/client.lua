local selfVisible = true -- Want to see your own message?
local messages = {} -- {text, player, lastTick, alpha, yPos}
local textures = {}
local timeVisible = 8500
local distanceVisible = 30
local bubble = true -- Rounded rectangle(true) or not(false)

function addBubble(text, player, tick)
	if (not messages[player]) then
		messages[player] = {}
	end
	local width = dxGetTextWidth(text:gsub("#%x%x%x%x%x%x", ""), 1, "default-bold")
	local _texture = dxCreateRoundedTexture(width+16,20,100)
	table.insert(messages[player], {["text"] = text, ["player"] = player, ["tick"] = tick, ["endTime"] = tick + 2000, ["alpha"] = 0, ["texture"] = _texture})
end

function removeBubble()
	table.remove(messages)
end

addEvent("onChatIncome", true)
addEventHandler("onChatIncome", root,
	function(message, messagetype)
		if source ~= localPlayer then
			addBubble(message, source, getTickCount())
		elseif selfVisible then
			addBubble(message, source, getTickCount())
		end
	end
)


-- outElastic | Got from https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua
local pi = math.pi
function outElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * math.asin(c/a)
  end

  return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * pi) / p) + c + b
end

addEventHandler("onClientRender", root, 
	function()
		local tick = getTickCount()
		local x, y, z = getElementPosition(localPlayer)
		for _, pMessage in pairs(messages) do
			for i, v in ipairs(pMessage) do
				if isElement(v.player) then
					if tick-v.tick < timeVisible then
						local px, py, pz = getElementPosition(v.player)
						if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < distanceVisible and isLineOfSightClear ( x, y, z, px, py, pz, true, not isPedInVehicle(v.player), false, true) then
							v.alpha = v.alpha < 200 and v.alpha + 5 or v.alpha
							local bx, by, bz = getPedBonePosition(v.player, 6)
							local sx, sy = getScreenFromWorldPosition(bx, by, bz)
		
							local elapsedTime = tick - v.tick
							local duration = v.endTime - v.tick
							local progress = elapsedTime / duration
							
							if sx and sy then
								if not v.yPos then v.yPos = sy end
								local width = dxGetTextWidth(v.text:gsub("#%x%x%x%x%x%x", ""), 1, "default-bold")
								--local yPos = interpolateBetween ( v.yPos, 0, 0, sy - 22*i, 0, 0, progress, "OutElastic")
								local yPos = outElastic(elapsedTime, v.yPos, ( sy - 22*i ) - v.yPos, duration, 3)
								if bubble then
									dxDrawImage ( sx-width/2-10, yPos - 16, width+16, 20, v.texture, nil, nil, tocolor(0, 0, 0, v.alpha) )
								else
									dxDrawRectangle(sx-width/2-10, yPos - 16, width+16, 20, tocolor(0, 0, 0, v.alpha))
								end
								dxDrawText(v.text, sx-width/2-2, yPos - 14, width, 20, tocolor( 255, 255, 255, v.alpha+50), 1, "default-bold", "left", "top", false, false, false, true)
							end
						end
					else
						table.remove(messages[v.player], i)
					end
				else
					table.remove(messages[v.player], i)
				end
			end
		end
	end
)