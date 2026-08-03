local function installLoveMock(soundSkill)
    local state = { draws = {}, plays = 0 }
    love = {
        filesystem = {
            getInfo = function(path)
                return soundSkill and path:find("/" .. soundSkill .. ".ogg", 1, true) and {} or nil
            end,
        },
        audio = {
            newSource = function()
                return {
                    clone = function()
                        return {
                            play = function() state.plays = state.plays + 1 end,
                            isPlaying = function() return false end,
                        }
                    end,
                }
            end,
        },
        graphics = {
            newImage = function(path)
                return {
                    path = path,
                    setFilter = function() end,
                    getDimensions = function() return 4096, 64 end,
                }
            end,
            newQuad = function(...) return { ... } end,
            setColor = function() end,
            draw = function(...) table.insert(state.draws, { ... }) end,
        },
    }
    return state
end

return function()
    local state = installLoveMock(nil)
    package.loaded.skill_effects = nil
    package.loaded.skill_audio = nil
    local SkillEffects = require("skill_effects")
    local effects = SkillEffects.new()
    effects:load()
    effects:trigger("impact", 0, 0, 1, 0)
    effects:trigger("lightning", 0, 0, 0, 1)
    assert(#effects.active == 2)

    effects:update(1 / 15 + 0.001)
    assert(effects.active[1].frame == 2 and effects.active[2].frame == 2)
    effects:update(0.08)
    local camera = { worldToIso = function(_, x, y) return x - y, (x + y) / 2 end }
    effects:draw({ cellSize = 68 }, camera)
    assert(#state.draws == 6, "Pawn and knight attacks should each combine three layers.")
    assert(math.abs(state.draws[1][5]) > 0.01)

    effects:update(10)
    assert(#effects.active == 0)

    state = installLoveMock(nil)
    package.loaded.skill_effects = nil
    package.loaded.skill_effect_renderer = nil
    package.loaded.skill_audio = nil
    SkillEffects = require("skill_effects")
    effects = SkillEffects.new()
    effects:load()
    local secondRowQuad = effects.animations.sparkle[4].quads[8]
    assert(secondRowQuad[1] == 0 and secondRowQuad[2] == 96,
        "Multi-row spritesheets should advance to the next row.")
    effects:trigger("royal_calamity", 0, 0, 1, 0)
    effects:update(0.16)
    effects:draw({ cellSize = 68 }, camera)
    assert(#state.draws == 4, "Royal Calamity should layer all four attack sprites.")

    state = installLoveMock("lightning")
    package.loaded.skill_effects = nil
    package.loaded.skill_audio = nil
    SkillEffects = require("skill_effects")
    effects = SkillEffects.new()
    effects:load()
    effects:trigger("lightning", 0, 0, 1, 1)
    effects:trigger("lightning", 0, 0, 1, 1)
    assert(state.plays == 2)
    effects:update(0)
    assert(#effects.audio.playing == 0)
end
