local SkillAudio = require("skill_audio")
local SkillCatalog = require("skill_catalog")
local SkillEffectRenderer = require("skill_effect_renderer")

local SkillEffects = {}
SkillEffects.__index = SkillEffects

function SkillEffects.new()
    return setmetatable({
        animations = {},
        active = {},
        audio = SkillAudio.new("assets/audio/skills"),
        loaded = false,
    }, SkillEffects)
end

function SkillEffects:load()
    self.animations = SkillEffectRenderer.load(SkillCatalog.all())
    self.audio:load(SkillCatalog.all())
    self.loaded = true
end

function SkillEffects:trigger(skillId, sourceColumn, sourceRow, targetColumn, targetRow)
    assert(self.loaded, "Skill effects must be loaded before they are triggered.")
    assert(SkillCatalog.get(skillId), "Unknown skill effect '" .. tostring(skillId) .. "'.")
    table.insert(self.active, {
        skillId = skillId,
        sourceColumn = sourceColumn,
        sourceRow = sourceRow,
        targetColumn = targetColumn,
        targetRow = targetRow,
        elapsed = 0,
        frame = 1,
    })
    self.audio:play(skillId)
end

function SkillEffects:update(dt)
    for index = #self.active, 1, -1 do
        local effect = self.active[index]
        local definition = SkillCatalog.get(effect.skillId)
        effect.elapsed = effect.elapsed + dt
        effect.frame = math.floor(effect.elapsed * definition.fps) + 1
        if effect.elapsed >= SkillEffectRenderer.duration(definition) then
            table.remove(self.active, index)
        end
    end
    self.audio:update()
end

function SkillEffects:draw(board, camera)
    love.graphics.setColor(1, 1, 1, 1)
    for _, effect in ipairs(self.active) do
        local definition = SkillCatalog.get(effect.skillId)
        SkillEffectRenderer.draw(effect, definition, self.animations[effect.skillId], board, camera)
    end
end

return SkillEffects
