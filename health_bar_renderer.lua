local HealthBarRenderer = {}

local barWidth = 28
local barHeight = 5

local function fillColor(theme, ratio)
    if ratio > 0.6 then return theme.healthHigh end
    if ratio > 0.3 then return theme.healthMid end
    return theme.healthLow
end

function HealthBarRenderer.draw(theme, piece, x, y, scale)
    local ratio = piece.hp / piece.maxHp
    local left = math.floor(x - barWidth / 2)
    local top = math.floor(y - 38 * scale)
    local innerWidth = barWidth - 4
    local fillWidth = math.floor(innerWidth * ratio)

    love.graphics.setColor(theme.healthShadow)
    love.graphics.rectangle("fill", left + 1, top + 1, barWidth, barHeight)
    love.graphics.setColor(theme.healthOutline)
    love.graphics.rectangle("fill", left, top, barWidth, barHeight)
    love.graphics.setColor(theme.healthTrack)
    love.graphics.rectangle("fill", left + 2, top + 2, innerWidth, 1)
    love.graphics.setColor(fillColor(theme, ratio))
    love.graphics.rectangle("fill", left + 2, top + 2, fillWidth, 1)

    love.graphics.setColor(theme.healthPixelShade)
    for pixel = 4, innerWidth - 1, 4 do
        love.graphics.rectangle("fill", left + 2 + pixel, top + 2, 1, 1)
    end
end

return HealthBarRenderer
