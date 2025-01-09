function getNextLevelExp(level)
    return math.floor(100 * level * math.max(math.floor(level / 40), 0.5))
end