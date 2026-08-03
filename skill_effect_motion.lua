local Motion = {}

local function clamp(value)
    return math.max(0, math.min(1, value))
end

local function easeOutCubic(value)
    return 1 - (1 - value) ^ 3
end

function Motion.centers(effect, board, camera)
    local sourceX, sourceY = camera:worldToIso(
        (effect.sourceColumn + 0.5) * board.cellSize,
        (effect.sourceRow + 0.5) * board.cellSize
    )
    local targetX, targetY = camera:worldToIso(
        (effect.targetColumn + 0.5) * board.cellSize,
        (effect.targetRow + 0.5) * board.cellSize
    )
    return sourceX, sourceY, targetX, targetY
end

function Motion.angle(sourceX, sourceY, targetX, targetY)
    local y, x = targetY - sourceY, targetX - sourceX
    if math.atan2 then return math.atan2(y, x) end
    return math.atan(y, x)
end

function Motion.position(layer, elapsed, sourceX, sourceY, targetX, targetY)
    if layer.anchor == "source" then return sourceX, sourceY end
    if layer.anchor ~= "travel" then return targetX, targetY end

    local duration = layer.travelDuration or layer.frameCount / layer.fps
    local progress = easeOutCubic(clamp(elapsed / duration))
    return sourceX + (targetX - sourceX) * progress,
        sourceY + (targetY - sourceY) * progress
end

function Motion.scale(layer, elapsed)
    local base = layer.scale or 1
    if not layer.scaleFrom and not layer.scaleTo then return base end
    local duration = layer.frameCount / layer.fps
    local progress = clamp(elapsed / duration)
    local first, last = layer.scaleFrom or base, layer.scaleTo or base
    return first + (last - first) * progress
end

function Motion.opacity(layer, elapsed)
    local opacity = layer.opacity or 1
    if not layer.fadeOut then return opacity end
    local duration = layer.frameCount / layer.fps
    local fadeStart = duration * (1 - layer.fadeOut)
    if elapsed <= fadeStart then return opacity end
    return opacity * (1 - clamp((elapsed - fadeStart) / (duration - fadeStart)))
end

return Motion
