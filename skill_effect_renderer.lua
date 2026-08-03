local Feedback = require("skill_impact_feedback")
local Motion = require("skill_effect_motion")

local SkillEffectRenderer = {}

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
    local duration = Feedback.duration(definition)
    for _, layer in ipairs(layersFor(definition)) do
        duration = math.max(duration, (layer.delay or 0) + layer.frameCount / layer.fps)
    end
    return duration
end

function SkillEffectRenderer.draw(effect, definition, animations, board, camera)
    local sourceX, sourceY, targetX, targetY = Motion.centers(effect, board, camera)
    Feedback.drawCast(effect, definition, board, sourceX, sourceY)
    for index, layer in ipairs(layersFor(definition)) do
        local elapsed = effect.elapsed - (layer.delay or 0)
        local frame = math.floor(elapsed * layer.fps) + 1
        if elapsed >= 0 and frame <= layer.frameCount then
            local x, y = Motion.position(layer, elapsed, sourceX, sourceY, targetX, targetY)
            local angle = layer.directional and Motion.angle(sourceX, sourceY, targetX, targetY) or 0
            local scale = Motion.scale(layer, elapsed)
            local animation = animations[index]
            love.graphics.setColor(1, 1, 1, Motion.opacity(layer, elapsed))
            love.graphics.draw(animation.image, animation.quads[frame],
                x, y + (layer.offsetY or 0), angle, scale, scale,
                layer.frameWidth / 2, layer.frameHeight / 2)
        end
    end
    Feedback.drawImpact(effect, definition, board, targetX, targetY)
    love.graphics.setColor(1, 1, 1, 1)
end

return SkillEffectRenderer
