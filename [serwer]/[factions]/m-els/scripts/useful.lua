function angleDiff(targetA, sourceA)
    local a = targetA - sourceA
    return (a + 180) % 360 - 180
end