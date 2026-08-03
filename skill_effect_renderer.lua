local SkillEffectRenderer = {}

local function directionAngle(sourceX, sourceY, targetX, targetY)
    local y, x = targetY - sourceY, targetX - sourceX
    if math.atan2 then return math.atan2(y, x) end
    return math.atan(y, x)
end

local function layersFor(definition)
    return definition.layers or { definition }
end

local function loadAnimation(definition)
    local image = love.graphics.newImage(definition.image)
    image:setFilter("nearest", "nearest")
    local quads = {}
    local columns = definition.columns or definition.frameCount
    for frame = 0, definition.frameCount - 1 do
        quads[frame + 1] = love.graphics.newQuad(
            (frame % columns) * definition.frameWidth,
            math.floor(frame / columns) * definition.frameHeight,
            definition.frameWidth, definition.frameHeight,
            image:getDimensions()
        )
    end
    return { image = image, quads = quads }
end

function SkillEffectRenderer.load(catalog)
    local animations = {}
    for skillId, definition in pairs(catalog) do
        animations[skillId] = {}
        for index, layer in ipairs(layersFor(definition)) do
            animations[skillId][index] = loadAnimation(layer)
        end
    end
    return animations
end

function SkillEffectRenderer.duration(definition)
    local duration = 0
    for _, layer in ipairs(layersFor(definition)) do
        duration = math.max(duration, (layer.delay or 0) + layer.frameCount / layer.fps)
    end
    return duration
end

local function targetPosition(effect, board, camera)
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

function SkillEffectRenderer.draw(effect, definition, animations, board, camera)
    local sourceX, sourceY, targetX, targetY = targetPosition(effect, board, camera)
    for index, layer in ipairs(layersFor(definition)) do
        local elapsed = effect.elapsed - (layer.delay or 0)
        local frame = math.floor(elapsed * layer.fps) + 1
        if elapsed >= 0 and frame <= layer.frameCount then
            local angle = layer.directional and directionAngle(sourceX, sourceY, targetX, targetY) or 0
            local scale = layer.scale or 1
            local animation = animations[index]
            love.graphics.setColor(1, 1, 1, layer.opacity or 1)
            love.graphics.draw(animation.image, animation.quads[frame],
                targetX, targetY + (layer.offsetY or 0), angle, scale, scale,
                layer.frameWidth / 2, layer.frameHeight / 2)
        end
    end
end

return SkillEffectRenderer
