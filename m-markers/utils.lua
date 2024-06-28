local colorCache = {}
sx, sy = guiGetScreenSize()
zoom = (sx < 2048) and math.min(2.2, 2048/sx) or 1
local figmaFonts = {}

function getFigmaFont(font, size)
    if not figmaFonts[font..size] then
        figmaFonts[font..size] = exports['figma']:getFont(font, size)
    end

    return figmaFonts[font..size]
end

function rgbToHsl(r, g, b, a)
    r, g, b = r / 255, g / 255, b / 255
    local key = 'rgb'..r..g..b
    if colorCache[key] then
        return unpack(colorCache[key])
    end

    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l = 0, 0, 0

    l = (max + min) / 2

    if max == min then
    h, s = 0, 0 -- achromatic
    else
    local d = max - min
    --   local s
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
        h = (g - b) / d
        if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
    end

    colorCache[key] = {h, s, l, a or 255}
    return h, s, l, a or 255
end

function hslToRgb(h, s, l, a)
    local key = 'hsl'..h..s..l
    if colorCache[key] then
        return unpack(colorCache[key])
    end
    local r, g, b

    if s == 0 then
    r, g, b = l, l, l -- achromatic
    else
    function hue2rgb(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
    end

    colorCache[key] = {r * 255, g * 255, b * 255, a * 255}
    return r * 255, g * 255, b * 255, a * 255
end