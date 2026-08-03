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

local function audioCue(definition)
    return type(definition.audio) == "table" and definition.audio or {}
end

local function soundAlreadyOwned(active, skillId, groupingWindow)
    for _, effect in ipairs(active) do
        if effect.skillId == skillId and effect.ownsSound
            and effect.elapsed <= groupingWindow then return true end
    end
    return false
end

local function playCue(effects, effect, definition)
    if not effect.soundPending then return end
    effects.audio:play(effect.skillId, audioCue(definition))
    effect.soundPending = false
end

function SkillEffects:trigger(skillId, sourceColumn, sourceRow, targetColumn, targetRow)
    assert(self.loaded, "Skill effects must be loaded before they are triggered.")
    assert(SkillCatalog.get(skillId), "Unknown skill effect '" .. tostring(skillId) .. "'.")
    local definition = SkillCatalog.get(skillId)
    local cue = audioCue(definition)
    local ownsSound = not soundAlreadyOwned(self.active, skillId, cue.groupingWindow or 0.08)
    local effect = {
        skillId = skillId,
        sourceColumn = sourceColumn,
        sourceRow = sourceRow,
        targetColumn = targetColumn,
        targetRow = targetRow,
        elapsed = 0,
        frame = 1,
        ownsSound = ownsSound,
        soundPending = ownsSound,
    }
    table.insert(self.active, effect)
    if (cue.delay or 0) <= 0 then playCue(self, effect, definition) end
end

function SkillEffects:update(dt)
    self.audio:update(dt)
    for index = #self.active, 1, -1 do
        local effect = self.active[index]
        local definition = SkillCatalog.get(effect.skillId)
        effect.elapsed = effect.elapsed + dt
        local duration = SkillEffectRenderer.duration(definition)
        if effect.soundPending and effect.elapsed >= (audioCue(definition).delay or 0)
            and effect.elapsed < duration then
            playCue(self, effect, definition)
        end
        effect.frame = math.floor(effect.elapsed * definition.fps) + 1
        if effect.elapsed >= duration then
            table.remove(self.active, index)
        end
    end
end

function SkillEffects:draw(board, camera)
    love.graphics.setColor(1, 1, 1, 1)
    for _, effect in ipairs(self.active) do
        local definition = SkillCatalog.get(effect.skillId)
        SkillEffectRenderer.draw(effect, definition, self.animations[effect.skillId], board, camera)
    end
end

return SkillEffects
