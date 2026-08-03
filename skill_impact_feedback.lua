local Feedback = {}

local function colorWithAlpha(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha)
end

local function ring(x, y, radius, color, alpha)
    colorWithAlpha(color, alpha * 0.16)
    love.graphics.ellipse("fill", x, y, radius, radius * 0.48)
    colorWithAlpha(color, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.ellipse("line", x, y, radius, radius * 0.48)
    love.graphics.setLineWidth(1)
end

function Feedback.duration(definition)
    local feedback = definition.feedback
    if not feedback then return 0 end
    return (feedback.impactAt or 0) + (feedback.duration or 0)
end

function Feedback.drawCast(effect, definition, board, sourceX, sourceY)
    local feedback = definition.feedback
    local impactAt = feedback and feedback.impactAt or 0
    if impactAt <= 0 or effect.elapsed >= impactAt then return end
    local progress = effect.elapsed / impactAt
    local radius = board.cellSize * (0.62 - progress * 0.25)
    ring(sourceX, sourceY - 4, radius, feedback.color, 0.18 + progress * 0.5)
end

function Feedback.drawImpact(effect, definition, board, targetX, targetY)
    local feedback = definition.feedback
    if not feedback then return end
    local elapsed = effect.elapsed - (feedback.impactAt or 0)
    local duration = feedback.duration or 0
    if elapsed < 0 or elapsed >= duration then return end
    local progress = elapsed / duration
    local radius = board.cellSize * (feedback.radius or 1) * (0.22 + progress * 0.78)
    ring(targetX, targetY + (feedback.offsetY or 0), radius,
        feedback.color, (1 - progress) ^ 2)
end

return Feedback
