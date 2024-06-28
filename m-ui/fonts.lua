local fonts = {}

function getFont(name, size)
    local unique = name .. size

    if not fonts[unique] then
        fonts[unique] = dxCreateFont('data/fonts/' .. name .. '.ttf', size, false, 'proof')
    end
    
    return fonts[unique]
end