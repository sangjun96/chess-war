local Math = {}

function Math.clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function Math.angleAt(x, y)
    if math.atan2 then return math.atan2(y, x) end
    if x == 0 then return y >= 0 and math.pi / 2 or -math.pi / 2 end
    local angle = math.atan(y / x)
    return x < 0 and angle + math.pi or angle
end

function Math.angleDistance(first, second)
    return math.abs((first - second + math.pi) % (2 * math.pi) - math.pi)
end

return Math
