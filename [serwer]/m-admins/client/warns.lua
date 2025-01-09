local sx, sy = guiGetScreenSize()
local zoom = (sx < 2048) and math.min(2.2, 2048/sx) or 1

local reason = ''
local admin = ''

local fonts = {
	bold = exports['m-ui']:getFont('Inter-Bold', 23.333/zoom),
	black = exports['m-ui']:getFont('Inter-Black', 54/zoom),
	boldSmall = exports['m-ui']:getFont('Inter-Bold', 16.666/zoom)
}

local function renderUI()
	dxDrawImage(0, 0, sx, sy, 'data/overlay.png')

	dxDrawText('OTRZYMAŁEŚ OSTRZEŻENIE!', sx/2 + 3, sy/2 - 47/zoom + 3, nil, nil, 0x99000000, 1, fonts.black, 'center', 'bottom')
	dxDrawText('Powód: ' .. reason .. '\nAdministrator: ' .. admin, sx/2 + 2, sy/2 + 36/zoom + 2, nil, nil, 0x44000000, 1, fonts.bold, 'center', 'center')
	dxDrawText('Nie stosowanie się do ostrzeżeń może skutkować kickiem lub banem!', sx/2 + 2, sy/2 + 113/zoom + 2, nil, nil, 0x44000000, 1, fonts.boldSmall, 'center', 'top')

	dxDrawText('OTRZYMAŁEŚ OSTRZEŻENIE!', sx/2, sy/2 - 47/zoom, nil, nil, white, 1, fonts.black, 'center', 'bottom')
	dxDrawText('Powód: ' .. reason .. '\nAdministrator: ' .. admin, sx/2, sy/2 + 36/zoom, nil, nil, white, 1, fonts.bold, 'center', 'center')
	dxDrawText('Nie stosowanie się do ostrzeżeń może skutkować kickiem lub banem!', sx/2, sy/2 + 113/zoom, nil, nil, white, 1, fonts.boldSmall, 'center', 'top')

	dxDrawRectangle(sx/2 - 594/zoom, sy/2 - 54/zoom, 1187/zoom, 5/zoom)
end

local function toggleUI(visible)
    local eventCallback = visible and addEventHandler or removeEventHandler

    eventCallback('onClientRender', root, renderUI, true, 'low-99999')
end

function showWarn(adminText, reasonText)
    reason = reasonText
    admin = adminText

    toggleUI(true)
    playSound('data/warn.mp3')

    setTimer(toggleUI, 12000, 1, false)
end

addEvent('onClientShowWarn', true)
addEventHandler('onClientShowWarn', resourceRoot, showWarn)