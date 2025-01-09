--[[
    @author THEGizmo dla GTAO.pl
    @copyright 2018-2019
    Wszelkie prawa zastrzeżone.
	
	Zezwalam na edycję skryptu pod własne potrzeby lecz proszę o zostawienie informacji o autorze !!!
    Zabrania się umieszczania tego skryptu na innych stronach "www" i sprzedawania na lewo !!!
]]--

local opcjaPomocnicza = false
local opcjaPomocniczaElementy = {"ped","vehicle","object","pickup","colshape","marker"}

local screenx, screeny = guiGetScreenSize()

function pokazOpcjePomocnicza()
    local int = getElementInterior(localPlayer)
    local dim = getElementDimension(localPlayer)
	local x, y, z = getElementPosition(localPlayer)
	local objects = getElementsWithinRange(x, y, z, 100, "object")
	local cols = getElementsWithinRange(x, y, z, 100, "")
    --for _,element in ipairs(opcjaPomocniczaElementy) do
        for _,v in ipairs(objects) do
            if getElementInterior(v) == int and getElementDimension(v) == dim then
                local x, y, z = getElementPosition(v)
				local elementID = getElementID(v)
				local elementParent = getElementParent(v)
				local model = getElementModel(v)
				local customModel = getElementData(v, 'element:model')
				local alpha = getElementAlpha(v)
				elementParent = getElementParent(elementParent)
				local sx, sy, sz = getScreenFromWorldPosition(x, y, z, 30, false)
		        if (sx) and (sy) and (sz) and (sz) < 30 then
			        dxDrawText("Zasób: "..getElementID(elementParent).." \nModel: "..model .. " \nAlpha: "..alpha .. " \nCustom model: " .. tostring(customModel), sx+2, sy+2, sx, sy, tocolor(0, 0, 0, 255), 1, "default-bold", "center", "center", false, false, false, false)
                    dxDrawText("Zasób: "..getElementID(elementParent).." \nModel: "..model .. " \nAlpha: "..alpha .. " \nCustom model: " .. tostring(customModel), sx, sy, sx, sy, tocolor(128, 230, 48, 255), 1, "default-bold", "center", "center", false, false, false, false)
                end
            end
		end

		for i,v in pairs(getElementsByType("colshape")) do
			local x, y, z = getElementPosition(v)
			local x2, y2, z2 = getElementPosition(localPlayer)
			local distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			local elementParent = getElementParent(v)
			elementParent = getElementParent(elementParent)
			if distance < 50 and elementParent then
				local sx, sy, sz = getScreenFromWorldPosition(x, y, z, 30, false)
				if (sx) and (sy) and (sz) and (sz) < 30 then
				dxDrawText("Zasób: "..getElementID(elementParent), sx+2, sy+2, sx, sy, tocolor(0, 0, 0, 255), 1, "default-bold", "center", "center", false, false, false, false)
                dxDrawText("Zasób: "..getElementID(elementParent), sx, sy, sx, sy, tocolor(128, 230, 48, 255), 1, "default-bold", "center", "center", false, false, false, false)
				end
			end
		end

		for _,v in ipairs(getElementsWithinRange(x, y, z, 100, "marker")) do
			if getElementInterior(v) == int and getElementDimension(v) == dim then
                local x, y, z = getElementPosition(v)
				local elementID = getElementID(v)
				local elementParent = getElementParent(v)
				elementParent = getElementParent(elementParent)
				local sx, sy, sz = getScreenFromWorldPosition(x, y, z, 30, false)
		        if (sx) and (sy) and (sz) and (sz) < 30 then
			        dxDrawText("Zasób: "..getElementID(elementParent), sx+2, sy+2, sx, sy, tocolor(0, 0, 0, 255), 1, "default-bold", "center", "center", false, false, false, false)
                    dxDrawText("Zasób: "..getElementID(elementParent), sx, sy, sx, sy, tocolor(128, 230, 48, 255), 1, "default-bold", "center", "center", false, false, false, false)
                end
            end

		end

		for _,v in ipairs(getElementsWithinRange(x, y, z, 100, "ped")) do
			if getElementInterior(v) == int and getElementDimension(v) == dim then
                local x, y, z = getElementPosition(v)
				local elementID = getElementID(v)
				local elementParent = getElementParent(v)
				elementParent = getElementParent(elementParent)
				local sx, sy, sz = getScreenFromWorldPosition(x, y, z, 30, false)
		        if (sx) and (sy) and (sz) and (sz) < 30 then
			        dxDrawText("Zasób: "..getElementID(elementParent), sx+2, sy+2, sx, sy, tocolor(0, 0, 0, 255), 1, "default-bold", "center", "center", false, false, false, false)
                    dxDrawText("Zasób: "..getElementID(elementParent), sx, sy, sx, sy, tocolor(128, 230, 48, 255), 1, "default-bold", "center", "center", false, false, false, false)
                end
            end

		end

		for i,v in ipairs(getElementsByType("shader")) do
			local at = getElementParent(getElementParent(v))
			if i > 100 and i < 200 then
				dxDrawText(getElementID(at).." "..inspect(v), screenx/2, 1 + ((i-1)*10) - 950, center, center, white, 1, "default-bold", "center", "center")
			elseif i > 199 and i < 300 then
				dxDrawText(getElementID(at).." "..inspect(v), screenx/2 + 300, 1 + ((i-1)*10) - 1950, center, center, white, 1, "default-bold", "center", "center")
			elseif i > 299 and i < 400 then
				dxDrawText(getElementID(at).." "..inspect(v), screenx/2 + 600, 1 + ((i-1)*10) - 2950, center, center, white, 1, "default-bold", "center", "center")
			else
				dxDrawText(getElementID(at).." "..inspect(v), screenx/2 - 300, 10 + ((i-1)*10), center, center, white, 1, "default-bold", "center", "center")
			end
		end
        --end
    --end
end

function wlaczaOpcjePomocnicza()
	if opcjaPomocnicza == false then
		opcjaPomocnicza = true
		addEventHandler("onClientRender", root, pokazOpcjePomocnicza)
	else
		opcjaPomocnicza = false
		removeEventHandler("onClientRender", root, pokazOpcjePomocnicza)
	end
end
addCommandHandler("wh", wlaczaOpcjePomocnicza)
getResourceName(getThisResource(), true, 535713524); if true then return end